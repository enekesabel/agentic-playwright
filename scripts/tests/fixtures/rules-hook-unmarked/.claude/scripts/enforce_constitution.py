# Fixture stub of .claude/scripts/enforce_constitution.py. It keeps only what
# scripts/check-rules-drift.sh parses: the RULES ids with the Constitution row
# annotation above each id, the hook-rule-id markers and the two special gates.
RULES = [
    (
        # AGENTS.md#rule-imports
        "no-playwright-test-import",
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-hard-waits, AGENTS.md#rule-assertions
        "no-hard-wait",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-strict-schemas, AGENTS.md#rule-no-loose-schemas
        "no-loose-schema",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-xpath, AGENTS.md#rule-selectors
        "no-xpath",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-json-static-data
        "no-json-static-data",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-multiple-tags
        "no-functional-tag",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-multiple-tags
        "no-multiple-tags",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-tags-on-describe
        "no-tags-on-describe",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-dependency-injection, AGENTS.md#rule-no-manual-instantiation
        "no-manual-instantiation",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-data-strategy
        "no-runtime-code-in-static-data",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-sources-of-truth
        "no-hardcoded-url",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-sources-of-truth
        "no-hardcoded-goto-url",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-data-strategy
        "no-inline-universal-invalids",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-multiple-tags
        "no-unknown-tag",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-jsdoc-on-locators, AGENTS.md#rule-jsdoc-on-actions
        "no-jsdoc-on-locators",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-hardcoded-test-content, AGENTS.md#rule-sources-of-truth
        "no-hardcoded-test-content",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-no-multiple-tags
        "no-missing-tag",  # hook-rule-id
        None,
        None,
        "",
    ),
    (
        # AGENTS.md#rule-linting
        "no-eslint-disable-scaffold",  # hook-rule-id
        None,
        None,
        "",
    ),
]

SPECIAL_GATES = "[protected-path] [explore-before-generate]"
# AGENTS.md#rule-explore-before-generate, AGENTS.md#rule-no-substitute-ui-exploration
