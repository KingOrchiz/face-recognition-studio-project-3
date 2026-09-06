#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
capture_dir="${2:-$project_root/evidence/yellowdig-published}"

python3 - "$capture_dir" <<'PY'
import datetime
import pathlib
import re
import struct
import sys

capture_dir = pathlib.Path(sys.argv[1])
name_pattern = re.compile(r"^post-0([1-7])-(\d{4}-\d{2}-\d{2})\.png$")
png_signature = b"\x89PNG\r\n\x1a\n"
png_iend = b"\x00\x00\x00\x00IEND\xaeB`\x82"

print("Yellowdig published-post evidence intake audit")
if not capture_dir.is_dir():
    print("Capture directory: FAIL (missing)", file=sys.stderr)
    raise SystemExit(1)

captures = []
for entry in sorted(capture_dir.iterdir(), key=lambda path: path.name):
    if entry.name == ".gitkeep":
        if entry.is_symlink() or not entry.is_file():
            print("Placeholder: FAIL", file=sys.stderr)
            raise SystemExit(1)
        continue
    if entry.is_symlink() or not entry.is_file():
        print(f"Regular-file boundary: FAIL ({entry.name})", file=sys.stderr)
        raise SystemExit(1)
    match = name_pattern.fullmatch(entry.name)
    if not match:
        print(f"Filename contract: FAIL ({entry.name})", file=sys.stderr)
        raise SystemExit(1)

    post = int(match.group(1))
    try:
        capture_date = datetime.date.fromisoformat(match.group(2))
    except ValueError:
        print(f"Calendar date: FAIL ({entry.name})", file=sys.stderr)
        raise SystemExit(1)

    data = entry.read_bytes()
    if len(data) < 33 or data[:8] != png_signature or data[-12:] != png_iend:
        print(f"PNG structure: FAIL ({entry.name})", file=sys.stderr)
        raise SystemExit(1)
    if data[12:16] != b"IHDR":
        print(f"PNG IHDR: FAIL ({entry.name})", file=sys.stderr)
        raise SystemExit(1)
    width, height = struct.unpack(">II", data[16:24])
    if width < 1000 or height < 600:
        print(f"PNG dimensions: FAIL ({entry.name}, {width}x{height})", file=sys.stderr)
        raise SystemExit(1)
    captures.append((post, capture_date, entry.name, width, height))

posts = [item[0] for item in captures]
if len(posts) != len(set(posts)):
    print("One capture per post: FAIL (duplicate post number)", file=sys.stderr)
    raise SystemExit(1)
expected = list(range(1, max(posts, default=0) + 1))
if posts != expected:
    print(f"Contiguous publication sequence: FAIL (found={posts}, expected={expected})", file=sys.stderr)
    raise SystemExit(1)
dates = [item[1] for item in captures]
if dates != sorted(dates):
    print("Nondecreasing publication dates: FAIL", file=sys.stderr)
    raise SystemExit(1)

for post, capture_date, name, width, height in captures:
    print(f"Post {post}: PASS ({capture_date.isoformat()}, {width}x{height}, {name})")
print("Filename/date/regular-file/PNG contract: PASS")
print("Contiguous publication sequence: PASS")
print(f"Published captures accepted: {len(captures)}/7")
if not captures:
    print("Current state: PENDING EXTERNAL ACTION (no publication claim inferred)")
else:
    print("Manual content/privacy review and evidence-register indexing remain required")
PY
