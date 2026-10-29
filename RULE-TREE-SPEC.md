# Spec: one home per rule, links everywhere else, mirrors as a build output

## Problem Statement

The AI rule trees are the product of this scaffold: a Constitution (`CLAUDE.md`) that is always loaded, seventeen skills that load on demand, and mirrors of both for Cursor and GitHub Copilot. Today every rule is written out many times. The median Constitution rule is stated as a rule in twelve to thirteen files of the canonical tree alone, and the two trees that mirror it triple that. The drift linter demands part of this duplication: it requires each Constitution rule's wording to appear inside the owning skill's Critical block, while the repo's own layering document says skills must not restate Constitution rules.

The cost showed up as real divergence. Copies that softened or truncated the source: a three-level selector order where the Constitution has five, "avoid `any`" where it says never, XPath as a last resort where it is forbidden, a review checklist missing rules, and good examples that break the rule they illustrate. Those were fixed by hand in a first pass, but nothing stops them from recurring, because no gate compares the copies to the source and no gate compares the Claude tree to the Cursor or Copilot trees at all, even though CONTRIBUTING says one does.

For a maintainer, changing one rule means touching roughly fourteen hand-maintained statements in one harness and three harnesses. For an agent, the always-loaded Constitution already carries every rule, so restating it in skills adds emphasis but no information, while skill-local rules that other skills restate in their own words drift silently.

## Solution

Every hard rule gets exactly one home. Constitution rules live in the Constitution tables, each row carrying a stable anchor. Skill-local rules live in the owning skill's Critical block. Every other mention becomes a Markdown link whose text is the rule's name, so prose stays readable and an agent sees what is being pointed at. Code gates that must restate a rule in a regex (the write-time hook, the ESLint config, the review scan script) carry a link to the rule's home in a comment.

A deterministic link check replaces the restatement linter: every relative link and every `file#anchor` reference in the rule trees, root docs and gate scripts must resolve to an existing file and heading or anchor. Rename or remove a rule and every reference to it breaks, in prose and in code.

The Cursor and Copilot trees stop being hand-maintained copies. A build script generates them from the canonical Claude tree by path rewriting, flattening, and copying reference files. The pre-commit hook regenerates them when canonical files are staged, and CI fails if the committed mirrors differ from a fresh build. The canonical tree itself is not generated; it stays hand-written.

The rule set does not change. Constitution rows keep their text apart from the added anchor. Skill-local rules keep their text in their home. Only restatements are replaced by links. The handful of hard rules that currently have no Critical-block home get one, with the exceptions recorded in the triage as upstream questions left untouched.

## User Stories

