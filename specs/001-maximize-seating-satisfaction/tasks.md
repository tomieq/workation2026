# Tasks: Maximize Seating Satisfaction

**Input**: Design documents from `/specs/001-maximize-seating-satisfaction/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Include integration, contract, and targeted unit tests per spec and constitution.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story label (`[US1]`, `[US2]`, `[US3]`)
- Include exact file paths in each task description

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize Kotlin CLI project structure and baseline tooling.

- [ ] T001 Create layered source and test package directories under `src/main/kotlin/workation/seating/{cli,application,domain/{model,constraints,scoring},infrastructure}` and `src/test/kotlin/workation/seating/{integration,contract,unit}`
- [ ] T002 Configure Gradle Kotlin/JVM application settings and main class wiring in `./build.gradle.kts`
- [ ] T003 [P] Add runtime and test dependencies (kotlinx-serialization, JUnit 5, JSON schema validator) in `./build.gradle.kts`
- [ ] T004 [P] Configure JUnit Platform and deterministic test JVM settings in `./build.gradle.kts`
- [ ] T005 Update `run.sh` to invoke the built CLI jar/class with `./run.sh <input.json> <output.json>` contract

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core domain and adapter infrastructure required before story implementation.

**⚠️ CRITICAL**: Complete all tasks in this phase before starting user stories.

- [ ] T006 Implement core domain entities and value objects in `src/main/kotlin/workation/seating/domain/model/DomainModels.kt`
- [ ] T007 [P] Implement CLI input/output DTOs and serializers in `src/main/kotlin/workation/seating/infrastructure/JsonDtos.kt`
- [ ] T008 [P] Implement canonical input validation (guest uniqueness, 5x6 capacity, required IDs) in `src/main/kotlin/workation/seating/domain/constraints/InputValidator.kt`
- [ ] T009 Implement seating plan invariant validator (coverage, uniqueness, table cardinality) in `src/main/kotlin/workation/seating/domain/constraints/PlanValidator.kt`
- [ ] T010 [P] Implement deterministic tie-break utilities (canonical guest ID and table ordering) in `src/main/kotlin/workation/seating/domain/scoring/DeterministicOrdering.kt`
- [ ] T011 Implement scenario rule set definitions (mandatory T1, political, cohort, separation rules) in `src/main/kotlin/workation/seating/domain/constraints/ScenarioRuleSet.kt`
- [ ] T012 Implement application orchestration skeleton and error model in `src/main/kotlin/workation/seating/application/GenerateSeatingPlanUseCase.kt`

**Checkpoint**: Foundation ready; user story phases can proceed.

---

## Phase 3: User Story 1 - Generate Valid Full Seating Plan (Priority: P1) 🎯 MVP

**Goal**: Always produce one valid full seating plan that satisfies all hard constraints.

**Independent Test**: Run `./run.sh input/scenario1.json output/scenario1-result.json`; verify 5 tables, 6 guests each, all 30 unique IDs exactly once, and mandatory `T1` placement (`bartek`, `nina`, `mama_ela`, `babcia_ela`).

### Tests for User Story 1

- [ ] T013 [P] [US1] Add integration test for full-plan structural validity in `src/test/kotlin/workation/seating/integration/GenerateValidPlanIntegrationTest.kt`
- [ ] T014 [P] [US1] Add contract test validating output against `contract/output-schema.json` in `src/test/kotlin/workation/seating/contract/OutputSchemaContractTest.kt`
- [ ] T015 [P] [US1] Add integration test for mandatory hard constraints (T1, politicians, maciek/jakub, cohort shape) in `src/test/kotlin/workation/seating/integration/HardConstraintsIntegrationTest.kt`

### Implementation for User Story 1

- [ ] T016 [US1] Implement deterministic hard-constraint-first assignment engine in `src/main/kotlin/workation/seating/application/ConstraintFirstPlanner.kt`
- [ ] T017 [US1] Implement corporate-heavy cohort table construction logic in `src/main/kotlin/workation/seating/domain/constraints/CohortAllocator.kt`
- [ ] T018 [US1] Implement political and pair-separation enforcement in `src/main/kotlin/workation/seating/domain/constraints/PoliticalConstraintEvaluator.kt`
- [ ] T019 [US1] Implement CLI entrypoint argument handling and use-case execution in `src/main/kotlin/workation/seating/cli/Main.kt`
- [ ] T020 [US1] Implement JSON input loading and output writing adapters in `src/main/kotlin/workation/seating/infrastructure/JsonPlanRepository.kt`
- [ ] T021 [US1] Add infeasible/invalid scenario failure reporting to stderr and non-zero exits in `src/main/kotlin/workation/seating/cli/Main.kt`

**Checkpoint**: US1 is independently functional and testable as MVP.

---

## Phase 4: User Story 2 - Prefer Placements That Improve Couple Satisfaction (Priority: P2)

**Goal**: Optimize valid plans with deterministic weighted satisfaction (Nina priority) and reproducible signal rules.

**Independent Test**: For fixed scenario fixtures and deterministic swap alternatives, selected plan must satisfy hard constraints and not score lower under documented weighted policy.

### Tests for User Story 2

- [ ] T022 [P] [US2] Add unit tests for Polish narrative signal extraction and neutral fallback in `src/test/kotlin/workation/seating/unit/NarrativeSignalExtractorTest.kt`
- [ ] T023 [P] [US2] Add unit tests for weighted score calculation and Nina-priority objective in `src/test/kotlin/workation/seating/unit/WeightedScorerTest.kt`
- [ ] T024 [P] [US2] Add integration tests for deterministic optimization and tie-break repeatability in `src/test/kotlin/workation/seating/integration/DeterministicOptimizationIntegrationTest.kt`
- [ ] T025 [P] [US2] Add integration tests for T4 overflow ranking/fallback behavior in `src/test/kotlin/workation/seating/integration/T4OverflowIntegrationTest.kt`

### Implementation for User Story 2

- [ ] T026 [US2] Implement deterministic Polish narrative signal extraction rules in `src/main/kotlin/workation/seating/domain/scoring/NarrativeSignalExtractor.kt`
- [ ] T027 [US2] Implement signal precedence policy (hard > pair conflict > pair affinity > individual > neutral) in `src/main/kotlin/workation/seating/domain/scoring/SignalPrecedencePolicy.kt`
- [ ] T028 [US2] Implement weighted couple satisfaction scorer with score breakdown output in `src/main/kotlin/workation/seating/domain/scoring/WeightedSatisfactionScorer.kt`
- [ ] T029 [US2] Implement table location affinity model (`T2` dance priority, `T4` hard-priority localization) in `src/main/kotlin/workation/seating/domain/scoring/TableLocationAffinityPolicy.kt`
- [ ] T030 [US2] Integrate candidate enumeration and scoring selection into planner in `src/main/kotlin/workation/seating/application/ConstraintFirstPlanner.kt`
- [ ] T031 [US2] Implement deterministic candidate tie resolution using canonical IDs in `src/main/kotlin/workation/seating/domain/scoring/CandidateTieBreaker.kt`
- [ ] T032 [US2] Add optimization trace logging hooks for score components in `src/main/kotlin/workation/seating/application/GenerateSeatingPlanUseCase.kt`

**Checkpoint**: US2 produces deterministic, explainable optimization while preserving US1 validity.

---

## Phase 5: User Story 3 - Handle Source Ambiguities Transparently (Priority: P3)

**Goal**: Make ambiguity resolution and interpretation decisions explicit and traceable for reviewers.

**Independent Test**: Verify ambiguity registry documents decisions for identity format, capacity authority, scoring authority, and translation/signal interpretation; confirm implementation references these rules.

### Tests for User Story 3

- [ ] T033 [P] [US3] Add documentation consistency test asserting implemented rule constants match spec decisions in `src/test/kotlin/workation/seating/contract/AmbiguityDecisionConsistencyTest.kt`

### Implementation for User Story 3

- [ ] T034 [US3] Create ambiguity decision registry for runtime rule references in `src/main/kotlin/workation/seating/domain/model/AmbiguityDecisionRegistry.kt`
- [ ] T035 [US3] Wire ambiguity decision IDs into validation and scoring components in `src/main/kotlin/workation/seating/application/GenerateSeatingPlanUseCase.kt`
- [ ] T036 [US3] Document executable decision map and rationale in `specs/001-maximize-seating-satisfaction/decision-log.md`
- [ ] T037 [US3] Update quickstart reviewer flow with ambiguity verification steps in `specs/001-maximize-seating-satisfaction/quickstart.md`

**Checkpoint**: US3 provides transparent and testable traceability for ambiguous source interpretation.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, documentation, and end-to-end validation across stories.

- [ ] T038 [P] Add final end-to-end CLI acceptance test using `input/scenario1.json` in `src/test/kotlin/workation/seating/integration/ScenarioAcceptanceIntegrationTest.kt`
- [ ] T039 [P] Add performance guard test (<2s deterministic solve target) in `src/test/kotlin/workation/seating/integration/PerformanceIntegrationTest.kt`
- [ ] T040 Harden error messages and exception mapping for all failure classes in `src/main/kotlin/workation/seating/cli/CliErrorRenderer.kt`
- [ ] T041 [P] Update implementation notes and scoring breakdown documentation in `./README.md`
- [ ] T042 Execute quickstart validation commands and record final verification checklist in `specs/001-maximize-seating-satisfaction/quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies.
- **Phase 2 (Foundational)**: depends on Phase 1; blocks all user stories.
- **Phase 3 (US1)**: depends on Phase 2; establishes MVP.
- **Phase 4 (US2)**: depends on US1 baseline planner/validators.
- **Phase 5 (US3)**: depends on US1/US2 implemented rule constants and scoring policy.
- **Phase 6 (Polish)**: depends on selected user stories being complete.

