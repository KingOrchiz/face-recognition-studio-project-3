#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
model_dir="${1:-$project_root/models}"
failures=0
count=0

if [[ "${FACE_STUDIO_FORCE_SHASUM:-0}" != 1 ]] && command -v sha256sum >/dev/null 2>&1; then
    hash_file() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then
    hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
else
    echo "No SHA-256 utility found (requires sha256sum or shasum)" >&2
    exit 1
fi

echo "Pinned model-integrity audit"

while read -r expected_hash expected_bytes filename; do
    [[ -n "$filename" ]] || continue
    count=$((count + 1))
    model="$model_dir/$filename"
    status="PASS"

    if [[ ! -f "$model" ]]; then
        status="FAIL (missing)"
        failures=$((failures + 1))
    else
        actual_hash="$(hash_file "$model")"
        actual_bytes="$(wc -c < "$model" | tr -d ' ')"
        if [[ "$actual_hash" != "$expected_hash" || "$actual_bytes" != "$expected_bytes" ]]; then
            status="FAIL (hash/size mismatch)"
            failures=$((failures + 1))
        fi
    fi

    printf '%-48s %s\n' "$filename" "$status"
done <<'MODELS'
50ef07f702a31741ca46a4c0d947773b64143b9362780237bf0d427d6c79bab7 345478 face_detection_yunet_2022mar.onnx
8f2383e4dd3cfbb4553ea8718107fc0423210dc964f9f4280604804ed2552fa4 232589 face_detection_yunet_2023mar.onnx
0ba9fbfa01b5270c96627c4ef784da859931e02f04419c829e83484087c34e79 38696353 face_recognition_sface_2021dec.onnx
MODELS

printf '\nPinned models checked: %d\n' "$count"
if (( failures > 0 )); then
    printf 'Model-integrity result: FAIL (%d issue(s))\n' "$failures" >&2
    exit 1
fi

echo "Expected SHA-256 and byte sizes: PASS"
echo "Model-integrity result: PASS"