1. As a maintainer of the fork, I want each rule to exist in one place, so that changing a rule is one edit rather than fourteen.
2. As a maintainer, I want a link from every mention to the rule's home, so that I can read a skill and jump to the authoritative wording without searching.
3. As a maintainer, I want link text to carry the rule's name rather than an identifier, so that prose stays readable when the link is not followed.
4. As a maintainer, I want a deterministic link check in pre-commit and CI, so that a renamed or deleted rule fails the build everywhere it is referenced.
5. As a maintainer, I want the check to cover comments in the hook, the ESLint config and the review scan script, so that mechanical enforcement cannot silently outlive the rule it enforces.
6. As a maintainer, I want the Cursor and Copilot trees generated from the Claude tree, so that I never edit the same change three times.
7. As a maintainer, I want CI to fail when committed mirrors differ from a fresh build, so that the claim in CONTRIBUTING that the trees cannot drift becomes true.
8. As a maintainer, I want pre-commit to regenerate the mirrors when I stage a canonical file, so that mirrors are always committed in sync without me remembering.
9. As a maintainer, I want the mirror build to be runnable locally with one npm script, so that I can inspect its output before committing.
10. As a maintainer, I want the restatement linter and its anchor manifest retired, so that the gate no longer mandates the duplication this change removes.
11. As a maintainer, I want the remaining structural checks kept (skills index matches disk, frontmatter name matches folder, no orphaned reference files), so that nothing that works today regresses.
12. As a maintainer, I want the dangling-token heuristic in the crossrefs check dropped once mentions are links, so that the allowlist of false positives stops growing.
13. As a maintainer, I want the authoring convention written down where anyone editing the trees will read it, so that new contributions link instead of restating.
14. As a maintainer, I want the convention to say what a hard rule's home is and what to do when a rule has none, so that the triage decisions are repeatable.
15. As an agent running in Claude Code, I want the Constitution still loaded on every turn with its rules intact, so that my behaviour does not change.
16. As an agent running in Claude Code, I want a skill's Critical block to tell me which Constitution rules apply by name and link, so that I know what to re-check without a second copy of the text.
17. As an agent running in Claude Code, I want a skill's own hard rules stated in full in that skill's Critical block, so that the rules I cannot get from the Constitution are in front of me when the skill loads.
18. As an agent running in Cursor, I want the Cursor rules file and skills to carry the same content as the Claude tree with Cursor paths, so that nothing is lost in the mirror.
19. As an agent running in Copilot, I want the instruction files to include the reference material the Claude skills link to, so that I am no longer the harness that never sees the examples.
20. As an agent running in Copilot, I want each instruction file scoped by the same glob it has today, so that the right instructions still activate for the files I edit.
21. As an agent in any harness, I want links inside my tree to point inside my tree, so that following one never lands on a path that does not exist in my checkout.
22. As an agent, I want the write-time hook to keep blocking the same seven violations, so that the deterministic floor under the prose is unchanged.
23. As a reviewer using the pr-reviewer skill, I want the review checklist to link each item to its rule, so that a finding can cite the rule's home.
24. As a reviewer, I want the review scan script to keep its checklist numbering and tiers, so that reports stay comparable.
25. As a downstream user who scaffolds a project, I want the generated project to pass its own gates with all three trees present, so that the template smoke test stays green.
26. As a downstream user who prunes the Cursor or Copilot tree at scaffold time, I want the gates to tolerate the missing tree, so that pruning keeps working.
27. As a downstream user who prunes the Claude tree, I want the remaining trees to be self-contained, so that no link points into a tree I removed.
28. As a downstream user who customises a skill, I want the convention and the link check to apply to my edits, so that my own rule trees do not drift either.
29. As a downstream user, I want the mirror build available in my generated project, so that customising the Claude tree regenerates my Cursor and Copilot trees.
30. As a downstream user, I want working notes from the fork's restructuring excluded from the template, so that my project does not ship someone else's to-do list.
31. As the upstream author, I want every Constitution row's wording unchanged apart from an invisible anchor, so that the rules remain mine.
32. As the upstream author, I want contradictions and exceptions the triage found left untouched and listed as questions, so that I decide them rather than a refactor.
33. As the upstream author, I want the change to arrive as a sequence of reviewable commits, each with its reasoning, so that I can accept or drop parts independently.
34. As the upstream author, I want the vendored `skill-creator` and `playwright-cli` skills untouched, so that reinstalling them from upstream keeps working.
35. As the upstream author, I want the skill-lint workflow to stay pure bash with no Node install, so that the gate stays cheap. (Superseded on the branch: the mirror check runs the Node build script, built-ins only, on a runner that ships Node; UPSTREAM-NOTES Q19.)
36. As anyone reading the Constitution on GitHub, I want the tables to render exactly as before, so that the anchors are invisible.
37. As anyone reading a skill, I want a rule that lives elsewhere to be a link and a rule that lives here to be text, so that I can tell the home from the reference at a glance.
38. As anyone running the checks locally, I want one npm script that runs every gate, so that I do not need to know the script names.
39. As a future contributor, I want a failing link check to name the file, the link and the reason, so that I can fix it without reading the script.
40. As a future contributor, I want a failing mirror check to tell me to run the build, so that the fix is one command.
41. As someone planning the later restatement experiment, I want the Critical blocks to be the only place Constitution rules are still echoed, so that a "links only" variant is one mechanical transformation away.

## Implementation Decisions

### Homes

