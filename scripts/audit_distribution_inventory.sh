#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="${1:-$project_root/dist}"
archive_name="face-recognition-studio-project-3.tar.gz"
sidecar_name="$archive_name.sha256"

if [[ ! -d "$dist_dir" ]]; then
    echo "Distribution directory not found: $dist_dir" >&2
    exit 1
fi

shopt -s nullglob dotglob
entries=("$dist_dir"/*)
shopt -u nullglob dotglob

archive_seen=0
sidecar_seen=0
unexpected=0

echo "Distribution handoff inventory audit"
for entry in "${entries[@]}"; do
    name="$(basename "$entry")"
    if [[ -L "$entry" || ! -f "$entry" ]]; then
        echo "Unexpected non-regular handoff entry: $name" >&2
        unexpected=$((unexpected + 1))
        continue
    fi
    case "$name" in
        "$archive_name") archive_seen=$((archive_seen + 1)) ;;
        "$sidecar_name") sidecar_seen=$((sidecar_seen + 1)) ;;
        *)
            echo "Unexpected handoff file: $name" >&2
            unexpected=$((unexpected + 1))
            ;;
    esac
done

if (( archive_seen != 1 || sidecar_seen != 1 || unexpected != 0 || ${#entries[@]} != 2 )); then
    echo "Canonical two-file handoff: FAIL" >&2
    echo "Expected only $archive_name and $sidecar_name" >&2
    exit 1
fi

echo "Canonical archive: PASS"
echo "Adjacent SHA-256 sidecar: PASS"
echo "Unexpected or stale handoff entries: 0"
echo "Canonical two-file handoff: PASS"
