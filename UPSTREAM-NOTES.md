# Upstream alignment notes

Working notes for the fork maintained by Ábel Enekes. The goal is a behaviour-preserving restructuring of the AI rule trees: the rules stay the author's, the plumbing changes. Each entry below is something to align with Ivan Davidov (upstream) before or while opening a PR. Drop this file before the PR, or turn the open questions into the PR description.

## Step 1: copies that disagreed with the Constitution (done on this branch)

The `ai-native-workflow` skill declares the `CLAUDE.md` MUST/SHOULD/WON'T tables the safety floor that wins over any prose, template, or example. Each row below is a copy that said something different.

| Commit                                                                    | Rule                                                                                                                | Where the copy deviated                                                                                            | Change                                                                                                    | Kind                                         |
| ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| docs(readme): align Constitution copy with CLAUDE.md where it contradicts | WON'T No XPath                                                                                                      | README Locator Priority item 6 listed `page.locator()` as "CSS/XPath (last resort)"                                | CSS only as last resort; XPath forbidden, linked to the WON'T table                                       | mechanical                                   |
| same                                                                      | WON'T No XPath                                                                                                      | README Page Object Guideline 2 "prefer getByRole, getByLabel over CSS/XPath"                                       | "over CSS. Never XPath"                                                                                   | mechanical                                   |
| same                                                                      | SHOULD JSDoc on Actions, WON'T No JSDoc on Locators                                                                 | README SHOULD row "JSDoc on all public methods"                                                                    | Action methods only, never locator getters                                                                | mechanical                                   |
| same                                                                      | WON'T No `any`                                                                                                      | README WON'T row "Avoid `any`"                                                                                     | NEVER use `any`                                                                                           | mechanical                                   |
| fix(skills): restore full Constitution rules truncated in common-tasks    | MUST Selectors                                                                                                      | common-tasks verification checklist listed three of five locator levels                                            | Full five-level order                                                                                     | mechanical                                   |
| same                                                                      | MUST Selectors                                                                                                      | common-tasks page-object template, same three-level shortcut                                                       | Full order plus "never XPath"                                                                             | mechanical                                   |
| same                                                                      | MUST Explore Before Generate, WON'T No Substitute UI Exploration                                                    | common-tasks test template asked to "navigate through the user flow" without naming playwright-cli                 | Names playwright-cli as the only tool; stop if it cannot run                                              | mechanical                                   |
| fix(pr-reviewer): complete the single-tag item and add test isolation     | WON'T No Multiple Tags                                                                                              | Checklist item 25 omitted the six allowed tags                                                                     | Six tags listed                                                                                           | mechanical                                   |
| same                                                                      | SHOULD Test Isolation                                                                                               | No checklist item at all                                                                                           | New item 28 at tier 🟠; items 28-30 renumbered 29-31                                                      | decision: tier                               |
| docs(constitution): name the ESLint disable in the coverage-drop rule     | WON'T No Silent Coverage Drops, MUST Linting                                                                        | Constitution row (3 copies) and README row prescribe `test.skip` + FIXME; ESLint errors on skips                   | Row names the ESLint disable comment the api-testing skill already requires                               | mechanical                                   |
| refactor(skills): scope the skip-test ESLint disable to one line          | same                                                                                                                | Six places showed a file-level `/* eslint-disable */`, which silences every later skip in the file                 | `// eslint-disable-next-line` directly above the skip                                                     | decision: convention                         |
| fix(skills): make "good" examples obey the rules they illustrate          | MUST Sources of Truth, Data Strategy, WON'T No Hardcoded Test Content, type-safety Critical, WON'T No Multiple Tags | Good examples with literal endpoint paths, literal credentials, literal UI strings, an `as` cast, an untagged test | Sanctioned sources: `ApiEndpoints.*`, `Messages.*`, static invalid data, a factory, `Schema.parse`, a tag | decision: examples bound by the Constitution |

### Examples reviewed and deliberately left alone

- Anti-pattern blocks marked as wrong (README "unsupervised" snippet, the FORBIDDEN block in helpers Phase 4, data-strategy ❌ blocks). They are supposed to show the violation.
- type-safety Pattern B, `Number(process.env.TIMEOUT_MS ?? 10000)`. The literal is the definition site of a default, which is what `config/` files hold; No Magic Numbers targets call sites.
- data-strategy override examples (`generateUser({ email: 'admin@company.com' })`) and the `@example` in `user.factory.ts`. The override value is the thing being taught.
- api-testing Phase 5 advice to use `beforeAll`/`afterAll` for shared resources, versus SHOULD Test Isolation's `beforeEach`. A refinement for read-only shared setup, not drift.

### Omissions in copies, not fixed here

