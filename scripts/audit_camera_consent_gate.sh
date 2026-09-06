#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${1:-$project_root/build/face_studio}"
audit_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-camera-gate.XXXXXX")"
output_file="$audit_root/should-not-exist.mp4"
command_log="$audit_root/command.log"

cleanup() {
    rm -rf "$audit_root"
}
trap cleanup EXIT

if [[ ! -x "$binary" ]]; then
    echo "Face Recognition Studio executable not found: $binary" >&2
    exit 1
fi

echo "Camera consent-gate semantic audit"
echo "Invocation: --mode camera (without --confirm-camera)"

set +e
"$binary" \
    --mode camera \
    --input 0 \
    --detector "$audit_root/missing-detector.onnx" \
    --recognizer "$audit_root/missing-recognizer.onnx" \
    --output "$output_file" >"$command_log" 2>&1
status=$?
set -e

if (( status != 2 )); then
    echo "Expected exit status 2; received $status" >&2
    sed -n '1,20p' "$command_log" >&2
    exit 1
fi
echo "Blocked invocation exit status: PASS (2)"

expected_message="Camera access blocked: obtain participant consent, then pass --confirm-camera"
if ! grep -Fq "$expected_message" "$command_log"; then
    echo "Consent-specific refusal message: FAIL" >&2
    sed -n '1,20p' "$command_log" >&2
    exit 1
fi
echo "Consent-specific refusal message: PASS"

if grep -Fq "Model not found:" "$command_log"; then
    echo "Consent gate ordering: FAIL (model validation ran first)" >&2
    exit 1
fi
echo "Consent gate precedes model initialization: PASS"

if [[ -e "$output_file" ]]; then
    echo "No camera output created: FAIL" >&2
    exit 1
fi
echo "No camera output created: PASS"
echo "Camera opened: NO"
echo "Camera consent-gate semantic audit: PASS"
