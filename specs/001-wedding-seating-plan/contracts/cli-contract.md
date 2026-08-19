# CLI Contract

## Invocation

```sh
./run.sh <input.json> <output.json>
```

`run.sh` builds or runs the `workation2026` SwiftPM executable and forwards exactly the two paths. The executable reads one input JSON document and writes one output JSON document.

## Input

The scenario format is represented by [input/scenario1.json](../../../input/scenario1.json). Before planning, the executable requires five distinct tables (`T1` through `T5`), capacity six for each table, exactly 30 guests, unique non-empty guest IDs, and distinct Bartek and Nina guests.

## Optional Agent Configuration

When all required variables are present, the executable invokes SwiftAgent to propose additional policy candidates from descriptions and table notes. When they are absent, it uses the built-in public-evidence catalogue and still completes a valid invocation deterministically.

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
    { "tableId": "T1", "guests": ["bartek", "nina", "...four IDs..."] }
  ]
}
```

No additional properties are emitted. Every input guest ID appears exactly once; each input table appears once with six IDs. `T1` contains Bartek and Nina.

## Exit Behavior

| Outcome | Exit | Standard output | Standard error | Destination |
|---|---:|---|---|---|
| Valid completed plan | 0 | Optional concise success line | Empty | Atomically replaced with schema-valid JSON |
| Invalid input | non-zero | Empty | Specific validation failure | Unchanged |
| Agent/provider unavailable | 0 | Optional concise success line | Non-fatal fallback diagnostic | Atomically replaced with schema-valid JSON |
| Output failure | non-zero | Empty | Clear path/write failure | Unchanged |