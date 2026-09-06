# Face Recognition Studio

A C++17/OpenCV application for detecting and counting faces in images, videos,
or a webcam stream. When labelled reference images are available, it uses SFace
embeddings and cosine similarity to label matches; all other faces are `Unknown`.

## Build

Dependencies: a C++17 compiler, CMake 3.16+, and OpenCV 4.5+ with the `core`,
`imgproc`, `imgcodecs`, `videoio`, `highgui`, `objdetect`, and `dnn` modules.

Ubuntu/Debian setup:

```bash
sudo apt-get install build-essential cmake ninja-build libopencv-dev
```

macOS/Homebrew setup:

```bash
brew install cmake ninja opencv@4
bash scripts/macos_setup_build.sh
```

OpenCV 4 is selected explicitly because OpenCV 5 removes the legacy
`CascadeClassifier` API used by the application's detection fallback. See
[`docs/MACOS_ENVIRONMENT_TROUBLESHOOTING.md`](docs/MACOS_ENVIRONMENT_TROUBLESHOOTING.md)
for the M-series Mac validation record and recovery commands.

The build selects the compatible bundled YuNet graph as the executable's real
default: `face_detection_yunet_2022mar.onnx` for OpenCV releases before 4.10,
and `face_detection_yunet_2023mar.onnx` for OpenCV 4.10 or newer. Run
`build/face_studio --build-info` to see the compiled OpenCV version and selected
default, or `bash scripts/audit_default_detector_selection.sh` to verify that
the selected model is present. This audit is camera-free.

Retrieve or verify the three pinned OpenCV Zoo model files:

```bash
bash scripts/download_models.sh
```

The downloader refuses to overwrite a file with an unexpected hash.

```bash
cmake -S . -B build -G Ninja
cmake --build build
ctest --test-dir build --output-on-failure
```

For a stricter local verification build, add
`-DFACE_STUDIO_WARNINGS_AS_ERRORS=ON` to the configure command. This turns the
project's `-Wall -Wextra -Wpedantic` diagnostics into build failures without
changing the default consumer build. The dedicated `macos_setup_build.sh`
verification path enables this switch automatically. Its post-build checks use
the compiled version-aware detector default, reject Haar fallback, assert the
expected synthetic known/unknown labels, and write timestamped result images so
repeat runs preserve earlier evidence.

The nine-test suite includes help/version checks, invalid-mode and invalid-threshold
handling, a camera-consent gate, a non-camera image smoke test, and a 30-frame
synthetic-video smoke test. The video smoke test intentionally omits `--output`
and verifies the mode-safe `output/result.mp4` default. Image mode defaults to
`output/result.jpg`; video and camera modes default to `output/result.mp4`.
When the
OpenCV 4.6-compatible YuNet 2022 model is present, it also verifies a synthetic
known match and a synthetic `Unknown` decision at the bounded test threshold.

Run the complete camera-safe prerequisite check without opening or enumerating
a device:

```bash
bash scripts/camera_test_preflight.sh \
  build/face_studio output/consented-camera-test.mp4
```

Audit all safe preflight acceptance/rejection paths without opening a camera:

```bash
bash scripts/audit_camera_test_preflight.sh build/face_studio
```

This preflight verifies the executable, pinned models, an unused writable MP4
target, exit status 2, the consent-specific refusal message, gate execution
before model initialization, and no created camera-output file. It ends by
stating that explicit confirmation is still required.
The consented hardware procedure, abort criteria, evidence fields, and current
blocked truth boundary are in
[`docs/CAMERA_TEST_RUNBOOK.md`](docs/CAMERA_TEST_RUNBOOK.md).

Verify that video mode refuses to overwrite its own input and preserves the
source bytes:

```bash
bash scripts/audit_video_output_safety.sh
```

