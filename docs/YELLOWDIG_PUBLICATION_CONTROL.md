# Yellowdig publication control — seven-post handoff

Prepared: 2026-09-05 18:40 WAT

This is Oche's single-page review index. It does not authorize Jane to publish
and it does not replace the first-person drafts. Review each row against the
named draft and selected screenshots before publishing in order.

| Post | State | Exact selected attachments | Evidence boundary | Next gate |
|---|---|---|---|---|
| 1 | Ready for Oche review | `post-01-project-tree-readme.png` | Documented scope and responsible-use design; not proof that every mode works | Oche content/privacy review |
| 2 | Ready for Oche review | `post-02-synthetic-input-output.png`; `post-02-synthetic-terminal-detection.png` | One synthetic still detected with Haar fallback; no recognition claim | Publish only after Post 1 |
| 3 | Ready for Oche review | `post-03-mac-build-tests.png` | Apple-silicon configure/build/link and the same 9/9 checks passed; no camera use | Publish only after Post 2 |
| 4 | Evidence complete; cadence hold | `post-04-video-input-output.png`; `post-04-video-terminal.png` | Synthetic 30-frame video result; 1.48-second Linux run is not a benchmark | Publish only after Post 3 |
| 5 | Blocked | `post-05-camera-consent-gate.png`; `post-05-camera-gate-semantic-audit.png` are safeguard evidence only | Proves refusal before device/model access; does not prove webcam operation | Oche's explicit camera-test confirmation, then privacy-safe hardware evidence |
| 6 | Evidence complete; cadence hold | `post-06-known-unknown-results.png`; `post-06-threshold-validation.png` | Two-query synthetic regression at threshold 0.400; no accuracy, fairness, or production claim | Hold behind resolved/published Post 5 |
| 7 | Non-camera evidence complete; cadence hold | `post-07-final-tests.png`; `post-07-package-tree.png`; `post-07-release-archive.png`; `post-07-consumer-validation.png`; `post-07-release-boundary-audit.png`; `post-07-privacy-audit.png`; `post-07-sidecar-integrity.png`; `post-07-archive-safety.png`; `post-07-model-integrity.png`; `post-07-claim-traceability.png`; `post-07-manifest-path-safety.png`; `post-07-image-output-safety.png`; `post-07-contact-sheet.png` | Reproducible cross-platform non-camera result and bounded release-integrity claims; retain camera as untested unless separately completed | Hold behind Post 6 and retain honest camera limitation |

## Publication controls

- Use the exact first-person copy in `YELLOWDIG_POSTS_1_TO_3.md` and
  `YELLOWDIG_POSTS_4_TO_7.md`; this file is a control index, not post copy.
- Use the copy-ready descriptions in `YELLOWDIG_SCREENSHOT_CAPTIONS.md` for the
  exact attachments; they preserve the same claim boundaries.
- Every post must retain the labelled **Evidence**, **Milestone**, **Lesson**,
  and **Next step** structure.
- Before each post, re-run `bash scripts/audit_yellowdig_readiness.sh`, inspect
  every attachment at readable size, and confirm there are no private paths,
  notifications, messages, email addresses, credentials, or non-consenting
  people.
- After Oche publishes, save the publication screenshot under
  `evidence/yellowdig-published/post-0N-YYYY-MM-DD.png` and index it in the
  evidence register.

Camera accessed: **No**. External publication by Jane: **No**.
