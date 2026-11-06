# Data templates

Prompt templates for [Data Generation](../../../../../AGENTS.md#rule-data-generation) and static test data. `data-strategy` owns the tiers and the factory shape, `type-safety` the schema a factory parses against. Resolve `{area}` with `ls test-data/factories/` or `ls test-data/static/` first.

## Create a data factory

```
Create a factory for [DATA TYPE] at test-data/factories/{area}/[name].factory.ts (run `ls test-data/factories/` first).

Fields:
- [field1]: [faker method]
- [field2]: [faker method]

Validate the output with the matching schema from fixtures/api/schemas/{area}/ and accept overrides; pattern file test-data/factories/app/user.factory.ts. Follow the data-strategy skill.
```

## Add static test data

Pick the tier first per `data-strategy`; follow [Data Strategy](../../../../../AGENTS.md#rule-data-strategy).

```
Create static test data for [PURPOSE] at test-data/static/{area}/[name].ts (run `ls test-data/static/` first):
- cases: [description, value, expected outcome]

Follow [No JSON Static Data](../../../../../AGENTS.md#rule-no-json-static-data) and the data-strategy skill.
```
