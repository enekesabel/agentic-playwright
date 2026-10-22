# 06: Code gates link to their rules

**What to build:** Each rule the write-time hook, the ESLint config and the review scan script enforce carries a relative link to its home in a comment, and each review checklist item links to its rule. Renaming a rule now breaks the gate's link, which the link check reports. Hook behaviour, lint severities, checklist numbering and tiers are unchanged.

**Blocked by:** 05 Constitution anchors and the authoring convention

**Status:** done (merged to rule-tree-links)

- [x] Every enforced rule in hook, ESLint config and scan script has a resolving link comment (ESLint rules whose home is a skill link the skill anchor; gate-only rules with no prose home, UPSTREAM-NOTES Q12, carry none)
- [ ] Review checklist items link to their rule homes
- [ ] Hook verified with a known-bad write: still blocks with the same messages
- [ ] Checklist numbering and tiers unchanged
