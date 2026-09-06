#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
archive="${1:-$project_root/dist/face-recognition-studio-project-3.tar.gz}"
sidecar="$archive.sha256"
verify_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-consumer.XXXXXX")"

cleanup() {
    rm -rf "$verify_root"
}
trap cleanup EXIT

if [[ ! -f "$archive" ]]; then
    echo "Release archive not found: $archive" >&2
    exit 1
fi
if [[ ! -f "$sidecar" ]]; then
    echo "Release SHA-256 sidecar not found: $(basename "$sidecar")" >&2
    exit 1
fi

hash_file() {
    if [[ "${FACE_STUDIO_FORCE_SHASUM:-0}" != 1 ]] && command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        echo "No SHA-256 utility found (requires sha256sum or shasum)" >&2
        return 1
    fi
}

verify_manifest() {
    python3 - "$1" <<'PY'
import hashlib
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
manifest = root / "SHA256SUMS"
pattern = re.compile(r"^([0-9A-Fa-f]{64}) ([ *])(.+)$")

for line_number, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
    match = pattern.fullmatch(line)
    if not match:
        print(f"SHA256SUMS verification: FAIL (invalid line {line_number})", file=sys.stderr)
        raise SystemExit(1)
    relative = match.group(3)
    if relative.startswith("./"):
        relative = relative[2:]
    path = pathlib.PurePosixPath(relative)
    if relative.startswith("/") or "\\" in relative or any(part in ("", ".", "..") for part in path.parts):
        print(f"SHA256SUMS verification: FAIL (unsafe line {line_number})", file=sys.stderr)
        raise SystemExit(1)
    digest = hashlib.sha256((root / pathlib.Path(*path.parts)).read_bytes()).hexdigest()
    if digest.lower() != match.group(1).lower():
        print(f"SHA256SUMS verification: FAIL ({relative})", file=sys.stderr)
        raise SystemExit(1)

print("SHA256SUMS verification: PASS")
PY
}

echo "Face Recognition Studio release consumer validation"
echo "Archive: $(basename "$archive")"
actual_archive_hash="$(hash_file "$archive")"
echo "Archive SHA-256: $actual_archive_hash"

read -r expected_archive_hash expected_archive_name extra_sidecar_field < "$sidecar" || {
    echo "Cannot read release SHA-256 sidecar" >&2
    exit 1
}
expected_archive_name="${expected_archive_name#\*}"
if [[ -n "${extra_sidecar_field:-}" ]] \
    || [[ ! "$expected_archive_hash" =~ ^[[:xdigit:]]{64}$ ]] \
    || [[ "$expected_archive_name" != "$(basename "$archive")" ]]; then
    echo "Release SHA-256 sidecar format/name: FAIL" >&2
    exit 1
fi
expected_archive_hash_lower="$(printf '%s' "$expected_archive_hash" | tr '[:upper:]' '[:lower:]')"
if [[ "$expected_archive_hash_lower" != "$actual_archive_hash" ]]; then
    echo "External SHA-256 sidecar: FAIL" >&2
    exit 1
fi
echo "External SHA-256 sidecar: PASS"

bash "$project_root/scripts/audit_archive_safety.sh" "$archive"
bash "$project_root/scripts/audit_release_freshness.sh" "$archive" "$project_root"
tar -xzf "$archive" -C "$verify_root"
source_root="$verify_root/face-recognition-studio-project-3"

if [[ ! -d "$source_root" ]]; then
    echo "Expected archive root is missing" >&2
    exit 1
fi

(
    cd "$source_root"
    bash scripts/audit_release_contents.sh
    verify_manifest "$PWD"
    bash scripts/audit_shell_script_syntax.sh
    bash scripts/audit_macos_consumer_compatibility.sh
    test -f docs/MACOS_ENVIRONMENT_TROUBLESHOOTING.md
    echo "README-linked macOS troubleshooting guide: present"
    bash scripts/audit_model_integrity.sh
    bash scripts/audit_document_links.sh
    bash scripts/audit_camera_evidence_record.sh
    bash scripts/audit_camera_evidence_record_contract.sh
    bash scripts/audit_yellowdig_readiness.sh
    bash scripts/audit_yellowdig_accessibility.sh
    bash scripts/audit_yellowdig_claims.sh
    bash scripts/audit_selected_evidence.sh
    bash scripts/audit_selected_png_privacy.sh
    bash scripts/audit_selected_png_privacy_contract.sh
    bash scripts/audit_selected_asset_disposition.sh
    bash scripts/audit_evidence_register_coverage.sh
    bash scripts/audit_submission_readiness.sh
    bash scripts/audit_final_lab_report_draft.sh
    bash scripts/audit_handoff_status_consistency.sh
    bash scripts/audit_published_post_intake.sh
    bash scripts/audit_published_post_intake_contract.sh
    cmake -S . -B build -G Ninja
    cmake --build build
    mkdir -p output
    bash scripts/audit_default_detector_selection.sh "$PWD" build/face_studio
    bash scripts/audit_default_threshold.sh "$PWD" build/face_studio
    bash scripts/audit_cli_numeric_validation.sh "$PWD" build/face_studio
    bash scripts/audit_camera_test_preflight.sh build/face_studio
    bash scripts/audit_camera_output_safety.sh build/face_studio
    bash scripts/audit_image_output_safety.sh build/face_studio
    bash scripts/audit_video_output_safety.sh build/face_studio
    ctest --test-dir build --output-on-failure
)

echo "Consumer validation: PASS"
