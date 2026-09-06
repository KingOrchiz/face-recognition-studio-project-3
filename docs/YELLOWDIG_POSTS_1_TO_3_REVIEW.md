# Yellowdig review packet — Posts 1 to 3

Prepared: 2026-09-05 18:22 WAT

This packet is for Oche's content/privacy review. It does not authorize Jane to
publish. The authoritative copy remains in `YELLOWDIG_POSTS_1_TO_3.md`.

## Post 1 — project design

- Attach only `evidence/selected/post-01-project-tree-readme.png`.
- Evidence boundary: project structure, three modes, and responsible-use design.
- Do not imply that a detection, Mac build, or camera test had happened at this
  milestone.
- Reviewer check: screenshot is legible, synthetic/person-free, and contains no
  private notification or path.

## Post 2 — still-image detection

- Attach `evidence/selected/post-02-synthetic-input-output.png` and
  `evidence/selected/post-02-synthetic-terminal-detection.png`.
- Evidence boundary: one fictional synthetic face detected and saved using the
  documented Haar fallback.
- Do not claim YuNet/SFace recognition from this result.
- Reviewer check: both screenshots show only the synthetic subject and
  privacy-clean technical evidence.

## Post 3 — reproducible Mac build

- Attach only `evidence/selected/post-03-mac-build-tests.png`.
- Evidence boundary: Apple-silicon configure/build/link plus 9/9 CTests using
  AppleClang and Homebrew OpenCV 4.14.0.
- Do not imply webcam operation; the screenshot explicitly states that no camera
  was opened.
- Reviewer check: dependency versions, nine named checks, and the 2.08-second
  bounded result are legible.

## Cadence gate

Review and publish in order. Post 4 remains held until Post 3 is cleared. Camera
testing and Post 5 remain blocked until Oche gives explicit camera-test
confirmation. Jane must not publish externally.
