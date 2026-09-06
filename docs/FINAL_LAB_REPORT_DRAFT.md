# Face Recognition Studio — final lab report working draft

Status: **engineering sections drafted; identity, team, GitHub, publication,
workload, and individual-reflection fields require Oche's input or real external
evidence**.

This working draft follows the Coding Camp lab-report structure already used in
the course workspace. It is not a submission-ready PDF and does not claim that
the camera milestone or any Yellowdig publication occurred.

## Cover details

- Course: Coding Camp II
- Project: Project 3 — Face Recognition Studio
- Team name: `PENDING`
- Student ID(s): `PENDING`
- Team member name(s): `PENDING`
- Study programme(s): `PENDING`
- Repository URL: `PENDING — must be the final public repository supplied by Oche`

## 1. Project overview

Face Recognition Studio is a C++17/OpenCV application that detects and counts
faces in still images, prerecorded videos, or a consent-gated webcam stream.
When labelled reference images are available, it uses SFace embeddings and
cosine similarity to return a label; otherwise it reports `Unknown`.

The verified engineering scope includes version-aware YuNet model selection,
a Haar detection fallback, bounded synthetic recognition checks, safe output
handling, reproducible packaging, and Linux plus Apple-silicon build evidence.
The webcam path remains untested because explicit camera-test confirmation has
not been given.

## 2. Team composition and matching

Complete this section before submission.

| Student ID | Name | Study programme | Previous experience |
|---|---|---|---|
| `PENDING` | `PENDING` | `PENDING` | `PENDING` |

- Did matching based on availability and commitment work? `PENDING`
- Explain any difference in team-member availability or contribution: `PENDING`

## 3. Feature plan and estimated-versus-actual effort

| Feature or workstream | Planned outcome | Estimate | Actual effort | Result/evidence |
|---|---|---:|---:|---|
| Project structure and CLI | Buildable three-mode C++ application | `PENDING` | `PENDING` | `README.md`, `src/main.cpp` |
| Still-image detection | Detect and annotate a permitted test image | `PENDING` | `PENDING` | Post 2 synthetic evidence |
| macOS build | Configure, compile, link, and test on Apple silicon | `PENDING` | `PENDING` | Post 3 build/test evidence |
| Prerecorded video | Process a short non-camera stream | `PENDING` | `PENDING` | Post 4 30-frame evidence |
| Camera mode | Run only after explicit consent and privacy preparation | `PENDING` | `PENDING` | **Blocked; safeguard evidence only** |
| Recognition | Demonstrate bounded known/unknown decisions | `PENDING` | `PENDING` | Post 6 synthetic evidence |
| Integration and handoff | Regression, reproducible archive, documentation | `PENDING` | `PENDING` | Post 7 release evidence |

Do not backfill invented hours. Use calendar, commit, meeting, terminal-log, and
Yellowdig timestamps where available, then explain material variances.

## 4. Workload and team process

Complete one row per contributor and ensure software-development work is visible.

| Contributor | Coding | Setup/testing | Research | Documentation | Meetings/coordination | Total |
|---|---:|---:|---:|---:|---:|---:|
| `PENDING` | `PENDING` | `PENDING` | `PENDING` | `PENDING` | `PENDING` | `PENDING` |

Team process narrative: `PENDING — describe task allocation, review, merging,
troubleshooting, and how continuous progress was maintained.`

## 5. Implementation and programming concepts

### C++ structure and object-oriented design

`FaceEngine` encapsulates detector, recognizer, cascade fallback, enrolled
identities, and threshold state. `Options` represents validated command-line
configuration, while small functions isolate parsing, path safety, image mode,
and stream mode.

### Collections and algorithms

`std::vector` stores known identities and filesystem candidates. Standard
algorithms provide deterministic sorting and model/cascade selection. OpenCV
matrices hold images, detections, landmarks, and face embeddings.

### Selection, iteration, and error handling

The CLI selects image, video, or camera execution. Frame loops process streams;
face loops annotate detections; identity loops select the highest cosine score.
Exceptions are converted into a consistent status-2 failure with a usage hint.

### Responsible image processing

