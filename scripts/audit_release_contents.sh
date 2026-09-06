#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
release_root="${1:-$project_root}"
manifest="$release_root/SHA256SUMS"

if [[ ! -d "$release_root" ]]; then
    echo "Release root not found: $release_root" >&2
    exit 1
fi

if [[ ! -f "$manifest" ]]; then
    echo "Release manifest not found: $manifest" >&2
    exit 1
fi

expected="$(mktemp "${TMPDIR:-/tmp}/face-studio-expected.XXXXXX")"
actual="$(mktemp "${TMPDIR:-/tmp}/face-studio-actual.XXXXXX")"
cleanup() {
    rm -f "$expected" "$actual"
}
trap cleanup EXIT

echo "Release-content boundary audit"

# Validate the manifest before any caller passes it to `sha256sum --check`.
# This prevents absolute or parent-traversal entries from making validation read
# files outside the extracted release tree.
python3 - "$manifest" "$expected" <<'PY'
import pathlib
import re
import sys

manifest = pathlib.Path(sys.argv[1])
expected = pathlib.Path(sys.argv[2])
line_pattern = re.compile(r"^([0-9A-Fa-f]{64}) ([ *])(.+)$")
names = []

for line_number, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
    match = line_pattern.fullmatch(line)
    if not match:
        print(f"Safe manifest syntax and paths: FAIL (line {line_number})", file=sys.stderr)
        raise SystemExit(1)

    name = match.group(3)
    if name.startswith("./"):
        name = name[2:]
    path = pathlib.PurePosixPath(name)
    if (
        not name
        or name.startswith("/")
        or "\\" in name
        or any(part in ("", ".", "..") for part in path.parts)
        or str(path) == "SHA256SUMS"
    ):
        print(f"Safe manifest syntax and paths: FAIL (line {line_number})", file=sys.stderr)
        raise SystemExit(1)
    names.append(str(path))

if not names:
    print("Safe manifest syntax and paths: FAIL (empty manifest)", file=sys.stderr)
    raise SystemExit(1)
if len(names) != len(set(names)):
    print("Unique manifest paths: FAIL", file=sys.stderr)
    raise SystemExit(1)

expected.write_text("".join(f"{name}\n" for name in sorted(names)), encoding="utf-8")
print(f"Safe manifest syntax and paths: PASS ({len(names)} entries)")
print("Unique manifest paths: PASS")
PY
(
    cd "$release_root"
    find . -type f ! -name SHA256SUMS -print \
        | sed 's#^\./##' \
        | LC_ALL=C sort -u
) > "$actual"

if ! diff -u "$expected" "$actual" >/dev/null; then
    echo "Manifest/file-set mismatch:" >&2
    diff -u "$expected" "$actual" >&2 || true
    exit 1
fi
echo "Manifest covers exact regular-file set: PASS ($(wc -l < "$actual" | tr -d ' ') files)"

symlink_count="$(find "$release_root" -type l | wc -l | tr -d ' ')"
if (( symlink_count != 0 )); then
    echo "Unexpected symbolic links: $symlink_count" >&2
    find "$release_root" -type l -print >&2
    exit 1
fi
echo "Symbolic links absent: PASS"

for forbidden in build build-opencv-compat output raw .git; do
    if find "$release_root" -mindepth 1 -type d -name "$forbidden" -print -quit | grep -q .; then
        echo "Forbidden generated/private directory present: $forbidden" >&2
        exit 1
    fi
done

# The exact publication-evidence intake directory is an intentional empty
# release scaffold. A same-named directory anywhere else still fails closed.
allowed_published_dir="$release_root/evidence/yellowdig-published"
while IFS= read -r published_dir; do
    if [[ "$published_dir" != "$allowed_published_dir" ]]; then
        echo "Forbidden generated/private directory present: yellowdig-published" >&2
        exit 1
    fi
done < <(find "$release_root" -mindepth 1 -type d -name yellowdig-published -print)
echo "Generated/private directories absent: PASS"

credential_pattern='(^|/)(\.env($|\.)|.*credentials?.*|.*secrets?.*|id_rsa($|\.)|.*\.pem$|.*\.p12$|.*\.key$)'
if grep -Eiq "$credential_pattern" "$actual"; then
    echo "Credential-like filename found in release:" >&2
    grep -Ei "$credential_pattern" "$actual" >&2
    exit 1
fi
echo "Credential-like filenames absent: PASS"
bash "$release_root/scripts/audit_release_privacy.sh" "$release_root"
echo "Release-content boundary audit: PASS"
