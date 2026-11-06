# Workflow and review conversion notes

## Row wins

1. `.claude/skills/test-standards/SKILL.md:31` (original line), Test Isolation severity.
    - Row (SHOULD): "independent tests; `test.beforeEach` for setup."
    - Copy: "Tests **must be independent**: no ordering, no shared mutable state. Setup goes in `test.beforeEach()` or a fixture."
    - Action: replaced the mandatory restatement with the row link; retained no ordering/no shared mutable state and fixture setup as skill-local details.
    - **Revised in the final commit**: not a contradiction under the brief's test. Obeying a stronger local MUST does not violate a SHOULD row, so the v2.0.1 wording is back after the link: "[Test Isolation](…): tests **must be independent**: no ordering, no shared mutable state. Setup goes in `test.beforeEach()` or a fixture." Procedure step 4's imperative GIVEN / WHEN / THEN instruction was restored beside the Test Steps link for the same reason.
2. `.claude/skills/pr-reviewer/references/constitution-checklist.md:32` (original line), Selectors exception.
    - Row: "`getByRole()` > `getByLabel()` > `getByPlaceholder()` > `getByText()` > `getByTestId()`."
    - Copy: "Selector priority respected: `getByRole` > `getByLabel` > `getByPlaceholder` > `getByText` > `getByTestId` (one sanctioned exception: `getByLabel` for labelled form fields — selectors skill, Critical)"
    - Action: removed the exception; linked the row and added a checking instruction.
3. `.claude/skills/pr-reviewer/references/constitution-checklist.md:28` (original line), Sources of Truth.
    - Row: "URLs and credentials from `process.env.*` (`env/.env.example`); endpoint paths, routes, messages and storage-state paths from `enums/{area}/*` and `enums/util/*`."
    - Copy: "URLs/credentials from `process.env.*`; endpoint paths, routes, UI strings, storage-state paths from `enums/*` / `config/*` — nothing hardcoded"
    - Action: removed config as an alternative source; linked Sources of Truth and No Secrets with a checking instruction.

## Questions

None.

Skill-local details retained: State Cleanup hook success after failure/zero writes; Test Isolation ordering/shared-state and fixture setup; shared-state examples; ticket URLs for mismatch skips; page-object response waits; common-tasks coverage of every body field with universal arrays and baseline path/401/403/405 checks; existing local rules.

## Manifest lines removed

- `waitForTimeout|test-standards|No hard waits`
- `exactly one** tag|test-standards|Single-tag rule`
- `@destructive|test-standards|@destructive heaviest`
- `Every state-mutating test|test-standards|State cleanup hooks`
- `confirm zero failures|test-standards|Test verification after edits`
- `must be independent|test-standards|Test isolation`
- `explore-only|test-standards|No explore-only files`
- `expect(locator)|test-standards|Web-first assertions`

## Cap pressure

No cap failures. The closest SKILL.md word counts are ai-native-workflow 592/600 and pr-reviewer 585/600; these leave 8 and 15 words of headroom. All Critical blocks pass with at least 75 words of headroom.

## Files changed

- `.agents/skills/ai-native-workflow/SKILL.md`
- `.agents/skills/ai-native-workflow/references/conversation-contract.md`
- `.agents/skills/common-tasks/SKILL.md`
- `.agents/skills/common-tasks/references/templates/api-schemas.md`
- `.agents/skills/common-tasks/references/templates/data.md`
- `.agents/skills/common-tasks/references/templates/page-objects.md`
- `.agents/skills/common-tasks/references/templates/tests.md`
- `.agents/skills/common-tasks/references/verification-checklist.md`
- `.agents/skills/debugging/SKILL.md`
- `.agents/skills/pr-reviewer/SKILL.md`
- `.agents/skills/pr-reviewer/references/constitution-checklist.md`
- `.agents/skills/pr-reviewer/references/reporting.md`
- `.agents/skills/pr-reviewer/references/verification.md`
- `.agents/skills/refactor-values/SKILL.md`
- `.agents/skills/test-standards/SKILL.md`
- `.agents/skills/test-standards/references/destructive-tests.md`
- `.agents/skills/test-standards/references/tags.md`
- `.claude/skills/ai-native-workflow/SKILL.md`
- `.claude/skills/ai-native-workflow/references/conversation-contract.md`
- `.claude/skills/common-tasks/SKILL.md`
- `.claude/skills/common-tasks/references/templates/api-schemas.md`
- `.claude/skills/common-tasks/references/templates/data.md`
- `.claude/skills/common-tasks/references/templates/page-objects.md`
- `.claude/skills/common-tasks/references/templates/tests.md`
- `.claude/skills/common-tasks/references/verification-checklist.md`
- `.claude/skills/debugging/SKILL.md`
- `.claude/skills/pr-reviewer/SKILL.md`
- `.claude/skills/pr-reviewer/references/constitution-checklist.md`
- `.claude/skills/pr-reviewer/references/reporting.md`
- `.claude/skills/pr-reviewer/references/verification.md`
- `.claude/skills/refactor-values/SKILL.md`
- `.claude/skills/test-standards/SKILL.md`
- `.claude/skills/test-standards/references/destructive-tests.md`
- `.claude/skills/test-standards/references/tags.md`
- `scripts/rules-manifest.txt`
