# Yellowdig review checklist

Last audited: 2026-09-05 18:22 WAT

All seven drafts use the required **Evidence → Milestone → Lesson → Next step**
structure and name at least one selected screenshot that exists in the project.
Run `bash scripts/audit_yellowdig_readiness.sh` to recheck the mapping before
review or packaging.

For the currently reviewable cadence block, use
`YELLOWDIG_POSTS_1_TO_3_REVIEW.md` and
`evidence/selected/yellowdig-posts-1-to-3-review.png` as the compact
attachment/claim/privacy cross-check. They are review aids, not post evidence.
Use `YELLOWDIG_PUBLICATION_CONTROL.md` and
`evidence/selected/yellowdig-publication-control.png` as the single-page final
handoff across all seven posts; they are also review aids, not post evidence.

Clean-recipient validation now also requires exact manifest/file-set parity and
rejects symlinks, generated/private directories, credential-like filenames,
and common sensitive-text patterns. Both the unmanifested-extra and synthetic
email-leak negative controls exit non-zero as intended.
The adjacent release `.sha256` is verified before extraction; a deliberately
tampered sidecar also exits non-zero before configure/build/test begins.

## Review order and gates

1. Posts 1–3: ready for Oche's content/privacy review; do not publish by Jane.
2. Post 4: evidence complete; hold until the earlier-post cadence is cleared.
3. Post 5: the consent-gate screenshot is ready, but webcam-success evidence is
   blocked until Oche explicitly confirms a camera test. The refusal path now
   has a semantic audit for the exact message, exit status, early ordering, and
   absent output file. The camera has not been activated.
4. Post 6: evidence complete; hold behind Post 5 to preserve the course cadence.
5. Post 7: non-camera integration, cross-platform tests, release, and clean
   consumer evidence are complete. Retain the untested-camera limitation unless
   the separate camera gate is cleared.

## Final check before each manual post

- Attach only the filename(s) named in that post's draft.
- Confirm the image is legible and contains no notifications, private paths,
  messages, email addresses, credentials, or non-consenting people.
- Keep result wording within the evidence boundary stated in the draft.
- After Oche publishes, archive a screenshot under
  `evidence/yellowdig-published/` and index it in the evidence register.
