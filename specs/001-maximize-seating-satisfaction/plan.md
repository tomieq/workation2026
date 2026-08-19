# Implementation Plan: Maximize Seating Satisfaction

**Branch**: `001-maximize-seating-satisfaction` | **Date**: 2026-08-19 | **Spec**: `specs/001-maximize-seating-satisfaction/spec.md`

**Input**: Feature specification from `/specs/001-maximize-seating-satisfaction/spec.md`

## Summary

Implement a deterministic Kotlin CLI solver (`./run.sh <input.json> <output.json>`) that always outputs a valid 5x6 seating plan for 30 guests, enforces all hard constraints from spec (including T1 mandatory guests, political separation, cohort composition, and canonical IDs), and optimizes a weighted satisfaction score with Nina priority over Bartek using explicit, reproducible narrative signal rules.

## Technical Context

**Language/Version**: Kotlin 2.2.10 on JVM 21

**Primary Dependencies**:
- Kotlinx Serialization (input/output JSON)
- JUnit 5 (unit + integration tests)
- JSON Schema validator for contract test against `contract/output-schema.json`

**Storage**: N/A (file-based input/output only)

**Testing**:
- Integration-first tests (full scenario behavior)
- Contract tests for CLI I/O schema and business rules
- Focused unit tests for scoring and constraint rules

**Target Platform**: Local CLI on macOS/Linux with Java 21

**Project Type**: Single Kotlin CLI application

**Performance Goals**:
- Deterministic output for identical input (FR-008 / SC-005)
- Complete solution generation under 2 seconds for 30-guest scenario

**Constraints**:
- Runtime contract remains `./run.sh <input.json> <output.json>`
- Exactly 5 tables x 6 guests; no hidden rules beyond spec/clarifications
- Output must use canonical input guest IDs
- Hard constraints must fail clearly when infeasible
- Artifacts and code identifiers remain in English

**Scale/Scope**:
- Current scope: scenario-style input with 30 guests and fixed table count/capacity
- Design remains extensible to future scenarios with the same contract shape

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Modularity**: PASS — planned split into domain/application/infrastructure/cli modules/packages.
- **SOLID**: PASS — scoring, constraints, parsing, and orchestration separated by responsibility.
- **Separation of Concerns (CLI Boundaries)**: PASS — JSON/file handling in adapters, business rules in domain/application.
- **Readability/Maintainability**: PASS — deterministic rule engine over opaque magic behavior.
- **CLI Architecture Boundaries**: PASS — canonical `run.sh` entrypoint preserved.
- **I/O Adapters & Schema Contracts**: PASS — explicit contracts and contract tests planned.
- **Testing**: PASS — integration-first strategy with contract coverage.
- **Dependency Rules**: PASS — inner layers independent from CLI/file system.
- **Change Discipline**: PASS — no unnecessary framework additions.
- **DDD/Domain Focus**: PASS — explicit entities/value objects, domain invariants, ubiquitous language.
- **English Artifact Policy**: PASS — all produced artifacts in English; Polish source interpreted with documented rules.

**Gate Result (pre-research)**: PASS

## Project Structure

### Documentation (this feature)

```text
specs/001-maximize-seating-satisfaction/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── seating-cli-contract.md
└── tasks.md (created later by /speckit.tasks)
```

### Source Code (repository root)

```text
src/
└── main/kotlin/... (planned)
    ├── cli/              # args, input loading, output writing
    ├── application/      # orchestration use case
    ├── domain/
    │   ├── model/        # Guest, Table, signals, assignment
    │   ├── constraints/  # hard-rule evaluators
    │   └── scoring/      # weighted satisfaction policy
    └── infrastructure/   # JSON serialization, schema validator adapter

src/test/kotlin/... (planned)
├── integration/
├── contract/
└── unit/
```

**Structure Decision**: Single-project Kotlin CLI with layered packages to satisfy constitution layering and keep core seating logic framework-agnostic.

## Phase 0: Research Summary

Research completed in `research.md`:
- Deterministic Kotlin CLI stack choices
- Feasible optimization strategy for constrained 30-guest seating
- Deterministic Polish narrative signal extraction without runtime AI services

All prior technical unknowns are resolved; no remaining `NEEDS CLARIFICATION`.

## Phase 1: Design Outputs

- `data-model.md`: entities, relationships, invariants, state transitions
- `contracts/seating-cli-contract.md`: CLI and JSON interface contract
- `quickstart.md`: validation scenarios and runnable checks

## Constitution Check (Post-Design)

- Re-evaluated after Phase 1 artifacts: **PASS**
- No justified violations required.

## Complexity Tracking

No constitution violations to track.
