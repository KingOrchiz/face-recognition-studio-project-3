#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
auditor="$project_root/scripts/audit_published_post_intake.sh"
source_png="$project_root/evidence/selected/post-01-project-tree-readme.png"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-published-intake.XXXXXX")"
trap 'rm -rf "$fixture_root"' EXIT

make_case() {
    mkdir -p "$fixture_root/$1/evidence/yellowdig-published"
    : > "$fixture_root/$1/evidence/yellowdig-published/.gitkeep"
}

expect_pass() {
    local name="$1"
    if ! bash "$auditor" "$fixture_root/$name" >/dev/null; then
        printf 'Case %s: FAIL (expected acceptance)\n' "$name" >&2
        exit 1
    fi
    printf 'Case %-24s PASS (accepted)\n' "$name"
}

expect_reject() {
    local name="$1"
    if bash "$auditor" "$fixture_root/$name" >/dev/null 2>&1; then
        printf 'Case %s: FAIL (expected rejection)\n' "$name" >&2
        exit 1
    fi
    printf 'Case %-24s PASS (rejected)\n' "$name"
}

echo 'Yellowdig published-post intake contract audit'

make_case empty-pending
expect_pass empty-pending

make_case contiguous-two
cp "$source_png" "$fixture_root/contiguous-two/evidence/yellowdig-published/post-01-2026-09-06.png"
cp "$source_png" "$fixture_root/contiguous-two/evidence/yellowdig-published/post-02-2026-09-07.png"
expect_pass contiguous-two

make_case sequence-gap
cp "$source_png" "$fixture_root/sequence-gap/evidence/yellowdig-published/post-01-2026-09-06.png"
cp "$source_png" "$fixture_root/sequence-gap/evidence/yellowdig-published/post-03-2026-09-07.png"
expect_reject sequence-gap

make_case duplicate-post
cp "$source_png" "$fixture_root/duplicate-post/evidence/yellowdig-published/post-01-2026-09-06.png"
cp "$source_png" "$fixture_root/duplicate-post/evidence/yellowdig-published/post-01-2026-09-07.png"
expect_reject duplicate-post

make_case malformed-name
cp "$source_png" "$fixture_root/malformed-name/evidence/yellowdig-published/post-1-draft.png"
expect_reject malformed-name

make_case truncated-png
cp "$source_png" "$fixture_root/truncated-png/evidence/yellowdig-published/post-01-2026-09-06.png"
python3 - "$fixture_root/truncated-png/evidence/yellowdig-published/post-01-2026-09-06.png" <<'PY'
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
path.write_bytes(path.read_bytes()[:1024])
PY
expect_reject truncated-png

make_case reversed-dates
cp "$source_png" "$fixture_root/reversed-dates/evidence/yellowdig-published/post-01-2026-09-07.png"
cp "$source_png" "$fixture_root/reversed-dates/evidence/yellowdig-published/post-02-2026-09-06.png"
expect_reject reversed-dates

echo 'Published-post intake contract: PASS (7/7)'
echo 'Camera opened: NO'
echo 'External publication performed: NO'
