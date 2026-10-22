# 02: Retire the restatement linter

**What to build:** The rules-drift script and its anchor manifest no longer exist, so nothing requires a Constitution rule's wording to be repeated inside a skill. The crossrefs script keeps the skills-index-to-disk and frontmatter checks and drops the dangling-token heuristic and its allowlist. Every place that names the removed script (workflows, hook, package scripts, README, CONTRIBUTING, the three-layer reference, the template smoke pruned step) is updated. All gates stay green.

**Blocked by:** 01 Link check over everything

**Status:** done (merged to rule-tree-links)

- [ ] Rules-drift script, manifest and npm script removed
- [ ] Crossrefs script retains index and frontmatter checks only
- [ ] No workflow, hook, doc or template step references the removed script
- [ ] Combined check script and template smoke pass on repo and on a pruned scaffold
