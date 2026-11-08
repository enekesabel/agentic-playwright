# Root-doc conversion notes

## Row wins (4)

- `README.md:970`: copy: "`page.locator()` -- CSS/XPath (last resort)"; row **No XPath**: "No XPath.". Replaced the copy with the named row link; retained compatible local explanation.
- `README.md:1349`: copy: "**Semantic Locators** -- Prefer `getByRole`, `getByLabel` over CSS/XPath"; row **No XPath**: "No XPath.". Replaced the copy with the named row link; retained compatible local explanation.
- `README.md:1316`: copy: "Avoid `any`"; row **No `any`**: "No `any`.". Replaced the copy with the named row link; retained compatible local explanation.
- `.github/prompts/pr-reviewer.prompt.md:116`: copy: "URLs/paths/messages from `config`/`enums`"; row **Sources of Truth**: "URLs and credentials from `process.env.*` (`env/.env.example`); endpoint paths, routes, messages and storage-state paths from `enums/{area}/*` and `enums/util/*`.". Replaced the copy with the named row link; retained compatible local explanation.

## Questions (0)

None.

## Judgement calls

- Preserved examples, tag classification explanations, API coverage details, static-data tier explanations and harness-specific CLAUDE.md content. These explain application or skill-local detail rather than changing a row.
- Kept the required Copilot prompt phrase `strictObject` beside Strict Schemas; preserved the other git-flow gate phrases.
- Confidence links target ai-native-workflow's Critical block as requested; its proposal format remains in Procedure. Kept proposal-format examples and review-specific confidence rubric.
- Corrected the README's documented budget from 800 to the implemented 840 words. Updated eight gates to nine including self-tests.
- CLAUDE.md's @AGENTS.md is a harness import, not a backticked prose path; its Claude Code block stays intact.

## Manifest lines removed

Commit 2 retires the file; remaining tokens are skill-local.

## Cap pressure

None; no skill or Constitution content edited.

## Uncovered rows (2)

- [Type Safety](../../AGENTS.md#rule-type-safety): no converted Critical block links it. Explicit allowlist reason in check-rules-drift.sh.
- [Test Steps](../../AGENTS.md#rule-test-steps): links occur in procedures rather than Critical blocks. Explicit allowlist reason in check-rules-drift.sh.

## Additional judgement calls

- Replaced the old hook-id table in rules-drift with row-link ownership checks; the separate link gate validates hook annotations. Updated documentation and hook comments accordingly.
- The rules gate requires 36 distinct row anchors, checks actual relative targets, ignores fenced/inline examples and vendored skills, and reports all owners. Added missing-row, broken-link, vendored-exclusion and generated-tree fallback tests.
- The existing prose-path fixture also has an orphan reference, so an independent fixture tests STRICT_PROSE_PATHS=0 without that unrelated failure.
- Formatted the three pre-existing untracked notes after full Prettier reported them; they remain untracked.
- Initialized missing Husky wrappers and amended the first commit with hooks enabled; no hook bypass.

- Pinned Prettier also required formatting-only changes to tracked gate-overlap.md and restatement-census.md; included in commit 1 to satisfy the full-project check.
- Smoke discovered --no-claude root-doc links targeting deleted files. The initializer now rewrites skill link targets to .agents and renders omitted CLAUDE importer links as text. This is the package-only exception needed to keep smoke green.
- Generated --skip-install scaffolds retain the template lock's version until install; refreshed their locks offline before the version check (temporary outputs only).
- Optional live demo/browser test skipped because it requires downloads/network; default scaffold quality and all three variants' gates tested locally.

## Files per commit

### db8b77f docs(root): README, CONTRIBUTING, AI-WORKFLOWS and the Copilot prompt link instead of restate

- `.github/prompts/pr-reviewer.prompt.md`
- `.scratch/v2-investigation/gate-overlap.md`
- `.scratch/v2-investigation/restatement-census.md`
- `AI-WORKFLOWS.md`
- `CONTRIBUTING.md`
- `README.md`

### 6dc98a1 feat(gates): rules drift checks links, manifest retired, prose paths strict

- `.github/workflows/skill-lint.yml`
- `.github/workflows/template-smoke.yml`
- `.husky/pre-commit`
- `README.md`
- `packages/create-agentic-playwright/bin/create.js`
- `scripts/check-rules-drift.sh`
- `scripts/check-skill-references-drift.sh`
- `scripts/rules-manifest.txt`
- `scripts/tests/fixtures/path-in-prose-off/.claude/skills/demo/SKILL.md`
- `scripts/tests/fixtures/path-in-prose-off/AGENTS.md`
- `scripts/tests/fixtures/rules-broken/.claude/skills/demo/SKILL.md`
- `scripts/tests/fixtures/rules-broken/AGENTS.md`
- `scripts/tests/fixtures/rules-clean/.claude/skills/demo/SKILL.md`
- `scripts/tests/fixtures/rules-clean/AGENTS.md`
- `scripts/tests/fixtures/rules-fallback/.agents/skills/demo/SKILL.md`
- `scripts/tests/fixtures/rules-fallback/AGENTS.md`
- `scripts/tests/fixtures/rules-uncovered/.claude/skills/demo/SKILL.md`
- `scripts/tests/fixtures/rules-uncovered/AGENTS.md`
- `scripts/tests/fixtures/rules-vendored/.claude/skills/demo/SKILL.md`
- `scripts/tests/fixtures/rules-vendored/AGENTS.md`
- `scripts/tests/fixtures/rules-vendored/skills-lock.json`
- `scripts/tests/run.sh`