These copies say less than `CLAUDE.md` without contradicting it. The links refactor (step 3) replaces them with links, so completing them now would be throwaway work.

- README MUST/WON'T tables lack rows for API Test Steps, No Hardcoded Test Content, No Explore-Only Files; its Data Generation row covers API data only where `CLAUDE.md` says "any UI content values too".
- `AI-WORKFLOWS.md` never mentions No Magic Numbers or No Explore-Only Files.
- The Copilot instruction files drop every `references/` pointer, so a Copilot agent never sees the deeper examples. Intended?

Questions for Ivan from this step:

1. **Skip pattern form.** The skills prescribed `/* eslint-disable playwright/no-skipped-test */` above a skip. That form disables the rule to the end of the file. The fork switched to `// eslint-disable-next-line`, verified against the repo's ESLint config. Was the block form a deliberate choice? If so, drop that commit.
2. **Checklist tiers.** There is no stated mapping from MUST/SHOULD/WON'T to 🔴/🟠/🟡 in the pr-reviewer checklist. Existing items follow a sense of damage rather than the table. Should the mapping be written down?
3. **Are teaching snippets bound by the Constitution?** The fork assumed yes and rewrote the good examples. Agents copy examples closely.
4. **ESLint severity versus MUST Linting.** Five Playwright rules are set to `warn` while the Constitution requires lint without warnings. `no-raw-locators` is one of them, so XPath in a `page.locator()` call passes lint; only the write-time hook catches it, and only in the Claude tree. Intended?
5. **Mirror drift is not gated.** `check-rules-drift.sh` and `check-skill-crossrefs.sh` read only `.claude/`. CONTRIBUTING says the gates fail if the trees drift apart; nothing compares them. On the branch the mirrors are build output and `check:mirrors` compares them with a fresh build in pre-commit and CI; `check-rules-drift.sh` is retired. Remaining question: is build output the model you want?
6. **`ai-native-workflow` says it never restates rules, then restates nine** in "Common Critical Rules to Re-Check". On the branch the nine are links; the question is whether you prefer them restated there.

## Step 2: triage of skill-only hard rules (done, see `RULE-TRIAGE.md`)

