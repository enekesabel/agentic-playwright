# Conversion notes: API and data (api-testing, type-safety, data-strategy, enums, config, helpers)

## Row wins

1. `.claude/skills/enums/SKILL.md:24`
    - Skill: "A UI message value is captured from the live app with `playwright-cli`, never guessed; app unreachable: add it with `// FIXME: unverified` and say so in the report."
    - Row (Explore Before Generate): "UI: you explore with `playwright-cli` (read that skill first) before you write any `pages/**` file, UI spec or selector; cannot run means stop and tell the human."
    - Action: kept the capture-live half after `[Explore Before Generate](../../../AGENTS.md#rule-explore-before-generate)`; removed "app unreachable: add it with `// FIXME: unverified` and say so in the report", because proceeding with an unverified value is what the row forbids.

Count: 1.

## Questions

1. `.claude/skills/enums/SKILL.md:21`, SHOULD raised to MUST? Skill said "Any app-defined string used in more than one place (endpoint path, UI message, role, route, storage-state path) lives in an enum and is imported". Enums for Strings is a SHOULD row; Sources of Truth (MUST) covers paths, routes, messages, storage-state paths but not roles. Following the sentence violates neither row, so not recorded as a row win; the restated "lives in an enum and is imported" is replaced by the two links, and the list of value kinds plus "`ApiEndpoints` members are the only source of endpoint paths" stay. Open: is a repeated role name a MUST (enum) or a SHOULD? **Update (revised in the final commit):** the replacement had silently dropped the imperative, so the v2.0.1 sentence is back after the two links, roles included: "any app-defined string used in more than one place (endpoint path, UI message, role, route, storage-state path) lives in an enum and is imported". The question stays open for the maintainer; the skill now keeps its v2.0.1 force until it is answered.
2. `.claude/skills/data-strategy/SKILL.md:33`, "suite tuning in `playwright.config.ts`" vs No Magic Numbers "constants in `config/` or `enums/`". `playwright.config.ts` is not under `config/`. Kept as skill-local after the link (Playwright's own tuning has to live in its config file); flagging in case the row should name it.
3. `.claude/skills/data-strategy/SKILL.md:30`, "Never Faker-generate an app-defined string (error message, label, heading, route)" vs No Hardcoded Test Content "names, labels and text come from factories". Compatible reading: the row's labels are test content the test creates, the skill's are app-defined UI labels. Kept per the task brief; noted only because the word "label" points both ways.

## Manifest lines removed

- `z.strictObject|type-safety|Strict Zod schemas`
- ``NEVER** use `any`|type-safety|No any``
- `SchemaName.parse(body)).toBeTruthy|api-testing|Response validation pattern`
- `test.skip|api-testing|Behaviour-mismatch protocol`
- `per-field omission|api-testing|No empty-body-only 400`
- `more than one API call|api-testing|API calls wrapped in test.step`
- `access tokens, emails, passwords|api-testing|No secrets`
- ``as const` literal values|data-strategy|Static data is TS literals``
- `Faker factory|data-strategy|Happy-path data via Faker`
- `hardcode test content strings|data-strategy|No hardcoded test content`
- `magic numbers|data-strategy|No magic numbers`
- `process.env|config|Env-driven URLs/credentials`
- `ApiEndpoints|enums|Endpoint paths in enums`

Kept: `fuzz path parameters|api-testing|Path-parameter fuzzing` (skill-local, sentence unchanged).

## Cap pressure

Critical words / non-blank lines, before -> after (cap 250 words / 25 lines):

| Skill         | Before   | After    |
| ------------- | -------- | -------- |
| api-testing   | 250 / 21 | 216 / 21 |
| type-safety   | 238 / 21 | 239 / 21 |
| data-strategy | 218 / 20 | 202 / 20 |
| enums         | 156 / 14 | 136 / 14 |
| config        | 142 / 12 | 140 / 12 |
| helpers       | 164 / 14 | 153 / 14 |

SKILL.md words before -> after: api-testing 530 -> 489, type-safety 422 -> 414, data-strategy 479 -> 458, enums 390 -> 370, config 328 -> 324, helpers 331 -> 320. No cap tripped. type-safety gained one word (the No `any` link text is three tokens).