- The Constitution tables (MUST, SHOULD, WON'T) are the canonical home for their rules. Each row gains an inline HTML anchor at the start of its rule-name cell. Anchor slugs derive from the rule name, not from an inventory number, and are stable across rewording of the row text. The File Naming table and the area-placeholder note gain anchors too, because skills reference both.
- The owning skill's Critical block is the canonical home for a skill-local hard rule. The triage document records the home for each.
- The rules the triage found outside any Critical block are given one: the API coverage items (405 per endpoint, 401 and 403 matrix) move into api-testing's Critical block; the spec-side wait-for-response sentence (test-standards Phase 5) and the unreplaced-placeholder sentence (common-tasks Phase 2) are anchored where main states them rather than moved, because moving them would put new sentences into a rule home; the idempotent-cleanup note stays a troubleshooting note. Promoting the three is UPSTREAM-NOTES Q24. Factory JSDoc keeps its place as a Phase 2 requirement with an anchor (an earlier draft demoted it to guidance); exporting inferred types stays prose in type-safety rather than being promoted. The two ESLint-only Playwright rules stay gate-only. The null-body exception, the Phase 7 status-code contradiction, and the allowed exceptions that contradict hard rules stay exactly as written, since they are upstream questions.
- The workflow and pr-reviewer process rules keep their homes in those two skills' phase sections. The confidence thresholds keep their declared single home in the workflow skill; every other restatement of the numbers becomes a link.

### Links

- Every mention of a rule outside its home becomes a Markdown link. Link text is the rule's name as it appears in its home. Links are relative and stay inside the tree that contains them.
- Skill Critical blocks keep a short list of the Constitution rules that apply to that skill, as links, so that the re-check behaviour survives. They do not restate the text.
- Code gates reference rules with a relative `file#anchor` in a comment next to the rule they enforce. The hook's user-facing messages keep naming the rule.
- The pr-reviewer checklist and scan script link each item to its rule; numbering and tiers are unchanged.

### Checks

- The references-drift script generalises into a link check over every tracked text file in the rule trees, root docs and gate scripts. It resolves inline Markdown links in `.md` and `.mdc` files, and bare `file.md#anchor` or `file.mdc#anchor` tokens in other text files (gate scripts, the hook, the ESLint config), relative to the containing file; it requires the target file to exist and the anchor to match a heading slug or an inline HTML anchor id. Reference-style link definitions are rejected so one link syntax resolves everywhere. A backticked path to an existing rule-tree Markdown file fails as a prose mention. The orphan-reference check stays and counts Markdown links only; skills listed in skills-lock.json are exempt from the orphan and prose-mention checks.
- The rules-drift script and its anchor manifest are removed.
- The crossrefs script keeps the index-to-disk and frontmatter checks and drops the dangling-token heuristic and its allowlist.
- The combined npm script that runs all gates is kept under its current name so CI and the pre-commit hook need no renaming beyond the removed script.
- Scripts accept an optional root directory argument so they can be run against a fixture tree. Default remains the repository that contains them.

### Mirrors

- A build script generates the Cursor tree and the Copilot tree from the canonical tree. Cursor: skills copied with path rewriting, the rules file produced from the Constitution with the Cursor frontmatter prepended. Copilot: each skill in the build script's mapping flattened to an instructions file with an `applyTo` frontmatter (pr-reviewer is not in the mapping and has no Copilot instructions file; the mapping says why), its reference files copied alongside under the layout the link check already supports, and the Constitution produced as the Copilot instructions file with its header. The two vendored skills are mirrored like the rest; the mapping, not their frontmatter, carries their globs.
- The build is idempotent: running it on a clean checkout produces no diff.
- The pre-commit hook runs the build when any canonical file is staged and adds the regenerated mirrors to the commit. CI runs the build and fails on a non-empty diff.
- The initializer's prune options are unchanged. A pruned tree simply has no build target; the gates already tolerate a missing tree.

### Convention

- The Constitution gains a short section on editing the rule trees: one home per hard rule, link instead of restating, run the mirror build, what the gates check. CONTRIBUTING links to it and drops the instruction to edit mirrors by hand. The section ships with the Constitution into scaffolded projects on purpose, because downstream users customise their trees.

### Packaging

- The fork's working documents (upstream notes, rule triage, this spec) are excluded from the template payload so they never reach a scaffolded project.
- No version bump and no changelog entry on the fork; both belong to the upstream release.

## Testing Decisions

A good test here exercises the scripts through the same entry points CI uses and asserts on exit code and output. It does not inspect script internals.

- **Seam: the gate scripts' command-line contract.** Each script takes a root directory and exits non-zero with a message naming the file and the problem. Tests feed fixture trees: one with a broken link, one with a missing anchor, one with an orphan reference, one with a clean tree. The link check must fail the first three and pass the last. The same seam is used for the crossrefs script with a fixture whose skills index disagrees with disk.
- **Seam: the mirror build's idempotence.** Build on a clean checkout, then assert an empty diff. Then modify a canonical skill in a scratch copy, build, and assert the Cursor and Copilot outputs contain the change at the rewritten path. This is the same assertion CI makes.
- **Seam: the scaffolded project.** The existing template smoke workflow scaffolds a full and a pruned project and runs the gates inside each. It is extended with the mirror check for the full variant and stays green for the pruned variant. No new workflow.
- **Seam: the write-time hook.** The hook's behaviour is unchanged; its existing manual contract (JSON on stdin, exit 0 or 2) is exercised once with a known-bad write to confirm the comment links did not break it.
- Prior art: the template smoke workflow is the only existing automated exercise of these scripts; there are no unit tests for scripts today. The fixture-tree approach adds the smallest harness that gives a negative test, kept in bash to match the skill-lint workflow's no-Node constraint.
- Not tested by automation: that an agent follows links. That is the later restatement experiment.

## Out of Scope

- Changing any rule's meaning, promoting a skill-local rule into the Constitution, or resolving the contradictions and exceptions listed as upstream questions.
- Editing the vendored `skill-creator` and `playwright-cli` skill bodies.
- Re-tuning Copilot `applyTo` globs or Cursor activation beyond reproducing what exists.
- Generating the canonical Claude tree from a registry or data file.
- A mechanical "no restatement" detector beyond the link check; the convention plus review covers it.
- The restatement eval experiment with the skill-creator loop.
- Reworking the initializer, the dev container, or the release workflow.

## Further Notes

- The first pass that fixed the disagreeing copies is already on the branch as seven commits, plus the inventory, the triage and its verification. The triage document names the home for every rule this spec relies on.
- The repo's own three-layer document already states the principle this spec implements: skills should link to the Constitution rather than restate it. The drift linter was the one mechanism contradicting that; retiring it is the change that lets the rest follow.
- Because the Constitution is always loaded, links from skills to it are free for the agent; the rule is already in context. Links between skills are the only place where a hop costs anything, which is what the later experiment measures.
- Prettier formats Markdown in CI, so edits to tables must be run through it; whole-table realignment is expected noise in diffs.
- The crossrefs check is structural only: Skills Index versus skill folders, and frontmatter names versus folder names. The earlier dangling-token heuristic is retired.
