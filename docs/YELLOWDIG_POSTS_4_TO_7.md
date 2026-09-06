# Yellowdig drafts and gates — Posts 4 to 7

## Post 4 — Verifying the non-camera video pipeline

**Evidence**

The attached screenshots show a frame from a synthetic 3-second input beside the corresponding processed frame, plus the preserved terminal and ffprobe results. No camera or real participant was used.

**Milestone**

The application processed all 30 frames of the 640×640, 10 fps input and produced a 30-frame output with the same dimensions, frame rate, and 3.0-second duration. The measured processing command completed in 1.48 seconds on the Linux test environment. The output frame shows one bounding box, `Faces: 1`, and `Unknown`.

The current OpenCV 4.6.0 environment still uses the Haar fallback, so this demonstrates video detection/counting—not YuNet execution or identity recognition.

**Lesson**

Video adds codec, frame-rate, frame-count, output-integrity, and timing checks that a still image does not expose. I also learned to preserve failed diagnostics: my first ffprobe command was malformed, so I kept that log and recorded the corrected command separately.

**Next step**

With macOS build evidence complete, I will hold the webcam milestone until explicit camera-test confirmation. Recognition and threshold validation remain separate later milestones.

**Screenshots to attach:** `evidence/selected/post-04-video-input-output.png` and `evidence/selected/post-04-video-terminal.png`.

## Post 5 — Webcam integration

Not ready for a webcam-success claim. Two privacy-safe prerequisite screenshots
are available: `evidence/selected/post-05-camera-consent-gate.png` and
`evidence/selected/post-05-camera-gate-semantic-audit.png`.

**Evidence**

The screenshots show camera mode refusing to continue without the new
`--confirm-camera` flag. The semantic audit required exit status 2, the exact
consent-specific refusal, execution before model initialization, and no created
camera-output file. That audit and the full 9/9 Linux regression passed. No
camera device was opened.

**Milestone**

The application now enforces the consent boundary in code instead of relying
only on written instructions. This is a safety milestone, not evidence that the
webcam integration works.

**Lesson**

Privacy requirements are stronger when they are executable, testable defaults.
A safe refusal path also makes accidental hardware activation less likely.

**Next step**

After Oche explicitly confirms the camera test, run the approved Mac command,
capture only a privacy-safe scene, verify the output, and replace this
prerequisite evidence with the full webcam result. Do not publish this draft as
a completed webcam milestone before that test.

**Screenshots to attach now:** `evidence/selected/post-05-camera-consent-gate.png`
and `evidence/selected/post-05-camera-gate-semantic-audit.png`.
This is prerequisite/safeguard evidence only; the eventual webcam-success post
must also include a consented result screenshot.

## Post 6 — SFace matching and threshold validation

**Evidence**

The attached screenshots show one same-identity synthetic query and one different synthetic subject, followed by the four preserved score/threshold decisions. All subjects are fictional and AI-generated; no camera was used.

**Milestone**

Using the OpenCV 4.6-compatible YuNet 2022 detector and SFace 2021 recognizer, the identity-preserving query scored 0.934496 against the enrolled Synthetic_A reference. The different identity scored 0.391773. At threshold 0.400, the first was labelled `Synthetic_A` and the second `Unknown`; both automated recognition checks passed.

OpenCV's published example threshold of 0.363 falsely accepted the different identity in this small test. That negative result is preserved rather than hidden, and the application now uses the bounded 0.400 setting as its operational default.

**Lesson**

Detection and recognition are distinct problems, and a published example threshold is not automatically suitable for a new dataset. Calibration needs genuine known and unknown comparisons.

**Next step**

I will broaden the validation set before making any accuracy claim and retain this feature as an educational demonstration rather than an access-control system. The cross-platform build milestone is now complete.

**Screenshots to attach:** `evidence/selected/post-06-known-unknown-results.png` and `evidence/selected/post-06-threshold-validation.png`.

## Post 7 — Final integration and reflection