### User Story Dependencies

- **US1 (P1)**: starts immediately after Foundational; no user-story dependency.
- **US2 (P2)**: depends on US1 assignment pipeline and hard-rule enforcement.
- **US3 (P3)**: depends on US1/US2 decisions to document and verify traceability.

### Within Each User Story

- Tests first (write and confirm failing), then implementation.
- Domain models/policies before orchestration wiring.
- Planner integration before CLI/reporting polish.

---

## Parallel Opportunities

- **Setup**: T003 and T004 parallel after T002.
- **Foundational**: T007, T008, and T010 parallel after T006.
- **US1**: T013/T014/T015 parallel; T017 and T018 parallel after T016 skeleton exists.
- **US2**: T022/T023/T024/T025 parallel; T026/T027/T029 parallel before T030.
- **US3**: T033 and T036 parallel once US2 rules are stable.
- **Polish**: T038, T039, and T041 parallel.

## Parallel Example: User Story 1

```bash
Task: "T013 [US1] Add integration test for full-plan structural validity in src/test/kotlin/workation/seating/integration/GenerateValidPlanIntegrationTest.kt"
Task: "T014 [US1] Add contract test validating output against contract/output-schema.json in src/test/kotlin/workation/seating/contract/OutputSchemaContractTest.kt"
Task: "T015 [US1] Add integration test for mandatory hard constraints in src/test/kotlin/workation/seating/integration/HardConstraintsIntegrationTest.kt"
```

