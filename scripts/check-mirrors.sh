#!/usr/bin/env bash
# check-mirrors.sh [root-dir]
#
# Fails when the committed Cursor and Copilot rule trees differ from a fresh
# build of the canonical Claude tree (CLAUDE.md + .claude/skills/). Runs
# scripts/build-mirrors.mjs in place, then asks git whether any mirror output
# changed, appeared or disappeared. A tree pruned at init is skipped by the
# build, so it shows no change here.
#
# The comparison is working tree against the git index, not against HEAD, plus
# untracked files: a mirror the build touched differs from what is staged or
# committed, while a freshly scaffolded project whose initial commit has not
# happened yet (no git identity on a CI runner, for example) still passes.
#
# Needs node (built-ins only) and git; no npm install. Run `npm run
# build:mirrors` and commit the result to fix a failure.

set -euo pipefail

# Optional first argument: root directory to check (default: the repo containing this script).
REPO_ROOT="$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd)"

# Output paths of the build (MIRRORS[*].outputs in build-mirrors.mjs).
MIRROR_PATHS=(
    .cursor/skills
    .cursor/rules/rules.mdc
    .github/instructions
    .github/copilot-instructions.md
)

node "${REPO_ROOT}/scripts/build-mirrors.mjs" "${REPO_ROOT}"

changes="$(
    git -C "${REPO_ROOT}" diff --name-status -- "${MIRROR_PATHS[@]}"
    git -C "${REPO_ROOT}" ls-files --others --exclude-standard -- "${MIRROR_PATHS[@]}" | sed 's/^/?? /'
)"
if [[ -z "${changes}" ]]; then
    echo "OK    mirrors match a fresh build"
    exit 0
fi

echo
echo "FAIL  committed mirrors differ from a fresh build of CLAUDE.md and .claude/skills/:"
echo "${changes}"
echo
git -C "${REPO_ROOT}" --no-pager diff -- "${MIRROR_PATHS[@]}"
echo
echo "The Cursor and Copilot trees are generated. Edit the canonical files, then run"
echo "  npm run build:mirrors"
echo "and commit the regenerated .cursor/ and .github/ files."
exit 1
