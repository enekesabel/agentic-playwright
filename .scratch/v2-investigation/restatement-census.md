# Restatement census: 36 Constitution rules vs skills and root docs (v2.0.1)

Scope read: `AGENTS.md` (rule rows at lines 11-52), every non-vendored `.claude/skills/**/*.md`, `README.md`, `CONTRIBUTING.md`, `AI-WORKFLOWS.md`, `.github/prompts/pr-reviewer.prompt.md`. `.agents/`, `skill-creator` and `playwright-cli` ignored. Manifest: `scripts/rules-manifest.txt`.

Path prefix: `S/` = `.claude/skills/`. All line numbers are 1-based lines of the file as it stands in this checkout.

## Counting rules (so the numbers can be reproduced)

- Unit = one (rule, file) pair. Several lines of one file that say the same thing are one restatement; the lines are listed. A file that restates a rule is counted once even if it does so in both Critical and Procedure.
- Counted: Critical bullets, Procedure steps that instruct the same requirement (so every "run `npm run lint`" / "run `npx playwright test <file>`" step counts toward Linting / Test Verification), classification tables, checklist rows, README summary bullets, AI-WORKFLOWS flow rows and anti-pattern rows.
- Not counted: code examples that comply, the rule name merely appearing, "per `skill-x`" pointers that do not restate the requirement, the AGENTS.md rows themselves.
- A sentence that restates two Constitution rules counts under both.
- MANDATED = a manifest token maps this rule to this skill (the SKILL.md, in its Critical block). A token's label decides which rule it serves. Everything else is INCIDENTAL, including restatements in `references/*.md` of the same skill, because the gate only reads the Critical block.
- Manifest tokens that serve no Constitution rule (skill-local rules): `fuzz path parameters` (`S/api-testing/SKILL.md:33`) and `find all consumers` (`S/refactor-values/SKILL.md:10`). Excluded from the counts.
- Two tokens serve one rule: `exactly one** tag` (`S/test-standards/SKILL.md:11`) and `@destructive` (`S/test-standards/SKILL.md:20`) both map to No Multiple Tags. One token (`test.skip`, `S/api-testing/SKILL.md:22`, label "Behaviour-mismatch protocol") is attributed to both Explore Before Generate (API half) and No Silent Coverage Drops, because both rows contain `test.skip`. `expect(locator)` and `waitForTimeout` are both on `S/test-standards/SKILL.md:22` and serve Assertions and No Hard Waits. The `Faker factory` and `hardcode test content strings` tokens are both on `S/data-strategy/SKILL.md:19` and serve Data Generation and No Hardcoded Test Content. `S/page-objects/SKILL.md:12` (token `Forbidden** on locator getters`, label "JSDoc rules on actions only") serves both JSDoc on Actions and No JSDoc on Locators.
- Judgement calls: `S/type-safety/SKILL.md:10` (token `NEVER** use any`) is MANDATED for No any and counted INCIDENTAL for Type Safety, because the token label names "No any", although Type Safety's row also says "no `any`". `S/fixtures/SKILL.md:10` (token `new AppPage(page)`) is MANDATED for No Manual Instantiation and INCIDENTAL for Dependency Injection for the same reason. `S/test-standards/SKILL.md:11` is INCIDENTAL for No Tags on Describe although it sits on a mandated line, because the token (`exactly one** tag`) does not pin the describe ban; deleting that clause would not fail the gate.

## 1. Table

