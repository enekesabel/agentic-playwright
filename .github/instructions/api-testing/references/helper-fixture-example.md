# Helper Fixture — Worked Example

Full code from Phase 8 of [`api-testing/SKILL.md`](../../api-testing.instructions.md). The decision matrix and the rule of thumb stay inline; this file shows the lifecycle-wired helper-fixture pattern.

## Pattern

```typescript
// In helper-fixture.ts
createdResource: async ({ request }, use) => {
    const { body } = await apiRequest({
        request,
        method: 'POST',
        url: ApiEndpoints.RESOURCES, // illustrative
        baseUrl: process.env.API_URL,
        headers: process.env.ACCESS_TOKEN,
        body: generateResource(),
    });
    const resource = ResourceSchema.parse(body); // illustrative schema; validate, never `as`-cast

    await use(resource);

    await apiRequest({
        request,
        method: 'DELETE',
        url: `${ApiEndpoints.RESOURCES}/${resource.id}`,
        baseUrl: process.env.API_URL,
        headers: process.env.ACCESS_TOKEN,
    });
},
```

## Lifecycle

1. **Setup** — Code before `await use(...)` runs before the test.
2. **Yield** — `await use(data)` passes the created data to the test (typed).
3. **Teardown** — Code after `await use(...)` runs after the test, even if the test fails.

## Usage in a test

```typescript
test(
    'should edit resource',
    { tag: '@regression' },
    async ({ createdResource, appPage }) => {
        await appPage.navigateToResource(createdResource.id);
        await appPage.editResource('New Name');
        await expect(appPage.resourceName).toHaveText('New Name');
    }
);
```

## When to promote (decision rule)

The rule is [Helper Fixture Promotion (3+ files)](../../api-testing.instructions.md#rule-helper-fixture-promotion-3plus). Below that threshold, keep the logic in `beforeAll`/`afterAll` in the single spec file and call `apiRequest` directly.

For the full decision matrix (`apiRequest` fixture vs helper fixture vs factory function) see [`SKILL.md`](../../api-testing.instructions.md) Phase 8.
