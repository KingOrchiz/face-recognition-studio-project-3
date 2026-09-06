#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
executable="${2:-$project_root/build/face_studio}"

if [[ ! -x "$executable" ]]; then
    echo "CLI numeric validation audit: FAIL (executable missing: $executable)" >&2
    exit 1
fi

run_rejection() {
    local name="$1"
    local expected="$2"
    shift 2
    local log
    log="$(mktemp "${TMPDIR:-/tmp}/face-studio-cli-numeric.XXXXXX")"
    set +e
    "$executable" "$@" >"$log" 2>&1
    local status=$?
    set -e
    if [[ "$status" -ne 2 ]] || ! grep -Fq -- "$expected" "$log"; then
        echo "$name: FAIL (status=$status)" >&2
        cat "$log" >&2
        rm -f "$log"
        exit 1
    fi
    if grep -Fq 'Loaded ' "$log" || grep -Fq 'Cannot open camera source' "$log"; then
        echo "$name: FAIL (rejection occurred after engine/device work)" >&2
        cat "$log" >&2
        rm -f "$log"
        exit 1
    fi
    rm -f "$log"
    echo "$name: PASS (status 2 before engine/device work)"
}

echo "CLI numeric validation audit (camera-free)"
run_rejection "Threshold trailing-text rejection" \
    "--threshold requires a number without trailing characters: 0.400junk" \
    --mode image --input unused.png --threshold 0.400junk
run_rejection "Threshold non-number rejection" \
    "--threshold requires a number: not-a-number" \
    --mode image --input unused.png --threshold not-a-number
run_rejection "Threshold NaN rejection" \
    "--threshold must be a finite value from -1 to 1" \
    --mode image --input unused.png --threshold nan
run_rejection "Threshold infinity rejection" \
    "--threshold must be a finite value from -1 to 1" \
    --mode image --input unused.png --threshold inf
run_rejection "Camera-index trailing-text rejection" \
    "--input requires a non-negative camera index: 0junk" \
    --mode camera --confirm-camera --input 0junk
run_rejection "Camera-index negative rejection" \
    "--input requires a non-negative camera index: -1" \
    --mode camera --confirm-camera --input -1
run_rejection "Camera-index overflow rejection" \
    "--input requires a non-negative camera index: 2147483648" \
    --mode camera --confirm-camera --input 2147483648

echo "Camera opened: NO"
echo "CLI numeric validation contract: PASS (7/7)"
