---

description: "Implementation tasks for the Wedding Seating Plan feature"
---

# Tasks: Wedding Seating Plan

**Input**: Design documents from `/specs/001-wedding-seating-plan/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/cli-contract.md](contracts/cli-contract.md), [quickstart.md](quickstart.md)

**Tests**: Swift Testing and shell-level integration checks are required by the feature specification and implementation plan.

**Organization**: Tasks are grouped by user story so each increment can be implemented and validated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the SwiftPM executable and Swift Testing targets required by every story.

- [X] T001 Update the Swift 6.2 executable target and SwiftAgent package dependency in `Package.swift`
- [X] T002 [P] Create the Swift Testing target directory and test target declaration for `Tests/workation2026Tests/`
- [X] T003 Update the executable launcher to forward exactly two input/output paths in `run.sh`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish shared Codable types, scenario validation, output validation, and failure-safe file publication before planning work begins.

**Critical**: Complete this phase before implementing any user story.

- [X] T004 Create Codable scenario, table, guest, policy, and output plan types in `Sources/workation2026/Models.swift`
- [X] T005 Implement fixed-venue input validation and candidate-plan invariant validation in `Sources/workation2026/Validation.swift`
- [X] T006 Implement temporary-file encoding, atomic output replacement, and destination-preservation cleanup in `Sources/workation2026/Validation.swift`
- [X] T007 [P] Add structural, mandatory-placement, and atomic-publication unit coverage in `Tests/workation2026Tests/ValidationTests.swift`
- [X] T008 Create the CLI argument parsing, error-to-stderr boundary, and dependency wiring in `Sources/workation2026/App.swift`

**Checkpoint**: The executable can decode a scenario, reject invalid shared invariants, and publish only a fully validated plan.

---

## Phase 3: User Story 1 - Generate a Valid Complete Plan (Priority: P1) MVP

**Goal**: Generate a complete, schema-valid, deterministic seating plan that seats every guest once and keeps Bartek and Nina at `T1`.

**Independent Test**: Run `./run.sh input/scenario1.json output/seating-plan.json`; validate five sorted table entries, six sorted guest IDs per table, all 30 unique input IDs, and Bartek/Nina at `T1`; repeat the run and compare byte-identical output.

### Tests for User Story 1

- [X] T009 [P] [US1] Add planner tests for complete assignment, T1 couple placement, canonical guest ordering, and lexicographic tie-breaking in `Tests/workation2026Tests/DeterministicPlannerTests.swift`
- [X] T010 [P] [US1] Add CLI integration tests for the supplied scenario, output-schema shape, and repeatable output in `Tests/workation2026Tests/CLIRunTests.swift`

### Implementation for User Story 1

- [X] T011 [US1] Implement deterministic backtracking or branch-and-bound assignment with fixed T1 placements in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T012 [US1] Implement canonical table/guest sorting and lexicographic equal-score selection in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T013 [US1] Connect scenario decoding, deterministic planning, candidate validation, and JSON publication in `Sources/workation2026/App.swift`

**Checkpoint**: The command produces a deterministic, complete contract-shaped plan for the supplied valid scenario.

---

## Phase 4: User Story 2 - Produce a Considered Social Arrangement (Priority: P2)

**Goal**: Apply only public, evidence-backed companion, separation, location, and final-tier group policies when choosing an otherwise valid plan.

**Independent Test**: Exercise the documented policy catalogue with fixtures that verify named companion/separation handling, T2 dance preference, T4 smoke/terrace preference, group scoring last, exclusion of workation-team lists, and deterministic resolution of policy ties.

### Tests for User Story 2

- [X] T014 [P] [US2] Add public-evidence catalogue and policy-candidate rejection tests in `Tests/workation2026Tests/PolicyTests.swift`
- [X] T015 [P] [US2] Add planner tests for hard relationship pruning and ordered location/group scoring in `Tests/workation2026Tests/DeterministicPlannerTests.swift`

### Implementation for User Story 2

- [X] T016 [US2] Implement the built-in public-evidence policy catalogue, priority validation, and exact evidence checks in `Sources/workation2026/SeatingPolicy.swift`
- [X] T017 [US2] Extend the deterministic planner to enforce separation/companion policies and score location then group preferences in `Sources/workation2026/DeterministicPlanner.swift`
- [X] T018 [US2] Implement optional environment-configured SwiftAgent policy proposals with non-fatal fallback and strict candidate validation in `Sources/workation2026/PolicyAssistant.swift`
- [X] T019 [US2] Integrate validated built-in and optional assistant policies without permitting assistant output to bypass deterministic planning in `Sources/workation2026/App.swift`

**Checkpoint**: Social choices are traceable to public evidence, higher-priority constraints win, and a missing or failed assistant still yields the deterministic built-in plan.

---

## Phase 5: User Story 3 - Receive Clear Feedback for Invalid Scenarios (Priority: P3)

**Goal**: Report specific invalid-input and output-write failures without emitting a partial or replacing a prior plan.

**Independent Test**: Run malformed JSON and invalid scenarios covering duplicate/missing guest IDs, mismatched count/capacity, missing T1/Bartek/Nina, and an unwritable output destination; each run exits non-zero, writes a specific stderr reason, and preserves any existing destination content.

### Tests for User Story 3

- [X] T020 [P] [US3] Add validation unit tests for duplicate or blank guest IDs, fixed venue/count violations, and missing mandatory seating elements in `Tests/workation2026Tests/ValidationTests.swift`
- [X] T021 [P] [US3] Add CLI integration tests for malformed input, specific error reporting, write failure, and unchanged existing output in `Tests/workation2026Tests/CLIRunTests.swift`

### Implementation for User Story 3

- [X] T022 [US3] Add precise validation error cases for malformed scenario structure and mandatory seating requirements in `Sources/workation2026/Validation.swift`
- [X] T023 [US3] Add clear non-zero CLI reporting for decode, validation, planning, and publication failures in `Sources/workation2026/App.swift`

**Checkpoint**: Invalid invocations fail clearly and never leave a partial or misleading destination file.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Verify the complete executable meets the published contract, performance, documentation, and reproducibility requirements.

- [X] T024 [P] Document the final invocation, optional environment configuration, deterministic behavior, and failure guarantees in `README.md`
- [X] T025 Run the documented package and CLI verification sequence from `specs/001-wedding-seating-plan/quickstart.md`
- [X] T026 Validate the generated output against `contract/output-schema.json` and record any unavoidable lower-priority policy trade-offs in `specs/001-wedding-seating-plan/research.md`
- [X] T027 Verify a valid supplied scenario completes within 10 seconds and leaves no credentials in output or diagnostics in `Tests/workation2026Tests/CLIRunTests.swift`
- [X] T028 Add regression coverage for evidence-backed food and drink affinity scoring in `Tests/workation2026Tests/DeterministicPlannerTests.swift`
- [X] T029 Extend the documented policy catalogue and solver with soft food/drink affinity and quiet-table preferences in `Sources/workation2026/Models.swift`, `Sources/workation2026/SeatingPolicy.swift`, and `Sources/workation2026/DeterministicPlanner.swift`
- [X] T030 Map public-brief special requirements to explicit weighted policies, including named companion/separation and location/affinity preferences, in `Sources/workation2026/Models.swift`, `Sources/workation2026/SeatingPolicy.swift`, `Sources/workation2026/DeterministicPlanner.swift`, and `specs/001-wedding-seating-plan/research.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately.
- **Foundational (Phase 2)**: Depends on T001-T003 and blocks every user story.
- **US1 (Phase 3)**: Depends on T004-T008 and provides the MVP executable path.
- **US2 (Phase 4)**: Depends on the canonical planner from US1; its policy tests can be prepared after the foundational models exist.
- **US3 (Phase 5)**: Depends on shared validation and CLI boundaries; it can be implemented after Phase 2, but is sequenced after the higher-priority behavior.
- **Polish (Phase 6)**: Depends on the desired story phases being complete.

