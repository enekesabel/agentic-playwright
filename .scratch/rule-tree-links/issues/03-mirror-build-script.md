# 03: Mirror build script

**What to build:** A maintainer runs one npm script and the Cursor and Copilot trees are regenerated from the canonical Claude tree and the Constitution: Cursor skills copied with path rewriting and the rules file produced with its frontmatter; Copilot skills flattened to instruction files with the `applyTo` glob from a mapping held in the script, reference files copied alongside under the layout the link check supports, and the Copilot instructions file produced from the Constitution with its header. The vendored skills are mirrored like the rest. Running the build twice yields no diff. The first run is committed on its own so the diff shows how far the hand-maintained copies had drifted.

**Blocked by:** None (can start immediately)

**Status:** done (merged to rule-tree-links)

- [ ] Single npm script regenerates both mirror trees
- [ ] Idempotent: second run produces an empty diff
- [ ] Copilot glob mapping lives in the build script and reproduces today's globs
- [ ] Copilot tree now contains reference files; the link check passes on it
- [ ] Links inside each generated tree stay inside that tree
- [ ] First regeneration committed separately with the drift described in the commit body
