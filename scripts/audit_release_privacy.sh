#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
release_root="${1:-$project_root}"

if [[ ! -d "$release_root" ]]; then
    echo "Release root not found: $release_root" >&2
    exit 1
fi

private_path_pattern='/(root|Users)/[[:alnum:]_.-]+/'
email_pattern='[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}'
secret_assignment_pattern="(api[_-]?key|client[_-]?secret|access[_-]?token|password)[[:space:]]*[:=][[:space:]]*[\"']?[[:alnum:]_./+=-]{8,}"
private_key_pattern='BEGIN .*PRIVATE'" KEY"

failures=0
checked=0

echo "Release text-privacy audit"

while IFS= read -r -d '' file; do
    checked=$((checked + 1))
    relative="${file#"$release_root"/}"

    if grep -Eq "$private_path_pattern" "$file"; then
        echo "Private absolute path found in: $relative" >&2
        failures=$((failures + 1))
    fi
    if grep -Eq "$email_pattern" "$file"; then
        echo "Email address found in: $relative" >&2
        failures=$((failures + 1))
    fi
    if grep -Eiq "$secret_assignment_pattern" "$file"; then
        echo "Credential-like assignment found in: $relative" >&2
        failures=$((failures + 1))
    fi
    if grep -Eq "$private_key_pattern" "$file"; then
        echo "Private-key material found in: $relative" >&2
        failures=$((failures + 1))
    fi
done < <(
    find "$release_root" -type f \
        \( -name '*.md' -o -name '*.txt' -o -name '*.cpp' -o -name '*.hpp' \
        -o -name '*.h' -o -name '*.cmake' -o -name '*.sh' -o -name '.gitignore' \
        -o -name 'CMakeLists.txt' -o -name 'SHA256SUMS' \) -print0
)

if (( failures > 0 )); then
    echo "Release text-privacy audit: FAIL ($failures finding(s))" >&2
    exit 1
fi

echo "Text files checked: $checked"
echo "Private absolute paths: PASS"
echo "Email addresses: PASS"
echo "Credential-like assignments: PASS"
echo "Private-key material: PASS"
echo "Release text-privacy audit: PASS"