This audit rejects a non-MP4 video destination before model initialization,
then verifies default preservation of an unrelated existing output, explicit
non-camera overwrite opt-in, and disposable copies of the synthetic video in four
equivalent-path cases: an identical pathname, a relative alias, a hard link,
and a symbolic link. It also refuses `--overwrite` when the destination is a
symbolic link, directory, or multiply linked file. All eleven cases complete
before model initialization and every protected fixture retains its SHA-256
digest. It does not access a camera.

Image and video modes also refuse to replace an unrelated existing output by
default. Pass `--overwrite` only when replacement is intentional; the destination
must be a regular file with exactly one hard link, never a symbolic link or
directory. Camera mode never accepts `--overwrite`; its evidence output must
always use a new path.

Still-image mode has the equivalent source-preservation control. Verify direct,
relative-alias, hard-link, and symbolic-link refusals with:

```bash
bash scripts/audit_image_output_safety.sh
```

The nine-case image audit requires status 2 and the exact refusal before model
initialization, confirms protected SHA-256 values remain unchanged across the
four source-alias and three unsafe-overwrite cases, and does not access a camera.

Verify that malformed threshold and camera-index values are rejected before
model initialization or device work:

```bash
bash scripts/audit_cli_numeric_validation.sh
```

The camera-free audit covers trailing-text, non-numeric, NaN, and infinite
thresholds plus trailing-text, negative, and overflowing camera indices. All
seven cases must exit with status 2 before engine construction; no camera device
is opened or enumerated.

Create a reproducible source, model, test, documentation, and selected-evidence
submission archive (Linux packaging host):

```bash
bash scripts/package_release.sh
```

The command writes the archive and its SHA-256 digest under `dist/`, lists the
archive contents, and verifies the embedded `SHA256SUMS` manifest in a clean
temporary extraction directory. Build products and generated recognition
outputs are deliberately excluded. It also fails if `dist/` contains a stale
or ambiguous handoff file: the directory must contain only the canonical
archive and its adjacent `.sha256` sidecar.

Confirm that every packaged file still matches the current workspace before
handoff (this detects documentation, source, model, or selected-evidence edits
made after the last package build):

```bash
bash scripts/audit_release_freshness.sh
```

Validate the archive as a consumer from a fresh extraction, including its
adjacent SHA-256 sidecar, README-linked documentation, seven-post
draft/screenshot mapping, 23 exact copy-ready screenshot captions, selected-PNG signature/dimensions/IEND integrity,
full PNG chunk-CRC/order validation with an image-only metadata policy and zero trailing payload,
pinned ONNX model hashes and byte sizes, cross-document evidence-claim
traceability, project-contained local documentation links and Markdown anchors,
portability/syntax validation for every packaged shell script,
strict command-line numeric parsing,
version-aware default-detector selection,
the camera-safe model/output/semantic-consent preflight,
the video input/output overwrite refusal,
configure/build, and all CTests:

```bash
bash scripts/validate_release.sh
```

Consumer validation first requires the adjacent `.sha256` file to name and
match the archive. Before extraction, it rejects absolute/traversal paths,
duplicate members, links/special files, unexpected archive roots, unsafe archive
permission roles (0644 data, 0755 `scripts/*.sh`, and 0755 directories),
excessive member counts, and excessive declared unpacked
size. It then rejects unsafe or
duplicate embedded-manifest paths before any manifest-directed file read and
confirms that `SHA256SUMS` covers the exact regular-file set. The release must
contain no symlinks or generated/private
directories, and no credential-like filename has crossed the package boundary.
Before configuring or building the extracted source, it scans packaged text
for private home paths, email addresses, credential-like assignments, and
private-key material. It also verifies all three bundled model files against
the independently pinned hashes and sizes recorded in the provenance guide,
so a self-consistent regenerated package manifest cannot legitimize a changed
model.

Run the same shell-script syntax gate directly in the workspace with:

```bash
bash scripts/audit_shell_script_syntax.sh
```

The gate checks every `scripts/*.sh` file for an environment-resolved Bash
shebang, executable mode, Unix line endings, and `bash -n` syntax before the
extracted release executes the remaining project audits. Disposable malformed,
wrong-shebang, and CRLF fixtures prove the corresponding checks fail closed.

