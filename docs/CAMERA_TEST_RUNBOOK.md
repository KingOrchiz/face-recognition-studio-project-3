# Consented camera-test runbook

Status: **blocked until Oche explicitly confirms the camera test**.

This is an operator checklist, not evidence that a webcam test has happened.
Do not request camera permission, enumerate camera devices, or run camera mode
until the confirmation gate below is satisfied.

## 1. Record the authorization boundary

- Obtain an explicit message from Oche confirming that the camera test may run.
- Confirm that every visible participant has consented.
- Use a neutral background with no documents, screens, badges, addresses, or
  non-participants visible.
- Close private applications and disable notifications before capture.

If any item is uncertain, stop. The existing non-camera evidence remains valid.

## 2. Prepare without opening a camera

From the project root, verify the build and the refusal path:

```bash
cmake --build build
bash scripts/camera_test_preflight.sh \
  build/face_studio output/consented-camera-test.mp4
ctest --test-dir build --output-on-failure
```

These commands do not activate or enumerate a camera. The preflight verifies
the executable, pinned models, unused MP4 target, and semantic refusal. It must
report status 2, the consent-specific refusal, no created output,
`Camera opened: NO`, and `EXPLICIT CONFIRMATION STILL REQUIRED`.

Create a dedicated empty output location and check that the intended filename
does not already exist. Never reuse a source-media path.

## 3. Run only after explicit confirmation

The operator—not an unattended automation—may then run:

```bash
./build/face_studio --mode camera --input 0 --confirm-camera \
  --output output/consented-camera-test.mp4 --display
```

Press `q` or Escape immediately after the bounded test. If macOS shows its
camera-permission prompt, approve it only for the terminal application being
used and only within the confirmed test window.

## 4. Abort criteria

Stop without retaining or posting the recording if:

- a non-consenting person or private detail enters the frame;
- the wrong camera activates;
- the output location is unexpected;
- the preview cannot be closed with `q` or Escape; or
- the application reports an unexpected model, writer, or device error.

## 5. Evidence and retention

Record the bounded result in
[`CAMERA_TEST_EVIDENCE_RECORD.md`](CAMERA_TEST_EVIDENCE_RECORD.md); the blank
template is neither test authorization nor webcam evidence.

- Keep one privacy-safe screenshot showing the application result and face
  count; crop away the room and unrelated desktop content where possible.
- Keep one privacy-safe terminal screenshot showing the exact command and final
  processed-frame result, with no home path, username, or notifications.
- Record the date/time, operator, participant-consent state, device index,
  output filename, observed face count, and whether the temporary video was
  deleted after review.
- Review both captures locally before adding them to `evidence/selected/`.
- Do not publish. Update Post 5 from safeguard wording to webcam-result wording
  only if the evidence truthfully demonstrates the completed test.

## Current truth boundary

The camera has not been accessed. Existing Post 5 screenshots demonstrate only
that unconfirmed camera mode fails closed before model initialization and
creates no output. Posts 6 and 7 remain held behind Post 5 in publication order.
