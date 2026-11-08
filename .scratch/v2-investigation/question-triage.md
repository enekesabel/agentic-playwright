Answered by v2: 7
Still open: 13
Moot: 4

## 1. Skip pattern form.

**Verdict: Answered by v2.**

The skip-disable choice is no longer needed: [eslint.config.mts:90](../../eslint.config.mts#L90) explicitly explains why `playwright/no-skipped-test` is now off ([eslint.config.mts:95](../../eslint.config.mts#L95)). The sanctioned example uses `test.skip` + FIXME without a disable comment: [.claude/skills/api-testing/SKILL.md:24](../../.claude/skills/api-testing/SKILL.md#L24).

## 2. Checklist tiers.

**Verdict: Still open.**

The checklist still assigns severity per item without a MUST/SHOULD/WON’T mapping: [.claude/skills/pr-reviewer/references/constitution-checklist.md:3](../../.claude/skills/pr-reviewer/references/constitution-checklist.md#L3) says “A failed item becomes a finding at the tier shown.” For example, “No magic numbers” is 🟡 ([.claude/skills/pr-reviewer/references/constitution-checklist.md:39](../../.claude/skills/pr-reviewer/references/constitution-checklist.md#L39)), although it is WON’T in [AGENTS.md:42](../../AGENTS.md#L42); UI exploration is 🟠 ([.claude/skills/pr-reviewer/references/constitution-checklist.md:36](../../.claude/skills/pr-reviewer/references/constitution-checklist.md#L36)) although MUST in [AGENTS.md:24](../../AGENTS.md#L24). The reporting instructions name tiers but supply no mapping ([.claude/skills/pr-reviewer/references/reporting.md:3](../../.claude/skills/pr-reviewer/references/reporting.md#L3)).

## 3. Are teaching snippets bound by the Constitution?

**Verdict: Still open.**

The rewritten positive examples still violate hard rules, so the question about their obligation remains unresolved. “Every exported helper” needs JSDoc with `@param`/`@returns` ([.claude/skills/helpers/SKILL.md:12](../../.claude/skills/helpers/SKILL.md#L12)), but its explicitly “CORRECT” `formatDate` example has none ([.claude/skills/helpers/SKILL.md:15](../../.claude/skills/helpers/SKILL.md#L15)). Also, the positive test-step example is untagged ([README.md:876](../../README.md#L876)), against “exactly one” tag ([AGENTS.md:41](../../AGENTS.md#L41)).

## 4. ESLint severity versus MUST Linting.

**Verdict: Answered by v2.**

Warnings remain configured, including `no-raw-locators` ([eslint.config.mts:99](../../eslint.config.mts#L99), [eslint.config.mts:101](../../eslint.config.mts#L101), [eslint.config.mts:103](../../eslint.config.mts#L103), [eslint.config.mts:104](../../eslint.config.mts#L104), [eslint.config.mts:112](../../eslint.config.mts#L112)), but `npm run lint` now uses `--max-warnings 0` ([package.json:22](../../package.json#L22)), matching “zero warnings” ([AGENTS.md:19](../../AGENTS.md#L19)). XPath enforcement also runs across harnesses at commit time ([.husky/pre-commit:17](../../.husky/pre-commit#L17)) and in CI ([.github/workflows/lint.yml:90](../../.github/workflows/lint.yml#L90)), rather than only through Claude’s write hook. This is a source comparison, not a gate evaluation.

## 5. Mirror drift is not gated.

**Verdict: Answered by v2.**

The generated-copy model is now explicit: “Edit the canonical tree only,” run `skills:sync`, commit both trees ([CONTRIBUTING.md:28](../../CONTRIBUTING.md#L28)). The copy is byte-for-byte and “never hand-edited” ([scripts/sync-skills.sh:4](../../scripts/sync-skills.sh#L4)); the parity check compares fresh temporary output against the generated tree ([scripts/check-skills-sync.sh:5](../../scripts/check-skills-sync.sh#L5)). The public architecture describes the same ownership ([README.md:1472](../../README.md#L1472), [README.md:1473](../../README.md#L1473)).

## 6. `ai-native-workflow` says it never restates rules, then restates nine

**Verdict: Answered by v2.**

The nine-item “Common Critical Rules to Re-Check” restatement block is gone. The replacement Critical instruction is “This skill routes; the leaf skills own the rules” ([.claude/skills/ai-native-workflow/SKILL.md:14](../../.claude/skills/ai-native-workflow/SKILL.md#L14)); the application step now says “re-check every loaded Critical block” ([.claude/skills/ai-native-workflow/SKILL.md:54](../../.claude/skills/ai-native-workflow/SKILL.md#L54)). This resolves the specific self-contradicting block without assessing the broader link-versus-restate design.

## 7. api-testing Phase 7 contradicts itself.

**Verdict: Answered by v2.**

The replacement gives one explicit decision: “Never change an expected status”; “422 where the spec says 400 is still a mismatch; only a human confirming the spec is stale changes the expectation” ([.claude/skills/api-testing/SKILL.md:22](../../.claude/skills/api-testing/SKILL.md#L22)). Execution likewise routes a disagreement to `test.skip` + FIXME ([.claude/skills/api-testing/SKILL.md:45](../../.claude/skills/api-testing/SKILL.md#L45)). The old competing “different valid code” instruction has no equivalent here.

## 8. Null-body carve-out.

**Verdict: Still open.**

The Constitution still requires “exactly `expect(SchemaName.parse(body)).toBeTruthy();`” without a null-body exception ([AGENTS.md:16](../../AGENTS.md#L16)). API Critical says “Assert every response body” with that pattern ([.claude/skills/api-testing/SKILL.md:12](../../.claude/skills/api-testing/SKILL.md#L12)), but the replacement coverage reference prescribes `expect(body).toBeNull()` for DELETE 204 ([.claude/skills/api-testing/references/coverage-matrix.md:18](../../.claude/skills/api-testing/references/coverage-matrix.md#L18)) and says “instead of a parse” for documented no-body responses ([.claude/skills/api-testing/references/coverage-matrix.md:20](../../.claude/skills/api-testing/references/coverage-matrix.md#L20)). The old exception need not survive in all three skills for this contradiction to remain.

## 9. Allowed exceptions that contradict hard rules.

**Verdict: Still open.**

The three exceptions survive, although one is expressed less explicitly now:

- “No Magic Numbers: constants in `config/` or `enums/`” ([AGENTS.md:42](../../AGENTS.md#L42)) versus “a per-assertion `{ timeout }` only with a comment saying why” ([.claude/skills/data-strategy/SKILL.md:33](../../.claude/skills/data-strategy/SKILL.md#L33)); this retains an exception but no longer shows the old literal `10000`.
- “cannot run means stop and tell the human” ([AGENTS.md:24](../../AGENTS.md#L24)) versus “app unreachable: add it with `// FIXME: unverified`” ([.claude/skills/enums/SKILL.md:24](../../.claude/skills/enums/SKILL.md#L24)); the workflow also forbids “unverified message strings” ([.claude/skills/ai-native-workflow/SKILL.md:12](../../.claude/skills/ai-native-workflow/SKILL.md#L12)).
- “remove … instrumentation before committing” ([.claude/skills/debugging/SKILL.md:39](../../.claude/skills/debugging/SKILL.md#L39)) and `no-console: error` ([eslint.config.mts:83](../../eslint.config.mts#L83)) versus “Add temporary instrumentation (`console.log` …), push … then remove … before merging” ([.claude/skills/debugging/references/ci-replay.md:20](../../.claude/skills/debugging/references/ci-replay.md#L20)).

## 10. Two confidence rubrics.

**Verdict: Still open.**

Both scales are still called confidence: workflow below 5 forbids a proposal ([.claude/skills/ai-native-workflow/SKILL.md:10](../../.claude/skills/ai-native-workflow/SKILL.md#L10)), 5–7 requires accepting unknowns ([.claude/skills/ai-native-workflow/SKILL.md:51](../../.claude/skills/ai-native-workflow/SKILL.md#L51)), and unattended auto-pass requires ≥8 with no unknowns ([.claude/skills/ai-native-workflow/SKILL.md:53](../../.claude/skills/ai-native-workflow/SKILL.md#L53)). Review “Confidence score” still uses 9–10 / 6–8 / ≤5 ([.claude/skills/pr-reviewer/references/reporting.md:5](../../.claude/skills/pr-reviewer/references/reporting.md#L5), [.claude/skills/pr-reviewer/references/reporting.md:7](../../.claude/skills/pr-reviewer/references/reporting.md#L7), [.claude/skills/pr-reviewer/references/reporting.md:8](../../.claude/skills/pr-reviewer/references/reporting.md#L8), [.claude/skills/pr-reviewer/references/reporting.md:9](../../.claude/skills/pr-reviewer/references/reporting.md#L9)). Their contexts are identifiable, but the requested review-score naming distinction has not been made; 5 and 8 retain different meanings.

## 11. Confidence thresholds restated

**Verdict: Still open.**

The playbook now says thresholds live in “one canonical place,” workflow Procedure step 4, and that it links “rather than restating them” ([AI-WORKFLOWS.md:50](../../AI-WORKFLOWS.md#L50)). Nevertheless README still restates “below confidence 5 … stop and ask” ([README.md:136](../../README.md#L136)). Moreover, the below-5 instruction actually lives in workflow Critical ([.claude/skills/ai-native-workflow/SKILL.md:10](../../.claude/skills/ai-native-workflow/SKILL.md#L10)), while the ≥8 unattended threshold lives in step 5 ([.claude/skills/ai-native-workflow/SKILL.md:53](../../.claude/skills/ai-native-workflow/SKILL.md#L53)), not exclusively step 4 ([.claude/skills/ai-native-workflow/SKILL.md:51](../../.claude/skills/ai-native-workflow/SKILL.md#L51)).

## 12. ESLint-only rules.

**Verdict: Still open.**

The prose coverage gap remains, though the original counts should not be carried forward. ESLint still mandates `no-console` ([eslint.config.mts:83](../../eslint.config.mts#L83)), `require-top-level-describe` ([eslint.config.mts:110](../../eslint.config.mts#L110)) and `expect-expect` ([eslint.config.mts:111](../../eslint.config.mts#L111)). Return types do have a Critical home now ([.claude/skills/type-safety/SKILL.md:33](../../.claude/skills/type-safety/SKILL.md#L33)); the rewritten spec procedure describes copying a sibling’s `describe` shape ([.claude/skills/test-standards/SKILL.md:38](../../.claude/skills/test-standards/SKILL.md#L38)), but supplies no equivalent explicit assertion-per-test rule. For console output, the remaining prose even permits pushing instrumentation ([.claude/skills/debugging/references/ci-replay.md:20](../../.claude/skills/debugging/references/ci-replay.md#L20)), rather than stating the lint ban. This verdict concerns prose coverage, not gate quality.

## 13. Repo-maintenance rules in README.

**Verdict: Still open.**

The README still ships maintainer instructions: regenerate skills after edits ([README.md:1472](../../README.md#L1472), [README.md:1473](../../README.md#L1473)) and verify/reinstall/re-lock vendored skills ([README.md:140](../../README.md#L140)). CONTRIBUTING also owns canonical editing and vendored-skill policy ([CONTRIBUTING.md:28](../../CONTRIBUTING.md#L28), [CONTRIBUTING.md:29](../../CONTRIBUTING.md#L29)). Thus the placement/duplication question remains; the nonexistent-command subproblem is fixed because CONTRIBUTING now names `npm run check:skills` ([CONTRIBUTING.md:12](../../CONTRIBUTING.md#L12), [CONTRIBUTING.md:21](../../CONTRIBUTING.md#L21)).

## 14. Area placeholder rule has no numbered home.

**Verdict: Still open.**

The Constitution still introduces `{area}` as unclassified prose before MUST: “`ls pages/` (or `tests/`, `enums/`) gives the real name” ([AGENTS.md:7](../../AGENTS.md#L7); MUST begins at [AGENTS.md:9](../../AGENTS.md#L9)). The hard instruction instead lives in skills: “Resolve `{area}` … never guess it” ([.claude/skills/common-tasks/SKILL.md:10](../../.claude/skills/common-tasks/SKILL.md#L10)) and folder names “come from `ls`, `grep`, `playwright-cli`, the OpenAPI document or the user” ([.claude/skills/ai-native-workflow/SKILL.md:11](../../.claude/skills/ai-native-workflow/SKILL.md#L11)). Thus mandatory behavior is clearer, but it has not become a Constitution rule; flat bullets replace the old table, not this placement gap.

## 15. Explicit return types has three scopes

**Verdict: Still open.**

The same scope difference remains: “every exported or public function” ([.claude/skills/type-safety/SKILL.md:33](../../.claude/skills/type-safety/SKILL.md#L33)) versus the general `**/*.ts` / `**/*.tsx` ESLint block ([eslint.config.mts:49](../../eslint.config.mts#L49)) enabling `explicit-function-return-type: error` without export/public restriction ([eslint.config.mts:72](../../eslint.config.mts#L72)), versus README “Always specify types for parameters and return values” ([README.md:1315](../../README.md#L1315)). The config still expresses the broader rule rather than the skill’s visibility scope.

## 16. Copilot instructions file.

**Verdict: Moot.**

The generated Copilot Constitution/instruction file and glob-based instruction tree no longer exist: their removal is recorded in [CHANGELOG.md:28](../../CHANGELOG.md#L28). Copilot now reads the shared orchestrator and generated skills ([AGENTS.md:62](../../AGENTS.md#L62), [README.md:1481](../../README.md#L1481), [README.md:1482](../../README.md#L1482)); its retained review prompt routes through that shared contract ([.github/prompts/pr-reviewer.prompt.md:8](../../.github/prompts/pr-reviewer.prompt.md#L8), [.github/prompts/pr-reviewer.prompt.md:61](../../.github/prompts/pr-reviewer.prompt.md#L61)). There is no old activation index to append to the deleted file.

## 17. Anchor slug for one rule differed between two implementers

**Verdict: Moot.**

The fork’s per-rule anchor-slug choice no longer applies. The equivalent application rule is an ordinary numbered Procedure step, “re-check every loaded Critical block” ([.claude/skills/ai-native-workflow/SKILL.md:54](../../.claude/skills/ai-native-workflow/SKILL.md#L54)); the Constitution is flat named bullets ([AGENTS.md:11](../../AGENTS.md#L11), [AGENTS.md:51](../../AGENTS.md#L51)), under the single-orchestrator design ([CHANGELOG.md:27](../../CHANGELOG.md#L27)). No surviving `rule-…` anchor names that rule.

## 18. CONTRIBUTING still summarises five Constitution rules in prose

**Verdict: Still open.**

CONTRIBUTING still restates the rules: “fixtures over manual instantiation, web-first assertions, no hard waits, no `any`, `z.strictObject()` for API schemas, one tag per test” ([CONTRIBUTING.md:27](../../CONTRIBUTING.md#L27)). These repeat the Constitution’s DI ([AGENTS.md:11](../../AGENTS.md#L11)), assertions ([AGENTS.md:18](../../AGENTS.md#L18)), no-hard-waits ([AGENTS.md:37](../../AGENTS.md#L37)), no-any ([AGENTS.md:39](../../AGENTS.md#L39)), strict-schema ([AGENTS.md:15](../../AGENTS.md#L15)) and tag ([AGENTS.md:41](../../AGENTS.md#L41)) instructions. This records the retained duplication, without recommending links or restatement.

## 19. Skill-lint is no longer pure bash.

**Verdict: Still open.**

The old fork-specific Node mirror builder is gone; the current generator is a shell script ([scripts/sync-skills.sh:1](../../scripts/sync-skills.sh#L1)). However, the workflow still claims “Pure bash + git” and a “Node-free hash check” ([.github/workflows/skill-lint.yml:3](../../.github/workflows/skill-lint.yml#L3), [.github/workflows/skill-lint.yml:4](../../.github/workflows/skill-lint.yml#L4)) while invoking vendored verification ([.github/workflows/skill-lint.yml:79](../../.github/workflows/skill-lint.yml#L79)), whose implementation says “node is required to parse skills-lock.json” ([scripts/sync-upstream-skills.sh:58](../../scripts/sync-upstream-skills.sh#L58)) and invokes `node -e` ([scripts/sync-upstream-skills.sh:65](../../scripts/sync-upstream-skills.sh#L65)). The stated runtime constraint still disagrees with the code; no execution or assessment of the gates was performed.

## 20. Mirror check sharp edge.

**Verdict: Answered by v2.**

The current parity check regenerates into a temporary directory ([scripts/check-skills-sync.sh:34](../../scripts/check-skills-sync.sh#L34), [scripts/check-skills-sync.sh:37](../../scripts/check-skills-sync.sh#L37)) and compares that output against the existing generated tree ([scripts/check-skills-sync.sh:41](../../scripts/check-skills-sync.sh#L41)); a mismatch reports drift ([scripts/check-skills-sync.sh:92](../../scripts/check-skills-sync.sh#L92)). Thus this check no longer regenerates over a hand-edited mirror. The separate mutation command remains explicitly documented as regeneration ([scripts/sync-skills.sh:16](../../scripts/sync-skills.sh#L16)).

## 21. Scaffold commit needs a git identity.

**Verdict: Still open.**

The initializer still performs plain `git init`, `git add`, `git commit` without supplying an identity ([packages/create-agentic-playwright/bin/create.js:455](../../packages/create-agentic-playwright/bin/create.js#L455)), and logs failure as “not fatal” ([packages/create-agentic-playwright/bin/create.js:467](../../packages/create-agentic-playwright/bin/create.js#L467)). The smoke workflow’s checkout/setup/scaffold steps supply no `user.name` or `user.email` ([.github/workflows/template-smoke.yml:18](../../.github/workflows/template-smoke.yml#L18), [.github/workflows/template-smoke.yml:20](../../.github/workflows/template-smoke.yml#L20), [.github/workflows/template-smoke.yml:29](../../.github/workflows/template-smoke.yml#L29)). The missing-identity case therefore remains possible; this is not a claim that a particular hosted run failed.

## 22. Linked path mentions.

**Verdict: Moot.**

The fork’s Markdown-link-only convention and path-in-prose rejection are not the v2 authoring model. The rewritten References use backticked paths directly ([.claude/skills/common-tasks/SKILL.md:34](../../.claude/skills/common-tasks/SKILL.md#L34), [.claude/skills/ai-native-workflow/SKILL.md:60](../../.claude/skills/ai-native-workflow/SKILL.md#L60)); the current reference checker explicitly recognizes “bare `references/...md`” tokens ([scripts/check-skill-references-drift.sh:45](../../scripts/check-skill-references-drift.sh#L45)). Ordinary file/heading pointers replaced the fork-specific linked-path requirement.

## 23. Vendored references.

**Verdict: Moot.**

The combined fork policy of vendored orphan exemptions plus rewritten mirror links is gone. All skills are copied byte-for-byte, with “No skill … excluded” ([scripts/sync-skills.sh:4](../../scripts/sync-skills.sh#L4), [scripts/sync-skills.sh:11](../../scripts/sync-skills.sh#L11)). The current orphan loop checks each discovered skill and exempts only reference `README.md` files ([scripts/check-skill-references-drift.sh:106](../../scripts/check-skill-references-drift.sh#L106), [scripts/check-skill-references-drift.sh:124](../../scripts/check-skill-references-drift.sh#L124)). Vendored content is separately upstream-tracked and protected from direct edits ([CONTRIBUTING.md:29](../../CONTRIBUTING.md#L29)). There is no mirror-specific Markdown rewriting or path-in-prose exemption to approve.

## 24. Three planned Critical homes left in place.

**Verdict: Answered by v2.**

The equivalent constraints now have Critical homes: waits belong “in the page-object action” ([.claude/skills/debugging/SKILL.md:12](../../.claude/skills/debugging/SKILL.md#L12)), with permitted wait forms also in page-objects Critical ([.claude/skills/page-objects/SKILL.md:28](../../.claude/skills/page-objects/SKILL.md#L28)); “Resolve `{area}` … never guess it” is common-tasks Critical ([.claude/skills/common-tasks/SKILL.md:10](../../.claude/skills/common-tasks/SKILL.md#L10)), while placeholders are globally refused ([.claude/skills/ai-native-workflow/SKILL.md:12](../../.claude/skills/ai-native-workflow/SKILL.md#L12)). Cleanup Critical now requires that “the hook succeeds after a failed test” ([.claude/skills/test-standards/SKILL.md:21](../../.claude/skills/test-standards/SKILL.md#L21)), reinforced by “must succeed when the test wrote nothing” ([.claude/skills/test-standards/references/destructive-tests.md:47](../../.claude/skills/test-standards/references/destructive-tests.md#L47)). The template procedure still explicitly requires replacing every placeholder ([.claude/skills/common-tasks/SKILL.md:28](../../.claude/skills/common-tasks/SKILL.md#L28)).

## New in v2

1. **API fallback conflicts with the new Critical stop rule.** “no document found: stop and ask” ([.claude/skills/api-testing/SKILL.md:11](../../.claude/skills/api-testing/SKILL.md#L11)) conflicts with the Constitution’s allowed “live capture only when none exists, flagged” ([AGENTS.md:24](../../AGENTS.md#L24)) and the reference’s no-documentation instruction, “Make one real request per status code … Treat the capture as the working contract” ([.claude/skills/api-testing/references/contract-sourcing.md:25](../../.claude/skills/api-testing/references/contract-sourcing.md#L25), [.claude/skills/api-testing/references/contract-sourcing.md:27](../../.claude/skills/api-testing/references/contract-sourcing.md#L27)). The new Critical rule states no fallback exception.

2. **Imports lost their spec-only scope.** The Constitution now says “`test` and `expect` … only, never `@playwright/test`” without a file scope ([AGENTS.md:12](../../AGENTS.md#L12)), while page-objects Critical says “Imports come from `@playwright/test`, never from `fixtures/pom/test-options.ts`” ([.claude/skills/page-objects/SKILL.md:11](../../.claude/skills/page-objects/SKILL.md#L11)). Its class example explicitly imports `expect` from `@playwright/test` ([.claude/skills/page-objects/references/class-pattern.md:6](../../.claude/skills/page-objects/references/class-pattern.md#L6)). The old Constitution expressly restricted the prohibition to spec files (old-base document “CLAUDE.md” at commit f6cbf35, line 19, inspected using `git show f6cbf35:CLAUDE.md`); v2 drops that qualifier.

3. **Manual-instantiation prohibition lost its test-only scope.** The Constitution now says “never `new PageObject(page)`” without a file scope ([AGENTS.md:43](../../AGENTS.md#L43)), while the fixture-registration procedure explicitly requires `await use(new X(page))` ([.claude/skills/fixtures/SKILL.md:44](../../.claude/skills/fixtures/SKILL.md#L44)). Fixtures Critical still scopes the ban correctly: “`new AppPage(page)` inside a spec is forbidden” ([.claude/skills/fixtures/SKILL.md:10](../../.claude/skills/fixtures/SKILL.md#L10)). The old Constitution limited the rule to “inside test files” (old-base document “CLAUDE.md” at commit f6cbf35, line 56, inspected using `git show f6cbf35:CLAUDE.md`); v2 omits that boundary.
