---

description: "Scenario 2 implementation tasks for the Wedding Seating Plan"
---

# Tasks: Wedding Seating Plan - Scenario 2

**Input**: Design documents from `/specs/001-wedding-seating-plan/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/cli-contract.md](contracts/cli-contract.md), [quickstart.md](quickstart.md)

**Tests**: Swift Testing and CLI integration coverage are required by the specification, constitution, and implementation plan. Write each listed test before the task it verifies and confirm it fails first.

**Organization**: Tasks are grouped by user story so each increment is independently implementable and testable.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the canonical Scenario 2 fixture and a clean test baseline for the existing SwiftPM application.

- [X] T001 Verify the 31-active-guest Scenario 2 roster and one-chair authorization in `input/scenario2.json`
- [X] T002 Update Scenario 2 invocation and structural verification commands in `specs/001-wedding-seating-plan/quickstart.md`
- [X] T003 Run the pre-change Swift test baseline before updating Scenario 2 coverage in `Tests/workation2026Tests/ValidationTests.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the shared Scenario 2 data and validation abstractions required by every user story.

**Critical**: Complete this phase before starting user-story implementation.

- [X] T004 Extend `SeatingScenario` with Codable `ExtraSeatPolicy` in `Sources/workation2026/Models.swift`
- [X] T005 Add Scenario 2 base-capacity, active-roster, extra-seat authorization, and exact `T1` colleague validation errors in `Sources/workation2026/Validation.swift`
- [X] T006 Derive final table capacities from the selected seven-seat table in `Sources/workation2026/Validation.swift`
- [X] T007 [P] Add Scenario 2 model and validation fixtures in `Tests/workation2026Tests/ValidationTests.swift`
- [X] T008 [P] Add decoding coverage for `extraSeatPolicy` in `Tests/workation2026Tests/CLIRunTests.swift`

**Checkpoint**: The application can decode the Scenario 2 fixture and shared validators can express its base-room, roster, and final-capacity invariants.

---

## Phase 3: User Story 1 - Generate a Valid Complete Plan (Priority: P1) MVP

**Goal**: Generate a deterministic, schema-valid plan for `input/scenario2.json` with 31 active guests, four six-guest tables, one solver-selected seven-guest table, and the mandatory `T1` composition.

**Independent Test**: Run `./run.sh input/scenario2.json output/scenario2-plan.json`; verify table sizes `[6,6,6,6,7]`, all 31 IDs exactly once, Bartek and Nina at `T1`, exactly two additional `work` guests at `T1`, and byte-identical repeated output.

### Tests for User Story 1

- [X] T009 [P] [US1] Add plan-validator tests for one seven-guest table, complete 31-guest coverage, and exact `T1` colleague composition in `Tests/workation2026Tests/ValidationTests.swift`
- [X] T010 [P] [US1] Add deterministic planner tests for selected extra-seat capacity, canonical ordering, and repeated Scenario 2 output in `Tests/workation2026Tests/DeterministicPlannerTests.swift`
- [X] T011 [P] [US1] Add end-to-end `input/scenario2.json` schema, occupancy, and repeatability tests in `Tests/workation2026Tests/CLIRunTests.swift`

### Implementation for User Story 1

- [X] T012 [US1] Enumerate each eligible seventh-chair table and legal non-Bartek `T1` work-colleague pair in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T013 [US1] Construct deterministic complete candidates with four six-seat capacities, one seven-seat capacity, and hard `T1` composition in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T014 [US1] Compare valid candidates by objective then canonical table/guest vector in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T015 [US1] Wire `ExtraSeatPolicy` validation through decode, planning, candidate validation, and atomic publication in `Sources/workation2026/App.swift`

**Checkpoint**: The updated executable independently meets every structural Scenario 2 invariant and is deterministic.

---

## Phase 4: User Story 2 - Produce a Considered Social Arrangement (Priority: P2)

**Goal**: Optimize the valid Scenario 2 plan using only active, evidence-backed policies, including newcomer/Leszek soft avoidance and the four-work-guest cluster threshold.

**Independent Test**: Review the `input/scenario2.json` result and targeted fixtures to verify retired policies are absent, named companion/separation behavior remains hard, the newcomer avoidances are soft, no Bald Club policy exists, and equal outcomes remain canonical.

### Tests for User Story 2

- [X] T016 [P] [US2] Add Scenario 2 catalogue tests for retired-guest removal, newcomer avoidance, work-cluster threshold, and no Bald Club policy in `Tests/workation2026Tests/PolicyTests.swift`
- [X] T017 [P] [US2] Add planner tests for Leszek/newcomer soft avoidance, four-work-guest penalty, and higher-priority constraint precedence in `Tests/workation2026Tests/DeterministicPlannerTests.swift`
- [X] T018 [P] [US2] Add Scenario 2 policy integration assertions in `Tests/workation2026Tests/CLIRunTests.swift`

### Implementation for User Story 2

