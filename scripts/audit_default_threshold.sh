#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
executable="${2:-$project_root/build/face_studio}"

if [[ ! -x "$executable" ]]; then
    echo "Default-threshold audit: FAIL (executable missing: $executable)" >&2
    exit 1
fi

audit_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-default-threshold.XXXXXX")"
cleanup() {
    rm -rf "$audit_root"
}
trap cleanup EXIT

run_case() {
    local name="$1"
    local input="$2"
    local expected_label="$3"
    local log="$audit_root/$name.log"
    local output="$audit_root/$name.png"

    (
        cd "$project_root"
        "$executable" \
            --mode image \
            --input "$input" \
            --known tests/known \
            --output "$output"
    ) >"$log" 2>&1

    if ! grep -Fq "Face 1: label=$expected_label" "$log" \
        || ! grep -Fq 'threshold=0.400000' "$log" \
        || grep -Fq 'using Haar detection fallback' "$log" \
        || [[ ! -s "$output" ]]; then
        echo "$name: FAIL" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    echo "$name: PASS (label=$expected_label; default threshold=0.400000)"
}

echo "Default-threshold audit (camera-free; --threshold omitted)"
run_case known-default tests/synthetic_portrait_a_variant_640.png Synthetic_A
run_case unknown-default tests/synthetic_portrait_b_unknown_640.png Unknown
echo "Camera accessed: NO"
echo "Default-threshold contract: PASS (2/2)"
