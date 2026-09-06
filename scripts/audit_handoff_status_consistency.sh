#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
status_document="$project_root/docs/PROJECT_STATUS.md"
checklist="$project_root/evidence/SCREENSHOT_CHECKLIST.md"
register="$project_root/evidence/EVIDENCE_REGISTER.md"
mac_runbook="$project_root/docs/MACOS_RUNBOOK.md"

validate() {
    local status_file="$1"
    local checklist_file="$2"
    local mac_runbook_file="${3:-$mac_runbook}"
    local disposition total review coverage last_id

    disposition="$(bash "$project_root/scripts/audit_selected_asset_disposition.sh")"
    total="$(printf '%s\n' "$disposition" | sed -n 's/^Exact selected-file disposition: PASS (\([0-9][0-9]*\) files)$/\1/p')"
    review="$(printf '%s\n' "$disposition" | sed -n 's/^Review aids: PASS (\([0-9][0-9]*\))$/\1/p')"
    coverage="$(bash "$project_root/scripts/audit_evidence_register_coverage.sh" "$project_root")"
    last_id="$(printf '%s\n' "$coverage" | sed -n 's/^Evidence records contiguous: PASS (E01-E\([0-9][0-9]*\))$/\1/p')"

    [[ -n "$total" && -n "$review" && -n "$last_id" ]] || {
        echo 'Handoff status source metrics: FAIL' >&2
        return 1
    }
    grep -Fq "all $total PNGs" "$status_file" \
        && grep -Fq "$review review aids" "$status_file" || {
        echo "Project-status selected-evidence totals: FAIL (expected $total files / $review review aids)" >&2
        return 1
    }
    grep -Fq "unique contiguous IDs E01–E$last_id" "$checklist_file" || {
        echo "Screenshot-checklist evidence sequence: FAIL (expected E01–E$last_id)" >&2
        return 1
    }
    grep -Fq "authentic $total-file set" "$checklist_file" || {
        echo "Screenshot-checklist selected-evidence total: FAIL (expected $total files)" >&2
        return 1
    }
    grep -Fq 'preserved baseline' "$mac_runbook_file" \
        && grep -Fq '**not** runtime validation of the current source/archive' "$mac_runbook_file" \
        && grep -Fq 'current source as AppleClang/OpenCV 4.14 verified' "$mac_runbook_file" || {
        echo 'Mac runbook current-source boundary: FAIL' >&2
        return 1
    }
}

echo 'Handoff status consistency audit'
validate "$status_document" "$checklist"
echo 'Project-status selected-evidence totals: PASS'
echo 'Screenshot-checklist evidence sequence: PASS'
echo 'Screenshot-checklist selected-evidence total: PASS'
echo 'Mac runbook current-source boundary: PASS'

fixture_dir="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-handoff-status.XXXXXX")"
trap 'rm -rf "$fixture_dir"' EXIT

sed 's/all [0-9][0-9]* PNGs/all 999 PNGs/' "$status_document" > "$fixture_dir/PROJECT_STATUS.md"
if validate "$fixture_dir/PROJECT_STATUS.md" "$checklist" >/dev/null 2>&1; then
    echo 'Stale selected-count negative control: FAIL' >&2
    exit 1
fi
echo 'Stale selected-count negative control: PASS (rejected)'

sed 's/unique contiguous IDs E01–E[0-9][0-9]*/unique contiguous IDs E01–E999/' "$checklist" > "$fixture_dir/SCREENSHOT_CHECKLIST.md"
if validate "$status_document" "$fixture_dir/SCREENSHOT_CHECKLIST.md" >/dev/null 2>&1; then
    echo 'Stale evidence-sequence negative control: FAIL' >&2
    exit 1
fi
echo 'Stale evidence-sequence negative control: PASS (rejected)'

sed 's/authentic [0-9][0-9]*-file set/authentic 999-file set/' "$checklist" > "$fixture_dir/SCREENSHOT_CHECKLIST.md"
if validate "$status_document" "$fixture_dir/SCREENSHOT_CHECKLIST.md" >/dev/null 2>&1; then
    echo 'Stale checklist-count negative control: FAIL' >&2
    exit 1
fi
echo 'Stale checklist-count negative control: PASS (rejected)'

sed 's/\*\*not\*\* runtime validation of the current source\/archive/**is** runtime validation of the current source\/archive/' \
    "$mac_runbook" > "$fixture_dir/MACOS_RUNBOOK.md"
if validate "$status_document" "$checklist" "$fixture_dir/MACOS_RUNBOOK.md" >/dev/null 2>&1; then
    echo 'False current-source Mac claim negative control: FAIL' >&2
    exit 1
fi
echo 'False current-source Mac claim negative control: PASS (rejected)'
echo 'Handoff status consistency audit: PASS (8/8)'
