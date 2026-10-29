# API Testing — Troubleshooting

## `expect(Schema.parse(body)).toBeTruthy()` throws `ZodError`

**Cause:** The API response disagrees with the schema (extra field, missing field, wrong type, wrong nullability).
**Fix:**

- **If OpenAPI / Swagger documentation exists and the schema was built from it**, this is a contract violation — treat it as a bug. Follow Phase 7: keep the test as the spec says, wrap with `test.skip` + `// FIXME: <ticket-url>`, and report the discrepancy. Do not loosen the schema to make the error go away ([Explore Before Generate](../../../copilot-instructions.md#rule-explore-before-generate)).
- **If no documentation exists** (Phase 1 fallback path), re-inspect the real response and update the schema to match. Never relax to `z.any()` ([No `any`](../../../copilot-instructions.md#rule-no-any)).

## 401 or 403 returns `null` body and the schema throws

**Cause:** The scaffold's unauthorized/forbidden responses have no body.
**Fix:** Do not call `schema.parse()` — assert `expect(body).toBeNull()` instead.

## Actual status code differs from the OpenAPI spec

**Cause:** Backend bug or spec drift.
**Fix:** Follow Phase 7 — keep the test as the spec says, wrap with `test.skip`, add a `// FIXME: <ticket-url>` comment and `// eslint-disable-next-line playwright/no-skipped-test` directly above it. Never change the expected status to match the bug ([No Silent Coverage Drops](../../../copilot-instructions.md#rule-no-silent-coverage-drops)).

## Only an empty-body `400` test exists for a POST/PUT/PATCH

**Cause:** Coverage gap — see [No Empty-Body-Only 400](../../../copilot-instructions.md#rule-no-empty-body-only-400) (Phase 6).
**Fix:** Add two additional loops: per-field invalid types (spread-and-override) and per-field omission (destructure + rest).

## ESLint fails with `playwright/no-skipped-test` on an intentional `test.skip`

**Fix:** Add `// eslint-disable-next-line playwright/no-skipped-test` directly above the `test.skip(...)`, together with a `// FIXME: <ticket-url>` comment explaining why. Use the next-line form, not a file-level `/* eslint-disable */`, so any further skip in the file is still reported.

## A test fails or behaves unexpectedly during Phase 7 (verify) and I need to investigate

**Fix:** Stop iterating blindly. Read the `debugging` skill for the failure-mode taxonomy (TimeoutError, ZodError, strict-mode violation, etc.) and the right tool to use (UI Mode, Trace Viewer, Inspector). For a confirmed contract violation, route back here to Phase 7's `test.skip` + `// FIXME:` workflow.

## Helper fixture duplicates setup that only one spec file uses

**Cause:** See [Helper Fixture Promotion (3+ files)](../../api-testing.instructions.md#rule-helper-fixture-promotion-3plus).
**Fix:** Move the logic back to `beforeAll`/`afterAll` in the single spec file and call `apiRequest` directly (Phase 8 rule of thumb).

## Test hardcodes `https://...` or a raw token

**Fix:** ([Sources of Truth](../../../copilot-instructions.md#rule-sources-of-truth)) Replace with `process.env.API_URL`, `process.env.ACCESS_TOKEN` (or `ACCESS_TOKEN_ZERO` for zero-permission cases), and `ApiEndpoints.*` enum entries for paths.
