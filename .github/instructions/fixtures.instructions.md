---
applyTo: 'fixtures/**/*.ts'
---

# Fixtures and Dependency Injection

## Critical

- <a id="rule-pom-fixtures-location"></a>**Page object fixtures** live in `fixtures/pom/page-object-fixture.ts`. Do not create per-page fixture files. Registering a page object: [Register Page Object Fixture](page-objects.instructions.md#rule-register-page-object-fixture).
- <a id="rule-helper-fixtures-location"></a>**Lifecycle (setup/teardown) fixtures** live in `fixtures/helper/helper-fixture.ts`. They use the Playwright `use()` callback pattern.
- <a id="rule-plain-utils-in-helpers"></a>**Plain utility functions** (no fixture lifecycle) live in `helpers/` — not in `fixtures/`. See the `helpers` skill.
- <a id="rule-fixtures-must-be-typed"></a>**Every new fixture** must be typed: extend `FrameworkFixtures` (for page objects) or `HelperFixtures` (for lifecycle) — do not add untyped fixtures.
- <a id="rule-fixture-teardown-after-use"></a>**Teardown uses `use()`.** Setup runs before `use()`, data is yielded via `use(data)`, teardown runs after `use()` — even if the test fails.
- <a id="rule-new-fixture-category-file"></a>**New fixture categories** (not page objects, not lifecycle helpers) must be declared in their own `fixtures/{category}/{name}-fixture.ts` file and merged into `test-options.ts` via `mergeTests()`.
- **Promoting setup/teardown to a helper fixture:** see [Helper Fixture Promotion](api-testing.instructions.md#rule-helper-fixture-promotion-3plus).
- Constitution rules that apply here: [Dependency Injection](../copilot-instructions.md#rule-dependency-injection), [Imports](../copilot-instructions.md#rule-imports), [No Manual Instantiation](../copilot-instructions.md#rule-no-manual-instantiation).

## Fixture Architecture

```
fixtures/pom/test-options.ts              ← Single import point (merges all fixtures)
    ├── fixtures/pom/page-object-fixture.ts       ← Page object fixtures
    ├── fixtures/api/api-request-fixture.ts       ← API request fixture (apiRequest for tests)
    └── fixtures/helper/helper-fixture.ts         ← Setup/teardown fixtures (important recurring operations)
```

`test-options.ts` uses `mergeTests()` to combine fixture layers:

```typescript
import { test as base, mergeTests, request } from '@playwright/test';
import { test as pageObjectFixture } from './page-object-fixture';
import { test as apiRequestFixture } from '../api/api-request-fixture';
import { test as helperFixture } from '../helper/helper-fixture';

const test = mergeTests(pageObjectFixture, apiRequestFixture, helperFixture);
const expect = base.expect;
export { test, expect, request };
```

## Instructions

### Phase 1: Classify what you're adding

Match the need to the correct home. This table exists to stop fixtures from creeping into places they don't belong.

| Need                                                                     | Home                                                                                               |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| New page object wired into tests via DI                                  | Page object fixture in `fixtures/pom/page-object-fixture.ts` (extend, don't create new file)       |
| One-off API call in a single test or describe                            | **No fixture.** Call `apiRequest` directly (see the `api-testing` skill)                           |
| Multi-step API setup/teardown that meets the promotion threshold         | Helper fixture in `fixtures/helper/helper-fixture.ts` (see the `api-testing` skill, Phase 8)       |
| Reusable pure function (no fixture lifecycle) called from tests/fixtures | **Plain function in `helpers/`** — not `fixtures/` (see the `helpers` skill)                       |
| A genuinely new fixture category (not a page object, not API setup)      | New file `fixtures/{category}/{name}-fixture.ts`, merged into `test-options.ts` via `mergeTests()` |
| Tweak to global Playwright config (timeouts, workers, retries, projects) | `playwright.config.ts` — not a fixture (see the `config` skill)                                    |

If the need fits none of these rows, stop and ask. Do not invent a new location.

### Phase 2: Prerequisites (only for page object fixtures)

Before registering a page object fixture, confirm the page object itself was built correctly:

- The page object was created **after exploring the live application** with `playwright-cli` ([Explore Before Generate](../copilot-instructions.md#rule-explore-before-generate); see the `selectors` skill → "Exploration-First Workflow").
- The page object includes **feedback/validation message locators** (success, error, field validation) — not just form inputs and buttons ([No Feedback-Less POM](../copilot-instructions.md#rule-no-feedback-less-pom); see the `selectors` skill → "Feedback & Validation Message Selectors").

Registering a page object that was generated from guesses rather than observed UI defeats the purpose of the DI pattern. Stop and run the exploration first.

### Phase 3: Create or extend the fixture file

For most additions, you are **extending an existing file** — `page-object-fixture.ts` or `helper-fixture.ts`. A brand-new file is only needed when you're introducing a new fixture **category** (Phase 5).

Scaffold of a standalone fixture file (used only for new categories):

```typescript
// fixtures/[category]/[name]-fixture.ts
import { test as base } from '@playwright/test';
import { MyNewPage } from '../../pages/app/my-new.page';

export type MyFixtures = {
    myNewPage: MyNewPage;
};

export const test = base.extend<MyFixtures>({
    myNewPage: async ({ page }, use) => {
        await use(new MyNewPage(page));
    },
});
```

### Phase 4: Register the fixture type and implementation

For a page object, extend `FrameworkFixtures` in `fixtures/pom/page-object-fixture.ts`:

```typescript
// fixtures/pom/page-object-fixture.ts
export type FrameworkFixtures = {
    appPage: AppPage;
    myNewPage: MyNewPage; // Add the type
    resetStorageState: () => Promise<void>;
};

export const test = base.extend<FrameworkFixtures>({
    appPage: async ({ page }, use) => {
        await use(new AppPage(page));
    },
    myNewPage: async ({ page }, use) => {
        await use(new MyNewPage(page)); // Add the fixture
    },
    resetStorageState: async ({ context }, use) => {
        await use(async () => {
            await context.clearCookies();
            await context.clearPermissions();
        });
    },
});
```

For a lifecycle fixture, extend `HelperFixtures` in `fixtures/helper/helper-fixture.ts` following the same shape. Helper fixtures use `plain-function.ts` internally (not the `apiRequest` fixture) because fixture-level code needs the raw `request` context — this is already wired in the scaffold.

### Phase 5: (Only for new categories) Merge into `test-options.ts`

If you added a completely new fixture category (not a page object, not a lifecycle helper), merge it so consumers pick it up automatically:

```typescript
// fixtures/pom/test-options.ts
const test = mergeTests(
    pageObjectFixture,
    apiRequestFixture,
    helperFixture,
    newCategoryFixture // ← add here
);
```

Page objects added in Phase 4 need no `mergeTests()` change — `pageObjectFixture` is already merged.

### Phase 6: Handle teardown via the `use()` callback

Any fixture that needs cleanup uses the Playwright lifecycle:

```typescript
myFixture: async ({ page }, use) => {
    // Setup -- runs BEFORE the test
    const resource = await createResource();

    // Yield -- passes data into the test
    await use(resource);

    // Teardown -- runs AFTER the test (even on failure)
    await resource.cleanup();
},
```

Order matters: code after `await use(...)` is the teardown. Do not teardown before `use()` — it won't run at all.

## Built-in Fixtures

| Fixture             | Source                   | Purpose                                                              |
| ------------------- | ------------------------ | -------------------------------------------------------------------- |
| `appPage`           | `page-object-fixture.ts` | Main application page object                                         |
| `resetStorageState` | `page-object-fixture.ts` | Clears cookies and permissions (for login tests)                     |
| `apiRequest`        | `api-request-fixture.ts` | Type-safe API request function (primary tool for API calls in tests) |
| `createdResource`   | `helper-fixture.ts`      | Example setup/teardown fixture (replace with your own)               |

### `apiRequest` fixture vs. helper fixtures

Use `apiRequest` directly for all API calls in tests; promotion to a helper fixture follows [Helper Fixture Promotion](api-testing.instructions.md#rule-helper-fixture-promotion-3plus). See the `api-testing` skill (Phase 8) for the full decision guide and lifecycle pattern.

## See Also

- **`api-testing`** skill — Phase 8 owns the deep decision for helper fixtures (promotion threshold, lifecycle, apiRequest-vs-helper table).
- **`helpers`** skill — plain utility functions that are **not** Playwright fixtures (no `use()` lifecycle).
- **`page-objects`** skill — what a page object must look like before it's wrapped in a fixture.
- **`selectors`** skill — exploration-first workflow and feedback-locator requirements for page objects.
- **`playwright-cli`** skill — how to run the live-app exploration before building the page object.
- **`common-tasks`** skill — prompt templates for "Add a New Page Object Fixture", "Add a Helper Fixture", "Add a New Fixture Category".
- **`debugging`** skill — `appPage is undefined` / `cannot read property of undefined` / fixture-lifecycle / merge-not-applied failures live here.
- **[`references/examples.md`](fixtures/references/examples.md)** — three worked walkthroughs (new page-object fixture, when NOT to create a fixture for a one-off call, brand-new fixture category).
- **[`references/troubleshooting.md`](fixtures/references/troubleshooting.md)** — common fixture pitfalls (wrong `test` import, fixture creep, teardown not running, missing `mergeTests`, helper-vs-fixture decision, manual instantiation temptation).