- [X] T019 [US2] Replace Donald/Jaroslaw catalogue entries with active Scenario 2 policies in `Sources/workation2026/SeatingPolicy.swift`
- [X] T020 [US2] Encode Leszek--Jakub G. and Leszek--Michal Z. soft avoidance plus the four-work-guest newcomer penalty in `Sources/workation2026/SeatingPolicy.swift`
- [X] T021 [US2] Score Scenario 2 avoidance and work-cluster policies while preserving hard-policy precedence in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T022 [US2] Preserve strict validation of optional assistant policies against the active Scenario 2 roster in `Sources/workation2026/SeatingPolicy.swift`

**Checkpoint**: The solver's social choices are traceable to active public evidence and do not weaken the P1 structural rules.

---

## Phase 5: User Story 3 - Receive Clear Feedback for Invalid Scenarios (Priority: P3)

**Goal**: Reject invalid Scenario 2 inputs clearly while preserving an existing output file.

**Independent Test**: Supply malformed Scenario 2 fixtures for missing or invalid `extraSeatPolicy`, wrong guest count, non-six base capacity, retired/omitted roster members, insufficient `T1` colleagues, and invalid output occupancy; verify specific failures and unchanged destination content.

### Tests for User Story 3

- [X] T023 [P] [US3] Add validation tests for invalid extra-seat authorization, base capacity, count, active roster, and `T1` colleague availability in `Tests/workation2026Tests/ValidationTests.swift`
- [X] T024 [P] [US3] Add CLI failure and destination-preservation tests for invalid Scenario 2 inputs in `Tests/workation2026Tests/CLIRunTests.swift`

### Implementation for User Story 3

- [X] T025 [US3] Return precise Scenario 2 validation errors for capacity authorization, roster, and `T1` composition in `Sources/workation2026/Validation.swift`
- [X] T026 [US3] Surface Scenario 2 decode, validation, planning, and publication failures as non-zero CLI errors in `Sources/workation2026/App.swift`

**Checkpoint**: Invalid Scenario 2 invocations fail clearly without publishing or replacing a misleading plan.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Confirm the updated program, artifacts, and contract meet the Scenario 2 delivery standard.

- [X] T027 [P] Update Scenario 2 behavior, command examples, and optional-agent fallback notes in `README.md`
- [X] T028 Update the verified Scenario 2 policy outcome and any unavoidable trade-offs in `specs/001-wedding-seating-plan/research.md`
- [X] T029 Run the documented Scenario 2 build, unit-test, structural, determinism, and failure-preservation checks from `specs/001-wedding-seating-plan/quickstart.md`
- [X] T030 Validate `output/scenario2-plan.json` against `contract/output-schema.json` after the quickstart run
- [X] T031 Measure that `./run.sh input/scenario2.json output/scenario2-plan.json` completes within 10 seconds in `Tests/workation2026Tests/CLIRunTests.swift`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 and blocks all user stories.
- **US1 (Phase 3)**: Depends on T004-T008 and is the MVP.
- **US2 (Phase 4)**: Depends on the Scenario 2 candidate planner from US1.
- **US3 (Phase 5)**: Depends on shared Scenario 2 validation from Phase 2 and can be developed in parallel with US2 after US1 contracts stabilize.
- **Polish (Phase 6)**: Depends on all desired user-story phases.

### User Story Dependency Graph

```text
Setup -> Foundational -> US1 (MVP) -> US2 -> Polish
                                \-> US3 -----> Polish
```

### Parallel Opportunities

- T007 and T008 can proceed in parallel after T004-T006 define shared APIs.
- T009, T010, and T011 can proceed in parallel after foundational validation contracts stabilize.
- T016, T017, and T018 can proceed in parallel after US1 produces valid Scenario 2 candidates.
- T023 and T024 can proceed in parallel after foundational validation contracts stabilize.
- T027 and T028 can proceed in parallel once the final policy behavior is settled.

### Parallel Example: User Story 1

```text
Task: "Add plan-validator coverage in Tests/workation2026Tests/ValidationTests.swift"
Task: "Add planner coverage in Tests/workation2026Tests/DeterministicPlannerTests.swift"
Task: "Add CLI integration coverage in Tests/workation2026Tests/CLIRunTests.swift"
```

### Parallel Example: User Story 2

```text
Task: "Add policy catalogue coverage in Tests/workation2026Tests/PolicyTests.swift"
Task: "Add policy scoring coverage in Tests/workation2026Tests/DeterministicPlannerTests.swift"
Task: "Add end-to-end policy assertions in Tests/workation2026Tests/CLIRunTests.swift"
```

## Implementation Strategy

### MVP First

1. Complete Phases 1 and 2.
2. Complete US1 through T015.
3. Run the US1 independent test using `input/scenario2.json`.
4. Stop for review only after the structural Scenario 2 plan is valid, deterministic, and schema-shaped.

### Incremental Delivery

1. Add US2 policies and scoring while preserving the US1 contract.
2. Add US3 failure coverage and output-preservation behavior.
3. Complete documentation, schema validation, performance verification, and the full quickstart sequence.

## Format Validation

Every task uses the required checklist format: checkbox, sequential task ID, optional `[P]` marker, user-story label for story tasks, and an exact repository path.