| #   | Rule                         | Restatements | Mandated | Incidental | Files (count)                                                                                                                                                                                                 |
| --- | ---------------------------- | -----------: | -------: | ---------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Dependency Injection         |            6 |        0 |          6 | fixtures, page-objects, PR checklist, AI-WORKFLOWS, README, CONTRIBUTING                                                                                                                                      |
| 2   | Imports                      |            6 |        1 |          5 | fixtures*, test-standards, fixtures/lifecycle, PR checklist, AI-WORKFLOWS, README                                                                                                                             |
| 3   | Selectors                    |            5 |        1 |          4 | selectors*, selectors/locator-choice, PR checklist, AI-WORKFLOWS, README                                                                                                                                      |
| 4   | Type Safety                  |            7 |        0 |          7 | type-safety, api-testing, PR checklist, AI-WORKFLOWS, README, CONTRIBUTING, PR prompt                                                                                                                         |
| 5   | Strict Schemas               |            8 |        1 |          7 | type-safety*, type-safety/zod-usage, common-tasks/api-schemas, PR checklist, AI-WORKFLOWS, README, CONTRIBUTING, PR prompt                                                                                    |
| 6   | Response Validation          |            8 |        1 |          7 | api-testing*, fixtures, type-safety, helpers, api-testing/coverage-matrix, PR checklist, AI-WORKFLOWS, PR prompt                                                                                              |
| 7   | Sources of Truth             |           14 |        2 |         12 | config*, enums*, api-testing, helpers, helpers/auth-bootstrap, page-objects, selectors, data-strategy, common-tasks/verification-checklist, common-tasks/tests, PR checklist, AI-WORKFLOWS, README, PR prompt |
| 8   | Assertions                   |            6 |        1 |          5 | test-standards*, page-objects, debugging, PR checklist, AI-WORKFLOWS, README                                                                                                                                  |
| 9   | Linting                      |           18 |        0 |         18 | 18 files, see appendix                                                                                                                                                                                        |
| 10  | Data Strategy                |            7 |        0 |          7 | data-strategy, data-strategy/static-data-tiers, api-testing/negative-testing, common-tasks/data, PR checklist, AI-WORKFLOWS, README                                                                           |
| 11  | State Cleanup                |            9 |        1 |          8 | test-standards*, test-standards/destructive-tests, api-testing/multi-call-steps, api-testing/coverage-matrix, common-tasks/verification-checklist, PR checklist, PR prompt, AI-WORKFLOWS, README              |
| 12  | API Test Steps               |            5 |        1 |          4 | api-testing*, api-testing/multi-call-steps, PR checklist, AI-WORKFLOWS, PR prompt                                                                                                                             |
| 13  | Test Verification            |           15 |        1 |         14 | test-standards*, 14 others, see appendix                                                                                                                                                                      |
| 14  | Explore Before Generate      |           21 |        2 |         19 | selectors* (UI), api-testing* (API), 19 others, see appendix                                                                                                                                                  |
| 15  | Data Generation              |           13 |        1 |         12 | data-strategy*, 12 others, see appendix                                                                                                                                                                       |
| 16  | Test Isolation               |            3 |        1 |          2 | test-standards*, test-standards/destructive-tests, README                                                                                                                                                     |
| 17  | Test Steps                   |            4 |        0 |          4 | test-standards, PR checklist, AI-WORKFLOWS, README                                                                                                                                                            |
| 18  | JSDoc on Actions             |            6 |        1 |          5 | page-objects*, page-objects/components, common-tasks/page-objects, PR checklist, AI-WORKFLOWS, README                                                                                                         |
| 19  | Enums for Strings            |            6 |        0 |          6 | enums, selectors, page-objects, data-strategy, PR checklist, AI-WORKFLOWS                                                                                                                                     |
| 20  | No XPath                     |            5 |        1 |          4 | selectors*, PR checklist, AI-WORKFLOWS, README, PR prompt                                                                                                                                                     |
| 21  | No Hard Waits                |            7 |        1 |          6 | test-standards*, page-objects, debugging, PR checklist, AI-WORKFLOWS, README, PR prompt                                                                                                                       |
| 22  | No Secrets                   |           10 |        1 |          9 | api-testing*, config, helpers, ai-native-workflow, common-tasks/verification-checklist, pr-reviewer, pr-reviewer/verification, PR checklist, AI-WORKFLOWS, PR prompt                                          |
| 23  | No `any`                     |            6 |        1 |          5 | type-safety*, PR checklist, AI-WORKFLOWS, README, CONTRIBUTING, PR prompt                                                                                                                                     |
| 24  | No Tags on Describe          |            5 |        0 |          5 | test-standards, test-standards/tags, PR checklist, AI-WORKFLOWS, README                                                                                                                                       |
| 25  | No Multiple Tags             |            8 |        1 |          7 | test-standards* (two tokens, one pair), test-standards/tags, test-standards/destructive-tests, PR checklist, AI-WORKFLOWS, README, CONTRIBUTING, PR prompt                                                    |
| 26  | No Magic Numbers             |            4 |        1 |          3 | data-strategy*, enums, PR checklist, README                                                                                                                                                                   |
| 27  | No Manual Instantiation      |            4 |        1 |          3 | fixtures*, PR checklist, AI-WORKFLOWS, README                                                                                                                                                                 |
| 28  | No Loose Schemas             |            6 |        0 |          6 | type-safety, type-safety/zod-usage, PR checklist, AI-WORKFLOWS, pr-reviewer, PR prompt                                                                                                                        |
| 29  | No JSDoc on Locators         |            5 |        1 |          4 | page-objects*, page-objects/components, PR checklist, AI-WORKFLOWS, README                                                                                                                                    |
| 30  | No Hardcoded Test Content    |            6 |        1 |          5 | data-strategy*, common-tasks/verification-checklist, PR checklist, AI-WORKFLOWS, README, PR prompt                                                                                                            |
| 31  | No Explore-Only Files        |            3 |        1 |          2 | test-standards*, common-tasks/verification-checklist, PR checklist                                                                                                                                            |
| 32  | No Empty-Body-Only 400       |            7 |        1 |          6 | api-testing*, api-testing/negative-testing, api-testing/coverage-matrix, common-tasks/verification-checklist, common-tasks/tests, PR checklist, AI-WORKFLOWS                                                  |
| 33  | No Feedback-Less POM         |            7 |        1 |          6 | page-objects*, selectors, selectors/feedback-selectors, common-tasks/verification-checklist, PR checklist, AI-WORKFLOWS, README                                                                               |
| 34  | No Substitute UI Exploration |            3 |        0 |          3 | common-tasks/page-objects, PR checklist, AI-WORKFLOWS                                                                                                                                                         |
| 35  | No Silent Coverage Drops     |           10 |        1 |          9 | api-testing*, api-testing/coverage-matrix, debugging, common-tasks/verification-checklist, common-tasks/tests, pr-reviewer, PR checklist, AI-WORKFLOWS, README, PR prompt                                     |
| 36  | No JSON Static Data          |            6 |        1 |          5 | data-strategy*, data-strategy/static-data-tiers, common-tasks/data, PR checklist, AI-WORKFLOWS, README                                                                                                        |

