# Verification checklist

Walk it after every generated or modified artifact, after [Linting](../../../../AGENTS.md#rule-linting) and a clean `npx tsc --noEmit` (the lint layer already catches imports, tags, `any`, hard waits, XPath, loose schemas, manual instantiation, JSON static data and hardcoded URLs). These boxes need judgment, not a linter.

- [ ] Nothing changed outside the approved proposal's scope.
- [ ] [Sources of Truth](../../../../AGENTS.md#rule-sources-of-truth), [No Secrets](../../../../AGENTS.md#rule-no-secrets): check the artifact.
- [ ] [Data Generation](../../../../AGENTS.md#rule-data-generation), [No Hardcoded Test Content](../../../../AGENTS.md#rule-no-hardcoded-test-content), [Data Strategy](../../../../AGENTS.md#rule-data-strategy): check the content and invalid values.
- [ ] [No Multiple Tags](../../../../AGENTS.md#rule-no-multiple-tags), [State Cleanup](../../../../AGENTS.md#rule-state-cleanup): check each state-mutating test.
- [ ] [No JSDoc on Locators](../../../../AGENTS.md#rule-no-jsdoc-on-locators), [JSDoc on Actions](../../../../AGENTS.md#rule-jsdoc-on-actions): check getters and action methods.
- [ ] [No Feedback-Less POM](../../../../AGENTS.md#rule-no-feedback-less-pom): check form and CRUD page objects.
- [ ] [No Silent Coverage Drops](../../../../AGENTS.md#rule-no-silent-coverage-drops), [Explore Before Generate](../../../../AGENTS.md#rule-explore-before-generate): check API coverage and schema changes.
- [ ] [No Empty-Body-Only 400](../../../../AGENTS.md#rule-no-empty-body-only-400): check API negative tests against the [skill-local field coverage requirement](../SKILL.md#critical).
- [ ] API: check the [skill-local coverage requirements](../SKILL.md#critical).
- [ ] [No Explore-Only Files](../../../../AGENTS.md#rule-no-explore-only-files): inspect the tree.
- [ ] [Test Verification](../../../../AGENTS.md#rule-test-verification): check the affected test results.
