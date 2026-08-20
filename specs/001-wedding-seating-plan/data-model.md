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
| `kind` | enum | A soft effect such as relationship affinity/avoidance, location preference, group affinity, balance effect, or risk avoidance. |
| `guestIDs` | ordered set of `String` | Subjects of the rule. |
| `tableID` | `String?` | Required for a mandatory table or location preference. |
| `category` | `CompetitionCategory` | Exactly one of the six competition categories for this effect. |
| `evidenceSourceID` | `String` | Stable table or guest ID that owns the exact evidence. |
| `evidence` | `String` | Exact input `notes` or `description` value. |
| `strength` | `Int` | Documented positive magnitude within the policy's category; sign is determined by effect kind. |

All `SeatingPolicy` values are soft. Capacity, complete unique assignment, couple placement, and exact `T1` work composition are represented by scenario and plan validation rather than narrative policies. Assistant candidates additionally require known IDs, an allowed soft kind/category combination, a known source ID, and exact evidence; invalid or duplicate candidates are discarded.

## CompetitionCategory

`Grupowanie zespołu`, `Lokalizacja`, `Relacje`, `T1 Production`, `Balans`, and `Ryzyko`. The declaration order is used only after equal total policy value; it does not make an earlier category a hard rule.

## EvidenceCatalogueEntry

| Field | Type | Rules |
|---|---|---|
| `source` | `EvidenceSource` | `.table(id)` or `.guest(id)`; unique across the catalogue. |
| `evidence` | `String` | Must exactly equal the source's input `notes` or `description`. |
| `categories` | ordered set of `CompetitionCategory` | At least one for actionable entries; no duplicates. |
| `policies` | `[SeatingPolicy]` | Soft effects supported by this evidence; at most one equivalent effect per category. |
| `nonActionableReason` | `String?` | Required when no policies exist; explains why no defensible seating implication is derived. |

The built-in Scenario 2 catalogue contains exactly 36 entries: five tables and 31 guests. An entry may mix actionable and explicitly ignored details, but every generated policy retains the complete exact source evidence.

## CategoryScore and PlanObjective

`CategoryScore` stores one integer total for each `CompetitionCategory` plus the identities already counted. `PlanObjective` stores the overall total, the six category totals in published order, and the canonical table/guest vector. Candidate comparison uses overall total, then category totals, then canonical vector. Counted identities prevent one evidence/effect from being applied twice within one category.

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