`*` = the file where the restatement is MANDATED. "PR checklist" = `S/pr-reviewer/references/constitution-checklist.md`. "PR prompt" = `.github/prompts/pr-reviewer.prompt.md`.

## 2. Totals

- Rules with zero restatements: 0 of 36.
- Rules restated once: 0 of 36.
- Rules restated 2+ times: 36 of 36 (minimum is 3: Test Isolation, No Explore-Only Files, No Substitute UI Exploration; maximum is 21).
- Total restatements: 269. MANDATED: 29. INCIDENTAL: 240.
- 27 rules have at least one mandated restatement (two of them, Sources of Truth and Explore Before Generate, have two). 9 rules have none: Dependency Injection, Type Safety, Linting, Data Strategy, Test Steps, Enums for Strings, No Tags on Describe, No Loose Schemas, No Substitute UI Exploration.
- The 29 mandated restatements by skill Critical block: test-standards 7, api-testing 6, data-strategy 4, page-objects 3, selectors 3, type-safety 2, fixtures 2, config 1, enums 1. The other 8 skills (helpers, debugging, refactor-values, common-tasks, ai-native-workflow, pr-reviewer, playwright-cli, skill-creator) carry no mandated Constitution restatement.

## 3. Ten most restated rules

Rank / rule / count; locations are in the appendix with full line numbers.

1. Explore Before Generate: 21. Includes `S/selectors/SKILL.md:20` and `S/api-testing/SKILL.md:22` (mandated), plus `S/api-testing/SKILL.md:11`, `S/api-testing/references/contract-sourcing.md:3`, `S/common-tasks/references/templates/api-schemas.md:10`, `S/ai-native-workflow/references/conversation-contract.md:12`, `S/ai-native-workflow/SKILL.md:11`, `S/debugging/SKILL.md:11`, `S/type-safety/SKILL.md:42`, `S/refactor-values/SKILL.md:12`, `S/data-strategy/references/factories.md:45`, `S/page-objects/SKILL.md:10`, `S/enums/SKILL.md:24`, `S/selectors/references/exploration-workflow.md:25`, checklist and docs.
2. Linting: 18, all incidental (no manifest token at all).
3. Test Verification: 15 (1 mandated).
4. Sources of Truth: 14 (2 mandated).
5. Data Generation: 13 (1 mandated).
6. No Secrets: 10 (1 mandated).
7. No Silent Coverage Drops: 10 (1 mandated).
8. State Cleanup: 9 (1 mandated).
9. (three-way tie at 8) Strict Schemas, Response Validation, No Multiple Tags.

