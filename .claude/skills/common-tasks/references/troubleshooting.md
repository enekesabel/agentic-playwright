# Common-Tasks Troubleshooting

Common pitfalls when using prompt templates from [`common-tasks/SKILL.md`](../SKILL.md).

## A template uses `{area}` but I don't know the real value

**Cause:** Path-resolution step skipped.
**Fix:** See [`{area}` is a placeholder](../../../../CLAUDE.md#rule-area-placeholder). Run the matching `ls` command (`ls pages/`, `ls tests/`, `ls fixtures/api/schemas/`, `ls test-data/factories/`, `ls test-data/static/`, `ls enums/`) and substitute the real folder name before generating code.

## I ran the prompt and got generic Playwright instead of repo conventions

**Cause:** The specialized skill for the category wasn't loaded.
**Fix:** Load the matching skill (`page-objects`, `api-testing`, `fixtures`, `data-strategy`, `test-standards`, etc.) and follow it end-to-end. See [Templates are starters, not substitutes](../SKILL.md#rule-templates-are-starters).

## The generated test uses `@functional` or stacks multiple tags

**Cause:** Template wording mis-read, or Critical rules skipped.
**Fix:** Follow [No Multiple Tags](../../../../CLAUDE.md#rule-no-multiple-tags).

## The generated API test uses `schema.parse(body)` without wrapping in `expect(...).toBeTruthy()`

**Cause:** The old pattern. Violates [Response Validation](../../../../CLAUDE.md#rule-response-validation).
**Fix:** Rewrite to the assertion that rule requires.

## The generated API test redefines `[123, true, null, undefined]` inline

**Cause:** Universal type-mismatch arrays were not imported.
**Fix:** Delete the inline array and import from `test-data/static/util/invalid-values.ts` (`INVALID_STRING_VALUES`, `INVALID_NUMBER_VALUES`, etc.), per [Data Strategy](../../../../CLAUDE.md#rule-data-strategy). Only field-specific boundary arrays may stay inline.

## The generated test hardcodes an endpoint path, URL, or token

**Cause:** Sources of truth were ignored.
**Fix:** Follow [Sources of Truth](../../../../CLAUDE.md#rule-sources-of-truth): `ApiEndpoints.*` from `enums/{area}/*` for paths, `process.env.API_URL` for the base URL, and `process.env.ACCESS_TOKEN` / `process.env.ACCESS_TOKEN_ZERO` for tokens.

## The generated page object has JSDoc on locator getters

**Cause:** Template wording mis-read.
**Fix:** Follow [No JSDoc on Locators](../../../../CLAUDE.md#rule-no-jsdoc-on-locators) and [JSDoc on Actions](../../../../CLAUDE.md#rule-jsdoc-on-actions).

## The generated schema uses `z.object()`

**Cause:** Template wording mis-read, or Critical rule skipped.
**Fix:** Follow [No Loose Schemas](../../../../CLAUDE.md#rule-no-loose-schemas); `z.object()` silently strips unknown keys and hides contract drift.

## The generated API test instantiates a page object with `new AppPage(page)` or imports `test` from `@playwright/test`

**Cause:** Fixture DI was bypassed.
**Fix:** Follow [Imports](../../../../CLAUDE.md#rule-imports) and [No Manual Instantiation](../../../../CLAUDE.md#rule-no-manual-instantiation): consume page objects through the fixture (`async ({ appPage }) => { ... }`).

## I wrote an explore-only file while investigating and it showed up in `git status`

**Fix:** [No Explore-Only Files](../../../../CLAUDE.md#rule-no-explore-only-files): delete the file before committing.

## The verify step (run affected tests) reported failures and I'm not sure how to investigate

**Fix:** Stop and read the `debugging` skill. It owns the failure-mode taxonomy (TimeoutError, ZodError, strict-mode violation, network errors, etc.) and the right tool per failure (UI Mode `npm run test:ui`, Trace Viewer `npx playwright show-trace`, Inspector `npm run test:debug`). [Never Suppress Failures](../../debugging/SKILL.md#rule-never-suppress-failures) applies.

## I'm onboarding to this scaffold and don't know how to work with the AI agent on it

**Fix:** Load the `ai-native-workflow` skill. It explains the three-layer model (orchestrator / specialized skills / code), the human↔agent conversation contract (audit-then-edit, when to ask vs do, when to refuse), the skill-routing matrix (which skill loads first for which intent), and the 8-phase task lifecycle (classify → route → explore → plan+confidence → human gate → apply → verify → report) that this skill's prompt templates plug into.
