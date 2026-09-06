# Project 3 submission readiness

Last verified: 2026-09-06 05:58 WAT

This is the handoff index for the Face Recognition Studio. It separates
verified artefacts from actions that require Oche or a future explicit camera
authorization. It does not authorize publication or camera access.

| Submission area | State | Exact artefact or gate | Next owner action |
|---|---|---|---|
| C++17/OpenCV source | Ready | `src/main.cpp`, `CMakeLists.txt` | None unless scope changes |
| Linux build and regression | Ready | 9/9 CTests plus clean-consumer validation | Re-run only after source changes |
| Apple-silicon build and regression | Baseline verified; current-source refresh pending | `evidence/selected/post-03-mac-build-tests.png` proves the preserved baseline; the current archive has only static stock-macOS shell checks since later source changes | Re-run `scripts/macos_setup_build.sh` when the paired Mac is online; do not describe that rerun as complete until its new log exists |
| Still-image milestone | Ready | Post 2 synthetic input/output and terminal captures | Oche reviews, then posts in sequence |
| Synthetic-video milestone | Ready; cadence hold | Post 4 input/output and terminal captures | Hold until Post 3 is published |
| Recognition milestone | Ready; cadence hold | Post 6 known/unknown and threshold captures | Hold behind resolved Post 5 |
| Camera milestone | Blocked | Consent gate, safe preflight, runbook, and blank evidence record are ready; no device has been opened | Oche must explicitly confirm the camera test at test time |
| Seven Yellowdig drafts | Ready for ordered review | `docs/YELLOWDIG_PUBLICATION_CONTROL.md` | Oche reviews and publishes; Jane does not publish |
| Published-post evidence | Pending external action | Intake folder and fail-closed sequence/PNG contract are ready; 0/7 real captures exist | Oche supplies or captures each published post, then runs the intake audit |
| Release handoff | Ready | Canonical archive plus adjacent SHA-256 sidecar in `dist/` | Use only the two canonical handoff files |
| Final lab-report assembly | Working draft ready; external evidence pending | `docs/FINAL_LAB_REPORT_DRAFT.md` maps the course-template sections to verified engineering evidence and leaves identity, workload, GitHub, publication, AIAS, evaluation, and reflection fields explicitly pending; its packaged 6/6 contract rejects missing sections and false camera/publication claims | Oche completes the personal/team fields and supplies real GitHub/post captures before PDF export |

## Honest completion boundary

- **Evidence:** source, synthetic media, Mac/Linux build results, 9/9 tests,
  release checks, post drafts, and all current draft attachments are preserved.
- **Milestone:** the non-camera engineering and review handoff is complete.
- **Lesson:** technical completion and submission completion are different; a
  consented hardware result and screenshots of actual posts cannot be inferred
  from drafts or safeguard evidence.
- **Next step:** Oche reviews Posts 1–3 in order. The camera remains untouched
  until he separately confirms the test; published-post captures and the final
  lab report follow the real posting sequence.
