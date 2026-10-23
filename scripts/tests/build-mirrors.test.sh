#!/usr/bin/env bash
# build-mirrors.test.sh
#
# Exercises scripts/build-mirrors.mjs through its command-line entry point on
# a scratch copy of the repository (tracked and untracked-but-not-ignored
# files; node_modules and .git are not copied):
#
#   1. Two consecutive builds leave an empty `git status`.
#   2. An edit to a canonical skill appears in the Cursor and Copilot mirrors
#      at the rewritten paths, with relative links re-targeted inside each tree.
#   3. A Copilot-mirrored file linking to a canonical file that has no Copilot
#      counterpart makes the build fail and name the file.
#
# Exits non-zero on the first failed assertion.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRATCH="$(mktemp -d)"
trap 'rm -rf "${SCRATCH}"' EXIT

failures=0
pass() { echo "PASS  $1"; }
fail() {
    echo "FAIL  $1"
    failures=$((failures + 1))
}

# Assert file $1 contains the fixed string $2.
assert_contains() {
    local file="$1" needle="$2" label="$3"
    if [[ -f "${SCRATCH}/${file}" ]] && grep -F -q -- "${needle}" "${SCRATCH}/${file}"; then
        pass "${label}"
    else
        fail "${label} -- '${needle}' not found in ${file}"
    fi
}

build() { node "${SCRATCH}/scripts/build-mirrors.mjs" >/dev/null; }

# --- Scratch copy: what git would see in this checkout, minus ignored files ---
(
    cd "${REPO_ROOT}"
    git ls-files -z --cached --others --exclude-standard \
        | while IFS= read -r -d '' f; do [[ -e "$f" ]] && printf '%s\0' "$f"; done \
        | xargs -0 tar -cf -
) | tar -xf - -C "${SCRATCH}"
git -C "${SCRATCH}" init -q
git -C "${SCRATCH}" add -A
git -C "${SCRATCH}" -c user.name=test -c user.email=test@example.invalid commit -q -m scratch

# --- 1. Idempotence ---
build
git -C "${SCRATCH}" add -A
git -C "${SCRATCH}" -c user.name=test -c user.email=test@example.invalid commit -q -m first-build --allow-empty
build
if [[ -z "$(git -C "${SCRATCH}" status --porcelain)" ]]; then
    pass "second build leaves an empty diff"
else
    fail "second build changed files:"
    git -C "${SCRATCH}" status --porcelain
fi

# --- 2. A canonical edit propagates with rewritten paths ---
cat >>"${SCRATCH}/.claude/skills/fixtures/SKILL.md" <<'MD'

Sentinel paragraph: read `.claude/skills/enums/SKILL.md` and the `CLAUDE.md` Constitution, see [Role](../../../CLAUDE.md#role), [Enums](../enums/SKILL.md), [Examples](references/examples.md) and [Contributing](../../../CONTRIBUTING.md).
MD
build

cursor_skill=".cursor/skills/fixtures/SKILL.md"
assert_contains "${cursor_skill}" 'Sentinel paragraph' "Cursor skill carries the canonical edit"
assert_contains "${cursor_skill}" '`.cursor/skills/enums/SKILL.md`' "Cursor rewrites .claude/ path mentions"
assert_contains "${cursor_skill}" 'the `.cursor/rules/rules.mdc` Constitution' "Cursor rewrites CLAUDE.md mentions"
assert_contains "${cursor_skill}" '[Role](../../rules/rules.mdc#role)' "Cursor link to the Constitution targets rules.mdc"
assert_contains "${cursor_skill}" '[Enums](../enums/SKILL.md)' "Cursor link to a sibling skill stays relative"
assert_contains "${cursor_skill}" '[Contributing](../../../CONTRIBUTING.md)' "Cursor link to a root doc still resolves"

copilot_skill=".github/instructions/fixtures.instructions.md"
assert_contains "${copilot_skill}" 'Sentinel paragraph' "Copilot instructions carry the canonical edit"
assert_contains "${copilot_skill}" "applyTo: 'fixtures/**/*.ts'" "Copilot frontmatter carries the mapped applyTo"
assert_contains "${copilot_skill}" '`.github/instructions/enums.instructions.md`' "Copilot rewrites skill path mentions"
assert_contains "${copilot_skill}" 'the `.github/copilot-instructions.md` Constitution' "Copilot rewrites CLAUDE.md mentions"
assert_contains "${copilot_skill}" '[Role](../copilot-instructions.md#role)' "Copilot link to the Constitution targets copilot-instructions.md"
assert_contains "${copilot_skill}" '[Enums](enums.instructions.md)' "Copilot link to a sibling skill targets its flat file"
assert_contains "${copilot_skill}" '[Examples](references/examples.md)' "Copilot keeps the flat-form references/ link"
assert_contains "${copilot_skill}" '[Contributing](../../CONTRIBUTING.md)' "Copilot link to a root doc still resolves"
assert_contains ".github/instructions/fixtures/references/examples.md" '# ' "Copilot tree carries the skill's reference files"
if [[ -z "$(git -C "${SCRATCH}" status --porcelain -- .github/skills .github/prompts)" ]]; then
    pass "Copilot folder-form skill-creator and prompts are untouched"
else
    fail "build modified .github/skills or .github/prompts"
fi

# --- 3. A link with no Copilot counterpart fails the build ---
printf '\nSee [the reviewer](../pr-reviewer/SKILL.md).\n' >>"${SCRATCH}/.claude/skills/fixtures/SKILL.md"
if output="$(node "${SCRATCH}/scripts/build-mirrors.mjs" 2>&1)"; then
    fail "build accepted a link to a skill with no Copilot counterpart"
elif grep -q 'fixtures/SKILL.md' <<<"${output}" && grep -q 'pr-reviewer/SKILL.md' <<<"${output}"; then
    pass "build fails on a link with no Copilot counterpart and names file and link"
else
    fail "build failed without naming the file and link: ${output}"
fi

echo
if [[ "${failures}" -eq 0 ]]; then
    echo "All mirror build checks passed."
else
    echo "${failures} mirror build check(s) failed."
    exit 1
fi
