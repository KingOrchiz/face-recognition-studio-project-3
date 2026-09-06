#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${1:-$project_root/build/face_studio}"
output_file="${2:-$project_root/output/consented-camera-test.mp4}"

if [[ ! -x "$binary" ]]; then
    echo "Camera-test preflight: FAIL (executable missing)" >&2
    exit 1
fi

case "${output_file##*/}" in
    *.mp4) ;;
    *)
        echo "Camera-test preflight: FAIL (output must use .mp4)" >&2
        exit 1
        ;;
esac

output_parent="$(dirname "$output_file")"
if [[ ! -d "$output_parent" || ! -w "$output_parent" ]]; then
    echo "Camera-test preflight: FAIL (output directory missing or not writable)" >&2
    exit 1
fi
if [[ -e "$output_file" || -L "$output_file" ]]; then
    echo "Camera-test preflight: FAIL (intended output already exists)" >&2
    exit 1
fi

echo "Consented camera-test preflight (camera-safe)"
echo "Executable present: PASS"
echo "Dedicated MP4 target absent: PASS"
bash "$project_root/scripts/audit_model_integrity.sh"
bash "$project_root/scripts/audit_camera_consent_gate.sh" "$binary"
echo "Camera-test preflight: PASS"
echo "Camera opened: NO"
echo "Authorization state: EXPLICIT CONFIRMATION STILL REQUIRED"
