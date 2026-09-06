# Yellowdig review packet — Posts 4 to 7

Prepared: 2026-09-05 18:30 WAT

This packet is for Oche's content/privacy review. It does not authorize Jane to
publish. The authoritative copy remains in `YELLOWDIG_POSTS_4_TO_7.md`.

## Post 4 — non-camera video pipeline

- Attach `evidence/selected/post-04-video-input-output.png` and
  `evidence/selected/post-04-video-terminal.png`.
- Evidence boundary: a 3-second synthetic video processed all 30 frames and
  retained 640×640, 10 fps, and 3.0-second output properties.
- Do not generalize the 1.48-second Linux run into a performance benchmark or
  claim that the camera path was used.
- Reviewer check: both screenshots identify synthetic input and state the Haar
  fallback/recognition limitation.

## Post 5 — camera-consent safeguard

- Attach `evidence/selected/post-05-camera-consent-gate.png` and
  `evidence/selected/post-05-camera-gate-semantic-audit.png` only as safeguard
  evidence.
- Evidence boundary: unconfirmed camera mode exits with status 2 before model
  initialization, creates no output, and does not open a camera device.
- Do not present this as a completed webcam milestone. A webcam-success post
  still requires Oche's explicit camera-test confirmation and a consented,
  privacy-safe capture.
- Reviewer check: the wording says prerequisite/safeguard, not webcam success.
- Operator handoff: use `docs/CAMERA_TEST_RUNBOOK.md` and the local review aid
  `evidence/selected/camera-test-readiness-card.png` for the consent record,
  controlled-scene checklist, exact bounded command, abort criteria, and
  retention fields. The card is not a Post 5 attachment or test authorization.

## Post 6 — recognition and threshold validation

- Attach `evidence/selected/post-06-known-unknown-results.png` and
  `evidence/selected/post-06-threshold-validation.png`.
- Evidence boundary: two fictional synthetic queries produced scores 0.934496
  and 0.391773; threshold 0.400 retained the known match and rejected the
  different identity.
- Do not claim accuracy, fairness, production readiness, or access-control
  suitability from this bounded two-query check.
- Reviewer check: preserve the documented false accept at OpenCV's example
  threshold 0.363 and describe 0.400 only as this demo's bounded default.

## Post 7 — integration and reflection

- Use the selected final-test, package, consumer-validation, integrity, and
  milestone contact-sheet screenshots listed in `YELLOWDIG_POSTS_4_TO_7.md`.
- Evidence boundary: nine named checks passed on Linux and Apple-silicon macOS;
  the reproducible release passed its clean-consumer and integrity gates.
- Do not imply that the camera path was exercised. Retain it as an explicit
  untested limitation unless the separate consented test is completed.
- Reviewer check: keep timing claims bounded, verify legibility/privacy, and
  avoid attaching redundant evidence if Yellowdig limits attachment count.

## Cadence gate

Review and publish in order. Post 4 remains held until Post 3 is cleared. Post 5
remains blocked pending explicit camera-test confirmation. Posts 6 and 7 remain
held behind Post 5, and Jane must not publish externally.
