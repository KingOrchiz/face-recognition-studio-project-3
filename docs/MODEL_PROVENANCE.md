# Model provenance and integrity

The project expects the following OpenCV Zoo models. They were already present when the 2026-09-05 audit began; this session did not download or replace them.

## YuNet face detector

- File: `models/face_detection_yunet_2023mar.onnx`
- Size observed: 232,589 bytes
- SHA-256 observed: `8f2383e4dd3cfbb4553ea8718107fc0423210dc964f9f4280604804ed2552fa4`
- Upstream project: <https://github.com/opencv/opencv_zoo/tree/main/models/face_detection_yunet>
- Intended upstream file: <https://github.com/opencv/opencv_zoo/raw/main/models/face_detection_yunet/face_detection_yunet_2023mar.onnx>

## SFace recognizer

- File: `models/face_recognition_sface_2021dec.onnx`
- Size observed: 38,696,353 bytes
- SHA-256 observed: `0ba9fbfa01b5270c96627c4ef784da859931e02f04419c829e83484087c34e79`
- Upstream project: <https://github.com/opencv/opencv_zoo/tree/main/models/face_recognition_sface>
- Intended upstream file: <https://github.com/opencv/opencv_zoo/raw/main/models/face_recognition_sface/face_recognition_sface_2021dec.onnx>

## Verification

From the project root:

```bash
sha256sum models/face_detection_yunet_2023mar.onnx \
  models/face_recognition_sface_2021dec.onnx
```

On macOS, use `shasum -a 256` if `sha256sum` is unavailable.

For a clean checkout, `scripts/download_models.sh` downloads pinned Git LFS media objects to temporary `.download` files, verifies the expected SHA-256 values, and only then moves them into place. It refuses to replace an existing file whose hash is unexpected.

Model presence and matching hashes establish file integrity against this workspace baseline, not model accuracy or fitness for identity decisions.

## OpenCV 4.6 compatibility model added during audit

OpenCV 4.6.0 expects YuNet output layers named `loc`, `conf`, and `iou`; the audited 2023 model triggers `Layer with requested id=-1 not found` on that runtime. A fixed-input YuNet 2022 model was therefore retrieved from an official OpenCV Zoo commit predating the YuNet v2 update.

- File: `models/face_detection_yunet_2022mar.onnx`
- Size: 345,478 bytes
- SHA-256: `50ef07f702a31741ca46a4c0d947773b64143b9362780237bf0d427d6c79bab7`
- OpenCV Zoo commit: `1eb16afe04db`
- Git LFS media URL used: <https://media.githubusercontent.com/media/opencv/opencv_zoo/1eb16afe04db/models/face_detection_yunet/face_detection_yunet_2022mar.onnx>

The first `raw.githubusercontent.com` request returned a 131-byte Git LFS pointer, which failed ONNX parsing. That failed download and run are preserved in the evidence trail. The media URL returned the 345,478-byte object with a hash matching the LFS object ID.

In the current OpenCV 4.6.0 runtime, this fixed-input model is reliable on the 640×640 synthetic test assets. A 1254×1254 attempt produced two overlapping detections for one visible face, so the 640×640 validation size is retained and the larger-input result remains logged as a limitation.