177 triage rows over the roughly 160 rules that live outside the Constitution. Outcome: 77 skill-local (most already sit in the owning skill's Critical block; a handful are only in prose or references and are listed as homeless), 46 process rules homed in `ai-native-workflow` or `pr-reviewer`, 12 restatements of Constitution rows, 33 guidance, 7 repo-maintenance rules whose home is CONTRIBUTING. Two unresolved. Rules triaged twice under the same id agree on fate and home; rules triaged under different slugs (area-placeholder via `ls`, helper-fixture 3+ threshold, never-suppress-failures / never-bump-timeouts, explicit return types) are flagged in the triage file for a hand merge.

Additional questions for Ivan surfaced by the triage:

7. **api-testing Phase 7 contradicts itself.** Item 4 says never adjust the expected status code to buggy behaviour; item 5 says to use the actual status code when the API returns a different valid code than the spec. Which wins, and what does "valid" mean here?
8. **Null-body carve-out.** MUST Response Validation names one exact pattern with no exception, yet api-testing, type-safety and helpers all allow `expect(body).toBeNull()` for 204 responses. Should the Constitution row name the exception?
9. **Allowed exceptions that contradict hard rules.** data-strategy allows an inline `{ timeout: 10000 }` with a comment (versus No Magic Numbers); enums allows shipping an enum value marked `// FIXME: unverified` when the app is unreachable (versus Explore Before Generate's stop-and-notify); debugging advises committing `console.log` instrumentation while ESLint errors on `no-console`.
10. **Two confidence rubrics.** The workflow gate (below 5 ask, 5-7 trade-offs, 8+ proceed) and the pr-reviewer review score (5 and below, 6-8, 9-10) share a 1-10 scale but mean different things and disagree at 5 and 8. Keep both and label the second as a review score?
11. **Confidence thresholds restated** in AI-WORKFLOWS (five places) and README (two) although the workflow skill declares its Phase 4 section the only home. On the branch both link to Phase 4; the question is whether Phase 4 should stay the only home.
12. **ESLint-only rules.** Seventeen lint rules at error level and five at warn level appear in no prose anywhere. Promotion candidates: `no-console`, `explicit-function-return-type`, `expect-expect`, `require-top-level-describe`.
13. **Repo-maintenance rules in README.** "Mirror rule edits" and the vendored-skill sync instructions sit in README, which ships into scaffolded projects. CONTRIBUTING told people to run `npm run lint:skills`, which did not exist; the branch names `check:skills`. The README placement question stands.
14. **Area placeholder rule has no numbered home.** "Resolve `{area}` with `ls`, never guess" is stated in `CLAUDE.md` prose twice and in seven skills, but is not one of the 36 rows. Promotion candidate.
15. **Explicit return types has three scopes**: type-safety says exported and public functions, ESLint checks every function, README says all parameters and return values.

## Step 3: links refactor (done on branch `rule-tree-links`, see `RULE-TREE-SPEC.md` and `.scratch/rule-tree-links/issues/`)

What changed, by mechanism:

- **Anchors.** Every Constitution row and the `{area}` note carry an inline `rule-<slug>` anchor. Skill-local hard rules carry the same form at the start of their Critical bullet. Row text unchanged.
- **Links.** Restatements across skills, references, the review checklist, the README and the workflows playbook are now links by rule name. Skill Critical blocks hold the skill's own rules in full plus one bullet listing the applicable Constitution rules as links. Gate scripts (write-time hook, ESLint config, review scan script) carry a `file#anchor` reference in a comment per enforced rule.
- **Gates.** The restatement linter and its anchor manifest are gone. The references-drift script is now a link check over all three trees, root docs and gate comments, with fixture-tree self-tests and a hook self-test. The crossrefs script keeps index and frontmatter checks only. `check:skills` keeps its name.
- **Mirrors.** `npm run build:mirrors` generates `.cursor/` and `.github/` from the Claude tree; pre-commit regenerates on canonical edits; `check:mirrors` gates CI and the template smoke test. Copilot now receives `references/` folders. The hand-written extras of the old Copilot instructions file (a Scoped Instructions Index and an Agent-skills section) are not reproduced.
- **Convention.** `CLAUDE.md` gained an "Editing the Rule Trees" section; CONTRIBUTING links to it and no longer asks for hand-edited mirrors. Working documents and tickets are excluded from the template payload.
- **Initializer.** Pruning a tree now unlinks references to it in README, the playbook and the ESLint config; the template smoke test covers full, pruned and no-Claude variants.

Commits an upstream reviewer can drop independently: the next-line skip-disable refinement (step 1), the README File Naming table replaced by a pointer (ticket 12), the Copilot references folders (ticket 03).

Further questions for Ivan from this step:

16. **Copilot instructions file.** Keep the generated Constitution copy as is, or have the build append a Copilot-only activation index listing which glob loads which instruction file?
17. **Anchor slug for one rule differed between two implementers** (re-check Critical blocks before applying); resolved to one anchor. Worth a glance that the surviving name reads well.
18. **CONTRIBUTING still summarises five Constitution rules in prose** in its "Follow the Constitution" bullet; left as a human-facing summary. Link instead?
19. **Skill-lint is no longer pure bash.** The mirror check runs the Node build script (built-ins only, no install) on a runner that ships Node. Intended, but it changes the workflow's stated constraint.
20. **Mirror check sharp edge.** `check:mirrors` rebuilds into the working tree before comparing against the git index, so an uncommitted hand edit to a mirror is overwritten and the check passes; the edit is lost without a message. Acceptable because mirrors are generated, but worth a sentence in the README if it ships.
21. **Scaffold commit needs a git identity.** The initializer's `git commit` fails on a runner with no `user.name` / `user.email` (logged as non-fatal), so the template-smoke project is left staged but uncommitted. Pre-existing on main; the fork only made `check:mirrors` tolerate it. Should template-smoke set an identity so the scaffold's own commit is exercised?

22. **Linked path mentions.** See Also lists and other mentions of existing rule-tree Markdown files now link to the file. The gate rejects the backticked-path phrasing used about 77 times on main. Directory mentions are deliberately out of scope. Is this authoring convention acceptable?
23. **Vendored references.** Skills listed in skills-lock.json are exempt from the orphan check, and their mirror copies get Markdown link targets rewritten while canonical vendored files stay untouched. Vendored prose remains exempt from the path-in-prose check. Is this acceptable?
24. **Three planned Critical homes left in place.** The spec planned to move the spec-side `waitForResponse` sentence (test-standards Phase 5), the unreplaced-placeholder sentence (common-tasks Phase 2) and the idempotent-cleanup note (test-standards troubleshooting) into Critical blocks. Moving them means writing new sentences into a rule home, so the branch anchors the first two where they stand and leaves the third as a troubleshooting note. Promote them to Critical, and if so in your words or the branch's?

## Later steps (planned, not started)

- **Restatement eval**, with Ivan: run the skill-creator eval loop against a "links only" and a "restated" variant of the Critical blocks. Decides whether any rule needs restating in a skill for steering, which the links refactor deliberately did not settle.

Steps 1 to 3 above are done on branch `rule-tree-links`. The questions are numbered in one sequence across the steps (1 to 24).
