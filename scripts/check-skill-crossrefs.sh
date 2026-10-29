#!/usr/bin/env bash
# check-skill-crossrefs.sh [root-dir]
#
# Lints the orchestration layer's skill wiring -- the gaps not covered by the
# sibling link check (check-skill-references-drift.sh resolves links, anchors
# and references/*.md pointers). This script catches two failure modes:
#
#   1. Index drift       -- a skill dir exists under .claude/skills/ but is
#                           missing from the CLAUDE.md Skills Index, or the
#                           index lists a skill with no dir on disk.
#   2. Frontmatter drift -- SKILL.md frontmatter `name:` does not match its
#                           directory name, or `description:` is missing/empty.
#
# Exits non-zero on any drift so CI can gate.

set -euo pipefail

# Optional first argument: root directory to check (default: the repo containing this script).
REPO_ROOT="$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd)"
SKILLS_DIR="${REPO_ROOT}/.claude/skills"
CONSTITUTION="${REPO_ROOT}/CLAUDE.md"

if [[ ! -f "${CONSTITUTION}" && ! -d "${REPO_ROOT}/.claude" ]]; then
    echo "SKIP: Claude rule tree not present (pruned at init) — nothing to check."
    exit 0
fi

errors=0

# --- Collect skills on disk (dirs under .claude/skills/ that have a SKILL.md) ---
disk_skills=""
while IFS= read -r skill_md; do
    disk_skills="${disk_skills}$(basename "$(dirname "${skill_md}")")"$'\n'
done < <(find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | sort)

# --- Collect skills listed in the CLAUDE.md Skills Index table ---
index_skills="$(awk '/^## Skills Index/ { in_sec = 1; next }
                     in_sec && /^## /   { in_sec = 0 }
                     in_sec             { print }' "${CONSTITUTION}" \
    | grep -oE '^\| `[a-z0-9-]+`' \
    | grep -oE '[a-z0-9-]+' || true)"

# --- Check 1: index <-> disk sync (both directions) ---
while IFS= read -r name; do
    [[ -z "${name}" ]] && continue
    if ! printf '%s' "${disk_skills}" | grep -F -x -q -- "${name}"; then
        echo "DRIFT index :: \`${name}\` listed in CLAUDE.md Skills Index but .claude/skills/${name}/SKILL.md is missing"
        errors=$((errors + 1))
    fi
done <<< "${index_skills}"

while IFS= read -r name; do
    [[ -z "${name}" ]] && continue
    if ! printf '%s\n' "${index_skills}" | grep -F -x -q -- "${name}"; then
        echo "DRIFT index :: .claude/skills/${name}/ exists but is missing from the CLAUDE.md Skills Index"
        errors=$((errors + 1))
    fi
done <<< "${disk_skills}"

# --- Check 2: frontmatter name/description per SKILL.md ---
frontmatter_field() {
    # Print the value of a frontmatter field ($2) from file $1.
    awk -v field="$2" '
        NR == 1 && /^---$/ { in_fm = 1; next }
        in_fm && /^---$/   { exit }
        in_fm && index($0, field ":") == 1 {
            sub(field ":[ ]*", ""); print; exit
        }
    ' "$1"
}

while IFS= read -r name; do
    [[ -z "${name}" ]] && continue
    skill_md="${SKILLS_DIR}/${name}/SKILL.md"
    fm_name="$(frontmatter_field "${skill_md}" "name")"
    fm_desc="$(frontmatter_field "${skill_md}" "description")"
    if [[ "${fm_name}" != "${name}" ]]; then
        echo "DRIFT frontmatter :: ${name}/SKILL.md name is '${fm_name:-<missing>}', expected '${name}'"
        errors=$((errors + 1))
    fi
    if [[ -z "${fm_desc}" ]]; then
        echo "DRIFT frontmatter :: ${name}/SKILL.md has a missing or empty description"
        errors=$((errors + 1))
    fi
done <<< "${disk_skills}"

skill_count="$(printf '%s' "${disk_skills}" | grep -c . || true)"
echo
echo "Checked ${skill_count} skill(s); ${errors} drift(s)."
[[ "${errors}" -eq 0 ]] || exit 1
