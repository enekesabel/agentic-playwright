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
omitted-pruned|check-skill-references-drift.sh|0|0 drift(s)
omitted-present|check-skill-references-drift.sh|nonzero|README.md:3;path named in prose;CLAUDE.md
missing-anchor|check-skill-references-drift.sh|nonzero|README.md:5;CONTRIBUTING.md#rule-no-hard-wait;broken anchor
missing-anchor-in-comment|check-skill-references-drift.sh|nonzero|scripts/gate.sh:2;../README.md#rule-no-xpath;broken anchor
orphan-reference|check-skill-references-drift.sh|nonzero|.claude/skills/demo/SKILL.md;references/unlinked.md;orphan reference
vendored-orphan|check-skill-references-drift.sh|0|0 drift(s)
reference-style-link|check-skill-references-drift.sh|nonzero|SKILL.md:5;reference-style link definition;[n]
angle-bracket-link|check-skill-references-drift.sh|0|0 drift(s)
tilde-inside-fence|check-skill-references-drift.sh|0|0 drift(s)
clean|check-skill-references-drift.sh|0|0 drift(s)
path-in-prose|check-skill-references-drift.sh|nonzero|path named in prose, make it a link;AGENTS.md
path-in-prose-off|check-skill-references-drift.sh|0|0 drift(s)
legacy-reference|check-skill-references-drift.sh|nonzero|path named in prose
missing-reference|check-skill-references-drift.sh|nonzero|references/missing.md;file not found
vendored-broken-link|check-skill-references-drift.sh|nonzero|missing.md;file not found
vendored-prose|check-skill-references-drift.sh|0|0 drift(s)
rules-clean|check-rules-drift.sh|0|Checked 36 Constitution row(s);0 drift(s)
rules-uncovered|check-rules-drift.sh|nonzero|Imports (rule-imports) linked from no skill Critical block
rules-broken|check-rules-drift.sh|nonzero|SKILL.md:;broken Constitution row link;rule-missing
rules-fallback|check-rules-drift.sh|0|0 drift(s)
rules-vendored|check-rules-drift.sh|nonzero|Imports (rule-imports) linked from no skill Critical block
multiline-link|check-skill-references-drift.sh|nonzero|README.md:5;file not found
multiline-definition|check-skill-references-drift.sh|nonzero|README.md:5;reference-style link definition
fake-html-anchor|check-skill-references-drift.sh|nonzero|README.md:1;README.md:2;broken anchor
mixed-prose|check-skill-references-drift.sh|nonzero|path named in prose;AGENTS.md;references/missing.md
fallback-broken-reference|check-skill-references-drift.sh|nonzero|.agents/skills/demo/SKILL.md:3;file not found
rules-comment-owner|check-rules-drift.sh|nonzero|Imports (rule-imports) linked from no skill Critical block
rules-label|check-rules-drift.sh|nonzero|ownership label differs from row name
rules-stale|check-rules-drift.sh|nonzero|stale coverage exception
rules-hook-rename|check-rules-drift.sh|nonzero|no-playwright-test-import has no matching Constitution annotation
rules-hook-unmarked|check-rules-drift.sh|nonzero|no-playwright-test-import missing hook-rule-id marker
rules-hook-added|check-rules-drift.sh|nonzero|new-rule has no matching Constitution annotation
rules-special-gate|check-rules-drift.sh|nonzero|explore-before-generate annotation missing or broken
rules-hook-missing|check-rules-drift.sh|nonzero|enforce_constitution.py not found
CASES_EOF

failures=0
ran=0

while IFS='|' read -r fixture script expected substrings; do
    [[ -z "${fixture}" ]] && continue
    ran=$((ran + 1))
    label="${script} :: ${fixture}"

    set +e
    strict=1
    [[ "${fixture}" != "path-in-prose-off" ]] || strict=0
    fixture_root="${fixture}"
    output="$(STRICT_PROSE_PATHS="${strict}" bash "${SCRIPTS_DIR}/${script}" "${FIXTURES_DIR}/${fixture_root}" 2>&1)"
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