## Parallel Example: User Story 2

```bash
Task: "T022 [US2] Add unit tests for narrative extraction in src/test/kotlin/workation/seating/unit/NarrativeSignalExtractorTest.kt"
Task: "T023 [US2] Add unit tests for weighted scorer in src/test/kotlin/workation/seating/unit/WeightedScorerTest.kt"
Task: "T025 [US2] Add integration tests for T4 overflow behavior in src/test/kotlin/workation/seating/integration/T4OverflowIntegrationTest.kt"
```

## Parallel Example: User Story 3

```bash
Task: "T033 [US3] Add ambiguity decision consistency test in src/test/kotlin/workation/seating/contract/AmbiguityDecisionConsistencyTest.kt"
Task: "T036 [US3] Document executable decision map in specs/001-maximize-seating-satisfaction/decision-log.md"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 tests and implementation (Phase 3).
3. Validate with `./run.sh input/scenario1.json output/scenario1-result.json`.
4. Demo/deploy MVP once US1 passes.

### Incremental Delivery

1. Deliver US1 (valid deterministic plan).
2. Add US2 (weighted optimization and deterministic scoring).
3. Add US3 (ambiguity traceability and reviewer confidence).
4. Finish with Phase 6 cross-cutting hardening.

### Parallel Team Strategy

1. Team aligns on Setup + Foundational.
2. Then split: one developer on US2 scoring engine, another on US3 documentation/consistency tests, while maintaining US1 baseline stability.

---

## Notes

- All tasks use the required checklist format with IDs, optional `[P]`, and `[US#]` labels in story phases.
- File paths are explicit so each task is executable without extra context.
- Keep artifacts and identifiers in English per constitution policy.
