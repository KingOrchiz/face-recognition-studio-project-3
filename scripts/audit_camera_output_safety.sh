#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${1:-$project_root/build/face_studio}"
audit_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-camera-output.XXXXXX")"

cleanup() {
    rm -rf "$audit_root"
}
trap cleanup EXIT

if [[ ! -x "$binary" ]]; then
    echo "Face Recognition Studio executable not found: $binary" >&2
    exit 1
fi

expected='Camera output already exists; choose an unused path to preserve prior evidence'

run_refusal_case() {
    local label="$1"
    local output="$2"
    local expected_message="${3:-$expected}"
    local log="$audit_root/refusal.log"
    local status

    set +e
    "$binary" \
        --mode camera \
        --confirm-camera \
        --input 0 \
        --detector "$audit_root/deliberately-missing-detector.onnx" \
        --recognizer "$audit_root/deliberately-missing-recognizer.onnx" \
        --output "$output" >"$log" 2>&1
    status=$?
    set -e

    if (( status != 2 )) || ! grep -Fq "$expected_message" "$log"; then
        echo "$label refusal: FAIL (status=$status)" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    if grep -Fq 'Model not found:' "$log"; then
        echo "$label refusal before model/device work: FAIL" >&2
        exit 1
    fi
    echo "$label: PASS (status 2; before model/device work)"
}

run_refusal_case 'Empty output without display rejected' \
    '' 'Stream output may be empty only when --display is enabled'

overwrite_log="$audit_root/overwrite.log"
set +e
"$binary" --mode camera --confirm-camera --overwrite --input 0 \
    --detector "$audit_root/deliberately-missing-detector.onnx" \
    --recognizer "$audit_root/deliberately-missing-recognizer.onnx" \
    --output "$audit_root/unused-overwrite.mp4" >"$overwrite_log" 2>&1
overwrite_status=$?
set -e
if (( overwrite_status != 2 )) \
    || ! grep -Fq -- '--overwrite is not allowed in camera mode' "$overwrite_log" \
    || grep -Fq 'Model not found:' "$overwrite_log" \
    || [[ -e "$audit_root/unused-overwrite.mp4" ]]; then
    echo "Camera overwrite opt-in refusal: FAIL (status=$overwrite_status)" >&2
    sed -n '1,20p' "$overwrite_log" >&2
    exit 1
fi
echo 'Camera overwrite opt-in rejected: PASS (status 2; before model/device work)'

run_refusal_case 'Non-MP4 output rejected' \
    "$audit_root/unused.avi" 'Camera output must use an .mp4 filename'

regular_output="$audit_root/existing.mp4"
printf 'preserve-camera-evidence\n' > "$regular_output"
regular_before="$(shasum -a 256 "$regular_output" | awk '{print $1}')"
run_refusal_case 'Existing regular output rejected' "$regular_output"
regular_after="$(shasum -a 256 "$regular_output" | awk '{print $1}')"
if [[ "$regular_before" != "$regular_after" ]]; then
    echo 'Existing regular output preserved: FAIL' >&2
    exit 1
fi
echo 'Existing regular output preserved: PASS'

mkdir "$audit_root/existing-directory.mp4"
run_refusal_case 'Existing directory output rejected' "$audit_root/existing-directory.mp4"

dangling_target="$audit_root/not-created.mp4"
dangling_output="$audit_root/dangling.mp4"
ln -s "$dangling_target" "$dangling_output"
dangling_before="$(readlink "$dangling_output")"
run_refusal_case 'Dangling symbolic-link output rejected' "$dangling_output"
if [[ ! -L "$dangling_output" ]] \
    || [[ "$(readlink "$dangling_output")" != "$dangling_before" ]] \
    || [[ -e "$dangling_target" ]]; then
    echo 'Dangling symbolic-link output preserved: FAIL' >&2
    exit 1
fi
echo 'Dangling symbolic-link output preserved: PASS'

parent_expected='Camera output parent directory must already exist and be a directory'
run_refusal_case 'Missing parent directory rejected' \
    "$audit_root/missing-parent/camera.mp4" "$parent_expected"

non_directory_parent="$audit_root/not-a-directory"
printf 'not a directory\n' > "$non_directory_parent"
non_directory_before="$(shasum -a 256 "$non_directory_parent" | awk '{print $1}')"
run_refusal_case 'Non-directory parent rejected' \
    "$non_directory_parent/camera.mp4" "$parent_expected"
non_directory_after="$(shasum -a 256 "$non_directory_parent" | awk '{print $1}')"
if [[ "$non_directory_before" != "$non_directory_after" ]]; then
    echo 'Non-directory parent preserved: FAIL' >&2
    exit 1
fi
echo 'Non-directory parent preserved: PASS'

safe_output="$audit_root/unused.mp4"
safe_log="$audit_root/safe.log"
set +e
"$binary" \
    --mode camera \
    --confirm-camera \
    --input 0 \
    --detector "$audit_root/deliberately-missing-detector.onnx" \
    --recognizer "$audit_root/deliberately-missing-recognizer.onnx" \
    --output "$safe_output" >"$safe_log" 2>&1
safe_status=$?
set -e
if (( safe_status != 2 )) || ! grep -Fq 'Model not found:' "$safe_log" \
    || grep -Fq "$expected" "$safe_log" || [[ -e "$safe_output" ]]; then
    echo "Unused output reaches model gate without device/output work: FAIL (status=$safe_status)" >&2
    sed -n '1,20p' "$safe_log" >&2
    exit 1
fi
echo 'Unused output reaches model gate without device/output work: PASS'
echo 'Camera output-safety cases passed: 9/9'
echo 'Camera opened: NO'
echo 'Camera output safety audit: PASS'
