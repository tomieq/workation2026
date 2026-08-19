# Data Model: Wedding Seating Plan

## SeatingScenario

| Field | Type | Rules |
|---|---|---|
| `scenario` | `String` | Preserved as input metadata; not emitted in the plan. |
| `title` | `String` | Preserved as input metadata; not emitted in the plan. |
| `tables` | `[VenueTable]` | Exactly five entries with distinct IDs `T1` through `T5`; each capacity is six. |
| `guests` | `[Guest]` | Exactly 30 entries with unique, non-empty IDs. |

## VenueTable

| Field | Type | Rules |
|---|---|---|
| `id` | `String` | Unique table identifier; `T1` must exist. |
| `name` | `String` | Human-readable input metadata. |
| `capacity` | `Int` | Must equal six. |
| `notes` | `String` | Optional location evidence; `T2` is dance-floor and `T4` is exit/terrace evidence. |

## Guest

| Field | Type | Rules |
|---|---|---|
| `id` | `String` | Unique, non-empty assignment identity and output value. |
| `name` | `String` | Used only to identify Bartek and Nina if required by input representation and to match explicit narrative references. |
| `group` | `String?` | Missing or blank means no group preference; otherwise lowest-priority soft evidence. |
| `description` | `String?` | Missing or blank means no inferred narrative policy. |

## SeatingPolicy

| Field | Type | Meaning |
|---|---|---|
| `kind` | enum | `mandatoryTable`, `separate`, `companion`, `locationPreference`, `affinityPreference`, or `groupPreference`. |
| `guestIDs` | ordered set of `String` | Subjects of the rule. |
| `tableID` | `String?` | Required for a mandatory table or location preference. |
| `priority` | enum | `structural`, `mandatory`, `separation`, `companion`, `location`, `affinity`, `group`. |
| `evidence` | `String` | Brief/scenario phrase and source used for audit tests; never invented organizer intent. |

Policies are evaluated in priority order. Structural and mandatory rules must hold. Explicit named separation and companion rules are hard constraints. Location, evidence-backed food/drink affinity, and group rules contribute only to the ordered preference score. `PolicyAssistant` candidates must additionally contain only known IDs, an allowed `kind`/`priority` combination, and an exact evidence span; candidates failing any check are discarded.

## SeatingPlan

| Field | Type | Rules |
|---|---|---|
| `tables` | `[SeatedTable]` | Exactly five output entries, sorted by `tableId`. No extra output properties. |

## SeatedTable

| Field | Type | Rules |
|---|---|---|
| `tableId` | `String` | An ID from `SeatingScenario.tables`. |
| `guests` | `[String]` | Exactly six distinct input guest IDs, sorted lexicographically for canonical output. |

## State Transitions

`received` -> `decoded` -> `validated` -> `policiesExtracted` -> `candidatePlanned` -> `candidateValidated` -> `encodedToTemporaryFile` -> `published`.

Any failure transitions to `failed`; the destination is unchanged because publication is only possible from `encodedToTemporaryFile`.