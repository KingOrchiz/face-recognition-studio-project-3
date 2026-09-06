#!/usr/bin/env bash
set -euo pipefail

script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
archive="${1:-$script_root/dist/face-recognition-studio-project-3.tar.gz}"
workspace_root="${2:-$script_root}"
verify_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-freshness.XXXXXX")"

cleanup() {
    rm -rf "$verify_root"
}
trap cleanup EXIT

if [[ ! -f "$archive" ]]; then
    echo "Release archive not found: $archive" >&2
    exit 1
fi
if [[ ! -d "$workspace_root" ]]; then
    echo "Workspace root not found: $workspace_root" >&2
    exit 1
fi

bash "$script_root/scripts/audit_archive_safety.sh" "$archive" >/dev/null
tar -xzf "$archive" -C "$verify_root"
package_root="$verify_root/face-recognition-studio-project-3"

python3 - "$package_root" "$workspace_root" <<'PY'
import hashlib
import pathlib
import re
import sys

package_root = pathlib.Path(sys.argv[1])
workspace_root = pathlib.Path(sys.argv[2])
manifest = package_root / "SHA256SUMS"
pattern = re.compile(r"^([0-9A-Fa-f]{64}) ([ *])(.+)$")

checked = 0
for line_number, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
    match = pattern.fullmatch(line)
    if not match:
        print(f"Workspace/package freshness: FAIL (invalid manifest line {line_number})", file=sys.stderr)
        raise SystemExit(1)

    relative = match.group(3)
    if relative.startswith("./"):
        relative = relative[2:]
    path = pathlib.PurePosixPath(relative)
    if relative.startswith("/") or "\\" in relative or any(
        part in ("", ".", "..") for part in path.parts
    ):
        print(f"Workspace/package freshness: FAIL (unsafe manifest line {line_number})", file=sys.stderr)
        raise SystemExit(1)

    workspace_file = workspace_root.joinpath(*path.parts)
    if workspace_file.is_symlink() or not workspace_file.is_file():
        print(f"Workspace/package freshness: FAIL ({relative} missing or not regular)", file=sys.stderr)
        raise SystemExit(1)

    digest = hashlib.sha256(workspace_file.read_bytes()).hexdigest()
    if digest.lower() != match.group(1).lower():
        print(f"Workspace/package freshness: FAIL ({relative} differs)", file=sys.stderr)
        raise SystemExit(1)
    checked += 1

print(f"Workspace/package freshness: PASS ({checked} packaged files match current workspace)")
PY
