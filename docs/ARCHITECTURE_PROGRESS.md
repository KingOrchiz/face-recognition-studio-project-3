# Architecture implementation progress

This document distinguishes the team's target architecture from verified code.

## Implemented

- `IFrameSource` shared input contract
- `ImageSource`, `VideoSource`, and consent-gated `CameraSource`
- `Logger`
- Existing image, video, webcam, detection, recognition, and output behavior
- Nine-test regression suite

## Next refactor milestones

- Extract `FaceDetector`, `FaceEncoder`, and `FaceRecognizer` from the current
  `FaceEngine` facade.
- Extract a `FaceDatabase` that loads explicitly approved labelled reference
  images. It will not silently enrol unknown people.
- Extract `ResultWriter` and `Config`.
- Add opt-in, privacy-bounded event logging with retention controls.
- Evaluate liveness separately. Liveness is not currently implemented and must
  not be claimed until it has its own tests and evidence.

## Privacy boundary

The application does not automatically save unknown faces or build an encounter
history. Reference images are enrolled deliberately by placing one approved
image per identity in `data/known/`; filename stems provide display labels.
