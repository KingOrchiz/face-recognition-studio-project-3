#!/usr/bin/env bash
set -euo pipefail

archive="${1:?Usage: audit_archive_safety.sh ARCHIVE [EXPECTED_ROOT]}"
expected_root="${2:-face-recognition-studio-project-3}"

if [[ ! -f "$archive" ]]; then
    echo "Release archive not found: $archive" >&2
    exit 1
fi

python3 - "$archive" "$expected_root" <<'PY'
import pathlib
import sys
import tarfile

archive = pathlib.Path(sys.argv[1])
expected_root = sys.argv[2]
max_members = 1_000
max_unpacked_bytes = 512 * 1024 * 1024

print("Pre-extraction archive-safety audit")

try:
    with tarfile.open(archive, mode="r:gz") as bundle:
        members = bundle.getmembers()
except (OSError, tarfile.TarError) as exc:
    print(f"Readable gzip/tar structure: FAIL ({type(exc).__name__})", file=sys.stderr)
    raise SystemExit(1)

if not members or len(members) > max_members:
    print(f"Bounded member count: FAIL ({len(members)})", file=sys.stderr)
    raise SystemExit(1)

seen = set()
unpacked_bytes = 0
regular_file_count = 0
directory_count = 0
for member in members:
    name = member.name
    path = pathlib.PurePosixPath(name)
    parts = path.parts

    if (
        not name
        or name.startswith("/")
        or "\\" in name
        or any(part in ("", ".", "..") for part in parts)
        or not parts
        or parts[0] != expected_root
    ):
        print("Safe relative member paths under expected root: FAIL", file=sys.stderr)
        raise SystemExit(1)

    normalized = str(path)
    if normalized in seen:
        print("Unique archive member paths: FAIL", file=sys.stderr)
        raise SystemExit(1)
    seen.add(normalized)

    if not (member.isfile() or member.isdir()):
        print("Regular files/directories only: FAIL", file=sys.stderr)
        raise SystemExit(1)

    # Fail before extraction if an archive could create a group/world-writable
    # path, carry special permission bits, or unexpectedly mark data as
    # executable. The release contract intentionally permits only ordinary
    # read-only data (0644), directly runnable scripts (0755), and traversable
    # directories (0755).
    permission_bits = member.mode & 0o7777
    if member.isdir():
        directory_count += 1
        expected_modes = {0o755}
    else:
        regular_file_count += 1
        # Executability is path-specific, not merely an allowed mode. Every
        # packaged scripts/*.sh entry must be directly runnable; models,
        # documentation, evidence, source, and other data must not be marked
        # executable.
        is_shell_script = (
            len(parts) == 3
            and parts[1] == "scripts"
            and parts[2].endswith(".sh")
        )
        expected_modes = {0o755} if is_shell_script else {0o644}
    if permission_bits not in expected_modes:
        print(
            "Safe archive permission roles: FAIL "
            f"({name} mode={permission_bits:04o} "
            f"expected={next(iter(expected_modes)):04o})",
            file=sys.stderr,
        )
        raise SystemExit(1)

    if member.isfile():
        unpacked_bytes += member.size
        if unpacked_bytes > max_unpacked_bytes:
            print("Bounded unpacked size: FAIL", file=sys.stderr)
            raise SystemExit(1)

print(f"Readable gzip/tar structure: PASS")
print(f"Safe relative member paths under expected root: PASS")
print(f"Unique archive member paths: PASS")
print(f"Regular files/directories only: PASS")
print(
    "Safe archive permission roles: PASS "
    f"({regular_file_count} files, {directory_count} directories)"
)
print(f"Bounded member count: PASS ({len(members)}/{max_members})")
print(f"Bounded unpacked size: PASS ({unpacked_bytes}/{max_unpacked_bytes} bytes)")
print("Pre-extraction archive-safety audit: PASS")
PY
