---
applyTo: '**/*'
---

# AI-Native Workflow

Routing layer between user intent and the specialized skills that own the rules. Load first on every non-trivial task.

For deeper context: see [`references/three-layer-model.md`](ai-native-workflow/references/three-layer-model.md), [`references/conversation-contract.md`](ai-native-workflow/references/conversation-contract.md), [`references/principles.md`](ai-native-workflow/references/principles.md), [`references/examples.md`](ai-native-workflow/references/examples.md), [`references/troubleshooting.md`](ai-native-workflow/references/troubleshooting.md).

## Critical

- **Low confidence means Phase 3 is incomplete.** Below the floor in [Confidence Gate Thresholds](#rule-confidence-gate-thresholds), do **NOT** emit Phase 4; return to Phase 3 and **ASK the user**. This rule is the most leveraged in the workflow: it stops plausible-looking plans built on guesses.
- <a id="rule-ask-dont-invent"></a>**Ask, don't invent.** Never guess folder names, file paths, env-var names, enum values, credentials, or message strings. `ls`, `grep`, `playwright-cli`, OpenAPI — or ask.
- <a id="rule-refuse-placeholders"></a>**Refuse placeholders.** Guessed selectors, unverified message strings, made-up enum values, secret-shaped strings — refuse and re-explore. **`TODO` / `skeleton` / "to fill in later" outputs count as placeholders too** — offering a "skeleton page object with TODO locators while we wait for `playwright-cli`" is the same failure mode as inventing locators outright; don't.
- **Verify the user's premise even in Direct Mode.** See [Direct Mode Premise Check](#rule-direct-mode-premise-check).
- <a id="rule-skill-wins"></a>**Specialized skills own the rules.** This skill never restates rules from `api-testing`, `page-objects`, etc. It tells you **which skill to load** and **in what order**.
- **The [Constitution](../copilot-instructions.md) is the safety floor.** It takes precedence over any prose, template, or example.
- <a id="rule-audit-then-edit"></a>**Audit-then-edit by default.** For any non-trivial change, follow the 8-phase workflow below. Phase 4 (Plan + Confidence) is mandatory before Phase 6 (Apply).
- **Confidence gate is required.** See [Confidence Gate Required](#rule-confidence-gate-required).
- **Exploration is non-negotiable.** See [Explore Before Generate](../copilot-instructions.md#rule-explore-before-generate) and [No Substitute UI Exploration](../copilot-instructions.md#rule-no-substitute-ui-exploration).
- **One skill at a time.** Load skills sequentially per the routing table. Don't stack 5 skills' Critical blocks before starting work.
- **After any test edit, run the affected tests.** See [Test Verification](../copilot-instructions.md#rule-test-verification). On red, load `debugging` ([Never Suppress Failures](debugging.instructions.md#rule-never-suppress-failures)).

## Main Workflow (8 Phases)

Every non-trivial task runs through these phases in order.

| #   | Phase                   | Generic substeps                                                                                                                                                                                                                               | Flow-specific substeps owned by                                                                                                                 |
| --- | ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Classify intent**     | Match user request → intent class (codegen / edit / refactor / debug / explore / config).                                                                                                                                                      | —                                                                                                                                               |
| 2   | **Route**               | Pick first skill from routing table. Codegen → `common-tasks`. Other → direct skill.                                                                                                                                                           | —                                                                                                                                               |
| 3   | **Explore**             | Confirm what's known vs unknown; gather evidence per flow. <a id="rule-ask-on-missing-input"></a>**If a primary input is missing (URL, OpenAPI, area folder, field list), ASK the user before advancing — do NOT carry the gap into Phase 4.** | UI: `playwright-cli`. API: `api-testing` Phase 1 (OpenAPI). Refactor: `refactor-values` Phase 1 (impact grep). Debug: `debugging` capture step. |
| 4   | **Plan + Confidence**   | Produce proposal block (see format below).                                                                                                                                                                                                     | — (owned here)                                                                                                                                  |
| 5   | **Human gate**          | <a id="rule-human-gate"></a>Wait for confirm / reject / rework. On reject → return to Phase 3 with stated gap.                                                                                                                                 | —                                                                                                                                               |
| 6   | **Apply**               | Edits per leaf-skill rules. Re-check Critical blocks of every loaded skill.                                                                                                                                                                    | leaf skill                                                                                                                                      |
| 7   | **Verify**              | Lint + run affected tests. Red → load `debugging`.                                                                                                                                                                                             | `debugging` (on red), `refactor-values` Phase 4 (refactor), `api-testing` Phase 5 (API coverage matrix)                                         |
| 8   | **Report + commit ask** | <a id="rule-ask-before-commit"></a>Files changed, line counts, lint status. Ask before committing.                                                                                                                                             | —                                                                                                                                               |

### Phase 4 — Confidence-Gate Format (mandatory)

<a id="rule-confidence-gate-required"></a>Every Plan output before the human gate uses this shape:

```
## Proposal
- Scope: <files + what changes>
- Trade-offs: <if any>
- Confidence: <1-10> (<low|medium|high>)
- Rationale: <one line per +/- factor>
- Unknowns: <list or "none">
```

<a id="rule-confidence-gate-thresholds"></a>**Confidence rules** (canonical home — `conversation-contract.md` and the Critical block above link here; never restate these thresholds elsewhere):

- **< 5** → **do NOT emit Phase 4.** Exploration is incomplete. Return to Phase 3 and **ASK the user** for the missing primary input (URL, OpenAPI source, area folder, field list, etc.). Frame the gap as questions, not as a low-confidence proposal — Phase 4 exists for honest _trade-off_ decisions, not for documenting "I don't have enough data".
- **5-7** → emit Phase 4 with explicit unknowns. Proceed only if the human accepts the trade-offs at this confidence level.
- **≥ 8** → full evidence in hand; proceed normally.
- **≥ 9** only if: explicit OpenAPI / spec match, no `{area}` ambiguity, no missing enum / env / credential, no untested branch, no in-flight conflicting work.
- <a id="rule-rejection-reenter-phase3"></a>**Rejection by human** → re-enter Phase 3 with stated gap. Do **not** retry Phase 4 with the same plan.

## Routing Table (intent → first skill)

| User intent                                 | First skill             | Then chains to                                            |
| ------------------------------------------- | ----------------------- | --------------------------------------------------------- |
| "Add tests for `POST /api/...`"             | `api-testing`           | `data-strategy`, `enums`, `type-safety`, `debugging`      |
| "Add a page object for X"                   | `page-objects`          | `selectors`, `playwright-cli`, `enums`, `fixtures`        |
| "Generate prompt for X" / "How do I add Y?" | `common-tasks`          | matching specialized skill                                |
| "Test failing / flaky"                      | `debugging`             | `api-testing`, `selectors`, `fixtures`, `refactor-values` |
| "Rename enum / change static value"         | `refactor-values`       | `enums` or `data-strategy` → `debugging`                  |
| "Create factory for X"                      | `data-strategy`         | `type-safety`, `api-testing`                              |
| "Wire setup helper / helper fixture"        | `helpers` or `fixtures` | `api-testing` Phase 8                                     |
| "Add env var / config / utility URL"        | `config`                | `enums`, `type-safety`                                    |
| "Add enum / endpoint / message"             | `enums`                 | `playwright-cli` for live-text verification               |
| "Refactor Zod schema / convert any → typed" | `type-safety`           | `api-testing`                                             |
| "Add spec file / tag / structure question"  | `test-standards`        | `data-strategy`, `api-testing`, `page-objects`            |
| "Create / improve / eval an agent skill"    | `skill-creator`         | `ai-native-workflow` (routing fit), this index            |
| "How does this scaffold work with AI?"      | **this skill**          | relevant specialized skill                                |

If intent matches none of the above → default to `common-tasks` or ask the user to clarify.

## Direct Mode (skip audit-then-edit)

<a id="rule-direct-mode-scope"></a>For trivial work (one-line fix, obvious typo, single import) the agent applies and reports back. The user can say "just do it" once to opt out of audit-then-edit for the rest of the session for trivial work. Substantive changes still go through the 8-phase workflow.

<a id="rule-direct-mode-premise-check"></a>**Even in Direct Mode, verify the user's premise before editing.** Open the cited file, find the cited line, confirm the reported defect is actually there. If the typo isn't on that line, the import isn't where the user said, or the value isn't what the user claims it currently is — stop and report the mismatch instead of applying a "fix" to a defect that doesn't exist. This is the same anti-invention principle as Phase 3 ASK, scaled to one-line work.

## When to Stop and Ask

- <a id="rule-stop-and-ask"></a>Path / folder name unknown (`ls` first; if still unclear, ask). Resolve [the `{area}` placeholder](../copilot-instructions.md#rule-area-placeholder) this way.
- Enum value / message text / endpoint path unknown (`playwright-cli` for UI, OpenAPI for API; ask if neither).
- Two valid approaches with meaningful trade-offs (architectural decisions belong to the human).
- <a id="rule-raise-conflict-dont-bypass"></a>A skill's Critical rule conflicts with the user's request (raise it; never silently bypass).

For the full conversation contract (audit-then-edit details, refusal triggers), see [`references/conversation-contract.md`](ai-native-workflow/references/conversation-contract.md).

## Common Critical Rules to Re-Check in Phase 6

<a id="rule-recheck-critical-blocks"></a>Surface across multiple specialized skills — re-check before declaring done:

- [Response Validation](../copilot-instructions.md#rule-response-validation)
- [Selectors](../copilot-instructions.md#rule-selectors)
- [No Multiple Tags](../copilot-instructions.md#rule-no-multiple-tags), [State Cleanup](../copilot-instructions.md#rule-state-cleanup)
- [No Loose Schemas](../copilot-instructions.md#rule-no-loose-schemas), [No Any](../copilot-instructions.md#rule-no-any), [No XPath](../copilot-instructions.md#rule-no-xpath), [No Hard Waits](../copilot-instructions.md#rule-no-hard-waits)
- [Sources of Truth](../copilot-instructions.md#rule-sources-of-truth)
- [No JSON Static Data](../copilot-instructions.md#rule-no-json-static-data)

## See Also

- **[`.github/copilot-instructions.md`](../copilot-instructions.md)** — always-loaded Constitution (MUST/SHOULD/WON'T tables).
- **`common-tasks`** — codegen sub-router with prompt templates.
- **`debugging`** — failure-investigation half of the lifecycle (Phase 7 routes here on red).
- **`api-testing`** — deep skill for API work; owns Phase 1 (contract source) and Phase 7 (behaviour mismatch).
- **`refactor-values`** — deep skill for changing existing enum / static values.
- **`page-objects`**, **`selectors`**, **`playwright-cli`** — UI authoring chain.
- **`test-standards`**, **`data-strategy`**, **`type-safety`**, **`enums`**, **`config`**, **`fixtures`**, **`helpers`** — rest of the suite.
- **`skill-creator`** — authoring/improving/evaluating the skills themselves (meta-work on this suite).
- **[`references/three-layer-model.md`](ai-native-workflow/references/three-layer-model.md)** — how orchestrator / specialized skills / code conventions layer.
- **[`references/conversation-contract.md`](ai-native-workflow/references/conversation-contract.md)** — audit-then-edit, when to ask vs do, when to refuse.
- **[`references/principles.md`](ai-native-workflow/references/principles.md)** — the five principles that make the scaffold AI-native.
- **[`references/examples.md`](ai-native-workflow/references/examples.md)** — three end-to-end multi-skill chains (API test, refactor, CI failure).
- **[`references/troubleshooting.md`](ai-native-workflow/references/troubleshooting.md)** — common agent failure modes and fixes.
