---
applyTo: 'pages/**/*.ts'
---

# Selector Strategy

## Critical

- <a id="rule-no-css-id-primary-selectors"></a>**NEVER** use CSS class or ID selectors as the primary strategy (`page.locator('.btn-primary')`, `page.locator('#submit')`). Acceptable only as an absolute last resort after ruling out every semantic option.
- **Locators are `get` accessors returning `Locator`:** see [Locators as getters](page-objects.instructions.md#rule-locators-as-getters).
- Constitution rules that apply here: [Selectors](../copilot-instructions.md#rule-selectors), [No XPath](../copilot-instructions.md#rule-no-xpath), [Explore Before Generate](../copilot-instructions.md#rule-explore-before-generate), [No Substitute UI Exploration](../copilot-instructions.md#rule-no-substitute-ui-exploration), [Sources of Truth](../copilot-instructions.md#rule-sources-of-truth), [Enums for Strings](../copilot-instructions.md#rule-enums-for-strings), [No Feedback-Less POM](../copilot-instructions.md#rule-no-feedback-less-pom).

## Instructions

### Phase 1: Open and authenticate

Never generate selectors from assumptions or documentation alone. Before writing any locators or page objects, explore the live application **by running `playwright-cli` in the terminal** (read the `playwright-cli` skill). **Do not** use IDE browser MCP, Cursor browser tools, or any substitute — Constitution rule: [No Substitute UI Exploration](../copilot-instructions.md#rule-no-substitute-ui-exploration). If `playwright-cli` cannot run, stop and notify the human.

```bash
playwright-cli open <APP_URL>
playwright-cli snapshot
```

**If the page fails to load or requires authentication:**

1. **Stop immediately** — do not guess selectors or proceed with placeholder locators.
2. **Notify the human** with the exact issue: _"The application at `<URL>` returned [error/login page/blank screen]. I need [credentials / a different URL / instructions to set up auth state] before I can proceed."_
3. **Wait** for the human to provide remediation (login credentials, storage state file, environment variables, or manual login instructions).
4. After remediation, re-open and verify the page loads correctly before continuing.

### Phase 2: Explore like a user

Navigate through the feature under test the way a real user would. At each page/state, take a snapshot and observe:

- **Forms** — input fields, labels, dropdowns, checkboxes, radio buttons.
- **Buttons and CTAs** — submit, cancel, delete, edit, create actions.
- **Navigation** — links, menus, breadcrumbs, tabs.
- **Feedback elements** — success banners, error messages, validation errors on fields, toast notifications, loading spinners.
- **Dynamic content** — content that appears after actions (modals, expanded sections, new rows in tables).

```bash
playwright-cli snapshot
playwright-cli click <ref>
playwright-cli snapshot
```

Trigger CRUD operations where possible to discover the actual validation messages and success/error feedback the application displays. Capture the **exact** text rendered — this will go into enums via the `enums` skill.

### Phase 3: Plan test coverage

Based on what was discovered, draft a test plan covering the critical paths. The plan should identify:

1. **Happy paths** — the primary successful flows (create, read, update, delete).
2. **Validation paths** — what happens when required fields are empty, invalid data is submitted, etc.
3. **Error paths** — server errors, permission denied, resource not found.
4. **Edge cases** — boundary inputs, concurrent operations, empty states.

If feature documentation exists (user stories, acceptance criteria, design specs), cross-reference it with the discovered UI to ensure coverage is complete.

**No human approval is needed for this plan** — proceed directly to generating selectors and page objects.

### Phase 4: Generate selectors

Now that the real UI is understood, generate selectors using the Priority Order below. Pay special attention to feedback / validation message selectors — these are the most commonly missed.

## Priority Order (Mandatory)

The order is the Constitution's [Selectors](../copilot-instructions.md#rule-selectors) rule: move to the next option only when the previous one is not feasible.

1. **`getByRole()`** — Accessibility-based. Always the first choice for buttons, links, headings, textboxes, checkboxes, etc.
2. **`getByLabel()`** — For form inputs that have associated `<label>` elements.
3. **`getByPlaceholder()`** — For inputs with placeholder text when no label exists.
4. **`getByText()`** — For static text content, messages, or non-interactive elements.
5. **`getByTestId()`** — Fallback when none of the above produce a reliable locator.

## Correct Examples

```typescript
// 1. getByRole -- buttons, links, headings, navigation
page.getByRole('button', { name: 'Submit' });
page.getByRole('link', { name: 'Dashboard' });
page.getByRole('heading', { name: 'Welcome' });
page.getByRole('navigation');
page.getByRole('textbox', { name: 'Email' });
page.getByRole('checkbox', { name: 'Remember me' });

// 2. getByLabel -- form fields with labels
page.getByLabel('Email');
page.getByLabel('Password');

// 3. getByPlaceholder -- inputs without labels
page.getByPlaceholder('Search...');

// 4. getByText -- static content
page.getByText(Messages.LOGIN_SUCCESS); // illustrative member
page.getByText(Messages.LOGIN_ERROR); // prefer enums for repeated strings

// 5. getByTestId -- last resort
page.getByTestId('user-avatar');
```

## Forbidden (NEVER Use)

- **XPath selectors** ([No XPath](../copilot-instructions.md#rule-no-xpath)) — brittle, unreadable, not accessible.

    ```typescript
    // FORBIDDEN
    page.locator('//div[@id="test"]');
    page.locator('xpath=//button[text()="Submit"]');
    ```

- **CSS selectors for primary strategy** ([see above](#rule-no-css-id-primary-selectors)) — acceptable only as a `page.locator()` last resort, never as the default approach.

    ```typescript
    // AVOID unless absolutely necessary
    page.locator('.btn-primary');
    page.locator('#submit-button');
    ```

## Choosing Between Similar Locators

- If the element has a **role** (button, link, heading, etc.), always prefer `getByRole()`.
- If the element is a **form input with a label**, prefer `getByLabel()` over `getByRole('textbox')`.
- If identifying by **exact text** risks matching multiple elements, add `{ exact: true }` or use a more specific role.
- If a parent container contains several similar elements, **scope the search**: `page.getByRole('form').getByRole('button', { name: 'Save' })`.
- Repeated string values (error messages, labels) come from enums: [Enums for Strings](../copilot-instructions.md#rule-enums-for-strings) and [Sources of Truth](../copilot-instructions.md#rule-sources-of-truth); see the `enums` skill.

## Feedback & Validation Message Selectors

Every page object that covers a form or CRUD operation includes selectors for the feedback the application shows after those operations ([No Feedback-Less POM](../copilot-instructions.md#rule-no-feedback-less-pom)). These are the most commonly missed selectors and the most important for assertion coverage.

### What to Capture

| Feedback Type        | When It Appears                         | Selector Strategy                                                          |
| -------------------- | --------------------------------------- | -------------------------------------------------------------------------- |
| Success message      | After successful create/update/delete   | `getByText(Messages.CREATED_SUCCESS)` or `getByRole('alert')`              |
| Error message        | After failed submission or server error | `getByText(Messages.SAVE_FAILED)` or `getByRole('alert')`                  |
| Field validation     | On blur or on submit with invalid input | `getByText(Messages.EMAIL_REQUIRED)` scoped to the form/field container    |
| Toast / notification | Temporary banner after any operation    | `getByRole('status')` or `getByText()` on the toast content                |
| Loading state        | During async operations                 | `getByRole('progressbar')` or `getByText(Messages.LOADING)`                |
| Empty state          | When a list/table has no data           | `getByText(Messages.EMPTY_STATE)` or `getByRole('heading')` in empty state |

> The `Messages.*` values shown above are **illustrative placeholders**. Use the real enum members from your scaffold's `enums/{area}/*.ts` (e.g. `Messages.LOGIN_SUCCESS`, `Messages.LOGIN_ERROR`, `Messages.REQUIRED_FIELD`). Capture the exact rendered text with `playwright-cli` first and encode it via the `enums` skill.

For a full worked code example (page object class with form + feedback locators + action method, plus how the test asserts on it), see [`references/feedback-selectors-example.md`](selectors/references/feedback-selectors-example.md).

### Forbidden: Page objects without feedback selectors

A page object without those selectors breaks [No Feedback-Less POM](../copilot-instructions.md#rule-no-feedback-less-pom). Every form submission or data mutation should have at least a success and error message selector so tests can verify the outcome.

## See Also

- **`page-objects`** skill — POM class structure (constructor, three locator sections, action methods), JSDoc rules, fixture registration, component composition.
- **`playwright-cli`** skill — the terminal-only live-app exploration tool used in Phase 1 and Phase 2.
- **`enums`** skill — where `Messages.*`, `ApiEndpoints.*`, and other app-defined strings live; live-text verification workflow.
- **`common-tasks`** skill — prompt templates for "Add a New Page Object (With / Without Exploration)" that chain into this skill.
- **`debugging`** skill — strict-mode violations (locator matched multiple), "element not found" / "not attached", and other locator-driven test failures.
- **[`references/examples.md`](selectors/references/examples.md)** — three worked examples (new login page, adding feedback selectors, getByRole vs getByLabel decision).
- **[`references/feedback-selectors-example.md`](selectors/references/feedback-selectors-example.md)** — full page-object code pattern with feedback locators and assertion usage.
- **[`references/troubleshooting.md`](selectors/references/troubleshooting.md)** — common selector pitfalls (multi-match, XPath temptation, stale locators, missing feedback) and their fixes.
