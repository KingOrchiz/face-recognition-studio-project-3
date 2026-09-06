#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

python3 - "$project_root" <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
relative_scripts = [
    "scripts/audit_archive_safety.sh",
    "scripts/audit_camera_consent_gate.sh",
    "scripts/audit_camera_evidence_record.sh",
    "scripts/audit_camera_evidence_record_contract.sh",
    "scripts/audit_camera_output_safety.sh",
    "scripts/audit_camera_test_preflight.sh",
    "scripts/audit_cli_numeric_validation.sh",
    "scripts/audit_default_detector_selection.sh",
    "scripts/audit_default_threshold.sh",
    "scripts/audit_document_links.sh",
    "scripts/audit_evidence_register_coverage.sh",
    "scripts/audit_final_lab_report_draft.sh",
    "scripts/audit_image_output_safety.sh",
    "scripts/audit_handoff_status_consistency.sh",
    "scripts/audit_model_integrity.sh",
    "scripts/audit_published_post_intake.sh",
    "scripts/audit_published_post_intake_contract.sh",
    "scripts/audit_release_contents.sh",
    "scripts/audit_release_freshness.sh",
    "scripts/audit_release_privacy.sh",
    "scripts/audit_selected_asset_disposition.sh",
    "scripts/audit_selected_evidence.sh",
    "scripts/audit_selected_png_privacy.sh",
    "scripts/audit_selected_png_privacy_contract.sh",
    "scripts/audit_shell_script_syntax.sh",
    "scripts/audit_submission_readiness.sh",
    "scripts/audit_video_output_safety.sh",
    "scripts/audit_yellowdig_accessibility.sh",
    "scripts/audit_yellowdig_claims.sh",
    "scripts/audit_yellowdig_readiness.sh",
    "scripts/audit_macos_consumer_compatibility.sh",
    "scripts/camera_test_preflight.sh",
    "scripts/validate_release.sh",
]

# Keep the static audit synchronized with the complete shell call graph rooted
# at validate_release.sh. Do not expand this audit's own source: its explicit
# inventory above would otherwise make a missing call-graph entry appear
# reachable merely because it was already listed here.
script_reference = re.compile(
    r"(?:\$[A-Za-z_][A-Za-z0-9_]*/)?(scripts/[A-Za-z0-9_.-]+\.sh)"
)
reachable_scripts = set()
pending_scripts = ["scripts/validate_release.sh"]
while pending_scripts:
    relative = pending_scripts.pop()
    if relative in reachable_scripts:
        continue
    reachable_scripts.add(relative)
    if relative == "scripts/audit_macos_consumer_compatibility.sh":
        continue
    path = root / relative
    if not path.is_file():
        continue
    for referenced in script_reference.findall(path.read_text(encoding="utf-8")):
        if referenced not in reachable_scripts:
            pending_scripts.append(referenced)

listed_scripts = set(relative_scripts)
missing_from_audit = sorted(reachable_scripts - listed_scripts)
not_on_consumer_path = sorted(listed_scripts - reachable_scripts)
scanned_scripts = [
    relative
    for relative in relative_scripts
    if relative != "scripts/audit_macos_consumer_compatibility.sh"
]
mac_setup_helpers = ["scripts/macos_setup_build.sh"]
scanned_scripts.extend(mac_setup_helpers)

def coverage_rejected(reachable, listed):
    return bool(reachable - listed or listed - reachable)

coverage_controls = [
    coverage_rejected(
        reachable_scripts | {"scripts/synthetic-unlisted-direct.sh"}, listed_scripts
    ),
    coverage_rejected(
        reachable_scripts, listed_scripts - {"scripts/audit_release_privacy.sh"}
    ),
]
coverage_rejections = sum(coverage_controls)

