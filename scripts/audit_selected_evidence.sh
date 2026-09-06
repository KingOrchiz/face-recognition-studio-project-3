#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
selected_dir="${1:-$project_root/evidence/selected}"
expected_png_signature="89 50 4e 47 0d 0a 1a 0a"
expected_png_iend="00 00 00 00 49 45 4e 44 ae 42 60 82"
minimum_width=1000
minimum_height=600
count=0
failures=0

echo "Selected-evidence integrity audit"

if [[ ! -d "$selected_dir" ]]; then
    echo "Selected evidence directory not found: $selected_dir" >&2
    exit 1
fi

while IFS= read -r -d '' screenshot; do
    count=$((count + 1))
    relative="${screenshot#"$project_root/"}"
    signature="$(od -An -tx1 -N8 "$screenshot" | tr -s ' ' | sed 's/^ //')"
    iend="$(tail -c 12 "$screenshot" | od -An -tx1 | tr -s ' ' | sed 's/^ //')"
    read -r -a dimensions <<<"$(od -An -tx1 -j16 -N8 "$screenshot")"
    bytes="$(wc -c < "$screenshot" | tr -d ' ')"

    status="PASS"
    width=0
    height=0
    if (( ${#dimensions[@]} == 8 )); then
        width=$((16#${dimensions[0]} * 16777216 + 16#${dimensions[1]} * 65536 + 16#${dimensions[2]} * 256 + 16#${dimensions[3]}))
        height=$((16#${dimensions[4]} * 16777216 + 16#${dimensions[5]} * 65536 + 16#${dimensions[6]} * 256 + 16#${dimensions[7]}))
    fi

    if [[ "$signature" != "$expected_png_signature" ]] \
        || [[ "$iend" != "$expected_png_iend" ]] \
        || (( bytes < 1024 || width < minimum_width || height < minimum_height )); then
        status="FAIL"
        failures=$((failures + 1))
    fi
    printf '%-58s %s  (%sx%s, %s bytes)\n' \
        "$relative" "$status" "$width" "$height" "$bytes"
done < <(find "$selected_dir" -maxdepth 1 -type f -name '*.png' -print0)

if (( count == 0 )); then
    echo "No selected PNG evidence files found" >&2
    exit 1
fi

printf '\nSelected PNG files checked: %d\n' "$count"
if (( failures > 0 )); then
    printf 'Evidence integrity result: FAIL (%d issue(s))\n' "$failures" >&2
    exit 1
fi

printf 'Required minimum dimensions: %sx%s\n' "$minimum_width" "$minimum_height"
echo "PNG signature, dimensions, and terminal IEND checks: PASS"
echo "Evidence integrity result: PASS"
