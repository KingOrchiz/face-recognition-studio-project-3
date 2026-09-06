#!/usr/bin/env bash
set -euo pipefail

project_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
scripts_dir="$project_root/scripts"

if [[ ! -d "$scripts_dir" ]]; then
    echo "Shell script syntax audit: FAIL (scripts directory is missing)" >&2
    exit 1
fi

scripts=()
while IFS= read -r script; do
    scripts+=("$script")
done < <(find "$scripts_dir" -maxdepth 1 -type f -name '*.sh' | LC_ALL=C sort)

if [[ "${#scripts[@]}" -eq 0 ]]; then
    echo "Shell script syntax audit: FAIL (no shell scripts found)" >&2
    exit 1
fi

echo "Shell script syntax audit"
for script in "${scripts[@]}"; do
    relative="scripts/$(basename "$script")"
    if [[ "$(head -n 1 "$script")" != '#!/usr/bin/env bash' ]]; then
        echo "Portable Bash shebang: FAIL ($relative)" >&2
        exit 1
    fi
    if [[ ! -x "$script" ]]; then
        echo "Executable mode: FAIL ($relative)" >&2
        exit 1
    fi
    if LC_ALL=C grep -q $'\r' "$script"; then
        echo "Unix line endings: FAIL ($relative)" >&2
        exit 1
    fi
    if ! bash -n "$script"; then
        echo "Syntax: FAIL ($relative)" >&2
        exit 1
    fi
    printf '%-58s PASS\n' "$relative"
done

printf 'Portable Bash shebang: PASS (%d/%d)\n' "${#scripts[@]}" "${#scripts[@]}"
printf 'Executable mode: PASS (%d/%d)\n' "${#scripts[@]}" "${#scripts[@]}"
printf 'Unix line endings: PASS (%d/%d)\n' "${#scripts[@]}" "${#scripts[@]}"
printf 'Shell script syntax: PASS (%d/%d)\n' "${#scripts[@]}" "${#scripts[@]}"

malformed_fixture="$(mktemp "${TMPDIR:-/tmp}/face-studio-malformed-shell.XXXXXX")"
wrong_shebang_fixture="$(mktemp "${TMPDIR:-/tmp}/face-studio-wrong-shebang.XXXXXX")"
crlf_fixture="$(mktemp "${TMPDIR:-/tmp}/face-studio-crlf-shell.XXXXXX")"
cleanup() {
    rm -f "$malformed_fixture" "$wrong_shebang_fixture" "$crlf_fixture"
}
trap cleanup EXIT
printf '#!/usr/bin/env bash\nif then\n' > "$malformed_fixture"
if bash -n "$malformed_fixture" 2>/dev/null; then
    echo "Malformed-script rejection: FAIL" >&2
    exit 1
fi
echo "Malformed-script rejection: PASS"

printf '#!/bin/sh\nprintf "wrong interpreter\\n"\n' > "$wrong_shebang_fixture"
if [[ "$(head -n 1 "$wrong_shebang_fixture")" == '#!/usr/bin/env bash' ]]; then
    echo "Wrong-shebang rejection: FAIL" >&2
    exit 1
fi
echo "Wrong-shebang rejection: PASS"

printf '#!/usr/bin/env bash\r\nprintf "CRLF\\r\\n"\r\n' > "$crlf_fixture"
if ! LC_ALL=C grep -q $'\r' "$crlf_fixture"; then
    echo "CRLF rejection: FAIL" >&2
    exit 1
fi
echo "CRLF rejection: PASS"
