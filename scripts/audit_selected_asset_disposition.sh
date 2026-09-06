#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
selected_dir="$project_root/evidence/selected"

attachments=(
    post-01-project-tree-readme.png
    post-02-synthetic-input-output.png
    post-02-synthetic-terminal-detection.png
    post-03-mac-build-tests.png
    post-04-video-input-output.png
    post-04-video-terminal.png
    post-05-camera-consent-gate.png
    post-05-camera-gate-semantic-audit.png
    post-06-known-unknown-results.png
    post-06-threshold-validation.png
    post-07-archive-safety.png
    post-07-claim-traceability.png
    post-07-consumer-validation.png
    post-07-contact-sheet.png
    post-07-final-tests.png
    post-07-image-output-safety.png
    post-07-manifest-path-safety.png
    post-07-model-integrity.png
    post-07-package-tree.png
    post-07-privacy-audit.png
    post-07-release-archive.png
    post-07-release-boundary-audit.png
    post-07-sidecar-integrity.png
)

review_aids=(
    archive-permission-mode-audit.png
    camera-evidence-record-contract-audit.png
    camera-evidence-record-audit.png
    camera-test-preflight-contract-audit.png
    camera-test-preflight.png
    camera-test-readiness-card.png
    cli-numeric-validation-audit.png
    distribution-inventory-audit.png
    evidence-register-coverage-audit.png
    evidence-register-sequence-audit.png
    final-lab-report-readiness.png
    macos-consumer-shell-compatibility-audit.png
    mode-safe-default-output.png
    shell-script-syntax-audit.png
    submission-readiness.png
    submission-readiness-contract-audit.png
    published-post-intake-audit.png
    selected-png-privacy-audit.png
    yellowdig-asset-disposition-audit.png
    yellowdig-exact-mapping-audit.png
    yellowdig-posts-1-to-3-review.png
    yellowdig-posts-4-to-7-review.png
    yellowdig-publication-control.png
    yellowdig-readiness-audit.png
    yellowdig-screenshot-captions.png
)

optional_support=(
    post-07-macos-consumer-portability.png
    post-07-macos-spaced-path-validation.png
    post-07-video-output-safety.png
)

superseded=(
    current-linux-regression.png
    post-02-input-output.png
    post-02-terminal-detection.png
)

expected="$(printf '%s\n' "${attachments[@]}" "${review_aids[@]}" \
    "${optional_support[@]}" "${superseded[@]}" | LC_ALL=C sort)"
actual="$(find "$selected_dir" -maxdepth 1 -type f -name '*.png' \
    -exec basename {} \; | LC_ALL=C sort)"

echo 'Selected evidence asset disposition audit'
if ! diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$actual"); then
    echo 'Exact selected-file disposition: FAIL' >&2
    exit 1
fi

drafts=(
    "$project_root/docs/YELLOWDIG_POSTS_1_TO_3.md"
    "$project_root/docs/YELLOWDIG_POSTS_4_TO_7.md"
)
for name in "${attachments[@]}"; do
    matches="$(grep -Fhc "evidence/selected/$name" "${drafts[@]}" \
        | awk '{sum += $1} END {print sum + 0}')"
    if [[ "$matches" -lt 1 ]]; then
        printf 'Draft attachment reference: FAIL (%s count=%s)\n' "$name" "$matches" >&2
        exit 1
    fi
done

for name in "${review_aids[@]}" "${optional_support[@]}" "${superseded[@]}"; do
    if grep -Fq "evidence/selected/$name" "${drafts[@]}"; then
        printf 'Non-attachment referenced by draft: FAIL (%s)\n' "$name" >&2
        exit 1
    fi
done

printf 'Exact selected-file disposition: PASS (%d files)\n' "$(wc -l <<<"$actual")"
printf 'Draft attachments present in post copy: PASS (%d)\n' "${#attachments[@]}"
printf 'Review aids: PASS (%d)\n' "${#review_aids[@]}"
printf 'Optional supporting evidence: PASS (%d)\n' "${#optional_support[@]}"
printf 'Superseded captures excluded from drafts: PASS (%d)\n' "${#superseded[@]}"
