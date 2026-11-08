---
name: test-standards
description: Use when creating or editing a spec file under tests/**, choosing a test type or tag, writing a data-driven loop, or wiring cleanup for a state-mutating test. Not for API coverage matrices (see `api-testing`) or factories and static data (see `data-strategy`).
---

# Test Standards

## Critical

- [Imports](../../../AGENTS.md#rule-imports).
- [No Multiple Tags](../../../AGENTS.md#rule-no-multiple-tags), [No Tags on Describe](../../../AGENTS.md#rule-no-tags-on-describe): never a tag array.

    ```typescript
    // CORRECT
    test('should login', { tag: '@smoke' }, async ({ appPage }) => {});
    // WRONG
    test('should login', { tag: ['@smoke', '@e2e'] }, async () => {});
    ```

- [No Multiple Tags](../../../AGENTS.md#rule-no-multiple-tags): shared/global state lives outside the test and other tests, users or sessions depend on it: locale, language or region; permissions, roles, guest access; feature flags, global settings or configuration; shared seed data every test reads (deleting all users, resetting a catalog).
- [State Cleanup](../../../AGENTS.md#rule-state-cleanup): the hook succeeds after a failed test; it must succeed when the test wrote nothing.
- [Assertions](../../../AGENTS.md#rule-assertions), [No Hard Waits](../../../AGENTS.md#rule-no-hard-waits).

    ```typescript
    // CORRECT
    await expect(appPage.username).toBeVisible();
    // WRONG
    await page.waitForTimeout(1000);
    ```

- [Test Isolation](../../../AGENTS.md#rule-test-isolation): tests **must be independent**: no ordering, no shared mutable state. Setup goes in `test.beforeEach()` or a fixture.
- [No Explore-Only Files](../../../AGENTS.md#rule-no-explore-only-files): never commit debug specs (`console.log(await page.content())`, probes).
- [Test Verification](../../../AGENTS.md#rule-test-verification).

## Procedure

1. Classify: functional (`tests/{area}/functional/`), API (`tests/{area}/api/`), E2E (`tests/{area}/e2e/`) or setup (`tests/{area}/*.setup.ts`). Run `ls tests/` to resolve `{area}`.
2. Open the nearest spec of the same type and copy its import, `describe` and `beforeEach` shape; a spec that must start signed out (login, anonymous forms) calls `resetStorageState()` in `beforeEach`; everything else starts signed in. Skeletons: [references/spec-patterns.md](references/spec-patterns.md).
3. Tag the test; when unsure which importance tag applies, read [references/tags.md](references/tags.md).
4. Split the body into `test.step()` blocks named GIVEN / WHEN / THEN ([Test Steps](../../../AGENTS.md#rule-test-steps)). An API test with more than one call follows `api-testing`.
5. Take values from a factory or a static `.ts` file per `data-strategy`; a data-driven `for...of` loop sits inside `describe`, outside `test()`.
6. Follow [State Cleanup](../../../AGENTS.md#rule-state-cleanup) per [references/destructive-tests.md](references/destructive-tests.md); API setup or teardown shared by several specs goes through `api-testing`.
7. Follow [Test Verification](../../../AGENTS.md#rule-test-verification) and [Linting](../../../AGENTS.md#rule-linting); on red, load `debugging`.

## References

- [references/spec-patterns.md](references/spec-patterns.md): skeletons for a functional, data-driven, E2E and setup spec.
- [references/tags.md](references/tags.md): what each tag covers, how each suite runs, the three tagging mistakes.
- [references/destructive-tests.md](references/destructive-tests.md): the shared-state definition, the cleanup pattern, the destructive suite, suite-only failures.
