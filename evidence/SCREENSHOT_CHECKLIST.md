# Screenshot capture checklist

Before every capture:

- Close private chats, email, credentials, unrelated documents, and notifications.
- Keep the application name, command, or relevant file heading visible.
- Make terminal text large enough to read and keep the command plus result in one frame where possible.
- Preserve the raw screenshot; make a separate redacted/cropped copy for posting if needed.
- Log the file in `EVIDENCE_REGISTER.md`.

Planned filenames:

- `post-01-project-tree-readme.png`
- `post-02-input-output.png`
- `post-02-terminal-detection.png`
- `post-02-synthetic-input-output.png` (recommended outward-facing version)
- `post-02-synthetic-terminal-detection.png` (recommended outward-facing version)
- `post-03-mac-versions.png`
- `post-03-mac-build.png`
- `post-03-mac-tests.png`
- `post-03-mac-build-tests.png` (selected combined privacy-clean evidence view)
- `post-04-video-input-output.png`
- `post-04-video-terminal.png`
- `post-05-camera-permission.png`
- `post-05-camera-consent-gate.png` (prerequisite safeguard; not a webcam-success screenshot)
- `post-05-camera-gate-semantic-audit.png` (exact refusal/exit/output safeguard evidence)
- `post-05-webcam-result.png`
- `post-05-issue-resolution.png`
- `post-06-known-unknown-results.png`
- `post-06-threshold-validation.png`
- `post-07-final-tests.png`
- `post-07-package-tree.png`
- `post-07-release-archive.png`
- `post-07-consumer-validation.png`
- `post-07-release-boundary-audit.png`
- `post-07-privacy-audit.png`
- `post-07-sidecar-integrity.png`
- `post-07-archive-safety.png`
- `post-07-model-integrity.png`
- `post-07-claim-traceability.png`
- `post-07-manifest-path-safety.png`
- `post-07-video-output-safety.png` (four-case source-alias overwrite safeguard; optional supporting evidence)
- `post-07-image-output-safety.png` (four-case still-image source-alias overwrite safeguard; visually inspected)
- `post-07-macos-consumer-portability.png` (optional supporting evidence; forced macOS-compatible hash branch, not a Mac execution claim)
- `post-07-macos-spaced-path-validation.png` (optional supporting evidence; forced macOS-compatible hash branch from a handoff folder containing spaces, not a Mac execution claim)
- `post-07-contact-sheet.png`
- `yellowdig-readiness-audit.png` (cross-post review aid; not a substitute for a post's named evidence)
- `yellowdig-posts-1-to-3-review.png` (privacy/claim-boundary review aid; not a substitute for a post's named evidence)
- `yellowdig-posts-4-to-7-review.png` (privacy/claim-boundary review aid; not a substitute for a post's named evidence)
- `yellowdig-publication-control.png` (single-page seven-post state/attachment/gate review aid; not a substitute for post evidence)
- `yellowdig-screenshot-captions.png` (copy-ready alt-text review aid for all exact draft attachments; not a substitute for post evidence)
- `yellowdig-exact-mapping-audit.png` (exact draft/control/caption-set audit review aid; not a substitute for post evidence)
- `yellowdig-asset-disposition-audit.png` (positive/negative selected-folder classification review aid; not a substitute for post evidence)
- `camera-test-readiness-card.png` (operator review aid; not webcam-success evidence or a post attachment)
- `camera-test-preflight.png` (camera-safe prerequisite review aid; not webcam-success evidence or a post attachment)
- `camera-test-preflight-contract-audit.png` (6/6 repeatable fail-closed preflight review aid; not webcam-success evidence or a post attachment)
- `camera-evidence-record-audit.png` (blank-template completeness/privacy gate review aid; not webcam-success evidence or a post attachment)
- `camera-evidence-record-contract-audit.png` (5/5 completed-state/fail-closed contract review aid; synthetic records only, not webcam-success evidence or a post attachment)
- `shell-script-syntax-audit.png` (all packaged shell scripts have the portable Bash shebang, executable mode, Unix line endings, and valid syntax; malformed, wrong-shebang, and CRLF controls are rejected; release review aid, not a post attachment)
- `cli-numeric-validation-audit.png` (7/7 strict threshold/camera-index rejections before engine or device work; camera-free release review aid, not a post attachment)
- `distribution-inventory-audit.png` (canonical archive-plus-sidecar inventory and stale-file rejection; release review aid, not a post attachment)
- `submission-readiness.png` (single-page verified/pending/blocked handoff matrix; review aid, not a post attachment)
- `submission-readiness-contract-audit.png` (5/5 semantic state/owner/narrative contract, including false camera-ready rejection; review aid, not a post attachment)
- `published-post-intake-audit.png` (7/7 empty/ordered and fail-closed publication-capture intake contract; review aid, not proof of publication)
- `archive-permission-mode-audit.png` (pre-extraction path-specific mode acceptance plus executable-data, non-executable-script, and writable-data rejection; release review aid, not a post attachment)
- `selected-png-privacy-audit.png` (all selected screenshots have valid chunk CRCs, image-only chunks, and no trailing payload; metadata/corruption/payload fixtures are rejected; review aid, not a post attachment)
- `macos-consumer-shell-compatibility-audit.png` (32/32 release-validator call-graph coverage, 31 consumer dependencies plus the dedicated Mac helper, 36/36 packaged shell contracts, 2/2 coverage-gap controls, and 28/28 portability controls; review aid, not a Mac runtime claim or post attachment)
- `final-lab-report-readiness.png` (template-aligned working-draft readiness card; review aid, not proof of publication, GitHub evidence, camera operation, or final PDF completion)

Status as of 2026-09-06 05:58 WAT:

- Posts 1 and 2 have verified source/log/image evidence and visually inspected selected screenshot files.
- Post 3 has verified baseline Mac configure/build/link and 9/9 CTest evidence plus a combined privacy-clean selected screenshot; later source changes have not received a refreshed AppleClang/OpenCV 4.14 runtime rerun, so the baseline must not be represented as validation of the current archive.
- Post 4 has complete Linux synthetic-video evidence and selected screenshots but remains held behind Post 3 in the cadence.
- Post 6 has complete bounded synthetic recognition/threshold evidence and selected screenshots but remains held behind Post 5 in the cadence.
- Post 5 now has consent-gate and semantic-audit screenshots proving the exact safe refusal without hardware access; it remains pending explicit camera-test confirmation and privacy-safe webcam capture.
- Post 7 now has visually inspected final-regression, package-tree, reproducible-release-validation, clean-consumer-validation, release-boundary-audit, text-privacy-audit, external-sidecar-integrity, pre-extraction archive-safety, pinned-model-integrity, evidence-claim-traceability, and milestone contact-sheet screenshots. The clean-consumer path verifies the adjacent archive digest, safe member metadata, all local Markdown targets/anchors, and all three pinned ONNX hashes/sizes before extraction/build; it also checks 17/17 key draft and Mac-handoff claims against packaged source records, and every selected file has a valid PNG signature, terminal IEND marker, at least 1000×600 dimensions, and non-trivial size. It rejects tampered sidecars, traversal paths, unexpected roots, duplicate archive members, links/special files, excessive declared extraction size, unmanifested extras, generated/private directories, credential-like filenames, common sensitive-text patterns, missing linked documents, altered model files, and stale Mac no-build guidance. The nine-test suite is current on Linux and preserved as a valid earlier Mac baseline; the changed source/archive still needs a refreshed Mac runtime rerun. The camera truth boundary remains explicit.
- The cross-post readiness screenshot is visually inspected; all seven drafts pass automated structure and referenced-file checks, including after clean extraction of the release.
- Posts 1–3 also have a single privacy-clean reviewer contact sheet that maps the exact attachments, allowed claims, and avoid-overclaiming boundaries without replacing their post-specific screenshots.
- Posts 4–7 also have a single privacy-clean reviewer contact sheet that keeps the camera milestone visibly blocked and maps bounded claims for video, recognition, and final integration.
- All seven posts now have one visually inspected privacy-clean publication control card that consolidates exact attachments, evidence boundaries, review states, and ordered gates; the readiness audit enforces every control mapping.
- All 23 exact draft attachments now have one privacy-scanned copy-ready alt-text description; the visually inspected accessibility card summarizes the mapping, and the audit retains Post 5's safeguard-only boundary.
- The readiness audit rejects stale or extra per-post screenshot references, not only missing required files; the visually inspected exact-mapping card records 23 attachments matching across all three handoff surfaces.
- The selected-folder classification audit passes the authentic 54-file set and rejects a disposable unclassified PNG; the Mac-consumer-portability and spaced-path captures are two of three optional supporting items and remain outside every draft attachment list.
- The macOS-compatible `shasum` branch passed the complete clean-consumer validator on Linux, including 9/9 CTests in 2.66 seconds; the privacy-clean 1600×1000 supporting screenshot was visually inspected, and no refreshed-package Mac execution is claimed.
- The same portable branch passed from a handoff directory whose name contains spaces, including all release gates and 9/9 CTests in 2.67 seconds; this is a bounded path-quoting regression, not a refreshed-package Mac run.
- The privacy-clean `evidence/selected/mode-safe-default-output.png` review aid records the corrected per-mode defaults and the 30-frame default-output regression. It is supporting review evidence, not a Yellowdig attachment or a refreshed Mac result.
- Camera capture remains prohibited until Oche explicitly confirms the camera test.
- A visually inspected 1600×1000 operator readiness card now points to the
  consented-test runbook and preserves the blocked truth boundary; it is an
  eighth reviewer aid, not webcam-success evidence or a draft attachment.
- A visually inspected 1600×1000 camera-safe preflight card records executable,
  pinned-model, unused-output-target, and semantic-refusal checks; it is the
  ninth reviewer aid, not webcam-success evidence or a draft attachment.
- A visually inspected 1600×1000 preflight-contract card records 6/6 automated
  acceptance/rejection cases and zero camera access; it is the tenth reviewer
  aid, not webcam-success evidence or a draft attachment.
- A visually inspected 1600×1000 evidence-record card proves the blank operator
  template retains every required consent/privacy/result field and keeps the
  webcam-result claim blocked; it is the eleventh reviewer aid, not webcam
  evidence or a draft attachment.
- A visually inspected 1600×1000 evidence-record contract card proves both
  accepted record states and three critical fail-closed cases; it is the
  twelfth reviewer aid, uses synthetic records only, and is not webcam evidence
  or a draft attachment.
- A privacy-clean 1600×1000 shell-contract card records that every packaged
  shell script has the expected Bash shebang, executable mode, Unix line
  endings, and valid syntax; malformed, wrong-shebang, and CRLF disposable
  scripts are rejected. It is the thirteenth reviewer aid, not a draft
  attachment.
- A visually inspected privacy-clean 1600×1000 CLI-numeric card records 7/7
  fail-fast rejections for malformed thresholds and camera indices. It is the
  fourteenth reviewer aid, not a draft attachment; the audit opened no camera.
- A visually inspected privacy-clean 1600×1000 distribution-inventory card
  records the canonical archive-plus-sidecar boundary and stale-file negative
  control. It is the fifteenth reviewer aid, not a draft attachment.
- A privacy-clean 1600×1000 submission-readiness card separates verified
  engineering and draft artefacts from the consented camera milestone,
  published-post captures, and final lab-report assembly. It is the sixteenth
  reviewer aid, not a draft attachment.
- A privacy-clean 1600×1000 submission-readiness contract card records the
  5/5 state, owner, narrative-order, and false-camera-ready rejection checks.
  It is the seventeenth reviewer aid, not a draft attachment.
- A visually inspected privacy-clean 1600×1000 published-post intake card
  records the authentic 0/7 pending state plus 7/7 acceptance/rejection
  fixtures. It is the eighteenth reviewer aid, not proof of publication or a
  draft attachment.
- A visually inspected privacy-clean 1600×1000 evidence-register sequence card
  records the sequence control; the live register now has unique contiguous IDs E01–E98,
  and missing-ID plus duplicate-ID fixtures remain rejected
  rejection fixtures. It is the twenty-second reviewer aid, not a draft
  attachment.
- A visually inspected privacy-clean 1600×1000 final-lab-report readiness card
  maps the course-template sections to the verified engineering narrative and
  keeps identity, workload, GitHub, publication, camera-result, AIAS,
  evaluation, and personal-reflection fields explicitly pending. It is the
  twenty-fifth reviewer aid, not a final report or proof of external action.
- A visually inspected privacy-clean 1600×1000 Mac consumer-shell card now records
  the current 32/32 call-graph inventory, 31 scanned dependencies plus the Mac
  helper, 36/36 packaged shell contracts, 2/2 rejected coverage gaps, and 28/28
  incompatible-form rejections. It is the twenty-third reviewer aid, includes
  the bounded camera-free helper result, and does not claim a refreshed
  AppleClang/OpenCV 4.14 execution.

- The refreshed 1600×1000 `submission-readiness.png` review card now separates
  the current 9/9 Linux result from the preserved Mac baseline and marks the
  current-source Mac rerun pending. It retains Evidence → Milestone → Lesson →
  Next step and is not a Yellowdig attachment.

Never include a non-consenting person's face, a private room detail, an access token, an email address, or a filesystem path that discloses sensitive personal information.
