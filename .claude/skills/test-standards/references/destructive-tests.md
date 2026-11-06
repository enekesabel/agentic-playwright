# Destructive tests

## What counts as shared state

[No Multiple Tags](../../../../AGENTS.md#rule-no-multiple-tags); see the [skill-local shared-state definition](../SKILL.md#critical).

[No Multiple Tags](../../../../AGENTS.md#rule-no-multiple-tags), [State Cleanup](../../../../AGENTS.md#rule-state-cleanup). Own-record tests run in the parallel suite.

## Cleanup pattern

```typescript
import { ApiEndpoints } from '../../../enums/app/app';
import { expect, test } from '../../../fixtures/pom/test-options';

test.describe('admin data management', () => {
    test.afterEach(async ({ apiRequest }) => {
        // RESET_DATA is illustrative; use the reset endpoint your app provides
        await apiRequest({
            method: 'POST',
            url: ApiEndpoints.RESET_DATA,
            baseUrl: process.env.API_URL,
            headers: process.env.ACCESS_TOKEN,
        });
    });

    test(
        'should delete all inactive users',
        { tag: '@destructive' },
        async ({ apiRequest }) => {
            const { status } = await apiRequest({
                method: 'DELETE',
                url: ApiEndpoints.INACTIVE_USERS,
                baseUrl: process.env.API_URL,
                headers: process.env.ACCESS_TOKEN,
            });
            expect(status).toBe(204);
        }
    );
});
```

See [cleanup hook resilience](../SKILL.md#critical) for the skill-local hook requirement.

## Running

- `npm test` excludes `@destructive` (`--grep-invert @destructive`).
- `npm run test:destructive` runs only `@destructive` tests with `--workers=1`.

## Suite-only failures

| Symptom                          | Cause                                                                                                    | Fix                                                                                                                                                                                                                                                                                                                                                                                                |
| -------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Passes alone, fails in the suite | Shared mutable state, a login flow without `resetStorageState`, or two tests writing the same fixed data | [Test Isolation](../../../../AGENTS.md#rule-test-isolation), [Data Generation](../../../../AGENTS.md#rule-data-generation): per-test data from a factory; `resetStorageState` in `beforeEach`; [No Multiple Tags](../../../../AGENTS.md#rule-no-multiple-tags), [State Cleanup](../../../../AGENTS.md#rule-state-cleanup): if the test mutates shared state, retag `@destructive` and add the hook |
| State leaks between runs         | Missing or non-idempotent `afterEach` / `afterAll`                                                       | [State Cleanup](../../../../AGENTS.md#rule-state-cleanup): add the hook inside the `describe`; make it succeed after a failed test ([cleanup hook resilience](../SKILL.md#critical))                                                                                                                                                                                                               |