rules = [
    ("Bash associative array", re.compile(r"\bdeclare\s+-A\b")),
    ("Bash typeset associative array", re.compile(r"\btypeset\s+-A\b")),
    ("Bash global declaration", re.compile(r"\bdeclare\s+-g\b")),
    ("Bash 4 mapfile/readarray", re.compile(r"\b(?:mapfile|readarray)\b")),
    ("Bash lowercase expansion", re.compile(r"\$\{[^}\n]*,,[^}\n]*\}")),
    ("Bash uppercase expansion", re.compile(r"\$\{[^}\n]*\^\^[^}\n]*\}")),
    ("Bash variable-exists test", re.compile(r"\[\[\s+-v\s")),
    ("Bash coprocess", re.compile(r"(?:^|[;&|]\s*)coproc(?:\s|$)", re.MULTILINE)),
    ("Bash globstar option", re.compile(r"\bshopt\s+-s\s+globstar\b")),
    ("Bash combined redirect", re.compile(r"&>>")),
    ("Bash pipeline shorthand", re.compile(r"\|&")),
    ("GNU find -printf", re.compile(r"(?:^|\s)-printf(?:\s|$)")),
    ("GNU sort -z", re.compile(r"\bsort\s+(?:[^\n#]*\s)?-z(?:\s|$)")),
    ("GNU sort -V", re.compile(r"\bsort\s+(?:[^\n#]*\s)?-V(?:\s|$)")),
    ("GNU sed -r", re.compile(r"\bsed\s+(?:[^\n#]*\s)?-r(?:\s|$)")),
    ("GNU grep -P", re.compile(r"\bgrep\s+(?:[^\n#]*\s)?-P(?:\s|$)")),
    ("GNU stat -c", re.compile(r"\bstat\s+(?:[^\n#]*\s)?-c(?:\s|$)")),
    ("GNU date long option", re.compile(r"\bdate\s+--[A-Za-z]")),
    ("GNU readlink -f", re.compile(r"\breadlink\s+(?:[^\n#]*\s)?-f(?:\s|$)")),
    ("non-stock realpath", re.compile(r"(?:^|[;&|]\s*)realpath(?:\s|$)", re.MULTILINE)),
    ("GNU xargs -r", re.compile(r"\bxargs\s+(?:[^\n#]*\s)?-r(?:\s|$)")),
    ("GNU cp -a", re.compile(r"\bcp\s+(?:[^\n#]*\s)?-a(?:\s|$)")),
    ("GNU install -D", re.compile(r"\binstall\s+(?:[^\n#]*\s)?-D(?:\s|$)")),
    ("GNU du -b", re.compile(r"\bdu\s+(?:[^\n#]*\s)?-b(?:\s|$)")),
    ("GNU head -c", re.compile(r"\bhead\s+(?:[^\n#]*\s)?-c(?:\s|$)")),
    ("GNU base64 -w", re.compile(r"\bbase64\s+(?:[^\n#]*\s)?-w(?:\s|$)")),
    ("non-stock md5sum", re.compile(r"(?:^|[;&|]\s*)md5sum(?:\s|$)", re.MULTILINE)),
    ("non-stock timeout", re.compile(r"(?:^|[;&|]\s*)timeout(?:\s|$)", re.MULTILINE)),
]

issues = []
for relative in missing_from_audit:
    issues.append(f"{relative}: consumer-path script missing from compatibility audit")
for relative in not_on_consumer_path:
    issues.append(f"{relative}: compatibility-audit entry is not on consumer path")
if coverage_rejections != len(coverage_controls):
    issues.append(
        "coverage negative controls: rejected "
        f"{coverage_rejections}/{len(coverage_controls)}"
    )
for relative in scanned_scripts:
    path = root / relative
    if not path.is_file():
        issues.append(f"{relative}: missing")
        continue
    text = path.read_text(encoding="utf-8")
    for label, pattern in rules:
        match = pattern.search(text)
        if match:
            line = text.count("\n", 0, match.start()) + 1
            issues.append(f"{relative}:{line}: {label}")

mac_helper_text = (root / "scripts/macos_setup_build.sh").read_text(encoding="utf-8")
source_identity_markers = [
    'echo "Project source identity (SHA-256):"',
    "shasum -a 256 CMakeLists.txt src/main.cpp scripts/macos_setup_build.sh",
]
for marker in source_identity_markers:
    if marker not in mac_helper_text:
        issues.append(f"scripts/macos_setup_build.sh: missing source-identity marker: {marker}")

controls = [
    "declare -A values=([one]=1)",
    "typeset -A values",
    "declare -g result=ready",
    "mapfile -t values < file",
    "value=${VALUE,,}",
    "value=${VALUE^^}",
    "[[ -v value ]]",
    "coproc worker { tool; }",
    "shopt -s globstar",
    "tool &>> result.log",
    "tool |& tee result.log",
    "find . -type f -printf '%f\\n'",
    "sort -z",
    "sort -V versions.txt",
    "sed -r 's/a/b/' file",
    "grep -P 'pattern' file",
    "stat -c '%a' file",
    "date --iso-8601=seconds",
    "readlink -f file",
    "realpath file",
    "xargs -r tool",
    "cp -a source target",
    "install -D source target",
    "du -b file",
    "head -c 8 file",
    "base64 -w 0 file",
    "md5sum file",
    "timeout 5 tool",
]
rejected = sum(any(pattern.search(control) for _, pattern in rules) for control in controls)
if rejected != len(controls):
    issues.append(f"negative controls: rejected {rejected}/{len(controls)}")

print("macOS stock-shell consumer compatibility audit")
print(
    "Scripts scanned: "
    f"{len(scanned_scripts)} "
    f"({len(scanned_scripts) - len(mac_setup_helpers)} consumer dependencies + "
    f"{len(mac_setup_helpers)} Mac setup helper)"
)
print(f"Consumer call-graph coverage: {len(reachable_scripts)}/{len(reachable_scripts)}")
print("Auditor entry point: covered by execution; embedded fixtures excluded from scan")
print(
    "Synthetic coverage-gap controls rejected: "
    f"{coverage_rejections}/{len(coverage_controls)}"
)
print("Target boundary: macOS Bash 3.2 syntax plus BSD find/sort")
print(f"Unsupported constructs absent: {'PASS' if not issues else 'FAIL'}")
print(f"Synthetic incompatible controls rejected: {rejected}/{len(controls)}")
print("Mac helper source-identity contract: " + ("PASS" if not any(
    issue.startswith("scripts/macos_setup_build.sh: missing source-identity")
    for issue in issues
) else "FAIL"))
print("Camera accessed: NO")

if issues:
    for issue in issues:
        print(f"- {issue}", file=sys.stderr)
    raise SystemExit(1)

print("Static compatibility audit: PASS")
print("Runtime Mac rerun: NOT CLAIMED by this static audit")
PY
