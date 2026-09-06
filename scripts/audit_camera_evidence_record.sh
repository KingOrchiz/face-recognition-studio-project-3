#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
record="${1:-$project_root/docs/CAMERA_TEST_EVIDENCE_RECORD.md}"

python3 - "$record" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
if not path.is_file():
    print("Camera evidence-record audit: FAIL (record missing)", file=sys.stderr)
    raise SystemExit(1)

text = path.read_text(encoding="utf-8")
required_headings = (
    "## Authorization and scene",
    "## Preflight",
    "## Bounded test result",
    "## Evidence and retention",
    "## Post 5 truth boundary",
)
missing = [heading for heading in required_headings if heading not in text]
if missing:
    print(f"Camera evidence-record audit: FAIL (missing heading: {missing[0]})", file=sys.stderr)
    raise SystemExit(1)

sensitive = re.search(r"(?:/Users/|/home/|/root/|[\w.+-]+@[\w.-]+\.[A-Za-z]{2,})", text)
if sensitive:
    print("Camera evidence-record audit: FAIL (private path or email pattern)", file=sys.stderr)
    raise SystemExit(1)

blank_status = "Status: **blank operator template — not evidence that a camera test occurred**."
complete_status = "Status: **completed consented camera-test evidence record**."

if blank_status in text:
    if text.count("PENDING") != 15 or text.count("[ ]") != 28 or re.search(r"\[[xX]\]", text):
        print("Camera evidence-record audit: FAIL (blank template was partially completed)", file=sys.stderr)
        raise SystemExit(1)
    print("Record state: BLANK TEMPLATE")
    print("Required sections: PASS (5/5)")
    print("Placeholder contract: PASS (15 PENDING; 14 unanswered choices)")
    print("Privacy pattern scan: PASS")
    print("Post 5 webcam-result claim: BLOCKED")
    print("Camera opened: NO")
    print("Camera evidence-record audit: PASS")
    raise SystemExit(0)

if complete_status not in text:
    print("Camera evidence-record audit: FAIL (unrecognized status)", file=sys.stderr)
    raise SystemExit(1)
if "PENDING" in text or "[ ] yes` `[ ] no" in text:
    print("Camera evidence-record audit: FAIL (incomplete field or choice)", file=sys.stderr)
    raise SystemExit(1)

required_yes = (
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
required_no = (
    "Unexpected model/writer/device error",
    "Abort criterion triggered",
)
for label in required_yes:
    if not re.search(rf"^- {re.escape(label)}: `\[[xX]\] yes` `\[ \] no`$", text, re.M):
        print(f"Camera evidence-record audit: FAIL (required yes: {label})", file=sys.stderr)
        raise SystemExit(1)
for label in required_no:
    if not re.search(rf"^- {re.escape(label)}: `\[ \] yes` `\[[xX]\] no`$", text, re.M):
        print(f"Camera evidence-record audit: FAIL (required no: {label})", file=sys.stderr)
        raise SystemExit(1)

for label in ("Application screenshot basename", "Terminal screenshot basename"):
    match = re.search(rf"^- {re.escape(label)}: `([^`]+)`$", text, re.M)
    if not match or "/" in match.group(1) or not match.group(1).lower().endswith(".png"):
        print(f"Camera evidence-record audit: FAIL (invalid {label.lower()})", file=sys.stderr)
        raise SystemExit(1)

output = re.search(r"^- Intended output basename only: `([^`]+)`$", text, re.M)
if not output or "/" in output.group(1) or not output.group(1).lower().endswith(".mp4"):
    print("Camera evidence-record audit: FAIL (invalid output basename)", file=sys.stderr)
    raise SystemExit(1)

for label in ("Evidence", "Milestone", "Lesson", "Next step"):
    match = re.search(rf"^{label}: `([^`]+)`$", text, re.M)
    if not match or not match.group(1).strip():
        print(f"Camera evidence-record audit: FAIL (missing {label})", file=sys.stderr)
        raise SystemExit(1)

print("Record state: COMPLETED")
print("Required sections: PASS (5/5)")
print("Consent/privacy/retention choices: PASS (14/14)")
print("Screenshot and output basenames: PASS")
print("Evidence → Milestone → Lesson → Next step: PASS")
print("Privacy pattern scan: PASS")
print("Camera evidence-record audit: PASS")
PY
