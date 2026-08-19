# Data Model: Wedding Seating Plan

## SeatingScenario

| Field | Type | Rules |
|---|---|---|
| `scenario` | `String` | Preserved as input metadata; not emitted in the plan. |
| `title` | `String` | Preserved as input metadata; not emitted in the plan. |
| `extraSeatPolicy` | `ExtraSeatPolicy` | Scenario 2 authorization for exactly one chair, addable to any base table. |
| `tables` | `[VenueTable]` | Exactly five entries with distinct IDs `T1` through `T5`; each base capacity is six. |
| `guests` | `[Guest]` | Exactly 31 active entries with unique, non-empty IDs. |

## ExtraSeatPolicy

| Field | Type | Rules |
|---|---|---|
| `extraSeats` | `Int` | Must equal one for Scenario 2. |
| `canBeAddedToAnyTable` | `Bool` | Must be `true`; the solver evaluates every table as the expanded table. |

## VenueTable

| Field | Type | Rules |
|---|---|---|
| `id` | `String` | Unique table identifier; `T1` must exist. |
| `name` | `String` | Human-readable input metadata. |
| `capacity` | `Int` | Base capacity; must equal six. The final plan may add the authorized chair to exactly one table. |
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
| `kind` | enum | `mandatoryTable`, `separate`, `companion`, `locationPreference`, `avoidancePreference`, `affinityPreference`, or `groupPreference`. |
| `guestIDs` | ordered set of `String` | Subjects of the rule. |
| `tableID` | `String?` | Required for a mandatory table or location preference. |
| `priority` | enum | `structural`, `mandatory`, `separation`, `companion`, `location`, `avoidance`, `affinity`, `group`. |
| `evidence` | `String` | Brief/scenario phrase and source used for audit tests; never invented organizer intent. |

Policies are evaluated in priority order. Structural and mandatory rules must hold. Explicit named separation and companion rules are hard constraints. Location, evidence-backed named-pair avoidance, food/drink affinity, and group rules contribute only to the ordered preference score. `PolicyAssistant` candidates must additionally contain only known IDs, an allowed `kind`/`priority` combination, and an exact evidence span; candidates failing any check are discarded.

The Scenario 2 built-in catalogue adds soft avoidance for `leszek` with `kuba_g` and `michal_z`, plus a work-cluster penalty when either newcomer shares a table with four or more work-group guests. It does not derive a policy from Michał S.'s Bald Club history. The mandatory `T1` composition is Bartek, Nina, and exactly two other `work` guests.

## SeatingPlan

| Field | Type | Rules |
|---|---|---|
| `tables` | `[SeatedTable]` | Exactly five output entries, sorted by `tableId`. No extra output properties. |

## SeatedTable

| Field | Type | Rules |
|---|---|---|
| `tableId` | `String` | An ID from `SeatingScenario.tables`. |
| `guests` | `[String]` | Six distinct input guest IDs at four tables and seven at exactly one selected table; each list is sorted lexicographically for canonical output. |

## State Transitions

`received` -> `decoded` -> `validated` -> `policiesExtracted` -> `candidatePlanned` -> `candidateValidated` -> `encodedToTemporaryFile` -> `published`.

Any failure transitions to `failed`; the destination is unchanged because publication is only possible from `encodedToTemporaryFile`.