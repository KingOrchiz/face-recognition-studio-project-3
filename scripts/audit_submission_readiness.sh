#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
readiness="$project_root/docs/SUBMISSION_READINESS.md"

validate() {
    local document="$1"
    [[ -f "$document" ]] || {
        echo "Submission-readiness document: FAIL (missing)" >&2
        return 1
    }

    local rows
    rows="$(grep -Ec '^\| (C\+\+17/OpenCV source|Linux build and regression|Apple-silicon build and regression|Still-image milestone|Synthetic-video milestone|Recognition milestone|Camera milestone|Seven Yellowdig drafts|Published-post evidence|Release handoff|Final lab-report assembly) \|' "$document")"
    [[ "$rows" == 11 ]] || {
        echo "Submission-readiness row set: FAIL (count=$rows)" >&2
        return 1
    }

    grep -Fq '| C++17/OpenCV source | Ready |' "$document" \
        && grep -Fq '| Linux build and regression | Ready |' "$document" \
        && grep -Fq '| Apple-silicon build and regression | Baseline verified; current-source refresh pending |' "$document" \
        && grep -Fq '| Camera milestone | Blocked |' "$document" \
        && grep -Fq '| Published-post evidence | Pending external action |' "$document" \
        && grep -Fq '| Final lab-report assembly | Working draft ready; external evidence pending |' "$document" \
        && grep -Fq '| Release handoff | Ready |' "$document" || {
        echo "Submission-readiness state contract: FAIL" >&2
        return 1
    }

    if grep -Eq '^\| Camera milestone \| (Ready|Complete)' "$document"; then
        echo "Camera truth boundary: FAIL" >&2
        return 1
    fi
    grep -Fq "Oche must explicitly confirm the camera test at test time" "$document" \
        && grep -Fq "Jane does not publish" "$document" \
        && grep -Fq '`docs/FINAL_LAB_REPORT_DRAFT.md`' "$document" \
        && grep -Fq 'do not describe that rerun as complete until its new log exists' "$document" \
        && grep -Fq "The camera remains untouched" "$document" || {
        echo "Owner/action boundary: FAIL" >&2
        return 1
    }

    local previous=0 current heading
    for heading in Evidence Milestone Lesson 'Next step'; do
        current="$(grep -nF -- "- **$heading:**" "$document" | cut -d: -f1)"
        [[ "$current" =~ ^[0-9]+$ && "$current" -gt "$previous" ]] || {
            echo "Evidence narrative order: FAIL ($heading)" >&2
            return 1
        }
        previous="$current"
    done
}

echo 'Submission-readiness semantic contract audit'
validate "$readiness"
echo 'Exact 11-row handoff matrix: PASS'
echo 'Ready/Pending/Blocked state contract: PASS'
echo 'Camera and publication owner boundaries: PASS'
echo 'Mac baseline/current-source boundary: PASS'
echo 'Evidence -> Milestone -> Lesson -> Next step order: PASS'

fixture_dir="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-readiness.XXXXXX")"
trap 'rm -rf "$fixture_dir"' EXIT
mutated="$fixture_dir/SUBMISSION_READINESS.md"
sed 's/| Camera milestone | Blocked |/| Camera milestone | Ready |/' "$readiness" > "$mutated"
if validate "$mutated" >/dev/null 2>&1; then
    echo 'False camera-ready negative control: FAIL' >&2
    exit 1
fi
echo 'False camera-ready negative control: PASS (rejected)'

sed 's/| Apple-silicon build and regression | Baseline verified; current-source refresh pending |/| Apple-silicon build and regression | Ready |/' "$readiness" > "$mutated"
if validate "$mutated" >/dev/null 2>&1; then
    echo 'False current-source Mac-ready negative control: FAIL' >&2
    exit 1
fi
echo 'False current-source Mac-ready negative control: PASS (rejected)'
echo 'Submission-readiness semantic contract: PASS (6/6)'
