#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${1:-$project_root/build/face_studio}"
audit_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-camera-preflight.XXXXXX")"

cleanup() {
    rm -rf "$audit_root"
}
trap cleanup EXIT

run_rejection() {
    local label="$1"
    local expected="$2"
    shift 2
    local log="$audit_root/rejection.log"

    set +e
    "$@" >"$log" 2>&1
    local status=$?
    set -e

    if (( status != 1 )) || ! grep -Fq "$expected" "$log"; then
        printf '%s: FAIL (status=%d)\n' "$label" "$status" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    printf '%s: PASS (status 1)\n' "$label"
}

echo "Camera-test preflight contract audit (camera-safe)"

run_rejection \
    "Missing executable rejected" \
    "Camera-test preflight: FAIL (executable missing)" \
    bash "$project_root/scripts/camera_test_preflight.sh" \
    "$audit_root/missing-face-studio" "$audit_root/missing-executable.mp4"

run_rejection \
    "Non-MP4 target rejected" \
    "Camera-test preflight: FAIL (output must use .mp4)" \
    bash "$project_root/scripts/camera_test_preflight.sh" \
    "$binary" "$audit_root/camera-output.avi"

run_rejection \
    "Missing output directory rejected" \
    "Camera-test preflight: FAIL (output directory missing or not writable)" \
    bash "$project_root/scripts/camera_test_preflight.sh" \
    "$binary" "$audit_root/missing-directory/camera-output.mp4"

existing_output="$audit_root/existing-output.mp4"
: > "$existing_output"
existing_before="$(wc -c < "$existing_output" | tr -d ' ')"
run_rejection \
    "Existing target rejected" \
    "Camera-test preflight: FAIL (intended output already exists)" \
    bash "$project_root/scripts/camera_test_preflight.sh" \
    "$binary" "$existing_output"
existing_after="$(wc -c < "$existing_output" | tr -d ' ')"
if [[ "$existing_before" != "$existing_after" ]]; then
    echo "Existing target preservation: FAIL" >&2
    exit 1
fi
echo "Existing target preservation: PASS"

dangling_target="$audit_root/nonexistent-camera-output.mp4"
dangling_output="$audit_root/dangling-output.mp4"
ln -s "$dangling_target" "$dangling_output"
dangling_before="$(readlink "$dangling_output")"
run_rejection \
    "Dangling symbolic-link target rejected" \
    "Camera-test preflight: FAIL (intended output already exists)" \
    bash "$project_root/scripts/camera_test_preflight.sh" \
    "$binary" "$dangling_output"
if [[ ! -L "$dangling_output" ]] \
    || [[ "$(readlink "$dangling_output")" != "$dangling_before" ]] \
    || [[ -e "$dangling_target" ]]; then
    echo "Dangling symbolic-link preservation: FAIL" >&2
    exit 1
fi
echo "Dangling symbolic-link preservation: PASS"

safe_output="$audit_root/safe-output.mp4"
bash "$project_root/scripts/camera_test_preflight.sh" "$binary" "$safe_output"
if [[ -e "$safe_output" ]]; then
    echo "Safe-success output absence: FAIL" >&2
    exit 1
fi
echo "Safe-success output absence: PASS"
echo "Preflight contract cases passed: 6/6"
echo "Camera opened: NO"
echo "Camera-test preflight contract audit: PASS"
