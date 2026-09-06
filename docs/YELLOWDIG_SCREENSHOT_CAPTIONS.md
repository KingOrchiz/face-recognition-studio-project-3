# Yellowdig screenshot captions and alt text

Prepared: 2026-09-05 20:29 WAT

Use the caption with the exact selected attachment named below. These descriptions
are copy-ready accessibility text; they do not expand the evidence claim in the
post drafts or authorize publication.

| Post | Exact selected attachment | Copy-ready alt text |
|---|---|---|
| 1 | `post-01-project-tree-readme.png` | Project tree beside the Face Recognition Studio README, showing C++ source, models, tests, and documented image, video, and consent-gated camera modes. |
| 2 | `post-02-synthetic-input-output.png` | Side-by-side fictional synthetic portrait before processing and after one detected face was outlined and counted. |
| 2 | `post-02-synthetic-terminal-detection.png` | Privacy-clean terminal record showing the Haar fallback warning, one detected face, and the saved synthetic output path. |
| 3 | `post-03-mac-build-tests.png` | Privacy-clean Apple-silicon Mac validation summary showing AppleClang, Homebrew OpenCV 4, successful configure and link, and nine of nine tests passing. |
| 4 | `post-04-video-input-output.png` | Synthetic video input frame beside its processed frame, with one face box, an Unknown label, and a face count of one. |
| 4 | `post-04-video-terminal.png` | Terminal evidence showing all 30 synthetic video frames processed and ffprobe confirming 640 by 640 pixels, 10 frames per second, and 3 seconds. |
| 5 | `post-05-camera-consent-gate.png` | Safeguard evidence showing camera mode refusing to run without the explicit confirmation flag; this is not evidence of webcam operation. |
| 5 | `post-05-camera-gate-semantic-audit.png` | Semantic camera-gate audit showing refusal status two, consent-specific messaging, early gate ordering, and no camera output file created. |
| 6 | `post-06-known-unknown-results.png` | Two fictional synthetic recognition results: the same-identity query labelled Synthetic_A and the different identity labelled Unknown at threshold 0.400. |
| 6 | `post-06-threshold-validation.png` | Threshold comparison showing a 0.934496 known score and 0.391773 different-identity score, including the false acceptance at 0.363 and rejection at 0.400. |
| 7 | `post-07-final-tests.png` | Cross-platform regression summary showing the same nine named non-camera checks passing on Linux and Apple-silicon macOS. |
| 7 | `post-07-package-tree.png` | Release package tree showing source, models, synthetic tests, documentation, audit scripts, and selected evidence without build directories. |
| 7 | `post-07-release-archive.png` | Reproducible release summary showing embedded checksum verification and matching SHA-256 values from consecutive package builds. |
| 7 | `post-07-consumer-validation.png` | Clean-recipient validation summary showing extraction, integrity checks, configure, compile, link, semantic camera refusal, and nine passing tests. |
| 7 | `post-07-release-boundary-audit.png` | Release-boundary audit showing exact manifest and file-set parity, no symlinks, no generated or private directories, and no credential-like filenames. |
| 7 | `post-07-privacy-audit.png` | Text privacy audit showing staged release files checked for private paths, email addresses, credential assignments, and private-key material. |
| 7 | `post-07-sidecar-integrity.png` | External archive-integrity check showing a valid adjacent SHA-256 sidecar accepted and a deliberately tampered sidecar rejected before extraction. |
| 7 | `post-07-archive-safety.png` | Pre-extraction safety audit showing bounded archive paths, types, count, and size, plus rejection of a deliberately crafted traversal member. |
| 7 | `post-07-model-integrity.png` | Independent model audit showing all three pinned ONNX files passing exact size and SHA-256 checks and a one-byte mutation being rejected. |
| 7 | `post-07-claim-traceability.png` | Automated traceability result confirming that 17 key Yellowdig claims remain consistent with packaged source, CTest definitions, macOS validation and handoff guidance, and synthetic-dataset evidence while retaining the untested-camera boundary. |
| 7 | `post-07-manifest-path-safety.png` | Release-integrity summary showing a genuine embedded checksum manifest accepted, a crafted parent-traversal checksum target rejected before hashing, and the clean extracted build passing nine of nine tests. |
| 7 | `post-07-image-output-safety.png` | Still-image source-preservation audit showing exact, relative-alias, hard-link, and symbolic-link output paths refused before model initialization while each disposable source retained its SHA-256 digest. |
| 7 | `post-07-contact-sheet.png` | Milestone contact sheet summarizing verified still-image, Mac build, synthetic video, consent gate, recognition threshold, and final release evidence. |

## Use boundary

- Keep the Post 5 descriptions labelled as safeguard evidence until Oche
  explicitly confirms and completes a privacy-safe camera test.
- Do not infer demographic accuracy, fairness, production readiness, or webcam
  success from any caption.
- Re-run `bash scripts/audit_yellowdig_accessibility.sh` before handoff.
- The audit also requires the README's documented attachment total to equal the
  authoritative mapping count; a stale total fails the handoff gate.

Camera accessed: **No**. External publication by Jane: **No**.
