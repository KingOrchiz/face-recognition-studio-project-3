#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
selected_dir="${1:-$project_root/evidence/selected}"

python3 - "$selected_dir" <<'PY'
import pathlib
import struct
import sys
import zlib

root = pathlib.Path(sys.argv[1])
files = sorted(root.glob("*.png")) if root.is_dir() else []
if not files:
    print(f"Selected PNG metadata audit: FAIL (no PNG files in {root})", file=sys.stderr)
    raise SystemExit(1)

allowed = {b"IHDR", b"IDAT", b"IEND"}
for path in files:
    data = path.read_bytes()
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        print(f"Selected PNG metadata audit: FAIL ({path.name}: signature)", file=sys.stderr)
        raise SystemExit(1)
    offset = 8
    chunks = []
    while offset + 12 <= len(data):
        length = struct.unpack(">I", data[offset:offset + 4])[0]
        end = offset + 12 + length
        if end > len(data):
            print(f"Selected PNG metadata audit: FAIL ({path.name}: truncated chunk)", file=sys.stderr)
            raise SystemExit(1)
        kind = data[offset + 4:offset + 8]
        payload = data[offset + 8:offset + 8 + length]
        expected_crc = struct.unpack(">I", data[offset + 8 + length:end])[0]
        actual_crc = zlib.crc32(kind + payload) & 0xffffffff
        if expected_crc != actual_crc:
            print(f"Selected PNG metadata audit: FAIL ({path.name}: {kind.decode('latin1')} CRC)", file=sys.stderr)
            raise SystemExit(1)
        if kind not in allowed:
            print(f"Selected PNG metadata audit: FAIL ({path.name}: forbidden {kind.decode('latin1')} metadata)", file=sys.stderr)
            raise SystemExit(1)
        chunks.append(kind)
        offset = end
        if kind == b"IEND":
            break
    if not chunks or chunks[0] != b"IHDR" or chunks[-1] != b"IEND" or b"IDAT" not in chunks:
        print(f"Selected PNG metadata audit: FAIL ({path.name}: invalid chunk order)", file=sys.stderr)
        raise SystemExit(1)
    first_idat = chunks.index(b"IDAT")
    last_idat = len(chunks) - 1 - chunks[::-1].index(b"IDAT")
    if any(kind != b"IDAT" for kind in chunks[first_idat:last_idat + 1]) or offset != len(data):
        print(f"Selected PNG metadata audit: FAIL ({path.name}: split image data or trailing payload)", file=sys.stderr)
        raise SystemExit(1)

print(f"Selected PNG metadata audit: PASS ({len(files)}/{len(files)})")
print("Allowed chunks only: IHDR, contiguous IDAT, terminal IEND")
print("Chunk CRCs and zero trailing payload: PASS")
print("Embedded text, EXIF, time, profile, and other ancillary metadata: NONE")
PY
