#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
posts_1_3="$project_root/docs/YELLOWDIG_POSTS_1_TO_3.md"
posts_4_7="$project_root/docs/YELLOWDIG_POSTS_4_TO_7.md"
mac_record="$project_root/docs/MACOS_ENVIRONMENT_TROUBLESHOOTING.md"
mac_runbook="$project_root/docs/MACOS_RUNBOOK.md"
dataset_record="$project_root/tests/SYNTHETIC_DATASET_PROVENANCE.md"
source_file="$project_root/src/main.cpp"
cmake_file="$project_root/CMakeLists.txt"

failures=0

require_literal() {
    local label="$1"
    local file="$2"
    local literal="$3"
    if grep -Fq -- "$literal" "$file"; then
        printf '%-58s PASS\n' "$label"
    else
        printf '%-58s FAIL\n' "$label" >&2
        failures=$((failures + 1))
    fi
}

forbid_literal() {
    local label="$1"
    local file="$2"
    local literal="$3"
    if grep -Fq -- "$literal" "$file"; then
        printf '%-58s FAIL\n' "$label" >&2
        failures=$((failures + 1))
    else
        printf '%-58s PASS\n' "$label"
    fi
}

printf 'Yellowdig evidence-claim traceability audit\n\n'

require_literal 'Post 1 draft: C++17/OpenCV project identity' "$posts_1_3" \
    'Face Recognition Studio in C++17 with OpenCV'
require_literal 'Post 2 draft: one-face still-image result' "$posts_1_3" \
    'Detected 1 face(s)'
require_literal 'Post 3 source: Homebrew OpenCV version' "$mac_record" \
    'OpenCV 4.14.0'
require_literal 'Post 3 source: Mac nine-test result' "$mac_record" \
    '100% tests passed, 0 tests failed out of 9'
require_literal 'Post 3 draft: Mac test time' "$posts_1_3" \
    '9/9 automated tests passed in 2.08 seconds'
require_literal 'Post 3 runbook: verified Mac baseline' "$mac_runbook" \
    'passed all 9/9 CTests in 2.08'
forbid_literal 'Post 3 runbook: stale no-build claim absent' "$mac_runbook" \
    'no Mac installation, shell command, checkout, build, test, or screenshot was attempted'
require_literal 'Post 4 draft: 30-frame processing result' "$posts_4_7" \
    'processed all 30 frames'
require_literal 'Post 4 draft: retained 640x640 / 10 fps / 3.0 s' "$posts_4_7" \
    '640×640, 10 fps input'
require_literal 'Post 5 source: consent-specific refusal' "$source_file" \
    'Camera access blocked: obtain participant consent, then pass --confirm-camera'
require_literal 'Post 5 draft: hardware test still blocked' "$posts_4_7" \
    'camera device was opened.'
require_literal 'Post 6 source: known-query score 0.934496' "$dataset_record" \
    '| Synthetic_A identity-preserving variant | 0.934496 | 0.400 | Synthetic_A |'
require_literal 'Post 6 source: unknown-query score 0.391773' "$dataset_record" \
    '| Different synthetic subject | 0.391773 | 0.400 | Unknown |'
require_literal 'Post 6 source: 0.363 false-accept retained' "$dataset_record" \
    '| Different synthetic subject | 0.391773 | 0.363 | Synthetic_A — false accept in this test |'

test_count="$(grep -Ec '^[[:space:]]*add_test\(' "$cmake_file")"
if [[ "$test_count" == 9 ]]; then
    printf '%-58s PASS\n' 'Post 7 source: exactly nine registered CTests'
else
    printf '%-58s FAIL (found %s)\n' 'Post 7 source: exactly nine registered CTests' "$test_count" >&2
    failures=$((failures + 1))
fi
require_literal 'Post 7 draft: Linux and Mac nine-test claim' "$posts_4_7" \
    'passed 9/9 checks with zero failures on Linux'
require_literal 'Post 7 draft: camera limitation retained' "$posts_4_7" \
    'claim that the separately gated camera path has been exercised.'

printf '\nCamera accessed by audit: NO\n'
printf 'External publication by audit: NO\n'

if (( failures > 0 )); then
    printf 'Traceability audit: FAIL (%d issue(s))\n' "$failures" >&2
    exit 1
fi

printf 'Traceability audit: PASS (17/17 claim checks)\n'
