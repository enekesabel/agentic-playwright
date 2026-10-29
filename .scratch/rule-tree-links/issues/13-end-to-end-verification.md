# 13: End-to-end verification and notes

**What to build:** With everything merged, a maintainer can run the combined gate script, pack the initializer, scaffold both a full and a pruned project, and see every check pass. A sweep for leftover restatements of Constitution rules outside their homes finds none. The upstream notes record what changed, which questions remain, and which commits an upstream reviewer can drop independently.

**Blocked by:** 02 Retire the restatement linter; 06 Code gates link to their rules; 07 through 12 (all conversions)

**Status:** done (merged to rule-tree-links)

- [ ] Combined gate script, TypeScript, ESLint and Prettier green on the repo
- [ ] Packed initializer: full and pruned scaffolds pass their gates
- [x] Sweep for restatements outside homes: the ones that remain are deliberate, passages tied to open questions (UPSTREAM-NOTES Q7, Q8, Q9, Q15) keep their wording and carry a link
- [ ] Upstream notes updated
