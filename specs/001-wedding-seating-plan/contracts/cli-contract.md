# CLI Contract

## Invocation

```sh
./run.sh <input.json> <output.json>
```

`run.sh` builds or runs the `workation2026` SwiftPM executable and forwards exactly the two paths. The executable reads one input JSON document and writes one output JSON document.

## Input

The Scenario 2 format is represented by [input/scenario2.json](../../../input/scenario2.json). Before planning, the executable requires five distinct base tables (`T1` through `T5`) with capacity six, exactly 31 active guests with unique non-empty IDs, distinct Bartek and Nina guests, and this capacity authorization:

```json
"extraSeatPolicy": {
  "extraSeats": 1,
  "canBeAddedToAnyTable": true
}
```

The active roster excludes `donald_t` and `jaroslaw_k` and includes `kuba_g`, `michal_z`, and `michal_s`. `T1` must contain Bartek, Nina, and exactly two additional `work`-group guests.

Every one of the 31 guest `description` values and five table `notes` values participates in an internal catalogue audit. Each exact value is categorized or explicitly non-actionable. This catalogue changes only assignment selection; it does not add input requirements or output fields.

## Optional Agent Configuration

When all required variables are present, the executable may invoke SwiftAgent to propose additional soft, categorized policy candidates from descriptions and table notes. Proposals cannot modify hard constraints and are accepted only with known references and exact evidence. When configuration is absent, the built-in catalogue still completes the invocation deterministically.

| Variable | Required | Meaning |
|---|---:|---|
| `SWIFT_AGENT_PROVIDER` | yes | `openAI` or `ollama`. |
| `SWIFT_AGENT_MODEL_URL` | yes | Provider base URL. |
| `SWIFT_AGENT_MODEL` | yes | Model supplied to the agent session. |
| `SWIFT_AGENT_AUTH_TOKEN` | no | Bearer token for compatible OpenAI endpoints. |

The scenario never selects the provider, URL, model, or credentials. An unavailable or failed assistant is reported as a non-fatal diagnostic and the solver falls back to the built-in catalogue. Invalid input and output-writing failures remain fatal and do not alter an existing output file.

## Successful Output

The output must conform exactly to [contract/output-schema.json](../../../contract/output-schema.json):

```json
{
  "tables": [
    { "tableId": "T1", "guests": ["bartek", "nina", "...four or five IDs..."] }
  ]
}
```

No additional properties are emitted. Every input guest ID appears exactly once; four tables contain six IDs and one solver-selected table contains seven. `T1` contains Bartek, Nina, and exactly two other `work`-group guests. The selected seven-seat table maximizes the documented six-category soft objective; equal results use canonical lexical ordering. Policies, categories, evidence, explanations, and scores are never emitted.

## Exit Behavior

| Outcome | Exit | Standard output | Standard error | Destination |
|---|---:|---|---|---|
| Valid completed plan | 0 | Optional concise success line | Empty | Atomically replaced with schema-valid JSON |
| Invalid input | non-zero | Empty | Specific validation failure | Unchanged |
| Agent/provider unavailable | 0 | Optional concise success line | Non-fatal fallback diagnostic | Atomically replaced with schema-valid JSON |
| Output failure | non-zero | Empty | Clear path/write failure | Unchanged |