The evidence register is also fail-closed against the selected screenshot
folder. Run `bash scripts/audit_evidence_register_coverage.sh` to require every
selected PNG to have an exact register reference and to reject stale register
references to absent selected files. The same gate also requires evidence IDs
to be unique and contiguous from E01, preventing a skipped or reused record
number from silently weakening the audit trail.

The consumer validator and image/video source-safety audits accept either GNU
`sha256sum` or the `shasum -a 256` command included with macOS. Manifest hashes
are verified with Python's standard-library SHA-256 implementation, so a Mac
recipient does not need to install GNU coreutils merely to validate the handoff.
The packaged `scripts/audit_macos_consumer_compatibility.sh` gate also scans 31
executable dependencies against 28 Bash 4-only or GNU/non-stock command forms,
while proving exact coverage of all 32 shell nodes reachable from the release
validator (including the audit entry point). Covered forms include arrays/case
conversion and common incompatible `find`, `sort`, `sed`, `grep`, `stat`,
`date`, `readlink`, `xargs`, and file-utility options.
This is a static compatibility boundary, not a claim that the refreshed archive
has been rerun on the Mac.

## Yellowdig review

The template-aligned report scaffold is in
[`docs/FINAL_LAB_REPORT_DRAFT.md`](docs/FINAL_LAB_REPORT_DRAFT.md). It contains
the verified engineering narrative and explicit placeholders for team identity,
workload, GitHub Insights, real published-post captures, AIAS assessment,
evaluation, and personal reflection. Do not treat the draft as a final report
or infer missing external evidence.

The seven copy-ready drafts and their publication gates are under `docs/`.
For the current review block, use
[`docs/YELLOWDIG_POSTS_1_TO_3_REVIEW.md`](docs/YELLOWDIG_POSTS_1_TO_3_REVIEW.md)
with `evidence/selected/yellowdig-posts-1-to-3-review.png` to verify the exact
attachments, allowed claims, and privacy boundaries before posting. The review
packet is not permission for Jane to publish.

For one-page final handoff, use
[`docs/YELLOWDIG_PUBLICATION_CONTROL.md`](docs/YELLOWDIG_PUBLICATION_CONTROL.md)
with `evidence/selected/yellowdig-publication-control.png`. It consolidates all
seven states, exact attachments, claim boundaries, and cadence gates; the
authoritative first-person copy remains in the two draft files.

For attachment accessibility text, use
[`docs/YELLOWDIG_SCREENSHOT_CAPTIONS.md`](docs/YELLOWDIG_SCREENSHOT_CAPTIONS.md).
The release validator enforces a single bounded description for every exact
draft attachment, including the safeguard-only wording for Post 5. It also
requires the per-post screenshot sets in the drafts, publication control, and
caption guide to match exactly. The privacy-clean
`evidence/selected/yellowdig-exact-mapping-audit.png` is a review aid for that
control, not an additional post attachment.

The selected-evidence disposition audit keeps the folder unambiguous: exactly
23 files are draft attachments, 24 are reviewer aids, three are optional
supporting evidence, and three older captures are retained only as superseded
records. Any new or misclassified selected PNG fails clean-recipient validation;
a disposable unclassified-PNG fixture proves that the gate fails closed.

Run `bash scripts/audit_handoff_status_consistency.sh` to prove the current
selected-file totals in both handoff documents and the evidence-sequence total
match the live disposition and evidence-register audits. Disposable stale
project-status count, checklist count, and evidence-sequence fixtures prove
that drift fails closed.

After each real publication, save exactly one screenshot as
`evidence/yellowdig-published/post-0N-YYYY-MM-DD.png`, then run
`scripts/audit_published_post_intake.sh`. The intake gate accepts an empty folder
as honestly pending, but once captures exist it requires a contiguous Post 1
through Post N sequence, nondecreasing valid dates, one regular file per post,
and complete PNGs of at least 1000x600. Its seven-case contract audit proves
that gaps, duplicate post numbers, malformed names, truncated images, and
reversed dates fail closed. Passing this structural gate does not replace the
manual content/privacy review or evidence-register entry.

