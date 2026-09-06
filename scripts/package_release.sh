#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_name="face-recognition-studio-project-3"
dist_dir="$project_root/dist"
archive="$dist_dir/$package_name.tar.gz"
archive_hash="$archive.sha256"
stage_dir="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-package.XXXXXX")"
verify_dir="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-verify.XXXXXX")"

cleanup() {
    rm -rf "$stage_dir" "$verify_dir"
}
trap cleanup EXIT

files=(
    .gitignore
    CMakeLists.txt
    README.md
    src/main.cpp
    scripts/download_models.sh
    scripts/audit_yellowdig_readiness.sh
    scripts/audit_yellowdig_accessibility.sh
    scripts/audit_yellowdig_claims.sh
    scripts/audit_document_links.sh
    scripts/audit_selected_evidence.sh
    scripts/audit_selected_png_privacy.sh
    scripts/audit_selected_png_privacy_contract.sh
    scripts/audit_selected_asset_disposition.sh
    scripts/audit_evidence_register_coverage.sh
    scripts/audit_model_integrity.sh
    scripts/audit_camera_consent_gate.sh
    scripts/audit_camera_output_safety.sh
    scripts/audit_camera_evidence_record.sh
    scripts/audit_camera_evidence_record_contract.sh
    scripts/camera_test_preflight.sh
    scripts/audit_camera_test_preflight.sh
    scripts/audit_image_output_safety.sh
    scripts/audit_video_output_safety.sh
    scripts/audit_release_contents.sh
    scripts/audit_release_privacy.sh
    scripts/audit_archive_safety.sh
    scripts/audit_release_freshness.sh
    scripts/audit_shell_script_syntax.sh
    scripts/audit_macos_consumer_compatibility.sh
    scripts/audit_cli_numeric_validation.sh
    scripts/audit_default_detector_selection.sh
    scripts/audit_default_threshold.sh
    scripts/audit_distribution_inventory.sh
    scripts/audit_submission_readiness.sh
    scripts/audit_final_lab_report_draft.sh
    scripts/audit_handoff_status_consistency.sh
    scripts/audit_published_post_intake.sh
    scripts/audit_published_post_intake_contract.sh
    scripts/macos_setup_build.sh
    scripts/package_release.sh
    scripts/validate_release.sh
    models/face_detection_yunet_2022mar.onnx
    models/face_detection_yunet_2023mar.onnx
    models/face_recognition_sface_2021dec.onnx
    tests/SYNTHETIC_DATASET_PROVENANCE.md
    tests/synthetic_portrait_a.provenance.md
    tests/synthetic_portrait_a.png
    tests/synthetic_portrait_a_640.png
    tests/synthetic_portrait_a_variant.png
    tests/synthetic_portrait_a_variant_640.png
    tests/synthetic_portrait_b_unknown.png
    tests/synthetic_portrait_b_unknown_640.png
    tests/synthetic_portrait_a_3s.mp4
    tests/synthetic_portrait_pan.mp4
    tests/known/Synthetic_A.png
    docs/MACOS_RUNBOOK.md
    docs/MACOS_ENVIRONMENT_TROUBLESHOOTING.md
    docs/CAMERA_TEST_RUNBOOK.md
    docs/CAMERA_TEST_EVIDENCE_RECORD.md
    docs/FINAL_LAB_REPORT_DRAFT.md
    docs/MODEL_PROVENANCE.md
    docs/PROJECT_STATUS.md
    docs/SUBMISSION_READINESS.md
    docs/YELLOWDIG_REVIEW_CHECKLIST.md
    docs/YELLOWDIG_7_POST_SEQUENCE.md
    docs/YELLOWDIG_PUBLICATION_CONTROL.md
    docs/YELLOWDIG_SCREENSHOT_CAPTIONS.md
    docs/YELLOWDIG_POSTS_1_TO_3.md
    docs/YELLOWDIG_POSTS_1_TO_3_REVIEW.md
    docs/YELLOWDIG_POSTS_4_TO_7.md
    docs/YELLOWDIG_POSTS_4_TO_7_REVIEW.md
    evidence/CHRONOLOGICAL_LOG.md
    evidence/EVIDENCE_REGISTER.md
    evidence/SCREENSHOT_CHECKLIST.md
    evidence/yellowdig-published/.gitkeep
)

while IFS= read -r selected; do
    files+=("${selected#./}")
done < <(cd "$project_root" && find evidence/selected -maxdepth 1 -type f -name '*.png' \
    | LC_ALL=C sort)

package_root="$stage_dir/$package_name"
mkdir -p "$package_root" "$dist_dir"

for relative in "${files[@]}"; do
    source_file="$project_root/$relative"
    if [[ ! -f "$source_file" ]]; then
        echo "Missing package input: $relative" >&2
        exit 1
    fi
    mkdir -p "$package_root/$(dirname "$relative")"
    cp -p "$source_file" "$package_root/$relative"
done

(
    cd "$package_root"
    find . -type f ! -name SHA256SUMS -print0 \
        | LC_ALL=C sort -z \
        | xargs -0 sha256sum > SHA256SUMS
)

rm -f "$archive" "$archive_hash"
tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
    --use-compress-program='gzip -n' -cf "$archive" \
    -C "$stage_dir" "$package_name"
(
    cd "$dist_dir"
    sha256sum "$package_name.tar.gz" > "$package_name.tar.gz.sha256"
)

bash "$project_root/scripts/audit_archive_safety.sh" "$archive"
tar -xzf "$archive" -C "$verify_dir"
(
    cd "$verify_dir/$package_name"
    bash scripts/audit_release_contents.sh
    sha256sum --check --strict SHA256SUMS
    bash scripts/audit_shell_script_syntax.sh
    bash scripts/audit_macos_consumer_compatibility.sh
    bash scripts/audit_model_integrity.sh
    bash scripts/audit_document_links.sh
    bash scripts/audit_camera_evidence_record.sh
    bash scripts/audit_camera_evidence_record_contract.sh
    bash scripts/audit_selected_png_privacy.sh
    bash scripts/audit_selected_png_privacy_contract.sh
    bash scripts/audit_selected_asset_disposition.sh
    bash scripts/audit_evidence_register_coverage.sh
    bash scripts/audit_submission_readiness.sh
    bash scripts/audit_final_lab_report_draft.sh
    bash scripts/audit_handoff_status_consistency.sh
    bash scripts/audit_published_post_intake.sh
    bash scripts/audit_published_post_intake_contract.sh
)
bash "$project_root/scripts/audit_release_freshness.sh" "$archive" "$project_root"
bash "$project_root/scripts/audit_distribution_inventory.sh" "$dist_dir"

file_count="$(tar -tzf "$archive" | grep -c -v '/$')"
archive_bytes="$(wc -c < "$archive" | tr -d ' ')"
echo "Created: $archive"
echo "Files: $file_count"
echo "Bytes: $archive_bytes"
echo "Archive SHA-256: $(cut -d ' ' -f1 "$archive_hash")"
echo "Embedded SHA256SUMS: verified"
echo "Distribution inventory: canonical archive + adjacent sidecar only"
