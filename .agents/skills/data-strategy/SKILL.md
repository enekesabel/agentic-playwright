---
name: data-strategy
description: Use when creating or extending a data factory, adding a static set of invalid or boundary values, or deciding whether a test value is generated, static, inline or an enum. Not for editing an existing static value (see `refactor-values`) or the loop that consumes a set (see `test-standards`).
---

# Data Strategy

## Critical

- [No JSON Static Data](../../../AGENTS.md#rule-no-json-static-data): literal values only, no runtime import, no function, no computed value, no Faker call.

    ```typescript
    // CORRECT
    export const INVALID_EMAILS = ['', 'plaintext', 'missing@domain'] as const;
    // WRONG
    export const INVALID_EMAILS = [faker.internet.email(), buildBadEmail()];
    ```

- [No Hardcoded Test Content](../../../AGENTS.md#rule-no-hardcoded-test-content), [Data Generation](../../../AGENTS.md#rule-data-generation): in a spec or page object this covers names, emails, descriptions and product names.

    ```typescript
    // CORRECT
    const product = generateProduct();
    // WRONG
    const product = { name: 'Test Product 1', price: 9.99 };
    ```

- [Data Strategy](../../../AGENTS.md#rule-data-strategy): never redefine the universal type-mismatch arrays inline; import `INVALID_STRING_VALUES`, `INVALID_NUMBER_VALUES`, `INVALID_BOOLEAN_VALUES`, `INVALID_UUID_VALUES`, `INVALID_ENUM_VALUES`, `INVALID_ARRAY_VALUES` and `INVALID_OBJECT_VALUES` from `test-data/static/util/invalid-values.ts`.
- A factory merges `overrides` over Faker defaults, returns `Schema.parse(merged)` and carries the Zod-inferred return type; never a cast.
- Never Faker-generate an app-defined string (error message, label, heading, route): [Sources of Truth](../../../AGENTS.md#rule-sources-of-truth) (`enums`).
- A value used in exactly one assertion stays inline in the test; a static file holds a curated set that a loop iterates.
- Editing an existing static value or enum member goes through `refactor-values` first.
- [No Magic Numbers](../../../AGENTS.md#rule-no-magic-numbers) (timeouts, retry counts, limits): suite tuning in `playwright.config.ts` (`config`), domain limits in `enums/{area}/*`, a per-assertion `{ timeout }` only with a comment saying why.

## Procedure

1. Classify the value; `ls test-data/static/` and `ls test-data/factories/` resolve `{area}`. App-defined strings go to `enums`, tuning numbers to `config`; anything that fits no row: stop and ask.

    | Value                                                        | Home                                                      |
    | ------------------------------------------------------------ | --------------------------------------------------------- |
    | Happy-path dynamic data (names, emails, ids, content)        | factory in `test-data/factories/{area}/<name>.factory.ts` |
    | Universal type-mismatch values                               | import from `test-data/static/util/invalid-values.ts`     |
    | Curated invalid or boundary set tied to the app's validation | `test-data/static/{area}/<name>.ts`                       |
    | Range violation for one field, used in one spec              | inline array in the spec                                  |

2. Factory: the schema must exist in `fixtures/api/schemas/{area}/` (`type-safety`); write it per [references/factories.md](references/factories.md).
3. Static set: pick the tier and the file shape per [references/static-data-tiers.md](references/static-data-tiers.md); a set a second spec or field needs moves from inline to `test-data/static/{area}/`.
4. Consume: the factory call in the spec, fixture or page-object action; a static export through a `for...of` loop per `test-standards`. [Linting](../../../AGENTS.md#rule-linting), [Test Verification](../../../AGENTS.md#rule-test-verification).

## References

- [references/factories.md](references/factories.md): open when creating or extending a factory, pinning fields with overrides, or when `Schema.parse` throws inside one.
- [references/static-data-tiers.md](references/static-data-tiers.md): open when adding a static set: the three tiers, the two file shapes, promotion from inline, collisions between parallel tests.
