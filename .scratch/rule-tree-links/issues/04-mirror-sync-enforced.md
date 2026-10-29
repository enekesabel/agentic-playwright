# 04: Mirror sync enforced

**What to build:** Staging any canonical rule-tree file regenerates the mirrors in pre-commit and adds them to the commit, so mirrors are never committed stale. CI runs the build and fails on a non-empty diff with a message telling the contributor to run the build. The fork's working documents (upstream notes, rule triage, spec, these tickets) are excluded from the template payload. The template smoke workflow runs the mirror check on the full scaffold and still passes on the pruned one.

**Blocked by:** 03 Mirror build script

**Status:** done (merged to rule-tree-links)

- [ ] Pre-commit regenerates mirrors when canonical files are staged
- [ ] CI job fails on stale mirrors with an actionable message
- [ ] Working documents excluded from the packed template
- [ ] Template smoke: full variant checks mirrors, pruned variant still green
- [ ] CONTRIBUTING no longer instructs editing mirrors by hand
