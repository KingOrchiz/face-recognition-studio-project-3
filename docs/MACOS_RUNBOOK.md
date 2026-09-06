# macOS build and evidence runbook

## Current status

On 2026-09-05, Oche completed the non-camera validation on an Apple-silicon
MacBook Air. The corrected build selected AppleClang 21 and Homebrew OpenCV
4.14.0, configured and linked `face_studio`, and passed all 9/9 CTests in 2.08
seconds. The privacy-clean result is preserved as
`evidence/selected/post-03-mac-build-tests.png`; the full diagnosis and recovery
path is in `docs/MACOS_ENVIRONMENT_TROUBLESHOOTING.md`.

No camera device was opened. Camera validation remains a separate blocked
milestone requiring Oche's explicit test-time confirmation.

## Repeatable non-camera rerun

From a privacy-clean terminal in the project root:

```bash
bash scripts/macos_setup_build.sh
```

The script:

1. Records SHA-256 identities for `CMakeLists.txt`, `src/main.cpp`, and the Mac
   helper itself, binding the future terminal log to the exact source tested.
2. Records the macOS, Homebrew, CMake, Ninja, Clang, and OpenCV versions.
3. Installs missing `cmake`, `ninja`, or `opencv` Homebrew formulae.
4. Verifies all three model files with SHA-256.
5. Configures an isolated `build-macos-opencv4/` tree with
   `FACE_STUDIO_WARNINGS_AS_ERRORS=ON`, compiles, and runs all CTests. This keeps
   the normal CMake consumer default unchanged while making any project
   AppleClang warning fail the dedicated Mac verification build.
6. Audits the compiled version-aware detector default, including a synthetic
   recognition check that must complete without Haar fallback.
7. Runs the synthetic known and unknown checks at the bounded 0.400 test
   threshold, asserts both labels, and writes timestamped output images so a
   rerun cannot silently replace earlier evidence.
8. Saves a timestamped combined log under `evidence/raw/`.

It does not access the camera. The verified 2026-09-05 run remains valid as a
preserved baseline and as the current Post 3 historical evidence. Later source
changes mean it is **not** runtime validation of the current source/archive.
Run this helper again when the paired Mac is online before describing the
current source as AppleClang/OpenCV 4.14 verified.

## Validate the release handoff on macOS

Keep the archive and its adjacent `.sha256` sidecar together, then run:

```bash
bash scripts/validate_release.sh
```

The consumer validator, model audit, and image/video source-safety audits use
macOS `shasum -a 256` when GNU `sha256sum` is unavailable. The embedded
`SHA256SUMS` file is checked with Python 3, already installed by the Homebrew
setup path above. A forced-`shasum` Linux regression verifies this fallback
branch without claiming that the full release validator has been rerun on the
Mac.

## Post 3 screenshot sequence

- Versions: terminal frame containing `sw_vers`, Homebrew, CMake, Ninja, Clang, and OpenCV versions.
- Build: terminal frame containing the CMake configure and successful link result.
- Tests: terminal frame showing the complete CTest summary.
- Preserve the original screen captures first; make separate selected copies with any username or unrelated path cropped/redacted.
- Record filenames, timestamps, hashes, and exact results in `evidence/EVIDENCE_REGISTER.md`.

## Camera gate

Do not run `--mode camera`, inspect camera devices, request camera permission, or capture a camera screenshot until Oche explicitly confirms the camera test at that time. The setup/build script does not contain any camera command.
