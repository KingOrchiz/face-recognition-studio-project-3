# Face Recognition Studio — seven-post Yellowdig plan

## Non-negotiable cadence

- Publish in order and only after the named milestone is verified.
- Every post uses four labelled parts: **Evidence**, **Milestone**, **Lesson**, and **Next step**.
- Every post includes at least one legible screenshot from the actual work. A plan, claim, or prose-only post is not ready.
- Keep the original capture in `evidence/raw/`; put the reviewed posting copy in `evidence/selected/`.
- After Oche publishes a post, save a screenshot of the published post in `evidence/yellowdig-published/`.
- Do not backfill a success narrative. If a step fails, show the error, state the bounded result, and make resolution the next milestone.
- Jane must not publish externally. Oche reviews and publishes each post himself unless he separately authorizes publication.
- Camera access stays prohibited until Oche gives explicit camera-test confirmation at test time.

## Post 1 — Scope, staged design, and responsible use

**Evidence:** `post-01-project-tree-readme.png`, showing the project tree and README sections for image, video, camera, `Unknown`, and privacy limitations.

**Milestone:** A C++17/OpenCV architecture and staged delivery path are documented. At this point, modes shown in the tree or README are design scope, not proof that each mode works.

**Lesson:** Consent, privacy, honest confidence thresholds, and `Unknown` handling are part of the engineering design.

**Next step:** Build the existing code, run the automated checks, and verify one still-image detection end to end.

**Ready when:** the screenshot is captured, indexed, reviewed, and contains no private desktop content.

## Post 2 — First verified still-image detection

**Evidence:** `post-02-synthetic-input-output.png` plus `post-02-synthetic-terminal-detection.png`. The first shows the fictional synthetic input and annotated output; the second shows the exact command, fallback warning, one-face count, and saved path.

**Milestone:** Linux image detection/counting succeeds and produces an annotated file. Identity recognition is not demonstrated. The 2026-09-05 Linux run used the Haar fallback after the OpenCV 4.6.0/YuNet path failed.

**Lesson:** A bounded fallback can preserve progress while keeping a model/runtime incompatibility visible.

**Next step:** Reproduce configure, build, and tests on the Mac and verify the intended YuNet model path on its OpenCV runtime.

**Ready when:** the synthetic input provenance, run log, output, hashes, and both selected screenshots are indexed. Completed locally on 2026-09-05; Oche review/publication remains.

## Post 3 — Reproducible macOS build

**Evidence:** `post-03-mac-build-tests.png`, the selected combined privacy-clean view of the verified Mac environment, configure/build/link result, and 9/9 CTest result.

**Milestone:** Claim macOS reproducibility only if configure, compilation, and CTest all complete successfully. If setup fails, the milestone is the documented dependency/error diagnosis—not a cross-platform success.

**Lesson:** Reproducibility requires explicit versions, commands, and output rather than “works on my machine.”

**Next step:** Exercise the non-camera stream pipeline with a synthetic or otherwise permitted video.

**Ready when:** Mac logs, screenshot, versions, commands, and hashes are in the evidence register. Completed locally on 2026-09-05; Oche review/publication remains.

## Post 4 — Video pipeline

**Evidence:** `post-04-video-input-output.png` and `post-04-video-terminal.png`, using synthetic footage or footage with documented permission.

**Milestone:** A video opens, every readable frame passes through annotation, and a playable output file is produced. Do not call it real-time unless frame rate and elapsed time are measured.

**Lesson:** Streams add codec, frame-size, frame-rate, output, and stability concerns that a still image does not expose.

**Next step:** Request Oche's explicit camera-test confirmation and prepare a privacy-safe scene before any webcam access.

**Ready when:** the input provenance, command, frame count, output inspection, logs, and screenshots are indexed. Completed locally on 2026-09-05; hold until Post 3 is resolved and published.

## Post 5 — Webcam integration and issue resolution

**Evidence:** `post-05-camera-consent-gate.png` currently proves the executable safeguard without opening a camera. After explicit confirmation, a completed webcam milestone also requires a privacy-safe `post-05-webcam-result.png` and, if relevant, `post-05-camera-permission.png` or `post-05-issue-resolution.png`.

**Milestone:** The camera mode is verified only after Oche explicitly confirms the test. Capture only Oche or another consenting participant, with a non-sensitive background.

**Lesson:** Hardware integration adds OS permissions, device indices, lighting, and environmental variability.

**Next step:** Test SFace with consented or synthetic known/unknown reference pairs and document the threshold behaviour.

**Ready when:** explicit confirmation is logged before the first camera command and all captures pass privacy review. Currently blocked at the explicit-confirmation gate; the safeguard screenshot is ready but is not webcam-success evidence.

## Post 6 — SFace matching and threshold validation

**Evidence:** `post-06-known-unknown-results.png` and `post-06-threshold-validation.png`, with reference labels and personal details minimized.

**Milestone:** Demonstrate at least one genuine known match and one genuine `Unknown` result, then compare scores around the chosen threshold. Do not present the educational demo as an identity or access-control system.

**Lesson:** Detection asks whether a face is present; recognition measures whether an embedding is sufficiently similar to a reference and therefore needs calibration.

**Next step:** Run the final regression, package the reproducible artefacts, and consolidate limitations.

**Ready when:** reference/input provenance, raw scores, thresholds, outputs, and screenshots are indexed. Completed locally on 2026-09-05; hold until Post 5 is resolved and published.

## Post 7 — Final integration and reflection

**Evidence:** `post-07-final-tests.png`, `post-07-package-tree.png`, `post-07-release-archive.png`, `post-07-consumer-validation.png`, `post-07-release-boundary-audit.png`, `post-07-privacy-audit.png`, `post-07-sidecar-integrity.png`, `post-07-archive-safety.png`, `post-07-model-integrity.png`, `post-07-claim-traceability.png`, and `post-07-contact-sheet.png`.

**Milestone:** The final package contains source, build instructions, tests, model provenance, selected evidence, and an honest status for each mode.

**Lesson:** A reproducible result with visible limitations is stronger than an unsupported accuracy claim.

**Next step:** Oche reviews the seven-post sequence, removes any private detail, publishes each post at the agreed cadence, and archives the published-post screenshots.

**Ready when:** the final regression passes, package contents are hashed, unresolved limitations are listed, and the contact sheet uses only verified evidence.

## Screenshot integrity rules

- Preserve the original capture and its SHA-256 hash.
- Record timestamp, environment, exact command/action, result, and intended post in `evidence/EVIDENCE_REGISTER.md`.
- Crop only irrelevant areas; never alter the technical result.
- Never expose tokens, email, private messages, unrelated files, usernames, or sensitive paths.
- A derived contact sheet must be labelled as derived and point back to its original files.
- A screenshot of a planned command is not evidence that the command ran.