### User Story Dependency Graph

```text
Setup -> Foundational -> US1 (MVP) -> US2 -> Polish
                      \-> US3 -----> Polish
```

### Within Each Story

- Write the listed Swift Testing checks before their corresponding implementation task and confirm they fail for the intended behavior.
- Keep structural and mandatory constraints ahead of all policy scoring.
- Run the story's independent test before beginning the next checkpoint.

## Parallel Opportunities

- T002 can proceed independently of T001 and T003.
- T007 can be written alongside T008 after the foundation interfaces are agreed.
- T009 and T010 can proceed in parallel; T014 and T015 can proceed in parallel; T020 and T021 can proceed in parallel.
- After Phase 2, US3 validation coverage can proceed in parallel with the US1 planner implementation, provided shared validation APIs remain stable.

### Parallel Example: User Story 1

```text
Task: "Add planner tests in Tests/workation2026Tests/DeterministicPlannerTests.swift"
Task: "Add CLI integration tests in Tests/workation2026Tests/CLIRunTests.swift"
```

### Parallel Example: User Story 2

```text
Task: "Add policy catalogue tests in Tests/workation2026Tests/PolicyTests.swift"
Task: "Add planner policy tests in Tests/workation2026Tests/DeterministicPlannerTests.swift"
```

## Implementation Strategy

### MVP First

1. Complete setup and foundational models, validation, publication, and CLI boundary.
2. Implement and test US1 to produce a deterministic, complete, schema-shaped plan.
3. Run the US1 independent test using `input/scenario1.json` before adding social policy behavior.

### Incremental Delivery

1. Add US2's public-evidence catalogue and deterministic scoring while preserving the US1 contract.
2. Add US3's explicit error coverage and destination-preservation checks.
3. Complete the quickstart, schema, determinism, timing, and documentation tasks in Phase 6.

## Notes

- `[P]` tasks are parallelizable only where their target files and incomplete dependencies do not conflict.
- `[US1]`, `[US2]`, and `[US3]` labels provide traceability to the priority-ordered user stories in `spec.md`.
- Every task uses the required checkbox, sequential ID, optional parallel marker, story label where required, and an exact file path.