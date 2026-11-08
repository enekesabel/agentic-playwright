# API schema templates

Prompt templates for Zod response schemas. `api-testing` owns contract sourcing, `type-safety` the Zod shape. Resolve `{area}` with `ls fixtures/api/schemas/` first.

## Create a schema from the documentation (default)

```
Create a Zod schema for the [STATUS] response of [ENDPOINT] from the OpenAPI document at [LOCATION].

Location fixtures/api/schemas/{area}/[name]Schema.ts (run `ls fixtures/api/schemas/` first); pattern file fixtures/api/schemas/app/userSchema.ts. Follow [Explore Before Generate](../../../../../AGENTS.md#rule-explore-before-generate): mirror the documented contract exactly (field types, required and optional, nullability, nested shapes, the envelope) per the type-safety skill; export the schema and its inferred type.
```

## Create a schema without documentation (fallback)

Follow [Explore Before Generate](../../../../../AGENTS.md#rule-explore-before-generate).

```
Follow [Explore Before Generate](../../../../../AGENTS.md#rule-explore-before-generate) for [ENDPOINT] at [API_URL/endpoint]; record the response structure, field types, optional versus required fields, nested shapes and the error bodies.

Generate fixtures/api/schemas/{area}/[name]Schema.ts from the observations per the type-safety skill.
```

## Add fields to an existing schema

```
Add to [SCHEMA_NAME]:
- [field1]: [type and validation]
- [field2]: [type and validation]

Follow [Strict Schemas](../../../../../AGENTS.md#rule-strict-schemas) and keep the type export in sync, per the type-safety skill.
```