## 4. Restatements whose wording differs in substance from the AGENTS.md row

Each entry: AGENTS row, then the differing sentence, then direction.

1. **Explore Before Generate (API), different procedure when no contract exists.**
   `AGENTS.md:24`: "live capture only when none exists, flagged". `S/api-testing/SKILL.md:11`: "no document found: stop and ask." `S/api-testing/references/contract-sourcing.md:11`: "Nothing found: stop and ask." Yet `S/api-testing/references/contract-sourcing.md:27`: "Make one real request per status code ... flag the missing documentation" and `S/ai-native-workflow/references/conversation-contract.md:12`, `S/common-tasks/references/templates/api-schemas.md:13-15` follow AGENTS. Stricter in the Critical block, matching in the reference; the two skill passages disagree with each other.

2. **Explore Before Generate (UI), looser fallback.**
   `AGENTS.md:24`: "cannot run means stop and tell the human." `S/enums/SKILL.md:24`: "app unreachable: add it with `// FIXME: unverified` and say so in the report." Proceeds instead of stopping (scope: UI message strings only).

3. **Response Validation, carve-outs for the "exact pattern".**
   `AGENTS.md:16`: "exactly `expect(SchemaName.parse(body)).toBeTruthy();`". `S/api-testing/SKILL.md:12`: "in fixture code, with no test to assert in, `const x = SchemaName.parse(body);`" (same carve-out at `S/fixtures/SKILL.md:28` and `S/type-safety/SKILL.md:41`). `S/api-testing/references/coverage-matrix.md:20`: "When the contract documents no body for a code, assert `expect(body).toBeNull()` instead of a parse." Looser (exceptions not in the row).

4. **Selectors, exception and extra tier.**
   `AGENTS.md:13`: `getByRole()` > `getByLabel()` > `getByPlaceholder()` > `getByText()` > `getByTestId()`. `S/selectors/SKILL.md:10`: "a labelled form field takes `getByLabel('Email')` over `getByRole('textbox', ...)`" (also `S/selectors/references/locator-choice.md:27-29`, `S/pr-reviewer/references/constitution-checklist.md:32`). `S/selectors/SKILL.md:19`: "CSS class or id selectors only as a last resort". Different order and an added tier. Contradicted inside the skill by `S/selectors/references/locator-choice.md:42`: "A class-based locator does not ship."

5. **No XPath, softened in README.**
   `AGENTS.md:36`: "No XPath." `README.md:970`: "`page.locator()` -- CSS/XPath (last resort)" as tier 6 of the priority list; `README.md:1349`: "Prefer `getByRole`, `getByLabel` over CSS/XPath". Looser (permits or merely discourages).

6. **No Empty-Body-Only 400, scope of "per-field" and of the status code.**
   `AGENTS.md:48`: "per-field omission and invalid-type `for...of` tests" for a 400. `S/api-testing/references/negative-testing.md:52` and `S/api-testing/references/coverage-matrix.md:11`: omission test "per required field" only (the optional-field rationale at `S/api-testing/references/negative-testing.md:9`). `S/common-tasks/references/verification-checklist.md:12`: "every body field has a per-field omission test". Narrower in the api-testing skill, wider in the checklist. Status: `S/api-testing/references/coverage-matrix.md:10` and `S/api-testing/references/negative-testing.md:3` accept "400/422", while `S/api-testing/SKILL.md:22` says "422 where the spec says 400 is still a mismatch".

7. **No Silent Coverage Drops, broader than "documented".**
   `AGENTS.md:51`: "every documented status code has a test or a `test.skip` with `// FIXME`". `S/api-testing/references/coverage-matrix.md:3`: "plus the baseline rows below" (401, 403, 405, 404 path-fuzz whether documented or not); `S/common-tasks/references/verification-checklist.md:13`: "secured endpoints have 401 and 403 tests; every endpoint has one 405 test". Stricter. Also `AGENTS.md:24,51` say `// FIXME`; `S/api-testing/SKILL.md:22` and `S/debugging/SKILL.md:11` require `// FIXME: <ticket-url>`; `.github/prompts/pr-reviewer.prompt.md:118` `// FIXME: <ticket>`. Stricter (ticket link required).

