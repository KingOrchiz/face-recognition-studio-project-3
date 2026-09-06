#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="$PROJECT_ROOT/evidence/raw"
RUN_STAMP="$(date '+%Y%m%dT%H%M%S%z')"
LOG_FILE="$EVIDENCE_DIR/${RUN_STAMP}-macos-setup-build.log"

mkdir -p "$EVIDENCE_DIR"
cd "$PROJECT_ROOT"
exec > >(tee "$LOG_FILE") 2>&1

echo "Face Recognition Studio macOS setup/build"
echo "Timestamp: $(date '+%Y-%m-%dT%H:%M:%S%z')"
echo "Camera access: NOT REQUESTED by this script"
echo "Project source identity (SHA-256):"
shasum -a 256 CMakeLists.txt src/main.cpp scripts/macos_setup_build.sh
uname -a
sw_vers

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is required: https://brew.sh/" >&2
  exit 2
fi

brew --version | head -1
for formula in cmake ninja opencv@4; do
  if brew list --versions "$formula" >/dev/null 2>&1; then
    brew list --versions "$formula"
  else
    brew install "$formula"
  fi
done

cmake --version | head -1
ninja --version
clang++ --version | head -1
"$(brew --prefix opencv@4)/bin/opencv_version"

bash scripts/download_models.sh

shasum -a 256 \
  models/face_detection_yunet_2023mar.onnx \
  models/face_detection_yunet_2022mar.onnx \
  models/face_recognition_sface_2021dec.onnx

OPENCV_CMAKE_DIR="$(brew --prefix opencv@4)/lib/cmake/opencv4"
echo "Compiler warnings as errors: ENABLED"
cmake -S . -B build-macos-opencv4 -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DFACE_STUDIO_WARNINGS_AS_ERRORS=ON \
  -DOpenCV_DIR="$OPENCV_CMAKE_DIR"
cmake --build build-macos-opencv4
ctest --test-dir build-macos-opencv4 --output-on-failure

bash scripts/audit_default_detector_selection.sh \
  "$PROJECT_ROOT" "$PROJECT_ROOT/build-macos-opencv4/face_studio"

run_recognition_check() {
  local input_file="$1"
  local expected_label="$2"
  local output_file="$3"
  local result

  result="$(./build-macos-opencv4/face_studio \
    --mode image \
    --input "$input_file" \
    --known tests/known \
    --threshold 0.400 \
    --output "$output_file" 2>&1)" || {
      printf '%s\n' "$result"
      return 1
    }
  printf '%s\n' "$result"

  if ! printf '%s\n' "$result" | grep -Fq "Face 1: label=$expected_label"; then
    echo "Error: expected recognition label $expected_label" >&2
    return 1
  fi
  if printf '%s\n' "$result" | grep -Fq 'using Haar detection fallback'; then
    echo "Error: version-aware default detector fell back to Haar" >&2
    return 1
  fi
  if [[ ! -s "$output_file" ]]; then
    echo "Error: recognition output was not created: $output_file" >&2
    return 1
  fi
}

KNOWN_OUTPUT="output/macos-synthetic-known-${RUN_STAMP}.png"
UNKNOWN_OUTPUT="output/macos-synthetic-unknown-${RUN_STAMP}.png"
run_recognition_check \
  tests/synthetic_portrait_a_variant_640.png Synthetic_A "$KNOWN_OUTPUT"
run_recognition_check \
  tests/synthetic_portrait_b_unknown_640.png Unknown "$UNKNOWN_OUTPUT"

echo "Known-result image: $KNOWN_OUTPUT"
echo "Unknown-result image: $UNKNOWN_OUTPUT"

echo "Completed non-camera macOS setup/build/test run."
echo "Evidence log: $LOG_FILE"
