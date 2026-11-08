# Constitution Checklist

Mandatory gate. Before writing the report, walk this list against the three-dot diff and record a verdict for **every** applicable item: ✅ pass · ❌ fail · ➖ n/a (not touched by this branch). A failed item becomes a finding at the tier shown. Skip an item only if the branch genuinely doesn't touch that area — never because it "looks fine."

The list is derived from the Constitution. It is the safety floor; the routed skills (step 3) add area-specific depth on top.

## How to use

Reproduce this table in your working notes (not necessarily in the final report) and fill the Verdict + Evidence columns. Evidence = `file:line` or a one-line reason. Any ❌ must appear in the report at its tier. If you mark an item ➖, you are asserting the diff does not touch it — be sure.

| #                              | Rule                                                                                                                                                                                                                     | Tier if violated | Verdict | Evidence |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- | ------- | -------- |
| **Imports & DI**               |
| 1                              | [Imports](../../../../AGENTS.md#rule-imports): check spec imports.                                                                                                                                                       | 🔴               |         |          |
| 2                              | [Dependency Injection](../../../../AGENTS.md#rule-dependency-injection), [No Manual Instantiation](../../../../AGENTS.md#rule-no-manual-instantiation): inspect test page-object construction.                           | 🔴               |         |          |
| **Type safety**                |
| 3                              | [Type Safety](../../../../AGENTS.md#rule-type-safety), [No `any`](../../../../AGENTS.md#rule-no-any): inspect types throughout the diff.                                                                                 | 🔴               |         |          |
| 4                              | [Strict Schemas](../../../../AGENTS.md#rule-strict-schemas), [No Loose Schemas](../../../../AGENTS.md#rule-no-loose-schemas): inspect API schema constructors.                                                           | 🔴               |         |          |
| 5                              | [Explore Before Generate](../../../../AGENTS.md#rule-explore-before-generate): compare schema changes with the documented contract.                                                                                      | 🔴               |         |          |
| 6                              | Exported functions have explicit return types                                                                                                                                                                            | 🟠               |         |          |
| 7                              | `process.env.*` uses a sanctioned pattern (`!` or `?? fallback`), values declared in `env/.env.example`                                                                                                                  | 🟠               |         |          |
| **API tests**                  |
| 8                              | [Response Validation](../../../../AGENTS.md#rule-response-validation): inspect response assertions.                                                                                                                      | 🔴               |         |          |
| 9                              | [API Test Steps](../../../../AGENTS.md#rule-api-test-steps): count API calls and inspect their steps.                                                                                                                    | 🔴               |         |          |
| 10                             | [No Silent Coverage Drops](../../../../AGENTS.md#rule-no-silent-coverage-drops): compare tests with documented status codes; require a ticket link per the [skill-local requirement](../../debugging/SKILL.md#critical). | 🔴               |         |          |
| 11                             | [No Empty-Body-Only 400](../../../../AGENTS.md#rule-no-empty-body-only-400): inspect negative tests.                                                                                                                     | 🟠               |         |          |
| **Sources of truth**           |
| 12                             | [Sources of Truth](../../../../AGENTS.md#rule-sources-of-truth), [No Secrets](../../../../AGENTS.md#rule-no-secrets): trace value sources.                                                                               | 🔴               |         |          |
| 13                             | [Enums for Strings](../../../../AGENTS.md#rule-enums-for-strings): inspect repeated string values.                                                                                                                       | 🟡               |         |          |
| 14                             | Existing enum value / `test-data/static` value changes followed the `refactor-values` impact analysis (no stale references)                                                                                              | 🔴               |         |          |
| **Selectors & POM** (UI diffs) |
| 15                             | [Selectors](../../../../AGENTS.md#rule-selectors): check locator choices against the priority order.                                                                                                                     | 🟠               |         |          |
| 16                             | [No XPath](../../../../AGENTS.md#rule-no-xpath): inspect selectors.                                                                                                                                                      | 🔴               |         |          |
| 17                             | [No Feedback-Less POM](../../../../AGENTS.md#rule-no-feedback-less-pom): inspect form/CRUD feedback locators.                                                                                                            | 🟠               |         |          |
| 18                             | [JSDoc on Actions](../../../../AGENTS.md#rule-jsdoc-on-actions), [No JSDoc on Locators](../../../../AGENTS.md#rule-no-jsdoc-on-locators): inspect method and getter documentation.                                       | 🟡               |         |          |
| 19                             | [Explore Before Generate](../../../../AGENTS.md#rule-explore-before-generate), [No Substitute UI Exploration](../../../../AGENTS.md#rule-no-substitute-ui-exploration): check UI exploration evidence.                   | 🟠               |         |          |
| **Assertions & waits**         |
| 20                             | [Assertions](../../../../AGENTS.md#rule-assertions), [No Hard Waits](../../../../AGENTS.md#rule-no-hard-waits): inspect assertions and waits.                                                                            | 🔴               |         |          |
| 21                             | [No Magic Numbers](../../../../AGENTS.md#rule-no-magic-numbers): trace constant sources.                                                                                                                                 | 🟡               |         |          |
| **Data strategy**              |
| 22                             | [Data Generation](../../../../AGENTS.md#rule-data-generation), [No Hardcoded Test Content](../../../../AGENTS.md#rule-no-hardcoded-test-content): inspect happy-path data.                                               | 🟠               |         |          |
| 23                             | [No JSON Static Data](../../../../AGENTS.md#rule-no-json-static-data): inspect static data files.                                                                                                                        | 🔴               |         |          |
| 24                             | [Data Strategy](../../../../AGENTS.md#rule-data-strategy): check invalid-data placement.                                                                                                                                 | 🟡               |         |          |
| **Tags & structure**           |
| 25                             | [No Multiple Tags](../../../../AGENTS.md#rule-no-multiple-tags), [No Tags on Describe](../../../../AGENTS.md#rule-no-tags-on-describe): inspect test tags.                                                               | 🔴               |         |          |
| 26                             | [State Cleanup](../../../../AGENTS.md#rule-state-cleanup), [No Multiple Tags](../../../../AGENTS.md#rule-no-multiple-tags): inspect state-mutating tests and cleanup.                                                    | 🔴               |         |          |
| 27                             | [Test Steps](../../../../AGENTS.md#rule-test-steps), [Test Isolation](../../../../AGENTS.md#rule-test-isolation): inspect test setup, dependencies, step structure and names.                                            | 🟠               |         |          |
| **Hygiene**                    |
| 28                             | [Linting](../../../../AGENTS.md#rule-linting), [Test Verification](../../../../AGENTS.md#rule-test-verification): check step 4 results.                                                                                  | 🔴               |         |          |
| 29                             | tsc clean for changed files (step 4 result, repo-wide pre-existing errors excluded)                                                                                                                                      | 🔴               |         |          |
| 30                             | [No Explore-Only Files](../../../../AGENTS.md#rule-no-explore-only-files): inspect committed files; check no scope creep beyond the ticket.                                                                              | 🟡               |         |          |

## Output of this gate

A filled table. Carry every ❌ into the report at its tier, and let the count of unresolved ❌ inform the confidence score and verdict. If you couldn't evaluate an item (e.g. tests unrunnable for env), say so explicitly rather than marking it ✅.