The project uses fictional synthetic portraits for repeatable non-camera tests.
The release preserves the 0.363 false-accept observation and uses 0.400 only as
a bounded two-query demonstration threshold, not as an accuracy or fairness
claim. Camera execution is blocked unless explicit confirmation is supplied.

## 6. Testing, results, and limitations

- Linux: clean strict build with project warnings treated as errors; 9/9 named
  CTests passed.
- Apple silicon: AppleClang/OpenCV 4.14.0 configure, compile, link, and 9/9 CTests
  passed in the preserved baseline run.
- Still image: one synthetic face detected on the selected 640×640 YuNet path.
- Video: 30/30 synthetic frames processed at the preserved 3-second input length.
- Recognition: known query cosine 0.934496; different synthetic identity cosine
  0.391773; decisions were `Synthetic_A` and `Unknown` at 0.400.
- Release: deterministic archive, adjacent SHA-256 sidecar, clean extraction,
  integrity/privacy gates, build, and CTest validation.
- Limitations: two-query recognition evidence is not an accuracy evaluation;
  demographic performance was not assessed; webcam operation remains untested;
  the refreshed package has not been rerun on the currently offline Mac.

## 7. AI Assessment Scale disclosure

AI assistance supported requirements organization, code review and hardening,
test/audit design, documentation drafting, and evidence-card preparation. Oche
must select the applicable AIAS level for each activity and describe his own
review, understanding, edits, and learning.

Sample prompts to retain only if they accurately reflect actual use:

- "Draft a safe C++/OpenCV plan for image, video, and consent-gated camera modes."
- "Design a synthetic known/unknown recognition check without using a webcam."
- "Audit a reproducible release package for integrity, privacy, and Mac shell portability."
- "Structure each Yellowdig update as Evidence, Milestone, Lesson, and Next step."

AIAS level(s), learning effect, and no-AI time comparison: `PENDING — Oche's
own assessment required.`

## 8. Team evaluation

Discuss and agree the values before entering them. Scale: 0 (absent) to 5 (top
contributor).

| Learner | Planning | Coding | Organization/well-being | Documentation | Presentation | Average |
|---|---:|---:|---:|---:|---:|---:|
| `PENDING` | `PENDING` | `PENDING` | `PENDING` | `PENDING` | `PENDING` | `PENDING` |

## 9. GitHub evidence

- Public repository URL: `PENDING`
- Contributors screenshot: `PENDING`
- Community Standards screenshot: `PENDING`
- Code Frequency screenshot: `PENDING`
- Explanation for unequal commit distribution, if applicable: `PENDING`

Do not publish a repository or infer contribution history from the local
workspace. Add only Oche-reviewed external evidence.

## 10. Yellowdig chronological learning log

Insert real published-post screenshots in this order only after they exist and
pass the intake/privacy review. Each post must visibly retain the four-part
structure below.

1. Post 1 — project structure and responsible-use boundary
2. Post 2 — synthetic still-image detection
3. Post 3 — Apple-silicon build and regression
4. Post 4 — non-camera video pipeline
5. Post 5 — consented camera result, or an explicitly stated untested limitation
6. Post 6 — bounded synthetic known/unknown recognition
7. Post 7 — final integration, release, and limitations

For every entry include:

- **Evidence:** the real post screenshot, date, topic/team tag, and named artefact.
- **Milestone:** what was actually completed at that point.
- **Lesson:** the technical or process learning, including failed attempts where useful.
- **Next step:** the next chronological action, not a retrospective invention.

Current publication evidence: **0/7 actual post captures**. Draft screenshots
are not substitutes for published-post screenshots.

## 11. Personal reflection

`PENDING — Oche writes this in his own voice.` Address what was learned about
C++/OpenCV, cross-platform dependencies, threshold limitations, safe evidence
handling, what worked well, and what should change in a future project.

## Final assembly gate

Before PDF export, require all of the following:

- identity, team, workload, estimates/actuals, AIAS, evaluation, and reflection completed;
- final public GitHub URL plus the three required Insights screenshots;
- seven chronological Yellowdig captures, or course-approved handling of the
  unresolved camera milestone, with privacy review completed;
- no private paths, email addresses, credentials, non-consenting faces, or room details;
- claims remain within the verified boundaries in `docs/PROJECT_STATUS.md`;
- final PDF inspected page by page after rendering.

