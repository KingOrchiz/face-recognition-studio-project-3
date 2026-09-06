#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$project_root" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote


root = Path(sys.argv[1]).resolve()
scan_roots = [root / "README.md", root / "docs", root / "evidence"]
markdown_files: list[Path] = []

for candidate in scan_roots:
    if candidate.is_file():
        markdown_files.append(candidate)
    elif candidate.is_dir():
        markdown_files.extend(sorted(candidate.rglob("*.md")))

link_pattern = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
issues: list[str] = []
checked = 0

for document in markdown_files:
    text = document.read_text(encoding="utf-8")
    for line_number, line in enumerate(text.splitlines(), start=1):
        for match in link_pattern.finditer(line):
            destination = match.group(1).strip()
            if destination.startswith("<") and destination.endswith(">"):
                destination = destination[1:-1]
            elif " " in destination:
                destination = destination.split(maxsplit=1)[0]

            destination = unquote(destination)
            path_text, _, fragment = destination.partition("#")
            if not path_text or path_text.startswith(("http://", "https://", "mailto:")):
                continue

            checked += 1
            target = (document.parent / path_text).resolve()
            try:
                target.relative_to(root)
            except ValueError:
                issues.append(
                    f"{document.relative_to(root)}:{line_number}: "
                    f"link escapes project root: {destination}"
                )
                continue

            if not target.exists():
                issues.append(
                    f"{document.relative_to(root)}:{line_number}: "
                    f"missing target: {destination}"
                )
                continue

            if fragment and target.is_file() and target.suffix.lower() == ".md":
                target_text = target.read_text(encoding="utf-8")
                headings = []
                for target_line in target_text.splitlines():
                    if not target_line.startswith("#"):
                        continue
                    heading = target_line.lstrip("#").strip().lower()
                    slug = re.sub(r"[^\w\- ]", "", heading)
                    headings.append(re.sub(r"[ _]+", "-", slug))
                if fragment.lower() not in headings:
                    issues.append(
                        f"{document.relative_to(root)}:{line_number}: "
                        f"missing Markdown anchor: {destination}"
                    )

if issues:
    print(f"Documentation-link audit: FAIL ({len(issues)} issue(s))", file=sys.stderr)
    for issue in issues:
        print(f"- {issue}", file=sys.stderr)
    raise SystemExit(1)

print(f"Markdown files scanned: {len(markdown_files)}")
print(f"Local links checked: {checked}")
print("Project-root containment: PASS")
print("Target existence: PASS")
print("Markdown anchors: PASS")
print("Documentation-link audit: PASS")
PY
