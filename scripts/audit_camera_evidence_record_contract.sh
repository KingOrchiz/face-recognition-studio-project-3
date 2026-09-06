#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
audit_root="$(mktemp -d "${TMPDIR:-/tmp}/face-studio-camera-record.XXXXXX")"

cleanup() {
    rm -rf "$audit_root"
}
trap cleanup EXIT

run_rejection() {
    local label="$1"
    local expected="$2"
    local record="$3"
    local log="$audit_root/rejection.log"

    set +e
    bash "$project_root/scripts/audit_camera_evidence_record.sh" "$record" >"$log" 2>&1
    local status=$?
    set -e

    if (( status != 1 )) || ! grep -Fq "$expected" "$log"; then
        printf '%s: FAIL (status=%d)\n' "$label" "$status" >&2
        sed -n '1,20p' "$log" >&2
        exit 1
    fi
    printf '%s: PASS (status 1)\n' "$label"
}

echo "Camera evidence-record contract audit (camera-safe)"

bash "$project_root/scripts/audit_camera_evidence_record.sh" \
    "$project_root/docs/CAMERA_TEST_EVIDENCE_RECORD.md" >/dev/null
echo "Blank template accepted with claim blocked: PASS"

completed="$audit_root/completed.md"
python3 - "$project_root/docs/CAMERA_TEST_EVIDENCE_RECORD.md" "$completed" <<'PY'
import pathlib
import sys

text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
text = text.replace(
    "Status: **blank operator template — not evidence that a camera test occurred**.",
    "Status: **completed consented camera-test evidence record**.",
)
yes_labels = (
    "Explicit Oche authorization recorded",
    "Every visible participant consented",
    "Neutral scene/privacy check passed",
    "Notifications and private applications hidden",
    "Intended output absent before test",
    "Preflight reported `Camera opened: NO`",
    "Preview closed with `q` or Escape",
    "Privacy-safe application screenshot reviewed",
    "Privacy-safe terminal screenshot reviewed",
    "Temporary video reviewed locally",
    "Temporary video deleted after review",
    "Evidence contains no room/private desktop detail",
)
no_labels = ("Unexpected model/writer/device error", "Abort criterion triggered")
for label in yes_labels:
    text = text.replace(
        f"- {label}: `[ ] yes` `[ ] no`",
        f"- {label}: `[x] yes` `[ ] no`",
    )
for label in no_labels:
    text = text.replace(
        f"- {label}: `[ ] yes` `[ ] no`",
        f"- {label}: `[ ] yes` `[x] no`",
    )
replacements = {
    "- Test date/time (WAT): `PENDING`": "- Test date/time (WAT): `2026-09-05 22:35 WAT`",
    "- Operator role (no personal name): `PENDING`": "- Operator role (no personal name): `authorized operator`",
    "- `camera_test_preflight.sh` result: `PENDING`": "- `camera_test_preflight.sh` result: `PASS`",
    "- Contract audit result: `PENDING`": "- Contract audit result: `PASS 6/6`",
    "- Intended output basename only: `PENDING`": "- Intended output basename only: `camera-bounded.mp4`",
    "- Device index used: `PENDING`": "- Device index used: `0`",
    "- Processed-frame result: `PENDING`": "- Processed-frame result: `30 frames`",
    "- Observed face-count range: `PENDING`": "- Observed face-count range: `0 to 1`",
    "- If aborted, sanitized reason: `PENDING`": "- If aborted, sanitized reason: `not applicable`",
    "- Application screenshot basename: `PENDING`": "- Application screenshot basename: `camera-result.png`",
    "- Terminal screenshot basename: `PENDING`": "- Terminal screenshot basename: `camera-terminal.png`",
    "Evidence: `PENDING`": "Evidence: `Bounded consented preview and sanitized result recorded.`",
    "Milestone: `PENDING`": "Milestone: `Camera workflow verified for this bounded test.`",
    "Lesson: `PENDING`": "Lesson: `Consent and retention checks are part of the technical result.`",
    "Next step: `PENDING`": "Next step: `Use only the two reviewed screenshots for Post 5.`",
}
for before, after in replacements.items():
    text = text.replace(before, after)
if "PENDING" in text:
    raise SystemExit("fixture generation left a PENDING field")
pathlib.Path(sys.argv[2]).write_text(text, encoding="utf-8")
PY

bash "$project_root/scripts/audit_camera_evidence_record.sh" "$completed" >/dev/null
echo "Fully completed synthetic record accepted: PASS"

retention_no="$audit_root/retention-no.md"
sed 's/Temporary video deleted after review: `\[x\] yes` `\[ \] no`/Temporary video deleted after review: `[ ] yes` `[x] no`/' \
    "$completed" > "$retention_no"
run_rejection \
    "Required retention failure rejected" \
    "required yes: Temporary video deleted after review" \
    "$retention_no"

private_path="$audit_root/private-path.md"
sed 's/`camera-result.png`/`\/Users\/operator\/camera-result.png`/' \
    "$completed" > "$private_path"
run_rejection \
    "Private path rejected" \
    "private path or email pattern" \
    "$private_path"

missing_lesson="$audit_root/missing-lesson.md"
sed 's/Lesson: `[^`]*`/Lesson: ``/' "$completed" > "$missing_lesson"
run_rejection \
    "Missing narrative field rejected" \
    "missing Lesson" \
    "$missing_lesson"

echo "Evidence-record contract cases passed: 5/5"
echo "Camera opened: NO"
echo "Camera evidence-record contract audit: PASS"
