# Conversion rules: link instead of restate

The rules the three `refactor(skills)` commits and the root-docs commit applied. Context they
rely on:

- `AGENTS.md`: every Constitution row carries an inline anchor right after its bold name,
  `- **Imports**<a id="rule-imports"></a>: …`. Slug = rule name in lowercase kebab-case.
  36 rows. These are the ONLY homes of Constitution rules.
- `scripts/check-skill-references-drift.sh`: the link gate. Every relative Markdown link must
  resolve (file + anchor); reference-style definitions are rejected; a `references/foo.md`
  file must be linked by its SKILL.md.

## The rule you apply

Two homes, decided by one question: does the requirement apply everywhere, or only inside
this skill's area?

- A **Constitution rule** (one of the 36 rows) has its home in `AGENTS.md`. Anywhere a skill
  or reference states that requirement again, replace the restated sentence with a link whose
  text is the rule's name: `[No Hard Waits](../../../AGENTS.md#rule-no-hard-waits)` from a
  SKILL.md, `../../../../AGENTS.md#…` from a `references/*.md`.
- A **skill-local rule** (detail only this area needs, not in any row) has its home in the
  skill's `## Critical` block. It stays as written.
- A line that mixes both keeps the local detail after the link:
  `- [State Cleanup](../../../AGENTS.md#rule-state-cleanup): the hook also succeeds after a failed test.`
- Several Constitution links with no local detail may share one bullet:
  `- [Imports](…#rule-imports), [No Tags on Describe](…#rule-no-tags-on-describe).`
- A **code example** that merely complies with a rule is not a restatement. Keep it. A
  CORRECT / WRONG pair whose only purpose is to show a Constitution rule may stay if the
  skill-shape caps hold; prefer keeping it when it carries area-specific detail.
- **Procedure steps and references** that restate a row: same treatment, link to the row.
  A step that says "take values from a factory per `data-strategy`" is a cross-skill
  pointer, not a restatement; leave it.
- **Never replace explanatory prose, a table row, or an example with a link to the skill's
  own Critical block or another heading.** References exist to hold detail; a reader who
  follows `[Components](../SKILL.md#critical)` finds a one-line rule, not the explanation
  that was deleted. Only sentences that restate a Constitution row become links.
- **Rule wording never changes.** No row is edited. No skill-local sentence is reworded
  beyond what removing the Constitution copy requires.

## Where the skill copy differs from the row (restatement-census.md section 4)

**The test:** a skill sentence contradicts its row ONLY if following the sentence would
violate the row. If following it is compatible with the row, because it adds, specifies, or
carves out something the row is silent on, it is skill-local and STAYS after the link.
"The row does not mention this" is never a contradiction.

- Compatible (stays): "every enum declaration carries a JSDoc line" (the JSDoc on Actions
  row is about page-object actions; enums are a different file kind); "an HTTP status in an
  assertion stays an inline literal" (a carve-out the No Magic Numbers row is silent on);
  "a 204 with no body asserts `expect(body).toBeNull()`" (there is no body to parse);
  "`z.looseObject()` only where the contract allows unknown keys" (the row says API schemas
  use `z.strictObject()`; the sentence restricts an alternative to contract-allowed cases);
  "the hook also succeeds after a failed test"; per-field loop details; classification tables.
- Contradiction (row wins): "URLs from `enums/*` / `config/*`" when the row names only
  `process.env` and `enums/`; "app unreachable: proceed with `// FIXME`" when the row says
  "cannot run means stop and tell the human" for the same situation; a SHOULD row restated
  as MUST ("tests must be independent" keeps its detail but loses the "must").
- On a contradiction: remove the contradicting words, link the row, and record it in the
  commit's conversion notes with file, line, both quoted sentences, and what was done.
- Expect few contradictions per skill group (zero to three). Twenty is a sign the test is
  being misread.
- Unsure which it is: keep the sentence as a skill-local line after the link and record it
  as a question.

## Other links

- `references/foo.md` mentioned in prose inside SKILL.md: make it a link,
  `[references/foo.md](references/foo.md)` or with a short label. Same for a reference
  naming a sibling reference.
- Mentions of another skill by name ("the `api-testing` skill", "`api-testing` step 5",
  "per `data-strategy`") stay prose. `check-skill-crossrefs.sh` and
  `check-heading-pointers.sh` cover those.
- A path to a rule-tree file (`AGENTS.md`, `CLAUDE.md`, a `SKILL.md`, a references file)
  named as a backticked path: make it a link.
- Paths to code (`fixtures/pom/test-options.ts`, `enums/{area}/*`) are not rule-tree files;
  leave them as backticked paths.