8. **No Hardcoded Test Content, labels and inline carve-out.**
   `AGENTS.md:46`: "names, labels and text come from factories." `S/data-strategy/SKILL.md:19`: "(names, emails, descriptions, product names)"; `S/data-strategy/SKILL.md:30`: "Never Faker-generate an app-defined string (error message, label, heading, route); those come from `enums/{area}/*`". Labels move from factories to enums. `S/data-strategy/SKILL.md:31`: "A value used in exactly one assertion stays inline in the test" is a carve-out the row lacks.

9. **No Feedback-Less POM, broader feedback set.**
   `AGENTS.md:49`: "success, error and validation selectors". `S/selectors/SKILL.md:22`: "success, error, field validation, and toast, loading or empty state where the app shows them" and `S/selectors/references/feedback-selectors.md:3`: "a locator for each outcome the app renders". Stricter.

10. **JSDoc on Actions, "only" vs JSDoc required elsewhere; SHOULD vs required.**
    `AGENTS.md:31`: "JSDoc (`@param`, `@returns`) on action methods only." `S/helpers/SKILL.md:12`: "Every exported helper has ... a JSDoc block with `@param` and `@returns`"; `S/data-strategy/references/factories.md:32`: factory JSDoc required; `S/enums/SKILL.md:23`: "Every enum declaration carries a JSDoc line"; `S/config/SKILL.md:21`: config property "with a JSDoc line"; `S/page-objects/references/components.md:32`: "a one-line JSDoc on [a component field] is allowed". Scope wider than "action methods only". `S/page-objects/SKILL.md:12`: JSDoc "required on every action and verification method" while AGENTS lists it under SHOULD (stricter; same line is a mandated token).

11. **SHOULD rules restated as Critical requirements.**
    `AGENTS.md:29` Test Isolation (SHOULD): "independent tests; `test.beforeEach` for setup." `S/test-standards/SKILL.md:31`: "Tests **must be independent** ... Setup goes in `test.beforeEach()` or a fixture." (mandated token `must be independent`; "or a fixture" is an addition). `AGENTS.md:32` Enums for Strings (SHOULD): "repeated strings come from `enums/`." `S/enums/SKILL.md:21`: "Any app-defined string used in more than one place ... lives in an enum and is imported." Severity raised.

12. **State Cleanup, extra requirement.**
    `AGENTS.md:21`: "reverts it in `afterEach` or `afterAll`." `S/test-standards/SKILL.md:21`: "... and the hook succeeds after a failed test"; `S/test-standards/references/destructive-tests.md:47`: "it must succeed when the test wrote nothing." Stricter (idempotent hook).

13. **No any, wider and narrower.**
    `AGENTS.md:39`: "No `any`." `S/type-safety/SKILL.md:10`: "NEVER use `any`, `@ts-ignore` or `@ts-expect-error`" (and `S/type-safety/SKILL.md:11` bans `as T`). Stricter. `README.md:1316`: "Avoid `any` | Use proper types or `unknown`". Looser (avoid, not never).

14. **No Loose Schemas / Strict Schemas, `looseObject` allowance.**
    `AGENTS.md:15,44`: "API schemas use `z.strictObject()`"; "never `z.object()`". `S/type-safety/references/zod-usage.md:32`: "`.passthrough()` -> `z.looseObject()`, only where the contract allows unknown keys". Looser (an exception not in the rows).

15. **Imports, scope.**
    `AGENTS.md:12`: "`test` and `expect` from `fixtures/pom/test-options.ts` only, never `@playwright/test`" (no scope qualifier). `S/fixtures/SKILL.md:11`: "Spec files import ..."; `S/page-objects/SKILL.md:11`: page objects import from `@playwright/test`, "never from `fixtures/pom/test-options.ts`"; `S/fixtures/references/lifecycle.md:10` fixture files import `test as base` from `@playwright/test`. The skills scope the rule to spec files; the AGENTS row reads as repo-wide.

