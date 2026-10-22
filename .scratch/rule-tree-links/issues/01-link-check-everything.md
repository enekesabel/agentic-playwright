# 01: Link check over everything, with fixture tests

**What to build:** A contributor who writes a Markdown link, or a `file#anchor` reference in a gate-script comment, that points to a missing file, a missing heading or anchor, or leaves a reference file unlinked, sees the pre-commit hook and the skill-lint CI job fail with the file, the link and the reason named. Existing content passes unchanged. The check covers the canonical Claude tree, the Cursor and Copilot trees, the root docs, the write-time hook, the ESLint config and the review scan script. All gate scripts accept an optional root-directory argument so they can run against a fixture tree, defaulting to the repository that contains them.

**Blocked by:** None (can start immediately)

**Status:** done (merged to rule-tree-links)

- [ ] Markdown links and bare `file#anchor` tokens in comments resolve relative to the containing file
- [ ] Anchors match either a heading slug or an inline HTML anchor id
- [ ] Orphan-reference check retained
- [ ] Fixture trees for broken link, missing anchor, orphan reference and clean tree; the first three fail, the last passes
- [ ] Scripts take an optional root directory; default behaviour unchanged
- [ ] Wired into the combined check script, pre-commit and the skill-lint workflow; pure bash
- [ ] Current repository passes