Run `bash scripts/audit_final_lab_report_draft.sh` before using the working lab
report for handoff. The contract requires the exact 11-section course mapping,
operator-owned placeholders, the truthful untested-camera and 0/7 publication
boundaries, the four-part Yellowdig narrative order, and the final PDF assembly
gate. Disposable missing-section, false-publication, and false-camera-result
mutations prove that these safeguards fail closed. Passing this audit means the
working draft is internally consistent; it does not make the report submission
ready or supply the still-missing external and personal evidence.

Before Post 5 can move from safeguard wording to a webcam-result claim, run
`scripts/audit_camera_evidence_record.sh`. It accepts the untouched blank
template while keeping the claim blocked; after an authorized test, its
completed-record mode requires all consent, privacy, result, retention,
screenshot-basename, and Evidence → Milestone → Lesson → Next step fields.
The camera-safe `scripts/audit_camera_evidence_record_contract.sh` exercises
both accepted record states and proves that failed retention, a private path,
or a missing narrative field is rejected without opening a camera.

## Run

```bash
./build/face_studio --mode image --input sample.jpg --output output/result.jpg
./build/face_studio --mode video --input sample.mp4 --output output/result.mp4
./build/face_studio --mode camera --input 0 --confirm-camera \
  --output output/camera.mp4 --display
```

If YuNet is incompatible with the installed OpenCV runtime, the application can
fall back to a Haar cascade for detection only. Common Linux and Homebrew paths
are auto-discovered; an explicit file can be supplied with `--cascade FILE`.
SFace recognition is deliberately disabled during fallback because Haar output
does not contain the five facial landmarks required for alignment.

Put one clear reference image per person in `data/known/`. The filename stem is
used as the label, for example `Oche.jpg`. Each reference image must contain
exactly one detectable face.

The operational default cosine threshold is `0.400`. On this project's bounded
synthetic pair it retained the known match and rejected the different identity.
Tune it with a broader validation set before drawing conclusions.

Model filenames, upstream locations, and current hashes are recorded in
`docs/MODEL_PROVENANCE.md`.

For the audited Linux OpenCV 4.6.0 environment, select the compatible model:

```bash
./build/face_studio --mode image --input tests/synthetic_portrait_a_variant_640.png \
  --detector models/face_detection_yunet_2022mar.onnx \
  --known tests/known --threshold 0.400 \
  --output output/recognition-example.png
```

The `0.400` default is only a bounded test setting for the small synthetic set.
At OpenCV's documented SFace example threshold of `0.363`, an unrelated
synthetic face scored `0.391773` and was falsely accepted; broader validation is
required before choosing a production threshold.

## Privacy and responsible use

Use only images for which the team has permission. This is an educational demo,
not an identity or access-control system. Recognition can fail because of light,
pose, image quality, demographic bias, or threshold selection.

Camera mode is blocked unless `--confirm-camera` is passed. The flag must only be
used after the participant explicitly confirms the camera test at test time.
Even after confirmation, camera mode refuses any output path that already exists
(including a dangling symbolic link) so a prior evidence file cannot be replaced.
It requires a `.mp4` filename and an output parent that already exists as a
directory. An explicitly empty stream output is accepted only together with
`--display`; this prevents an otherwise unobservable run from processing and
discarding every frame. These invalid destinations are rejected before model
construction or device access.
Follow `docs/CAMERA_TEST_RUNBOOK.md` and complete the audited
`docs/CAMERA_TEST_EVIDENCE_RECORD.md`; a camera screenshot alone is not a
complete consented-test record.
Prefer the synthetic input documented in
`tests/synthetic_portrait_a.provenance.md` for repeatable non-camera checks.