16. **Sources of Truth, `config/` named as a source.**
    `AGENTS.md:17`: URLs and credentials from `process.env.*`; paths, routes, messages from `enums/`. `S/pr-reviewer/references/constitution-checklist.md:28`: "from `enums/*` / `config/*`"; `.github/prompts/pr-reviewer.prompt.md:116`: "URLs/paths/messages from `config`/`enums`". `S/config/SKILL.md:19` says endpoint paths are enums, "never config properties". Different scope in the reviewer text.

17. **No Magic Numbers, home and carve-outs.**
    `AGENTS.md:42`: "constants in `config/` or `enums/`." `S/data-strategy/SKILL.md:33`: suite tuning in `playwright.config.ts`, "a per-assertion `{ timeout }` only with a comment saying why"; `S/enums/SKILL.md:36`: HTTP status code stays an "inline literal ... the sanctioned carve-out from the magic-number rule". `README.md:1362`: "No Hardcoded Timeouts -- Rely on Playwright's auto-waiting" (narrower). Looser in the skills (home and exceptions), narrower in README.

18. **No JSON Static Data, additional bans.**
    `AGENTS.md:52`: "`.ts` with `as const`." `S/data-strategy/SKILL.md:10`: "no runtime import, no function, no computed value, no Faker call". Stricter.

19. **Test Steps, naming scheme for API steps.**
    `AGENTS.md:30`: "`test.step()` with Given/When/Then." `S/api-testing/references/multi-call-steps.md:3`: steps "named `<verb> <resource> via <METHOD> <path>`". Different naming for API tests.

## Appendix: per-rule locations

Format: `file:lines` M (mandated) or I (incidental). `S/` = `.claude/skills/`. `PRC` = `S/pr-reviewer/references/constitution-checklist.md`. `PRP` = `.github/prompts/pr-reviewer.prompt.md`. `AW` = `AI-WORKFLOWS.md`. `RM` = `README.md`. `CON` = `CONTRIBUTING.md`.