Publication-gated draft. The Linux final-regression, Mac build/test,
package-tree, release-validation, clean-consumer-validation, and milestone contact-sheet screenshots are ready. The
explicitly approved camera milestone remains open and may be retained as a stated limitation.

**Evidence**

The attached screenshots show the preserved Linux CTest result, the packaged
source/model/test/evidence structure with SHA-256 integrity anchors, the clean
extraction, external sidecar, pre-extraction path/type/size safety, exact content-boundary, and reproducibility checks for the release archive, a fresh
configure/build/9-of-9 test run from only the extracted package, the Mac
build/test evidence included in that archive, and a contact sheet of the verified milestones. Nine named checks passed on both Linux and Mac, including
still-image detection, expected CLI failure handling, the camera-consent refusal path, synthetic known/unknown
recognition, and a 30-frame non-camera video smoke test.
The still-image safety audit also rejected exact, relative-alias, hard-link,
and symbolic-link attempts to overwrite the input before model initialization,
with the source SHA-256 unchanged in all four cases.

**Milestone**

The integrated suite passed 9/9 checks with zero failures on Linux in 2.94 seconds and on Apple-silicon macOS in 2.08 seconds.
The release archive verified every embedded file hash after clean extraction,
its adjacent `.sha256` handoff file matched the archive, and two consecutive
package builds produced the same archive SHA-256. A deliberately tampered
sidecar was rejected before extraction. This
validation also rejects archive path traversal, duplicate paths, links or
special files, an unexpected root, and excessive declared extraction size
before `tar` writes anything; a deliberately unsafe `../` member was rejected.
It now also validates the embedded checksum manifest before any
manifest-directed file read, rejecting unsafe, malformed, self-referencing, or
duplicate paths; a crafted `../` checksum target was rejected with status 1.
All three bundled ONNX files also pass an independent pinned SHA-256 and
byte-size audit; a deliberately altered copy was rejected, proving this gate
does not merely trust the package's regenerated manifest.
This
consumer-style check also caught and resolved an omitted README-linked macOS
troubleshooting guide before configuring, compiling, linking, and passing all
nine tests from a fresh extraction. It also validates the PNG signature,
minimum readable dimensions, terminal IEND marker, and minimum size of every
selected evidence file before the build. This closes the cross-platform non-camera integration/package milestone; it does not
claim that the separately gated camera path has been exercised.

**Lesson**

An end-to-end regression should exercise the risky paths, not only prove that
the executable launches. A checksum-valid package can still omit a support file,
so delivery should also be exercised from a recipient's clean environment. A
valid manifest can also miss an unlisted extra, so the validator now compares
the exact file set and rejects symlinks, generated/private directories, and
credential-like filenames. The
separate text-privacy audit also rejects private home-directory paths, email
addresses, credential-like assignments, and private-key material without
printing any matched value. The recognition and video checks now protect the
specific evidence used in earlier milestones.

**Next step**

The privacy audit result is captured in
`evidence/selected/post-07-privacy-audit.png`. I will retain the untested-camera
limitation unless Oche explicitly confirms a privacy-safe hardware test. The
seven-post sequence remains for Oche's review; nothing will be published
externally by the project assistant.

**Screenshots ready:** `evidence/selected/post-07-final-tests.png`,
`evidence/selected/post-07-package-tree.png`,
`evidence/selected/post-07-release-archive.png`,
`evidence/selected/post-07-consumer-validation.png`,
`evidence/selected/post-07-release-boundary-audit.png`,
`evidence/selected/post-07-privacy-audit.png`,
`evidence/selected/post-07-sidecar-integrity.png`,
`evidence/selected/post-07-archive-safety.png`,
`evidence/selected/post-07-model-integrity.png`,
`evidence/selected/post-07-claim-traceability.png`, and
`evidence/selected/post-07-manifest-path-safety.png`, and
`evidence/selected/post-07-image-output-safety.png`, and
`evidence/selected/post-07-contact-sheet.png`.

Do not publish this draft until all Post 7 readiness gates are resolved or
truthfully marked as limitations.
