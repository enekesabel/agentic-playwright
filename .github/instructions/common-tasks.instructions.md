---
applyTo: 'pages/**/*.ts,tests/**/*.ts,fixtures/**/*.ts,test-data/**/*'
---

# AI Prompt Templates for Agentic Playwright

Codegen sub-router. Owns prompt templates per artifact type and the post-generation verification checklist. Plugs into `ai-native-workflow` Phase 2 (Route) for codegen intents.

For the 8-phase workflow see [`ai-native-workflow/SKILL.md`](ai-native-workflow.instructions.md). For worked examples and troubleshooting see this skill's `references/`.

## Critical

These rules are unique to template usage. **All other rules** live in the **[`.github/copilot-instructions.md`](../copilot-instructions.md) Constitution** and the **leaf skills** (`api-testing`, `page-objects`, `selectors`, `test-standards`, `data-strategy`, `type-safety`, `fixtures`, `enums`). Before generating from any template here, follow [Reread Constitution Before Codegen](ai-native-workflow.instructions.md#rule-recheck-critical-blocks).

- **Resolve `{area}` first.** Every template contains `{area}` as a placeholder; see [`{area}` is a placeholder](../copilot-instructions.md#rule-area-placeholder). Run the matching `ls` (`ls pages/`, `ls tests/`, `ls fixtures/api/schemas/`, `ls test-data/factories/`, `ls test-data/static/`, `ls enums/`) and substitute the real folder name **before** filling the template. Do not guess.
- <a id="rule-templates-are-starters"></a>**Templates are starters, not substitutes.** Each template is a 10-15 line scaffold. The leaf skill listed for the category owns the deep rules — load it and follow it end-to-end. Never reimplement a leaf skill's rules inline in your prompt.
- <a id="rule-walk-verification-checklist"></a>**Walk the verification checklist** (below) after generating. It is the canonical post-codegen audit; the leaf skills point here for it.
- Constitution rules that apply here: [Explore Before Generate](../copilot-instructions.md#rule-explore-before-generate), [No Substitute UI Exploration](../copilot-instructions.md#rule-no-substitute-ui-exploration), [Test Verification](../copilot-instructions.md#rule-test-verification).

## Instructions

### Phase 1: Identify the task category and resolve paths

Match the user's request to one row, then run the `ls` commands the row's templates need.

| Category                | Template section                      | Specialized skill(s)                          | `ls` to run before filling                           |
| ----------------------- | ------------------------------------- | --------------------------------------------- | ---------------------------------------------------- |
| Page object / component | Page Object Tasks                     | `page-objects`, `selectors`, `playwright-cli` | `ls pages/`                                          |
| Functional / E2E test   | Test Tasks                            | `test-standards`, `data-strategy`             | `ls tests/`, `ls test-data/factories/`               |
| API test                | Test Tasks → Add API Test             | `api-testing`, `test-standards`               | `ls tests/`, `ls fixtures/api/schemas/`, `ls enums/` |
| Zod response schema     | API Schema Tasks                      | `api-testing`, `type-safety`                  | `ls fixtures/api/schemas/`                           |
| Data factory            | Data Factory Tasks                    | `data-strategy`, `type-safety`                | `ls test-data/factories/`                            |
| Static test data        | Data Factory Tasks → Static Test Data | `data-strategy`, `api-testing`                | `ls test-data/static/`                               |
| Fixture (POM / helper)  | Fixture Tasks                         | `fixtures`, `helpers`                         | (no path placeholder)                                |
| UI component            | Component Tasks                       | `page-objects`, `selectors`                   | (no path placeholder)                                |

### Phase 2: Select and customize the matching prompt template

Open the theme file for your category from the [Prompt Templates](#prompt-templates) index below, copy the block, and replace every `[PLACEHOLDER]` and every `{area}` with concrete values. <a id="rule-no-unreplaced-placeholders"></a>Leave no unreplaced placeholders in the final prompt.

### Phase 3: Load the specialized skill for the deep rules

The templates intentionally stay shallow. When the task needs more than the template's bullets — full status-code coverage, selector exploration rules, fixture composition patterns — load the specialized skill listed in Phase 1 and follow it end-to-end. See [Templates are starters, not substitutes](#rule-templates-are-starters), and re-read the Constitution and the leaf skill's Critical block before writing code ([Reread Constitution Before Codegen](ai-native-workflow.instructions.md#rule-recheck-critical-blocks)).

### Phase 4: Verify with the checklist, then run the affected tests

Walk every box ([Walk the verification checklist](#rule-walk-verification-checklist)). Then run the affected tests; on red, load `debugging`.

#### Verification Checklist

After generating code, confirm each box:

- [ ] [Imports](../copilot-instructions.md#rule-imports)
- [ ] [Sources of Truth](../copilot-instructions.md#rule-sources-of-truth)
- [ ] [Selectors](../copilot-instructions.md#rule-selectors), [No XPath](../copilot-instructions.md#rule-no-xpath)
- [ ] [No `any`](../copilot-instructions.md#rule-no-any)
- [ ] [No Hard Waits](../copilot-instructions.md#rule-no-hard-waits)
- [ ] [No JSDoc on Locators](../copilot-instructions.md#rule-no-jsdoc-on-locators), [JSDoc on Actions](../copilot-instructions.md#rule-jsdoc-on-actions)
- [ ] [Test Steps](../copilot-instructions.md#rule-test-steps)
- [ ] [No Multiple Tags](../copilot-instructions.md#rule-no-multiple-tags)
- [ ] [No Tags on Describe](../copilot-instructions.md#rule-no-tags-on-describe)
- [ ] [No Multiple Tags](../copilot-instructions.md#rule-no-multiple-tags) (shared-state tests are tagged only `@destructive`; tests that create and clean up only their own data keep their importance tag)
- [ ] [State Cleanup](../copilot-instructions.md#rule-state-cleanup)
- [ ] [Data Generation](../copilot-instructions.md#rule-data-generation), [Data Strategy](../copilot-instructions.md#rule-data-strategy)
- [ ] [Strict Schemas](../copilot-instructions.md#rule-strict-schemas), [No Loose Schemas](../copilot-instructions.md#rule-no-loose-schemas)
- [ ] [Response Validation](../copilot-instructions.md#rule-response-validation)
- [ ] [No Empty-Body-Only 400](../copilot-instructions.md#rule-no-empty-body-only-400)
- [ ] **Coverage audit:** [No Silent Coverage Drops](../copilot-instructions.md#rule-no-silent-coverage-drops)
- [ ] **Path parameter tests:** [Path Param Fuzzing](api-testing.instructions.md#rule-path-param-fuzzing)
- [ ] **405 tests:** [405 Test Per Endpoint](api-testing.instructions.md#rule-405-test-per-endpoint)
- [ ] **Auth matrix:** [Auth Matrix 401 403](api-testing.instructions.md#rule-auth-matrix-401-403)
- [ ] **Behavior mismatches:** [No Silent Coverage Drops](../copilot-instructions.md#rule-no-silent-coverage-drops)
- [ ] [No Explore-Only Files](../copilot-instructions.md#rule-no-explore-only-files)

#### Run the affected tests (mandatory)

```bash
npx playwright test tests/{area}/[type]/[name].spec.ts   # specific file
npx playwright test --grep @smoke                        # by tag
npm test                                                 # all non-destructive
```

**Failure protocol:** Read the error ([Read Failure First](debugging.instructions.md#rule-read-failure-first)) → load `debugging` (failure-mode taxonomy + right Playwright tool per failure: UI Mode, Trace Viewer, Inspector, HTML report) → fix the root cause ([Never Suppress Failures](debugging.instructions.md#rule-never-suppress-failures)) → re-run; for flake fixes, [Flaky Rerun 5x](debugging.instructions.md#rule-flaky-rerun-5x).

## Prompt Templates

Split by theme under `templates/` so the agent loads only the slice it needs — open the file matching your Phase 1 category, copy the block, and replace every `[PLACEHOLDER]` and `{area}` with concrete values.

- [Page object templates](references/templates/page-objects.md) — new page object (with / without exploration), add locators, add action method
- [Test templates](references/templates/tests.md) — functional, E2E, data-driven, and API tests
- [API schema templates](references/templates/api-schemas.md) — Zod schema from docs, fallback capture, add fields
- [Data templates](references/templates/data.md) — Faker factory and static test data
- [Fixture templates](references/templates/fixtures.md) — page-object fixture, helper fixture, fixture category
- [Component templates](references/templates/components.md) — reusable UI component

## See Also

- **[`.github/copilot-instructions.md`](../copilot-instructions.md)** — Constitution (MUST/SHOULD/WON'T tables) is the safety floor for every artifact generated from a template here.
- **`ai-native-workflow`** — owns the 8-phase workflow; Phase 2 routes codegen intents to this skill.
- **`api-testing`** — deep rules for API tests + schemas; load before using **Add API Test** or **Create a New Zod Schema** templates.
- **`page-objects`**, **`selectors`**, **`playwright-cli`** — the UI authoring chain; load before using Page Object Tasks templates.
- **`test-standards`** — spec structure, tagging, web-first assertions, data-driven loops; load before using any Test Tasks template.
- **`data-strategy`** — factory + static-data three-tier rule; load before using Data Factory Tasks.
- **`fixtures`**, **`helpers`** — DI patterns and helper-fixture promotion; load before using Fixture Tasks.
- **`type-safety`** — Zod 4 validators + the `expect(Schema.parse(body)).toBeTruthy()` rule; load before any schema work.
- **`debugging`** — load on Phase 4 verification red.
- **`refactor-values`** — load when a template would change an existing enum value or static-data row.
- **[`references/examples.md`](references/examples.md)** — three end-to-end multi-skill chains using the templates.
- **[`references/troubleshooting.md`](references/troubleshooting.md)** — common pitfalls when filling templates and how to fix.
