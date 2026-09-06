#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
report="$project_root/docs/FINAL_LAB_REPORT_DRAFT.md"

validate() {
    local document="$1"
    [[ -f "$document" ]] || {
        echo "Final lab-report draft: FAIL (missing)" >&2
        return 1
    }

    local section_count
    section_count="$(grep -Ec '^## ([1-9]|1[01])\. ' "$document")"
    [[ "$section_count" == 11 ]] || {
        echo "Final lab-report section set: FAIL (count=$section_count)" >&2
        return 1
    }

    local section
    for section in \
        '## 1. Project overview' \
        '## 2. Team composition and matching' \
        '## 3. Feature plan and estimated-versus-actual effort' \
        '## 4. Workload and team process' \
        '## 5. Implementation and programming concepts' \
        '## 6. Testing, results, and limitations' \
        '## 7. AI Assessment Scale disclosure' \
        '## 8. Team evaluation' \
        '## 9. GitHub evidence' \
        '## 10. Yellowdig chronological learning log' \
        '## 11. Personal reflection'; do
        grep -Fqx "$section" "$document" || {
            echo "Final lab-report required section: FAIL ($section)" >&2
            return 1
        }
    done

    grep -Fq 'Team name: `PENDING`' "$document" \
        && grep -Fq 'Student ID(s): `PENDING`' "$document" \
        && grep -Fq 'Repository URL: `PENDING' "$document" \
        && grep -Fq 'AIAS level(s), learning effect, and no-AI time comparison: `PENDING' "$document" \
        && grep -Fq '`PENDING — Oche writes this in his own voice.`' "$document" || {
        echo "Operator-owned placeholder boundary: FAIL" >&2
        return 1
    }

    grep -Fq 'The webcam path remains untested because explicit camera-test confirmation has' "$document" \
        && grep -Fq '| Camera mode | Run only after explicit consent and privacy preparation | `PENDING` | `PENDING` | **Blocked; safeguard evidence only** |' "$document" \
        && grep -Fq 'webcam operation remains untested;' "$document" || {
        echo "Camera truth boundary: FAIL" >&2
        return 1
    }

    grep -Fq 'Current publication evidence: **0/7 actual post captures**.' "$document" \
        && grep -Fq 'Draft screenshots' "$document" \
        && grep -Fq 'Do not publish a repository or infer contribution history' "$document" || {
        echo "External-evidence truth boundary: FAIL" >&2
        return 1
    }

    local previous=0 current heading
    for heading in Evidence Milestone Lesson 'Next step'; do
        current="$(grep -nF -- "- **$heading:**" "$document" | cut -d: -f1)"
        [[ "$current" =~ ^[0-9]+$ && "$current" -gt "$previous" ]] || {
            echo "Yellowdig narrative order: FAIL ($heading)" >&2
            return 1
        }
        previous="$current"
    done

    grep -Fq '## Final assembly gate' "$document" \
        && grep -Fq 'final public GitHub URL plus the three required Insights screenshots;' "$document" \
        && grep -Fq 'final PDF inspected page by page after rendering.' "$document" || {
        echo "Final assembly gate: FAIL" >&2
        return 1
    }
}

echo 'Final lab-report working-draft contract audit'
validate "$report"
echo 'Exact 11-section template mapping: PASS'
echo 'Operator-owned placeholders: PASS'
echo 'Camera truth boundary: PASS (untested; explicit confirmation still required)'
echo 'External publication/GitHub boundary: PASS (0/7 post captures)'
echo 'Evidence -> Milestone -> Lesson -> Next step order: PASS'
echo 'Final assembly gate: PASS'

fixture_dir="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-report.XXXXXX")"
trap 'rm -rf "$fixture_dir"' EXIT

missing_section="$fixture_dir/missing-section.md"
sed '/^## 8\. Team evaluation$/d' "$report" > "$missing_section"
if validate "$missing_section" >/dev/null 2>&1; then
    echo 'Missing-section negative control: FAIL' >&2
    exit 1
fi
echo 'Missing-section negative control: PASS (rejected)'

false_publication="$fixture_dir/false-publication.md"
sed 's/Current publication evidence: \*\*0\/7 actual post captures\*\*\./Current publication evidence: **7\/7 actual post captures**./' \
    "$report" > "$false_publication"
if validate "$false_publication" >/dev/null 2>&1; then
    echo 'False-publication negative control: FAIL' >&2
    exit 1
fi
echo 'False-publication negative control: PASS (rejected)'

false_camera="$fixture_dir/false-camera.md"
sed 's/The webcam path remains untested because explicit camera-test confirmation has/The webcam path was tested even though explicit camera-test confirmation has/' \
    "$report" > "$false_camera"
if validate "$false_camera" >/dev/null 2>&1; then
    echo 'False-camera-result negative control: FAIL' >&2
    exit 1
fi
echo 'False-camera-result negative control: PASS (rejected)'
echo 'Final lab-report working-draft contract: PASS (6/6 gates; 3/3 mutations rejected)'
