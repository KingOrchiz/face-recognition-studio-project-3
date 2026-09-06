#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
executable="${2:-$project_root/build/face_studio}"

if [[ ! -x "$executable" ]]; then
    echo "Default-detector selection audit: FAIL (executable missing: $executable)" >&2
    exit 1
fi

audit_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-default-detector.XXXXXX")"
cleanup() {
    rm -rf "$audit_root"
}
trap cleanup EXIT

build_info="$($executable --build-info)"
opencv_version="$(printf '%s\n' "$build_info" | awk '/^OpenCV / {print $2}')"
default_detector="$(printf '%s\n' "$build_info" | awk -F': ' '/^Default detector: / {print $2}')"

if [[ ! "$opencv_version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?([.-].*)?$ ]]; then
    echo "Default-detector selection audit: FAIL (unparseable OpenCV version)" >&2
    exit 1
fi

major="${opencv_version%%.*}"
remainder="${opencv_version#*.}"
minor="${remainder%%.*}"
if (( major > 4 || (major == 4 && minor >= 10) )); then
    expected="models/face_detection_yunet_2023mar.onnx"
else
    expected="models/face_detection_yunet_2022mar.onnx"
fi

if [[ "$default_detector" != "$expected" ]]; then
    echo "Default-detector selection audit: FAIL (OpenCV $opencv_version selected $default_detector; expected $expected)" >&2
    exit 1
fi
if [[ ! -f "$project_root/$default_detector" ]]; then
    echo "Default-detector selection audit: FAIL (selected model is not packaged)" >&2
    exit 1
fi


functional_log="$audit_root/functional.log"
(
    cd "$project_root"
    "$executable" \
        --mode image \
        --input tests/synthetic_portrait_a_variant_640.png \
        --known tests/known \
        --threshold 0.400 \
        --output "$audit_root/default-detector-result.png"
) >"$functional_log" 2>&1
if ! grep -Fq 'Face 1: label=Synthetic_A' "$functional_log" \
    || grep -Fq 'using Haar detection fallback' "$functional_log" \
    || [[ ! -s "$audit_root/default-detector-result.png" ]]; then
    echo "Default-detector functional recognition: FAIL" >&2
    sed -n '1,20p' "$functional_log" >&2
    exit 1
fi

echo "OpenCV version: $opencv_version"
echo "Default detector: $default_detector"
echo "Version-aware YuNet selection: PASS"
echo "Default-detector recognition: PASS (Synthetic_A; no Haar fallback)"
echo "Camera accessed by audit: NO"
echo "Default-detector selection audit: PASS"
