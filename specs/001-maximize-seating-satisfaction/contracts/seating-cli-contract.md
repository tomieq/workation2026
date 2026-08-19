# Seating CLI Contract

## Command Contract

```bash
./run.sh <input.json> <output.json>
```

- `input.json`: path to scenario input.
- `output.json`: path where seating plan is written.
- Non-zero exit code indicates validation/feasibility/runtime failure.

## Input Contract (Domain-Level)

Input JSON must include:
- `tables[]` with 5 tables (`id`, `capacity`, optional metadata).
- `guests[]` with canonical unique `id` values and descriptions.

For this feature scope:
- Total guest count must equal 30.
- Total capacity must equal 30 (5x6 textual rule is authoritative).

## Output Contract (Schema-Level)

Output must satisfy `contract/output-schema.json`:

```json
{
  "tables": [
    {
      "tableId": "T1",
      "guests": ["bartek", "nina", "mama_ela", "babcia_ela", "id5", "id6"]
    }
  ]
}
```

Constraints from schema:
- Root object with required `tables`.
- Each table object requires `tableId` and `guests`.
- No additional properties.

## Output Contract (Business-Level)

In addition to schema validity:
- Exactly 5 tables in output.
- Exactly 6 guests per table.
- All input guests appear exactly once; no unknown IDs.
- Hard placement constraints from spec must be satisfied.
- Deterministic output for identical input.

## Error Contract

If no valid plan exists or input is invalid, the program must:
- Exit non-zero.
- Provide a clear reason (stderr) indicating violated precondition or infeasible rule set.
