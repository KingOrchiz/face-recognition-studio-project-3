#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${1:-$project_root/build/face_studio}"
fixture="$project_root/tests/synthetic_portrait_a_640.png"
audit_dir="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-image-safety.XXXXXX")"

cleanup() {
    rm -rf "$audit_dir"
}
trap cleanup EXIT

if [[ ! -x "$binary" ]]; then
    echo "Face Studio binary is not executable: $binary" >&2
    exit 1
fi
if [[ ! -f "$fixture" ]]; then
    echo "Image fixture is missing: $fixture" >&2
    exit 1
fi

hash_file() {
    if [[ "${FACE_STUDIO_FORCE_SHASUM:-0}" != 1 ]] && command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        echo "No SHA-256 utility found (requires sha256sum or shasum)" >&2
        return 1
    fi
}

echo "Image input/output safety audit"
expected='Image output must differ from input; refusing to overwrite the source file'

existing_output="$audit_dir/existing-result.png"
printf 'preserve-image-evidence\n' > "$existing_output"
existing_before="$(hash_file "$existing_output")"
existing_log="$audit_dir/existing-output.log"
set +e
"$binary" --mode image --input "$fixture" --output "$existing_output" \
    --detector "$audit_dir/deliberately-missing-detector.onnx" \
    --recognizer "$audit_dir/deliberately-missing-recognizer.onnx" \
    >"$existing_log" 2>&1
existing_status=$?
set -e
if [[ "$existing_status" != 2 ]] \
    || ! grep -Fq 'Image output already exists; pass --overwrite to replace it explicitly' "$existing_log" \
    || grep -Fq 'Model not found:' "$existing_log" \
    || [[ "$(hash_file "$existing_output")" != "$existing_before" ]]; then
    echo "Existing unrelated output refusal/preservation: FAIL (status=$existing_status)" >&2
    sed -n '1,20p' "$existing_log" >&2
    exit 1
fi
echo "Existing unrelated output: PASS (status 2; SHA-256 unchanged)"

overwrite_log="$audit_dir/explicit-overwrite.log"
set +e
"$binary" --mode image --input "$fixture" --output "$existing_output" --overwrite \
    --detector "$audit_dir/deliberately-missing-detector.onnx" \
    --recognizer "$audit_dir/deliberately-missing-recognizer.onnx" \
    >"$overwrite_log" 2>&1
overwrite_status=$?
set -e
if [[ "$overwrite_status" != 2 ]] || ! grep -Fq 'Model not found:' "$overwrite_log" \
    || [[ "$(hash_file "$existing_output")" != "$existing_before" ]]; then
    echo "Explicit overwrite reaches model gate without output work: FAIL (status=$overwrite_status)" >&2
    sed -n '1,20p' "$overwrite_log" >&2
    exit 1
fi
echo "Explicit overwrite opt-in reaches model gate without output work: PASS"

run_unsafe_overwrite_case() {
    local case_name="$1"
    local output="$2"
    local expected_message="$3"
    local preserved_file="$4"
    local log="$audit_dir/unsafe-${case_name}.log"
    local before_hash status

    before_hash="$(hash_file "$preserved_file")"
    set +e
    "$binary" --mode image --input "$fixture" --output "$output" --overwrite \
        --detector "$audit_dir/deliberately-missing-detector.onnx" \
        --recognizer "$audit_dir/deliberately-missing-recognizer.onnx" \
        >"$log" 2>&1
    status=$?
    set -e
    if [[ "$status" != 2 ]] || ! grep -Fq "$expected_message" "$log" \
        || grep -Fq 'Model not found:' "$log" \
        || [[ "$(hash_file "$preserved_file")" != "$before_hash" ]]; then
        echo "$case_name overwrite refusal/preservation: FAIL (status=$status)" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    echo "$case_name overwrite: PASS (status 2; preserved SHA-256)"
}

unsafe_target="$audit_dir/unsafe-target.png"
printf 'preserve-unsafe-target\n' > "$unsafe_target"
unsafe_symlink="$audit_dir/unsafe-symlink.png"
ln -s "$unsafe_target" "$unsafe_symlink"
run_unsafe_overwrite_case "Symbolic-link" "$unsafe_symlink" \
    'Image --overwrite requires an existing regular file, not a link or directory' "$unsafe_target"

unsafe_directory="$audit_dir/unsafe-directory.png"
mkdir "$unsafe_directory"
directory_marker="$unsafe_directory/marker"
printf 'preserve-directory-marker\n' > "$directory_marker"
run_unsafe_overwrite_case "Directory" "$unsafe_directory" \
    'Image --overwrite requires an existing regular file, not a link or directory' "$directory_marker"

unsafe_hardlink="$audit_dir/unsafe-hardlink.png"
ln "$unsafe_target" "$unsafe_hardlink"
run_unsafe_overwrite_case "Multiply-linked file" "$unsafe_hardlink" \
    'Image --overwrite requires a file with exactly one hard link' "$unsafe_target"

run_refusal_case() {
    local case_name="$1"
    local input="$2"
    local output="$3"
    local log="$audit_dir/${case_name}.log"
    local before_hash after_hash status

    before_hash="$(hash_file "$input")"
    set +e
    "$binary" \
        --mode image \
        --input "$input" \
        --output "$output" \
        --detector "$audit_dir/deliberately-missing-detector.onnx" \
        --recognizer "$audit_dir/deliberately-missing-recognizer.onnx" \
        >"$log" 2>&1
    status=$?
    set -e
    after_hash="$(hash_file "$input")"

    if [[ "$status" != 2 ]]; then
        echo "$case_name refusal status 2: FAIL (received $status)" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    if ! grep -Fq "$expected" "$log"; then
        echo "$case_name same-file refusal: FAIL" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    if grep -Fq 'Model not found:' "$log"; then
        echo "$case_name refusal before model initialization: FAIL" >&2
        exit 1
    fi
    if [[ "$before_hash" != "$after_hash" ]]; then
        echo "$case_name input SHA-256 unchanged: FAIL" >&2
        exit 1
    fi
    echo "$case_name: PASS (status 2; source SHA-256 unchanged)"
}

mkdir -p "$audit_dir/media" "$audit_dir/aliases"

exact_input="$audit_dir/media/exact.png"
cp "$fixture" "$exact_input"
run_refusal_case "Exact pathname" "$exact_input" "$exact_input"

relative_input="$audit_dir/media/relative.png"
cp "$fixture" "$relative_input"
run_refusal_case \
    "Relative path alias" \
    "$relative_input" \
    "$audit_dir/media/../media/relative.png"

hardlink_input="$audit_dir/media/hardlink-source.png"
hardlink_output="$audit_dir/aliases/hardlink-output.png"
cp "$fixture" "$hardlink_input"
ln "$hardlink_input" "$hardlink_output"
run_refusal_case "Hard-link alias" "$hardlink_input" "$hardlink_output"

symlink_input="$audit_dir/media/symlink-source.png"
symlink_output="$audit_dir/aliases/symlink-output.png"
cp "$fixture" "$symlink_input"
ln -s "$symlink_input" "$symlink_output"
run_refusal_case "Symbolic-link alias" "$symlink_input" "$symlink_output"

echo "Equivalent-path cases passed: 4/4"
echo "Unsafe overwrite cases passed: 3/3"
echo "Image output-safety cases passed: 9/9"
echo "All refusals occurred before model initialization: PASS"
echo "Camera accessed by audit: NO"
echo "Image output safety audit: PASS"
