#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
audit="$project_root/scripts/audit_selected_png_privacy.sh"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-png-privacy.XXXXXX")"
trap 'rm -rf "$fixture_root"' EXIT

source_png="$project_root/evidence/selected/post-01-project-tree-readme.png"
python3 - "$source_png" "$fixture_root" <<'PY'
import pathlib, struct, sys, zlib
src = pathlib.Path(sys.argv[1]).read_bytes()
root = pathlib.Path(sys.argv[2])
iend = src.rfind(b"\x00\x00\x00\x00IEND")
if iend < 0:
    raise SystemExit("source fixture has no IEND")
payload = b"Comment\x00private-review-note"
chunk = struct.pack(">I", len(payload)) + b"tEXt" + payload
chunk += struct.pack(">I", zlib.crc32(b"tEXt" + payload) & 0xffffffff)
(root / "text-metadata.png").write_bytes(src[:iend] + chunk + src[iend:])
bad_crc = bytearray(src)
bad_crc[-1] ^= 1
(root / "bad-crc.png").write_bytes(bad_crc)
(root / "trailing-payload.png").write_bytes(src + b"hidden")
PY

echo "Selected PNG privacy contract audit"
for name in text-metadata bad-crc trailing-payload; do
    case_dir="$fixture_root/$name"
    mkdir "$case_dir"
    cp "$fixture_root/$name.png" "$case_dir/fixture.png"
    if bash "$audit" "$case_dir" >/dev/null 2>&1; then
        echo "$name rejection: FAIL" >&2
        exit 1
    fi
    echo "$name rejection: PASS (status 1)"
done
echo "Selected PNG privacy contract: PASS (3/3 fail-closed cases)"
