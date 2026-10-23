#!/usr/bin/env bash
# run.sh -- fixture tests for the gate scripts.
#
# Runs a gate script against each fixture tree under fixtures/ (passing the
# fixture as the root-directory argument) and asserts the exit code and that
# the output names the offending file and the reason. Pure bash, so it runs in
# the skill-lint CI job, which installs nothing.
#
# Case format, one per line:
#   <fixture>|<script>|<expected exit: 0 or nonzero>|<substring>[;<substring>...]

set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "${TESTS_DIR}/.." && pwd)"
FIXTURES_DIR="${TESTS_DIR}/fixtures"

read -r -d '' CASES <<'CASES_EOF' || true
broken-link|check-skill-references-drift.sh|nonzero|README.md:5;docs/missing.md;file not found
missing-anchor|check-skill-references-drift.sh|nonzero|README.md:5;CONTRIBUTING.md#rule-no-hard-wait;broken anchor
missing-anchor-in-comment|check-skill-references-drift.sh|nonzero|scripts/gate.sh:2;../README.md#rule-no-xpath;broken anchor
missing-mdc-anchor-in-comment|check-skill-references-drift.sh|nonzero|scripts/gate.sh:2;rules.mdc#rule-absent;broken anchor
orphan-reference|check-skill-references-drift.sh|nonzero|.claude/skills/demo/SKILL.md;references/unlinked.md;orphan reference
clean|check-skill-references-drift.sh|0|0 drift(s)
index-lists-missing-skill|check-skill-crossrefs.sh|nonzero|DRIFT index;`ghost` listed in CLAUDE.md Skills Index;.claude/skills/ghost/SKILL.md is missing
skill-missing-from-index|check-skill-crossrefs.sh|nonzero|DRIFT index;.claude/skills/stray/ exists but is missing from the CLAUDE.md Skills Index
frontmatter-name-mismatch|check-skill-crossrefs.sh|nonzero|DRIFT frontmatter;alpha/SKILL.md name is 'alfa', expected 'alpha'
skills-index-clean|check-skill-crossrefs.sh|0|0 drift(s)
CASES_EOF

failures=0
ran=0

while IFS='|' read -r fixture script expected substrings; do
    [[ -z "${fixture}" ]] && continue
    ran=$((ran + 1))
    label="${script} :: ${fixture}"

    set +e
    output="$(bash "${SCRIPTS_DIR}/${script}" "${FIXTURES_DIR}/${fixture}" 2>&1)"
    status=$?
    set -e

    problems=""
    if [[ "${expected}" == "0" && "${status}" -ne 0 ]]; then
        problems="${problems}
  expected exit 0, got ${status}"
    elif [[ "${expected}" == "nonzero" && "${status}" -eq 0 ]]; then
        problems="${problems}
  expected a non-zero exit, got 0"
    fi

    IFS=';' read -r -a wanted <<< "${substrings}"
    for want in "${wanted[@]+"${wanted[@]}"}"; do
        [[ -z "${want}" ]] && continue
        if ! printf '%s' "${output}" | grep -F -q -- "${want}"; then
            problems="${problems}
  output does not contain '${want}'"
        fi
    done

    if [[ -z "${problems}" ]]; then
        echo "PASS  ${label}"
    else
        echo "FAIL  ${label}${problems}"
        printf '%s\n' "${output}" | sed 's/^/    | /'
        failures=$((failures + 1))
    fi
done <<< "${CASES}"

echo
echo "Ran ${ran} case(s); ${failures} failure(s)."
[[ "${failures}" -eq 0 ]] || exit 1
