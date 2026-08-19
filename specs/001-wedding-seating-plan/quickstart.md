# Quickstart: Validate the Wedding Seating Plan

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

## Generate a Plan

```sh
./run.sh input/scenario1.json output/seating-plan.json
```

Expected outcome: exit code `0`; the file matches the output contract, contains five sorted table entries of six sorted guest IDs, and has Bartek and Nina at `T1`. See [the data model](data-model.md) for the complete invariants.

## Verify Determinism

```sh
./run.sh input/scenario1.json output/first.json
./run.sh input/scenario1.json output/second.json
diff -u output/first.json output/second.json
```

Expected outcome: `diff` has no output. The deterministic solver remains the authority whether or not the optional SwiftAgent policy assistant is configured.

## Verify Failure Preservation

```sh
printf '{"tables":[]}' > output/existing.json
./run.sh /tmp/invalid-wedding-scenario.json output/existing.json
```

Expected outcome: non-zero exit with a clear error, and the content of `output/existing.json` is unchanged. Use malformed JSON, a duplicate guest ID, missing `T1`, or mismatched capacity as input-validation cases described in [the CLI contract](contracts/cli-contract.md).