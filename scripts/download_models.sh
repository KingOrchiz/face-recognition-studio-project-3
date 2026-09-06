#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_DIR="$PROJECT_ROOT/models"
mkdir -p "$MODEL_DIR"

if command -v sha256sum >/dev/null 2>&1; then
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
elif command -v shasum >/dev/null 2>&1; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
else
  echo "Error: sha256sum or shasum is required" >&2
  exit 2
fi

download_model() {
  local filename="$1"
  local expected_hash="$2"
  local url="$3"
  local destination="$MODEL_DIR/$filename"
  local temporary="$destination.download"

  if [[ -f "$destination" ]]; then
    local current_hash
    current_hash="$(hash_file "$destination")"
    if [[ "$current_hash" == "$expected_hash" ]]; then
      echo "Verified existing $filename ($current_hash)"
      return
    fi
    echo "Error: refusing to overwrite $filename with unexpected hash $current_hash" >&2
    exit 2
  fi

  curl -fL --retry 2 --output "$temporary" "$url"
  local downloaded_hash
  downloaded_hash="$(hash_file "$temporary")"
  if [[ "$downloaded_hash" != "$expected_hash" ]]; then
    echo "Error: hash mismatch for $filename: expected $expected_hash, got $downloaded_hash" >&2
    exit 2
  fi
  mv "$temporary" "$destination"
  echo "Downloaded and verified $filename ($downloaded_hash)"
}

download_model \
  face_detection_yunet_2023mar.onnx \
  8f2383e4dd3cfbb4553ea8718107fc0423210dc964f9f4280604804ed2552fa4 \
  https://media.githubusercontent.com/media/opencv/opencv_zoo/f12e12798e83/models/face_detection_yunet/face_detection_yunet_2023mar.onnx

download_model \
  face_detection_yunet_2022mar.onnx \
  50ef07f702a31741ca46a4c0d947773b64143b9362780237bf0d427d6c79bab7 \
  https://media.githubusercontent.com/media/opencv/opencv_zoo/1eb16afe04db/models/face_detection_yunet/face_detection_yunet_2022mar.onnx

download_model \
  face_recognition_sface_2021dec.onnx \
  0ba9fbfa01b5270c96627c4ef784da859931e02f04419c829e83484087c34e79 \
  https://media.githubusercontent.com/media/opencv/opencv_zoo/ba91a3b91d00/models/face_recognition_sface/face_recognition_sface_2021dec.onnx
