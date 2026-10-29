#!/usr/bin/env bash
# enforce-constitution.test.sh -- self-test for the write-time hook.
#
# Exercises .claude/scripts/enforce_constitution.py through its Claude Code
# hook contract (JSON payload on stdin; exit 0 allows, exit 2 blocks with the
# reason on stderr), so a change to the hook's comments or rules list cannot
# silently stop it from blocking. Needs python3, as the hook itself does
# (.claude/settings.json runs it with python3).
#
# Exits non-zero on the first failed assertion.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="${REPO_ROOT}/.claude/scripts/enforce_constitution.py"

if [[ ! -f "${HOOK}" ]]; then
    echo "SKIP: write-time hook not present (Claude rule tree pruned at init) — nothing to test."
    exit 0
fi

failures=0

# Args: label, payload, expected exit, expected stderr (exact).
check() {
    local label="$1" payload="$2" want_status="$3" want_err="$4"
    local err status
    set +e
    err="$(printf '%s' "${payload}" | python3 "${HOOK}" 2>&1 >/dev/null)"
    status=$?
    set -e
    if [[ "${status}" -eq "${want_status}" && "${err}" == "${want_err}" ]]; then
        echo "PASS  enforce_constitution.py :: ${label}"
    else
        echo "FAIL  enforce_constitution.py :: ${label}"
        echo "  expected exit ${want_status}, got ${status}"
        echo "  expected stderr:"
        printf '%s\n' "${want_err}" | sed 's/^/    | /'
        echo "  got stderr:"
        printf '%s\n' "${err}" | sed 's/^/    | /'
        failures=$((failures + 1))
    fi
}

check "hard wait in a .ts write is blocked" \
    '{"tool_name":"Write","tool_input":{"file_path":"pages/demo/login.page.ts","content":"await page.waitForTimeout(1000);\n"}}' \
    2 \
    "BLOCKED by Constitution enforcement hook (pages/demo/login.page.ts):
  - [no-hard-wait] \`waitForTimeout()\` is forbidden everywhere. Use web-first assertions, e.g. \`expect(locator).toBeVisible()\` (Constitution WON'T: No Hard Waits)."

check "clean .ts write is allowed" \
    '{"tool_name":"Write","tool_input":{"file_path":"pages/demo/login.page.ts","content":"await expect(locator).toBeVisible();\n"}}' \
    0 \
    ""

echo
echo "Hook self-test: ${failures} failure(s)."
[[ "${failures}" -eq 0 ]] || exit 1
