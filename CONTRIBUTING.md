# Contributing to Agentic Playwright

Thanks for your interest in improving Agentic Playwright!

## Before you start

This repository is unusual in one important way: **the AI rule trees are part of the product.** The Constitution (`CLAUDE.md`), the skills (`.claude/skills/`), and their mirrors for Cursor (`.cursor/`) and GitHub Copilot (`.github/`) define how AI coding agents behave inside a generated project. Changes to code and changes to rules usually travel together.

That means contributions are checked by more gates than a typical repo:

1. **ESLint + Prettier + `tsc --noEmit`** — standard code quality.
2. **Skill lint (`npm run check:skills`)** — the Skills Index matches the skill folders on disk, every `SKILL.md` frontmatter has a matching `name` and a `description`, and every relative link and `file#anchor` reference in the rule trees, root docs and gate scripts resolves.
3. **Mirror check (`npm run check:mirrors`)** — the Cursor (`.cursor/`) and Copilot (`.github/`) trees are generated from `CLAUDE.md` and `.claude/skills/`; the check fails if the committed mirrors differ from a fresh build.
4. **Version single-sourcing (`npm run check:version`)** — `VERSION`, `package.json`, and the latest `CHANGELOG.md` heading must agree.

Run everything locally before pushing:

```bash
npm ci
npx tsc --noEmit && npx eslint . && npx prettier --check .
npm run check:skills && npm run check:mirrors && npm run check:version
npx playwright test        # requires env/.env.dev — see README "Environment Variables"
```

## Ground rules for changes

- **Follow the Constitution.** The rules in `CLAUDE.md` apply to contributed test code too: fixtures over manual instantiation, web-first assertions, no hard waits, no `any`, `z.strictObject()` for API schemas, one tag per test.
- **Edit the canonical tree; the mirrors are generated.** Change `CLAUDE.md` or `.claude/skills/`, then run `npm run build:mirrors` to regenerate `.cursor/` and `.github/`. The pre-commit hook does this and stages the result whenever a canonical file is staged; CI rejects stale mirrors. Never edit the mirror files by hand.
- **Vendored skills are off-limits for direct edits.** `skill-creator` and `playwright-cli` are tracked in `skills-lock.json` and synced from upstream; local edits get overwritten. Open an issue instead.
- **New behavior needs an example.** A new pattern (fixture type, data tier, selector rule) should come with a small example file demonstrating it.

## Sign-off (DCO)

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). Every commit must be signed off:

```bash
git commit -s -m "your message"
```

The sign-off certifies you have the right to submit the contribution under the project's MIT license.

## Pull requests

1. Fork, branch from `main`, keep PRs focused on one change.
2. Fill in the PR template; explain the _why_, not just the _what_.
3. All CI checks must pass; a maintainer reviews after that.

## Questions / ideas

Open a [discussion or issue](https://github.com/idavidov13/agentic-playwright/issues) — issues are welcome for bugs, feature requests, and rule-quality reports (e.g. "my agent misread rule X").
