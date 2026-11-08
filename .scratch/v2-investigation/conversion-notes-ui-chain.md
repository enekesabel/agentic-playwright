# Conversion notes: UI chain (selectors, page-objects, fixtures)

## Row wins

None. Every skill sentence that differs from its row is compatible with it under the brief's test, so it stays as skill-local text after the link.

Kept as compatible (not contradictions):

- `selectors/SKILL.md:10` labelled-field exception, `getByLabel('Email')` over `getByRole('textbox', { name: 'Email' })` (also `selectors/references/locator-choice.md:27-29`). The Selectors row is an order; the exception refines it for one element kind.
- `selectors/SKILL.md:22` feedback set wider than the row (toast, loading, empty state). Stricter, compatible.
- `fixtures/SKILL.md:28` fixture code does the bare `SchemaName.parse(body)`; Response Validation is for spec files (no test to assert in; shipped `fixtures/helper/helper-fixture.ts` does the bare parse).
- `page-objects/SKILL.md:11` page objects import from `@playwright/test`, never from `fixtures/pom/test-options.ts`. The Imports row says "in spec files"; page objects are not spec files. Left unlinked (it is not a restatement).
- `page-objects/references/components.md:32` one-line JSDoc on a component field (not a locator, not an action; shipped `pages/app/app.page.ts` has it). Unchanged.
- `page-objects/references/components.md:50-52` splitting a large page object, and `fixtures/references/lifecycle.md` "Teardown never runs" fix cell: unchanged explanatory prose.

## Questions

1. `selectors/SKILL.md:19`: "CSS class or id selectors only as a last resort after every semantic option is ruled out." Row (`AGENTS.md#rule-selectors`): "`getByRole()` > `getByLabel()` > `getByPlaceholder()` > `getByText()` > `getByTestId()`." The sentence adds a sixth tier below the row's five; following it does not break the order, so kept. It does conflict with the skill's own `selectors/references/locator-choice.md:42` "A class-based locator does not ship." (skill-internal inconsistency, not a row conflict; left for a human to decide).
2. `page-objects/SKILL.md:12`: "JSDoc with `@param` and `@returns` is required on every action and verification method." Row JSDoc on Actions is a SHOULD: "JSDoc (`@param`, `@returns`) on action methods only." The brief lists SHOULD-restated-as-MUST as a row-wins example, but the task brief says the verification-method requirement stays. Kept verbatim after the link; is "required" acceptable as a page-objects local strengthening, or should it lose the "required"?

## Manifest lines removed

- `fixtures/pom/test-options.ts|fixtures|Single import point for test/expect`
- `new AppPage(page)|fixtures|No manual page-object instantiation`
- `getByRole|selectors|Selector priority order`
- `XPath|selectors|No XPath`
- `` `playwright-cli` is mandatory|selectors|Explore Before Generate (UI) ``
- `Forbidden** on locator getters|page-objects|JSDoc rules on actions only`
- `Feedback locators are not optional|page-objects|No feedback-less POM`

## Cap pressure

None. Caps: SKILL.md 100 lines / 600 words, Critical 25 non-blank lines / 250 words (wc counts; link URLs count as words).

- selectors: SKILL.md 36 lines / 381 words; Critical 11 lines / 131 words.
- page-objects: SKILL.md 45 lines / 428 words; Critical 19 lines / 204 words.
- fixtures: SKILL.md 51 lines / 420 words; Critical 17 lines / 153 words.
  `check-skill-shape.sh`: 0 failures.
