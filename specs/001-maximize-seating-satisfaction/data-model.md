# Data Model — Maximize Seating Satisfaction

## Core Entities

## 1) Guest (Entity)
- **Fields**:
  - `id: String` (canonical, unique, required)
  - `name: String`
  - `group: String` (`family|friends|work|politics|bride`)
  - `description: String` (source narrative text)
- **Validation**:
  - `id` must be unique across input.
  - `id` is the only authoritative identity for output guest lists.

## 2) Table (Entity)
- **Fields**:
  - `id: String` (`T1..T5` for current scenario)
  - `name: String`
  - `capacity: Int`
  - `notes: String`
- **Validation**:
  - Exactly 5 tables, each capacity exactly 6 (for this feature scope).

## 3) ScenarioInput (Aggregate Root)
- **Fields**:
  - `scenario: String`
  - `tables: List<Table>`
  - `guests: List<Guest>`
- **Invariants**:
  - Total seats = total guests = 30.
  - Required guests (`bartek`, `nina`, `mama_ela`, `babcia_ela`) exist.

## 4) SeatingAssignment (Entity)
- **Fields**:
  - `tableId: String`
  - `guestIds: List<String>`
- **Validation**:
  - `guestIds.size == 6`
  - guest IDs are canonical input IDs only.

## 5) SeatingPlan (Aggregate Root, Output)
- **Fields**:
  - `tables: List<SeatingAssignment>`
- **Invariants**:
  - Exactly 5 table assignments.
  - Every guest appears exactly once globally.
  - Hard constraints are satisfied.

## 6) NarrativeSignal (Value Object)
- **Types**:
  - `PairConflict`
  - `PairAffinity`
  - `LocationAffinity`
  - `BehaviorSignal`
  - `NeutralSignal`
- **Purpose**:
  - Deterministic, traceable interpretation from guest descriptions used by scorer.

## 7) ScoreBreakdown (Value Object)
- **Fields**:
  - `ninaScore: Int`
  - `bartekScore: Int`
  - `weightedTotal: Int` (Nina weight > Bartek weight)
  - `components: List<ScoreComponent>`
- **Purpose**:
  - Explain optimization decisions and support deterministic tie-breaking review.

## Relationships

- `ScenarioInput` **contains** many `Guest` and many `Table`.
- `SeatingPlan` **contains** 5 `SeatingAssignment`.
- `SeatingAssignment.guestIds` **references** `Guest.id`.
- `NarrativeSignal` and pair rules **reference** one or more `Guest.id`.
- `ScoreBreakdown` is computed from `SeatingPlan + NarrativeSignal + RuleSet`.

## Scenario-Specific Rule Sets (Domain Constraints)

- Mandatory T1 set: `bartek`, `nina`, `mama_ela`, `babcia_ela`.
- Political constraints: no politician at T1; `slawek_m` separate; `donald_t` + `jaroslaw_k` shared non-T1 table.
- Corporate-heavy cohort: exactly two full tables; each 5 corporate + 1 catalyst; catalysts are `swiadek_kuba` and `kacper` on different cohort tables.
- Pair separation: `maciek` and `jakub` must be at different tables.
- T4 localization overflow: deterministic ranking and canonical ID tie-break.

## State Transitions

1. `RawInputLoaded`
2. `InputValidated`
3. `HardConstraintsPrepared`
4. `CandidatePlanGenerated`
5. `CandidatePlanScored`
6. `BestPlanSelected`
7. `OutputValidated`
8. `PlanSerialized`

Failure transitions:
- Any invalid structural/business invariant -> `Infeasible` with explicit error reason.
