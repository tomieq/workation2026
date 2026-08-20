# Quickstart: Validate the Wedding Seating Plan - Scenario 2

## Prerequisites

- Swift 6.2 or later and network access for SwiftPM dependency resolution.
- A running OpenAI-compatible endpoint or Ollama instance is optional.
- Provider configuration enables the SwiftAgent policy-assistant pass as specified in [the CLI contract](contracts/cli-contract.md); the deterministic solver works without it.

For local Ollama, a representative setup is:

```sh
export SWIFT_AGENT_PROVIDER=ollama
export SWIFT_AGENT_MODEL_URL=http://localhost:11434
export SWIFT_AGENT_MODEL=<installed-model-name>
```

## Build and Unit Test

```sh
swift build
swift test
```

Expected outcome: the package resolves SwiftAgent, compiles the executable and tests, and all validation, policy, deterministic-planner, and CLI tests pass.

Policy tests must report complete catalogue coverage for 31 guest descriptions and five table notes, exact evidence equality, valid categories, explicit non-actionable entries, no duplicate evidence/category effects, and no narrative hard constraints.

## Generate a Plan

```sh
./run.sh input/scenario2.json output/scenario2-plan.json
```

Expected outcome: exit code `0`; the file matches the output contract, contains five sorted table entries with table sizes `[6,6,6,6,7]`, and has Bartek, Nina, and exactly two additional `work`-group guests at `T1`. See [the data model](data-model.md) for the complete invariants.

Review focused planner tests for all six categories. They must demonstrate team grouping, table-note location use, named relationship affinity/avoidance, soft `T1` preferences, energy/conversation balance, and disruption-risk dispersion while preserving every hard invariant.

## Verify Scenario 2 Structure

```sh
jq '[.tables[].guests | length] | sort' output/scenario2-plan.json
jq '[.tables[].guests[]] | length' output/scenario2-plan.json
```

Expected outcome: `[6,6,6,6,7]` and `31`. Verify that every ID from `input/scenario2.json` occurs once and that `T1` has Bartek, Nina, and exactly two other input guests whose group is `work`.

Validate the generated JSON against `contract/output-schema.json` and verify it contains no category, policy, evidence, explanation, or score properties.

## Verify Determinism

```sh
./run.sh input/scenario2.json output/first.json
./run.sh input/scenario2.json output/second.json
diff -u output/first.json output/second.json
```

Expected outcome: `diff` has no output. The deterministic solver remains the authority whether or not the optional SwiftAgent policy assistant is configured.

## Verify Failure Preservation

```sh
printf '{"tables":[]}' > output/existing.json
./run.sh /tmp/invalid-wedding-scenario.json output/existing.json
```

Expected outcome: non-zero exit with a clear error, and the content of `output/existing.json` is unchanged. Use malformed JSON, a duplicate guest ID, missing `T1`, an invalid `extraSeatPolicy`, or an invalid 31-guest roster as input-validation cases described in [the CLI contract](contracts/cli-contract.md).