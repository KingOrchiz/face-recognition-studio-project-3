#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
draft_a="$project_root/docs/YELLOWDIG_POSTS_1_TO_3.md"
draft_b="$project_root/docs/YELLOWDIG_POSTS_4_TO_7.md"
publication_control="$project_root/docs/YELLOWDIG_PUBLICATION_CONTROL.md"
publication_control_png="$project_root/evidence/selected/yellowdig-publication-control.png"
caption_guide="$project_root/docs/YELLOWDIG_SCREENSHOT_CAPTIONS.md"

screenshots_for_post() {
    case "$1" in
        1) printf '%s\n' 'post-01-project-tree-readme.png' ;;
        2) printf '%s\n' 'post-02-synthetic-input-output.png post-02-synthetic-terminal-detection.png' ;;
        3) printf '%s\n' 'post-03-mac-build-tests.png' ;;
        4) printf '%s\n' 'post-04-video-input-output.png post-04-video-terminal.png' ;;
        5) printf '%s\n' 'post-05-camera-consent-gate.png post-05-camera-gate-semantic-audit.png' ;;
        6) printf '%s\n' 'post-06-known-unknown-results.png post-06-threshold-validation.png' ;;
        7) printf '%s\n' 'post-07-final-tests.png post-07-package-tree.png post-07-release-archive.png post-07-consumer-validation.png post-07-release-boundary-audit.png post-07-privacy-audit.png post-07-sidecar-integrity.png post-07-archive-safety.png post-07-model-integrity.png post-07-claim-traceability.png post-07-manifest-path-safety.png post-07-image-output-safety.png post-07-contact-sheet.png' ;;
        *) return 1 ;;
    esac
}

failures=0
expected_attachment_count=0
draft_mapping_status="PASS"
printf 'Yellowdig seven-post readiness audit\n'
printf 'Required structure: Evidence -> Milestone -> Lesson -> Next step\n\n'

for post in {1..7}; do
    post_screenshots="$(screenshots_for_post "$post")"
    if (( post <= 3 )); then
        draft="$draft_a"
    else
        draft="$draft_b"
    fi

    section="$(awk -v start="## Post $post " '
        index($0, start) == 1 {active=1}
        active && index($0, "## Post ") == 1 && index($0, start) != 1 {exit}
        active {print}
    ' "$draft")"

    structure="PASS"
    for label in Evidence Milestone Lesson "Next step"; do
        if ! grep -Fq "**$label**" <<<"$section"; then
            structure="FAIL"
            failures=$((failures + 1))
        fi
    done

    screenshot_status="PASS"
    for name in $post_screenshots; do
        if [[ ! -f "$project_root/evidence/selected/$name" ]] || ! grep -Fq "$name" <<<"$section"; then
            screenshot_status="FAIL"
            failures=$((failures + 1))
        fi
        expected_attachment_count=$((expected_attachment_count + 1))
    done
    if ! diff -u \
        <(printf '%s\n' $post_screenshots | LC_ALL=C sort -u) \
        <(grep -oE 'evidence/selected/[A-Za-z0-9._-]+\.png' <<<"$section" \
            | sed 's#evidence/selected/##' | LC_ALL=C sort -u) \
        >/dev/null; then
        screenshot_status="FAIL"
        draft_mapping_status="FAIL"
        failures=$((failures + 1))
    fi

    gate="READY FOR OCHE REVIEW"
    if (( post == 5 )); then
        gate="BLOCKED: explicit camera confirmation; safeguard evidence only"
    elif (( post >= 6 )); then
        gate="HOLD: preserve seven-post cadence"
    fi

    printf 'Post %d  structure=%s  screenshots=%s\n' "$post" "$structure" "$screenshot_status"
    printf '        %s\n' "$gate"
done

control_status="PASS"
if [[ ! -f "$publication_control" || ! -f "$publication_control_png" ]]; then
    control_status="FAIL"
    failures=$((failures + 1))
else
    for post in {1..7}; do
        post_screenshots="$(screenshots_for_post "$post")"
        control_row="$(grep -E "^\| $post \|" "$publication_control" || true)"
        for name in $post_screenshots; do
            if ! grep -Fq "$name" <<<"$control_row"; then
                control_status="FAIL"
                failures=$((failures + 1))
            fi
        done
        if ! diff -u \
            <(printf '%s\n' $post_screenshots | LC_ALL=C sort -u) \
            <(grep -oE '[A-Za-z0-9._-]+\.png' <<<"$control_row" | LC_ALL=C sort -u) \
            >/dev/null; then
            control_status="FAIL"
            failures=$((failures + 1))
        fi
    done
fi

printf '\nPublication control=%s\n' "$control_status"

caption_status="PASS"
if [[ ! -f "$caption_guide" ]]; then
    caption_status="FAIL"
    failures=$((failures + 1))
else
    for post in {1..7}; do
        post_screenshots="$(screenshots_for_post "$post")"
        for name in $post_screenshots; do
            if ! grep -Fq "| $post | \`$name\` |" "$caption_guide"; then
                caption_status="FAIL"
                failures=$((failures + 1))
            fi
        done
        if ! diff -u \
            <(printf '%s\n' $post_screenshots | LC_ALL=C sort -u) \
            <(awk -F '|' -v post="$post" \
                '$2 ~ "^[[:space:]]*" post "[[:space:]]*$" {print $3}' "$caption_guide" \
                | sed -nE 's/^[[:space:]]*`([^`]+)`[[:space:]]*$/\1/p' \
                | LC_ALL=C sort -u) \
            >/dev/null; then
            caption_status="FAIL"
            failures=$((failures + 1))
        fi
    done
fi
printf 'Screenshot captions=%s\n' "$caption_status"
if [[ "$draft_mapping_status" == PASS && "$control_status" == PASS && "$caption_status" == PASS ]]; then
    printf 'Exact attachment mapping=PASS (%d attachments across 7 posts)\n' \
        "$expected_attachment_count"
else
    printf 'Exact attachment mapping=FAIL\n'
fi

printf '\nCamera accessed: NO\n'
printf 'External publication: NO\n'

if (( failures > 0 )); then
    printf 'Audit result: FAIL (%d issue(s))\n' "$failures" >&2
    exit 1
fi

printf 'Audit result: PASS\n'