1. Dependency Injection: S/fixtures/SKILL.md:10 I; S/page-objects/SKILL.md:30 I; PRC:15 I; AW:183,308 I; RM:80,1372 I; CON:27 I.
2. Imports: S/fixtures/SKILL.md:11 M; S/test-standards/SKILL.md:10 I; S/fixtures/references/lifecycle.md:71 I; PRC:14 I; AW:119 I; RM:845,1372,1532 I.
3. Selectors: S/selectors/SKILL.md:10 M; S/selectors/references/locator-choice.md:6-22,27-29 I; PRC:32 I; AW:117,181 I; RM:963-970,1349 I.
4. Type Safety: S/type-safety/SKILL.md:10,38 I; S/api-testing/SKILL.md:39 I; PRC:17 I; AW:307 I; RM:1316 I; CON:27 I; PRP:117 I.
5. Strict Schemas: S/type-safety/SKILL.md:21 M; S/type-safety/references/zod-usage.md:36 I; S/common-tasks/references/templates/api-schemas.md:30 I; PRC:18 I; AW:91,196,301 I; RM:1374 I; CON:27 I; PRP:116 I.
6. Response Validation: S/api-testing/SKILL.md:12 M; S/fixtures/SKILL.md:28 I; S/type-safety/SKILL.md:41 I; S/helpers/SKILL.md:24 I; S/api-testing/references/coverage-matrix.md:20 I; PRC:23 I; AW:95,198,302 I; PRP:116 I.
7. Sources of Truth: S/config/SKILL.md:10 M (also 19,20,27 I-lines same file); S/enums/SKILL.md:21 M (also 33); S/api-testing/SKILL.md:10 I; S/helpers/SKILL.md:23 I; S/helpers/references/auth-bootstrap.md:15 I; S/page-objects/SKILL.md:27 I; S/selectors/SKILL.md:21 I; S/data-strategy/SKILL.md:30 I; S/common-tasks/references/verification-checklist.md:6 I; S/common-tasks/references/templates/tests.md:43 I; PRC:28 I; AW:92,270,273,309 I; RM:1373 I; PRP:116 I.
8. Assertions: S/test-standards/SKILL.md:22 M; S/page-objects/SKILL.md:28 I; S/debugging/SKILL.md:12 I; PRC:38 I; AW:120,137,307 I; RM:80,1361,1376 I.
9. Linting (all I): S/test-standards/SKILL.md:43; S/api-testing/SKILL.md:45; S/page-objects/SKILL.md:40; S/type-safety/SKILL.md:42; S/enums/SKILL.md:41; S/data-strategy/SKILL.md:48; S/helpers/SKILL.md:32; S/debugging/SKILL.md:16,39; S/refactor-values/SKILL.md:22; S/ai-native-workflow/SKILL.md:55; S/common-tasks/references/verification-checklist.md:3; S/pr-reviewer/SKILL.md:41; PRC:49; S/pr-reviewer/references/verification.md:7; AW:43; CON:11,20; RM:1376; PRP:86-87.
10. Data Strategy (all I): S/data-strategy/SKILL.md:28,39-43; S/data-strategy/references/static-data-tiers.md:7-9; S/api-testing/references/negative-testing.md:5; S/common-tasks/references/templates/data.md:19; PRC:43; AW:93,212; RM:1121-1123.
11. State Cleanup: S/test-standards/SKILL.md:21 M (also 42); S/test-standards/references/destructive-tests.md:12 I; S/api-testing/references/multi-call-steps.md:3 I; S/api-testing/references/coverage-matrix.md:25 I; S/common-tasks/references/verification-checklist.md:8 I; PRC:46 I; PRP:116 I; AW:306 I; RM:800 I.
12. API Test Steps: S/api-testing/SKILL.md:21 M; S/api-testing/references/multi-call-steps.md:3,57 I; PRC:24 I; AW:95 I; PRP:116 I.
13. Test Verification: S/test-standards/SKILL.md:33 M (also 43); I: S/api-testing/SKILL.md:45; S/page-objects/SKILL.md:40; S/fixtures/SKILL.md:47; S/enums/SKILL.md:41; S/data-strategy/SKILL.md:48; S/helpers/SKILL.md:32; S/refactor-values/SKILL.md:22,35; S/debugging/SKILL.md:16,39; S/ai-native-workflow/SKILL.md:55; S/common-tasks/SKILL.md:30; S/common-tasks/references/verification-checklist.md:15; S/config/SKILL.md:31; AW:43; CON:22.
14. Explore Before Generate: S/api-testing/SKILL.md:22 M (API mismatch half); S/selectors/SKILL.md:20 M (UI half); I: S/api-testing/SKILL.md:11 (same file as the M, listed for the stop-and-ask wording); S/api-testing/references/contract-sourcing.md:3,17-23,25-27; S/common-tasks/references/templates/api-schemas.md:10,13-20; S/ai-native-workflow/references/conversation-contract.md:12; S/ai-native-workflow/SKILL.md:11; S/debugging/SKILL.md:11,30; S/type-safety/SKILL.md:42; S/refactor-values/SKILL.md:12,34; S/data-strategy/references/factories.md:45; S/common-tasks/references/verification-checklist.md:11; S/page-objects/SKILL.md:10,35; S/enums/SKILL.md:24,39; S/selectors/references/exploration-workflow.md:25-29; S/common-tasks/references/templates/page-objects.md:3,21; S/common-tasks/references/templates/tests.md:22,43; PRC:19,36; S/pr-reviewer/SKILL.md:17; PRP:118,156; AW:89,98,115,133,162,164,179,194,199; RM:1374,1375.
15. Data Generation: S/data-strategy/SKILL.md:19 M; I: S/data-strategy/references/factories.md:3; S/data-strategy/references/static-data-tiers.md:49; S/common-tasks/references/templates/data.md:14; S/common-tasks/references/templates/tests.md:14,22; S/common-tasks/references/verification-checklist.md:7; S/test-standards/SKILL.md:41; S/api-testing/SKILL.md:41; S/fixtures/SKILL.md:45; PRC:41; AW:93,118,137,211; RM:1373.
16. Test Isolation: S/test-standards/SKILL.md:31 M; S/test-standards/references/destructive-tests.md:58-59 I; RM:1360 I.
17. Test Steps (all I): S/test-standards/SKILL.md:40; PRC:47; AW:119; RM:1359.
18. JSDoc on Actions: S/page-objects/SKILL.md:12 M; S/page-objects/references/components.md:3 I; S/common-tasks/references/templates/page-objects.md:50 I; PRC:35 I; AW:181 I; RM:403,1352 I.
19. Enums for Strings (all I): S/enums/SKILL.md:21,40; S/selectors/SKILL.md:21; S/page-objects/SKILL.md:27; S/data-strategy/SKILL.md:30; PRC:29; AW:258.
20. No XPath: S/selectors/SKILL.md:19 M; PRC:33 I; AW:307 I; RM:970,1349 I (softened, see section 4); PRP:117 I.
21. No Hard Waits: S/test-standards/SKILL.md:22 M; S/page-objects/SKILL.md:28 I; S/debugging/SKILL.md:12 I; PRC:38 I; AW:307 I; RM:80,1362 I; PRP:117 I.
22. No Secrets: S/api-testing/SKILL.md:10 M; S/config/SKILL.md:10,20 I; S/helpers/SKILL.md:23 I; S/ai-native-workflow/SKILL.md:12 I; S/common-tasks/references/verification-checklist.md:6 I; S/pr-reviewer/SKILL.md:16 I; S/pr-reviewer/references/verification.md:35 I; PRC:28 I; AW:309 I; PRP:108,117 I.
23. No any: S/type-safety/SKILL.md:10 M; PRC:17 I; AW:307 I; RM:80,1316 I; CON:27 I; PRP:117 I.
24. No Tags on Describe (all I): S/test-standards/SKILL.md:11; S/test-standards/references/tags.md:3,24; PRC:45; AW:304; RM:770,835,1358.
25. No Multiple Tags: S/test-standards/SKILL.md:11,20 M; S/test-standards/references/tags.md:3,14,22 I; S/test-standards/references/destructive-tests.md:5,12 I; PRC:45,46 I; AW:120,304,305 I; RM:80,770,774,1357 I; CON:27 I; PRP:116 I.
26. No Magic Numbers: S/data-strategy/SKILL.md:33 M; S/enums/SKILL.md:36 I; PRC:39 I; RM:1362 I.
27. No Manual Instantiation: S/fixtures/SKILL.md:10 M; PRC:15 I; AW:183,308 I; RM:1372 I.
28. No Loose Schemas (all I): S/type-safety/SKILL.md:21; S/type-safety/references/zod-usage.md:36; PRC:18; AW:301; S/pr-reviewer/SKILL.md:17; PRP:116,118.
29. No JSDoc on Locators: S/page-objects/SKILL.md:12 M; S/page-objects/references/components.md:3 I; PRC:35 I; AW:181 I; RM:1352 I.
30. No Hardcoded Test Content: S/data-strategy/SKILL.md:19 M; S/common-tasks/references/verification-checklist.md:7 I; PRC:41 I; AW:118 I; RM:1373 I; PRP:117 I.
31. No Explore-Only Files: S/test-standards/SKILL.md:32 M; S/common-tasks/references/verification-checklist.md:14 I; PRC:51 I.
32. No Empty-Body-Only 400: S/api-testing/SKILL.md:32 M; S/api-testing/references/negative-testing.md:5-9,48,52 I; S/api-testing/references/coverage-matrix.md:10-12 I; S/common-tasks/references/verification-checklist.md:12 I; S/common-tasks/references/templates/tests.md:43 I; PRC:26 I; AW:97 I.
33. No Feedback-Less POM: S/page-objects/SKILL.md:26 M; S/selectors/SKILL.md:22 I; S/selectors/references/feedback-selectors.md:3 I; S/common-tasks/references/verification-checklist.md:10 I; PRC:34 I; AW:117,181 I; RM:1350 I.
34. No Substitute UI Exploration (all I): S/common-tasks/references/templates/page-objects.md:3,21; PRC:36; AW:115,179. No Critical block names IDE browser, MCP browser or `codegen`; `S/selectors/SKILL.md:20` states the mandate only.
35. No Silent Coverage Drops: S/api-testing/SKILL.md:22 M (also 45); S/api-testing/references/coverage-matrix.md:3,16 I; S/debugging/SKILL.md:11 I; S/common-tasks/references/verification-checklist.md:11 I; S/common-tasks/references/templates/tests.md:43 I; S/pr-reviewer/SKILL.md:17 I; PRC:25 I; AW:98 I; RM:1374 I; PRP:117,156 I.
36. No JSON Static Data: S/data-strategy/SKILL.md:10 M; S/data-strategy/references/static-data-tiers.md:3 I; S/common-tasks/references/templates/data.md:25 I; PRC:42 I; AW:213,310 I; RM:1117 I.
