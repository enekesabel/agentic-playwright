# Kick-off prompt

Paste this, replacing `<branch>`:

> Review PR for branch `<branch>` against the base branch (auto-resolve it; main or master): fetch it, switch to it, then check all diffs against this repo's .cursor/rules/rules.mdc and the skills that apply to the changed files (route by path, as in [Phase 3 of the skill](../SKILL.md#phase-3--route-to-applicable-skills)). Verify with eslint + prettier + tsc on the changed files and attempt the affected tests. Report tiered findings (must-fix / should-fix / minor), what's good, a verdict, and a confidence score. Don't modify anything — just report. After the report, ask me if I want any findings implemented.

Shorter form (the skill fills in the rest):

> PR review on branch `<branch>` against the base branch.
