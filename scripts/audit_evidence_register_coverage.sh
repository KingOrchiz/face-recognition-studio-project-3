#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
register="${2:-$project_root/evidence/EVIDENCE_REGISTER.md}"
selected_dir="$project_root/evidence/selected"

if [[ ! -d "$selected_dir" ]]; then
    echo "Selected evidence directory not found" >&2
    exit 1
fi
if [[ ! -f "$register" ]]; then
    echo "Evidence register not found" >&2
    exit 1
fi

actual="$(find "$selected_dir" -maxdepth 1 -type f -name '*.png' \
    -exec basename {} \; | sed 's#^#evidence/selected/#' | LC_ALL=C sort)"
indexed="$(grep -Eo 'evidence/selected/[A-Za-z0-9._-]+\.png' "$register" \
    | LC_ALL=C sort -u || true)"

echo 'Evidence-register selected-screenshot coverage audit'

python3 - "$register" <<'PY'
import pathlib
import re
import sys

register = pathlib.Path(sys.argv[1])
rows = []
for line_number, line in enumerate(register.read_text(encoding="utf-8").splitlines(), 1):
    match = re.match(r"^\| E([0-9]{2,}) \|", line)
    if match:
        rows.append((line_number, int(match.group(1)), match.group(1)))

if not rows:
    print("Evidence-record sequence: FAIL (no E-record rows)", file=sys.stderr)
    raise SystemExit(1)

expected = list(range(1, len(rows) + 1))
actual = [number for _, number, _ in rows]
if actual != expected:
    print("Evidence-record sequence: FAIL", file=sys.stderr)
    for position, (line_number, number, label) in enumerate(rows, 1):
        if number != position:
            print(
                f"First mismatch: line {line_number} has E{label}; expected E{position:02d}",
                file=sys.stderr,
            )
            break
    raise SystemExit(1)

labels = [label for _, _, label in rows]
if len(labels) != len(set(labels)):
    print("Evidence-record uniqueness: FAIL", file=sys.stderr)
    raise SystemExit(1)

print(f"Evidence records contiguous: PASS (E01-E{actual[-1]:02d})")
print(f"Evidence record IDs unique: PASS ({len(rows)})")
PY

if ! diff -u <(printf '%s\n' "$actual") <(printf '%s\n' "$indexed"); then
    echo 'Exact selected-screenshot coverage: FAIL' >&2
    exit 1
fi

count="$(printf '%s\n' "$actual" | sed '/^$/d' | wc -l | tr -d ' ')"
printf 'Selected screenshots present: %s\n' "$count"
printf 'Unique selected screenshots indexed: %s\n' "$count"
echo 'Missing selected references: 0'
echo 'Stale selected references: 0'
echo 'Exact selected-screenshot coverage: PASS'
