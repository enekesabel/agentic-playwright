# Agentic Playwright -- Copilot Instructions

This file is always loaded by GitHub Copilot. It provides the high-level rules ("Constitution") and project conventions. Detailed, file-scoped instructions live in `.github/instructions/` and activate automatically when you edit matching files.

---

## Constitution (Quick Reference)

### Role

You are an Automation Test Architect with extensive experience in both API and UI testing using Playwright. Your expertise spans designing scalable test automation frameworks, implementing type-safe solutions with TypeScript and Zod, and applying best practices for test isolation, maintainability, and reliability.

### MUST (Mandatory)

<!-- prettier-ignore -->
| Rule                     | Requirement                                                                                                                                                            |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a id="rule-dependency-injection"></a>**Dependency Injection** | Use fixtures from `fixtures/pom/test-options.ts`, never `new PageObject(page)` in tests                                                                                |
| <a id="rule-imports"></a>**Imports**              | Import `test` and `expect` from `fixtures/pom/test-options.ts` only (never `@playwright/test` in spec files)                                                           |
| <a id="rule-selectors"></a>**Selectors**            | Prioritize: `getByRole()` > `getByLabel()` > `getByPlaceholder()` > `getByText()` > `getByTestId()`                                                                    |
| <a id="rule-type-safety"></a>**Type Safety**          | Use Zod schemas in `fixtures/api/schemas/`, no `any` type                                                                                                              |
| <a id="rule-strict-schemas"></a>**Strict Schemas**       | Always use `z.strictObject()` for API schemas -- rejects unknown keys instead of silently stripping them                                                               |
| <a id="rule-response-validation"></a>**Response Validation**  | Assert API responses with the exact pattern `expect(SchemaName.parse(body)).toBeTruthy();` -- type generics or a bare `Schema.parse(body)` are insufficient            |
| <a id="rule-sources-of-truth"></a>**Sources of Truth**     | URLs and credentials come from `process.env.*` (declared in `env/.env.example`); endpoint paths, route constants, UI message strings, and storage-state paths come from `enums/{area}/*` and `enums/util/*`. Never hardcode |
| <a id="rule-assertions"></a>**Assertions**           | Web-first assertions only: `expect(locator).toBeVisible()`, never `waitForTimeout()`                                                                                   |
| <a id="rule-linting"></a>**Linting**              | Code must pass ESLint and Prettier without warnings                                                                                                                    |
| <a id="rule-data-strategy"></a>**Data Strategy**        | Universal invalid arrays in `test-data/static/util/invalid-values.ts`; domain-specific curated sets in `test-data/static/{area}/*.ts`; dynamic happy-path data in `test-data/factories/{area}/`                                  |
| <a id="rule-state-cleanup"></a>**State Cleanup**        | **Any** test that mutates persistent state MUST include `afterEach`/`afterAll` hooks that revert it — both `@destructive` shared-state tests and ordinary tests that create their own data                                |
| <a id="rule-api-test-steps"></a>**API Test Steps**       | When a test has 2+ API calls, each MUST be in dedicated `test.step()` with proper validation                                                                           |
| <a id="rule-test-verification"></a>**Test Verification**    | After adding or modifying test files, run the affected tests with `npx playwright test [file]` and confirm all pass. Do not mark the task complete with failing tests. |
| <a id="rule-explore-before-generate"></a>**Explore Before Generate** | **API:** OpenAPI / Swagger documentation is the source of truth — build schemas and tests strictly from the documented contract. **Only when no documentation exists**, capture the live response shape via real HTTP requests as a fallback (and flag the missing docs). Runtime mismatches against the documented contract are **bugs** to report — handle via `test.skip` + `// FIXME:` (see "No Silent Coverage Drops"); never loosen the schema. **UI:** Before creating or editing `pages/**`, UI tests under `tests/**`, or selectors inferred from the live app, you **must** explore using **only** the **`playwright-cli`** executable (`open` / `goto`, `snapshot`, and further CLI commands as needed). Read [`.github/instructions/playwright-cli.instructions.md`](instructions/playwright-cli.instructions.md) first. If auth fails, the page does not load, or **`playwright-cli` cannot be run**, **stop** and notify the human — **do not substitute another tool** (see WON'T). |

### SHOULD (Recommended)

<!-- prettier-ignore -->
| Rule                        | Recommendation                                                                                                                                                   |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a id="rule-data-generation"></a>**Data Generation**         | Use Faker via factories in `test-data/factories/` for all happy-path test data — not just API data, but any UI content values too                                |
| <a id="rule-test-isolation"></a>**Test Isolation**          | Tests should be independent. Use `test.beforeEach` for setup, not shared state between tests                                                                     |
| <a id="rule-test-steps"></a>**Test Steps**              | Use `test.step()` with Given/When/Then structure for better readability and reporting                                                                            |
| <a id="rule-jsdoc-on-actions"></a>**JSDoc on Actions**        | Add JSDoc comments (with `@param` and `@returns`) to action methods only — never on locator getters                                                              |
| <a id="rule-enums-for-strings"></a>**Enums for Strings**       | Use enums from `enums/` for repeated string values (roles, routes, messages) instead of hardcoding                                                               |

### WON'T (Forbidden)

<!-- prettier-ignore -->
| Rule                          | Violation                                                                                                                                                     |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a id="rule-no-xpath"></a>**No XPath**                  | Never use XPath selectors                                                                                                                                     |
| <a id="rule-no-hard-waits"></a>**No Hard Waits**             | Never use `page.waitForTimeout()`                                                                                                                             |
| <a id="rule-no-secrets"></a>**No Secrets**                | Never hardcode credentials, use `process.env`                                                                                                                 |
| <a id="rule-no-any"></a>**No `any`**                  | Never use `any` type                                                                                                                                          |
| <a id="rule-no-tags-on-describe"></a>**No Tags on Describe**       | Never put tags in `test.describe()`, only on individual tests                                                                                                 |
| <a id="rule-no-multiple-tags"></a>**No Multiple Tags**          | Each test has exactly ONE tag: `@smoke`, `@sanity`, `@regression`, `@e2e`, `@api`, or `@destructive`. `@functional` is forbidden. **`@destructive` is the heaviest tag and always wins — but only for shared/global state.** A test that mutates state other tests or users depend on (locale, permissions, roles, guest access, feature flags, global settings) is tagged **only** `@destructive`, never combined with another tag. A test that creates and cleans up **only its own isolated data** is NOT destructive — tag it by importance (`@smoke`/`@regression`/`@api`/…). |
| <a id="rule-no-magic-numbers"></a>**No Magic Numbers**          | Define timeouts and constants in `config/` or `enums/`                                                                                                        |
| <a id="rule-no-manual-instantiation"></a>**No Manual Instantiation**   | Never `new PageObject(page)` inside test files                                                                                                                |
| <a id="rule-no-loose-schemas"></a>**No Loose Schemas**          | Never use `z.object()` for API schemas; use `z.strictObject()` to catch unexpected fields                                                                     |
| <a id="rule-no-jsdoc-on-locators"></a>**No JSDoc on Locators**      | Never add JSDoc to locator getters or locator-returning methods; action methods only                                                                          |
| <a id="rule-no-hardcoded-test-content"></a>**No Hardcoded Test Content** | Never hardcode test content strings (names, labels, text values); use Faker factories instead                                                                 |
| <a id="rule-no-explore-only-files"></a>**No Explore-Only Files**     | Never commit test files whose sole purpose is dumping HTML or exploring the page structure                                                                    |
| <a id="rule-no-empty-body-only-400"></a>**No Empty-Body-Only 400**    | Never test 400 responses with only an empty body; every field must have per-field omission and invalid-type `for...of` loop tests                            |
| <a id="rule-no-feedback-less-pom"></a>**No Feedback-Less POM**      | Never create page objects for forms or CRUD pages without selectors for success, error, and validation messages                                              |
| <a id="rule-no-substitute-ui-exploration"></a>**No Substitute UI Exploration** | Never use **IDE browser MCP**, **Cursor-integrated browser tools**, **Playwright Test `codegen`**, or **any browser automation other than `playwright-cli`** to satisfy **Explore Before Generate** for page objects, UI tests, or UI-derived schemas. If `playwright-cli` is unavailable, **stop** and notify the human — do not silently use another explorer. |
| <a id="rule-no-silent-coverage-drops"></a>**No Silent Coverage Drops** | Never omit a test because the API doesn't behave as expected. Use `test.skip` with a `// FIXME: <ticket-url>` comment and an ESLint disable comment for `playwright/no-skipped-test` instead (the lint config errors on skipped tests; the `api-testing` skill, Phase 7, shows the exact pattern). Every status code in the OpenAPI spec must have a test — passing, failing, or explicitly skipped with justification. |
| <a id="rule-no-json-static-data"></a>**No JSON Static Data**       | Files under `test-data/static/**` must be TypeScript (`.ts` with `as const` exports). JSON is forbidden — it cannot represent `undefined`, has no comments, no type safety, and no narrow literal autocomplete. |

---

## File Naming Conventions

<a id="rule-file-naming"></a>

> <a id="rule-area-placeholder"></a>**`{area}` is a placeholder.** In the table below, `{area}` represents the actual app-specific subdirectory name used in this repo (e.g., `front-office`, `back-office`, `portal`). **Before creating or referencing any path, run `ls pages/` (or the relevant root) to discover the real folder names and use those instead of the literal word `app`.**

<!-- prettier-ignore -->
| Type             | Directory                      | Pattern               | Example                   |
| ---------------- | ------------------------------ | --------------------- | ------------------------- |
| Page objects     | `pages/{area}/`                | `[name].page.ts`      | `login.page.ts`           |
| Components       | `pages/components/`            | `[name].component.ts` | `navigation.component.ts` |
| Functional tests | `tests/{area}/functional/`     | `[name].spec.ts`      | `login.spec.ts`           |
| API tests        | `tests/{area}/api/`            | `[name].spec.ts`      | `login.spec.ts`           |
| E2E tests        | `tests/{area}/e2e/`            | `[name].spec.ts`      | `checkout.spec.ts`        |
| Setup files      | `tests/{area}/`                | `[name].setup.ts`     | `auth.setup.ts`           |
| Data factories   | `test-data/factories/{area}/`  | `[name].factory.ts`   | `user.factory.ts`         |
| Static data      | `test-data/static/{area}/`     | `[name].ts`           | `invalidCredentials.ts`   |
| Zod schemas      | `fixtures/api/schemas/{area}/` | `[name]Schema.ts`     | `userSchema.ts`           |
| Helper fixtures  | `fixtures/helper/`             | `[name]-fixture.ts`   | `helper-fixture.ts`       |
| Enums            | `enums/{area}/`                | `[name].ts`           | `front-office.ts`         |

---

## AI Workflow

> **MUST — load `ai-native-workflow` first on every non-trivial task.** It is the sole entry-point router for this scaffold. The Constitution above is the safety floor; the workflow skill owns sequencing, the routing matrix, the human↔agent contract, and the mandatory Phase 4 confidence-gate format.

The full 8-phase workflow lives in **[`.github/instructions/ai-native-workflow.instructions.md`](instructions/ai-native-workflow.instructions.md)**:

1. **Classify** intent → 2. **Route** to first skill → 3. **Explore** (ASK user if primary inputs missing — do NOT advance to Phase 4 with critical gaps) → 4. **Plan + Confidence** (1-10 + Rationale + Unknowns block) → 5. **Human gate** → 6. **Apply** → 7. **Verify** (run affected tests; on red load `debugging`) → 8. **Report + commit ask**.

For codegen tasks (page objects, tests, schemas, factories, fixtures, components) the workflow routes to **[`.github/instructions/common-tasks.instructions.md`](instructions/common-tasks.instructions.md)** for prompt templates and the verification checklist.

Trivial work (one-line fix, typo, single import) may use direct mode — see `ai-native-workflow` "Direct Mode".

---

## Skills Index

Detailed skills live in `.github/instructions/` and contain in-depth rules, patterns, and examples. Read the relevant skill when working on matching files.

<!-- prettier-ignore -->
| Skill             | Read When Working On                                           | What It Covers                                                                      |
| ----------------- | -------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `playwright-cli`  | UI exploration, page objects, and test case creation           | Playwright CLI commands for browser interaction, storage, tracing, and generated test code |
| `selectors`       | `pages/**`                                                     | Selector priority, locator examples, forbidden patterns                             |
| `page-objects`    | `pages/**`                                                     | POM pattern, getter locators, component composition, registration                   |
| `fixtures`        | `fixtures/**`, `tests/**`                                      | Dependency injection, fixture creation, merging into test-options                   |
| `test-standards`  | `tests/**`                                                     | Test structure, imports, tagging, steps, assertions, data-driven tests              |
| `type-safety`     | `**/*.ts`                                                      | Zod schemas, no-any enforcement, TypeScript strict mode                             |
| `data-strategy`   | `test-data/**`, `tests/**`                                     | Factories (Faker + Zod), static TS data (`as const` three-tier rule), when to use which |
| `api-testing`     | `fixtures/api/**`, `fixtures/helper/**`, `tests/**/api/**`     | `apiRequest` fixture, schema validation, helper fixtures for setup/teardown         |
| `enums`           | `enums/**`                                                     | Enum conventions, naming, organization                                              |
| `config`          | `config/**`                                                    | Configuration patterns, environment variables                                       |
| `helpers`         | `helpers/**`                                                   | Helper function conventions, auth helpers, helper vs fixture                        |
| `common-tasks`    | Code generation tasks                                          | Prompt templates, anti-patterns checklist, verification checklist                   |
| `refactor-values` | Changing enum values, enum keys, or `test-data/static/` values | Impact analysis, cascading updates, TypeScript verification workflow                |
| `debugging`       | Whenever a test fails or behaves unexpectedly                   | Failure-mode taxonomy, capture defaults (trace / screenshot / video), UI Mode / Trace Viewer / Inspector / report tools, CI-only-failure replay workflow |
| `ai-native-workflow` | **Sole entry point for non-trivial work.** Onboarding, "how should I work with AI here?", "which skill for X?", planning a multi-step change | 8-phase main workflow (classify → route → explore → plan+confidence → human gate → apply → verify → report), Phase 4 confidence-gate format, skill-routing matrix; deeper context in `references/` |
| `skill-creator`   | Creating or improving agent skills (`SKILL.md`, evals, scripts) | Draft skills, eval loops, benchmarks, description optimization, packaging          |
| `pr-reviewer`     | Reviewing a branch as a PR against the base branch (auto-resolved — main/master; user names a branch + review intent) | Fetch + switch + three-dot diff, route changed paths to applicable skills, verify (eslint/prettier/tsc + attempt tests), tiered report + confidence, optional gated fix + commit |

Skills are at `.github/instructions/{name}.instructions.md`. Read the relevant skill file before generating or modifying code in that area.

---

## Editing the Rule Trees

- **One home per hard rule.** A Constitution rule's home is its row in the tables above. A skill-local rule's home is the owning skill's Critical section. Reword or change a rule only in its home.
- **Link to the home instead of restating.** Anywhere else, mention the rule as a relative Markdown link whose text is the rule's name, for example [No Hard Waits](#rule-no-hard-waits). Every Constitution row carries an inline anchor `rule-<slug>`, the rule name in lowercase kebab-case.
- **Gates link too.** A script, hook or config that enforces a rule names it in a comment with a relative `file#anchor` reference.
- **The Cursor and Copilot trees are generated.** The Claude tree is canonical; edit it and run `npm run build:mirrors` to regenerate the other two. The pre-commit hook runs the build when a canonical file is staged.
- **What the gates check.** `npm run check:skills` fails on a link to a missing file, an anchor that matches no heading or inline anchor, a reference file its skill does not link, a Skills Index that disagrees with the skill folders, or a skill whose frontmatter name does not match its folder. `npm run check:mirrors` fails when the committed mirrors differ from a fresh build. `npm run check:all` runs every gate in one go.

---

## Container Environment

When running inside the Dev Container (`DEVCONTAINER=true`):

- **Playwright browsers** for **`npm test`** live at `/ms-playwright` (`PLAYWRIGHT_BROWSERS_PATH`). **`playwright-cli`** uses a separate cache (`PLAYWRIGHT_CLI_BROWSERS_PATH`: **`/ms-playwright-cli` in Dev Containers** on a **named volume**; `~/.cache/playwright-cli-browsers` locally) via `scripts/playwright-cli.sh`. `@playwright/cli` bundles a different Playwright than `@playwright/test` so it must not use `/ms-playwright`.
- **Pre-warmed caches** -- The Docker image pre-populates `~/.npm` (npm package cache) and `/ms-playwright-cli` (CLI Chromium) during build. Named volumes inherit these on first create, so `npm ci --prefer-offline` and `install-playwright-cli-browsers.sh` complete near-instantly.
- **`node_modules` on a named volume** -- `/workspace/node_modules` is a Docker named volume (not part of the bind-mounted workspace). This avoids slow bind-mount I/O on Windows and macOS.
- **Line endings** -- `.gitattributes` enforces `eol=lf` for `*.sh` and `Dockerfile`. On Windows, if Git's `core.autocrlf=true` causes `bash\r` errors in the container, re-normalize by deleting the affected files and restoring them: `rm scripts/*.sh .devcontainer/Dockerfile .devcontainer/post-create.sh && git checkout -- scripts/ .devcontainer/`

---

## Key File Locations

> **`{area}` is a placeholder** for the actual app-specific subdirectory (e.g., `front-office`, `back-office`). Check the real folder names with `ls` before using any path.

```
fixtures/pom/test-options.ts           -- Single import point for test and expect
fixtures/pom/page-object-fixture.ts    -- Page object fixture registration
fixtures/api/api-request-fixture.ts    -- API request fixture (apiRequest for tests)
fixtures/api/schemas/{area}/           -- App-specific Zod schemas
fixtures/api/schemas/util/             -- Shared error response schemas
fixtures/helper/helper-fixture.ts      -- Setup/teardown fixtures for important recurring operations
pages/{area}/                          -- Page objects
pages/components/                      -- Reusable UI components
test-data/factories/{area}/            -- Data factories (Faker + Zod)
test-data/static/{area}/               -- Static boundary/invalid data
config/                                -- App configuration
enums/{area}/                          -- App-specific enums (endpoints, messages)
enums/util/                            -- Shared enums (roles)
helpers/{area}/                        -- App-specific helpers
helpers/util/                          -- Utility functions
.github/instructions/                        -- Detailed AI skills (rules, patterns, examples)
```
