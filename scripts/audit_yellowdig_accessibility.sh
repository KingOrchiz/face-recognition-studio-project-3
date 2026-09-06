#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
guide="$project_root/docs/YELLOWDIG_SCREENSHOT_CAPTIONS.md"
readme="$project_root/README.md"

expected_attachments='1 post-01-project-tree-readme.png
2 post-02-synthetic-input-output.png
2 post-02-synthetic-terminal-detection.png
3 post-03-mac-build-tests.png
4 post-04-video-input-output.png
4 post-04-video-terminal.png
5 post-05-camera-consent-gate.png
5 post-05-camera-gate-semantic-audit.png
6 post-06-known-unknown-results.png
6 post-06-threshold-validation.png
7 post-07-final-tests.png
7 post-07-package-tree.png
7 post-07-release-archive.png
7 post-07-consumer-validation.png
7 post-07-release-boundary-audit.png
7 post-07-privacy-audit.png
7 post-07-sidecar-integrity.png
7 post-07-archive-safety.png
7 post-07-model-integrity.png
7 post-07-claim-traceability.png
7 post-07-manifest-path-safety.png
7 post-07-image-output-safety.png
7 post-07-contact-sheet.png'

[[ -f "$guide" ]] || { echo "Caption guide missing" >&2; exit 1; }
[[ -f "$readme" ]] || { echo "README missing" >&2; exit 1; }

failures=0
checked=0
printf 'Yellowdig screenshot accessibility audit\n\n'

while IFS=' ' read -r post name; do
    selected="$project_root/evidence/selected/$name"
    line="$(grep -F "| $post | \`$name\` |" "$guide" || true)"
    matches="$(grep -Fc "| $post | \`$name\` |" "$guide" || true)"
    alt_length="$(awk -F '|' '{value=$4; gsub(/^[[:space:]]+|[[:space:]]+$/, "", value); print length(value)}' <<<"$line")"

    status=PASS
    if [[ ! -f "$selected" || "$matches" -ne 1 || -z "$alt_length" || "$alt_length" -lt 60 ]]; then
        status=FAIL
        failures=$((failures + 1))
    fi
    checked=$((checked + 1))
    printf 'Post %d  %-44s %s\n' "$post" "$name" "$status"
done <<<"$expected_attachments"

if grep -Eq '(/root/|/Users/|[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,})' "$guide"; then
    echo 'Caption privacy scan: FAIL' >&2
    failures=$((failures + 1))
else
    echo 'Caption privacy scan: PASS'
fi

if ! grep -Fq 'this is not evidence of webcam operation' "$guide"; then
    echo 'Post 5 safeguard boundary: FAIL' >&2
    failures=$((failures + 1))
else
    echo 'Post 5 safeguard boundary: PASS'
fi

expected_count="$(printf '%s\n' "$expected_attachments" | wc -l | tr -d ' ')"
readme_count="$(sed -nE 's/.*draft\/screenshot mapping, ([0-9]+) exact copy-ready screenshot captions,.*/\1/p' "$readme")"
if [[ "$readme_count" != "$expected_count" ]]; then
    printf 'README attachment count: FAIL (documented=%s expected=%s)\n' \
        "${readme_count:-missing}" "$expected_count" >&2
    failures=$((failures + 1))
else
    printf 'README attachment count: PASS (%s exact attachments)\n' "$expected_count"
fi

if (( failures > 0 )); then
    printf 'Accessibility audit: FAIL (%d issue(s))\n' "$failures" >&2
    exit 1
fi

printf 'Accessibility audit: PASS (%d/%d exact attachments)\n' "$checked" "$expected_count"
