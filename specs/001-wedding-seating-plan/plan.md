# Implementation Plan: Wedding Seating Plan

**Branch**: `001-wedding-seating-plan` | **Date**: 2026-08-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-wedding-seating-plan/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Amend the existing SwiftPM executable for Scenario 2 without changing its `./run.sh <input.json> <output.json>` interface or output schema. Decode and validate the one-chair authorization in `input/scenario2.json`; produce four six-guest tables and one solver-selected seven-guest table; enforce Bartek, Nina, and exactly two additional work colleagues at `T1`; and replace retired guest policies with the documented newcomer policies. The deterministic planner remains authoritative; SwiftAgent remains an optional, validated policy-proposal sidecar.

## Technical Context

**Language/Version**: Swift 6.2

**Primary Dependencies**: `SwiftAgent` from `https://github.com/tomieq/SwiftAgent.git` (branch `master`); Foundation

**Storage**: Input and output JSON files only; no persistent data store

**Testing**: Swift Testing via `swift test`; shell-level integration checks through `./run.sh`

**Target Platform**: macOS challenge environment; SwiftAgent also supports Linux for portable SwiftPM builds

**Project Type**: SwiftPM command-line executable

**Performance Goals**: Generate or clearly reject `input/scenario2.json` within 10 seconds

**Constraints**: Five base six-seat tables plus exactly one authorized solver-selected chair; 31 active guests assigned exactly once; Bartek and Nina plus exactly two other work-group guests at `T1`; output has only the published schema fields; deterministic canonical result; leave a pre-existing output untouched on failure. Runtime model credentials/configuration are read only from environment and are never written to output or logs.

**Scale/Scope**: One Scenario 2 invocation, 31 guests, five tables, one extra chair, and a finite catalogue of public-evidence policies

## Constitution Check

*GATE: Passed before Phase 0 research. Re-checked after Phase 1 design: passed.*

| Constitution principle | Design response | Status |
|---|---|---|
| Evidence-Based Requirement Extraction | Policies are a static catalogue sourced only from the brief, scenario fields, approved change request, and clarifications. Additional work-team rules remain excluded. | Pass |
| Swift Package Manager Implementation | `Package.swift` declares SwiftAgent and the `workation2026` executable; all source and Swift Testing targets use SwiftPM. | Pass |
| Contract-Valid, Change-Controlled Swift Executable Is Non-Negotiable | `run.sh` delegates to the executable; decoding, Scenario 2 structural validation, result validation, and atomic publication guard the contract. | Pass |
| Deterministic, Verifiable Optimization | The application-owned solver evaluates all allowed seventh-chair candidates, enforces hard rules, scores documented preferences, and chooses the lexicographically smallest tied arrangement. SwiftAgent policy suggestions require deterministic validation and cannot bypass this result. | Pass |
| Simplicity and Explainability | A single executable module separates decoding, policy extraction, deterministic planning, agent orchestration, and JSON encoding without a persistence layer or framework. | Pass |

**Dependency justification**: SwiftAgent is used for the requested AI-assisted transformation of narrative notes into candidate policies. Its non-deterministic output is not authoritative: the policy validator rejects unsupported references, unknown guests/tables, invalid priority classes, or any change to hard constraints beyond the published catalogue.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
Package.swift
run.sh
Sources/
└── workation2026/
  ├── App.swift                 # argument parsing and error-to-stderr boundary
  ├── Models.swift              # Codable scenario and output types
  ├── Validation.swift          # input/output invariants and atomic publication
  ├── SeatingPolicy.swift       # public-evidence policy catalogue and validation
  ├── DeterministicPlanner.swift # main constraint solver, scoring, canonical tie-break
  └── PolicyAssistant.swift     # optional SwiftAgent candidate-policy extraction
Tests/
└── workation2026Tests/
  ├── ValidationTests.swift
  ├── PolicyTests.swift
  ├── DeterministicPlannerTests.swift
  └── CLIRunTests.swift
```

**Structure Decision**: Use one SwiftPM executable target and one Swift Testing target. The module boundaries above keep JSON contracts, public-evidence policy interpretation, deterministic solver behavior, and optional provider integration independently testable without introducing packages or a service boundary.

## Implementation Design

1. **Models and fixture**: Extend `SeatingScenario` with Codable `ExtraSeatPolicy`; retain base `VenueTable.capacity`. Validate five six-seat base tables, 31 unique active guests, the exact Scenario 2 roster, and one chair authorized for any table.
2. **Validation**: Derive final capacity from the selected seven-seat table instead of assuming six seats everywhere. Add clear errors for invalid extra-seat authorization, roster mismatch, invalid seven-seat distribution, and invalid `T1` colleague count; retain duplicate, unknown, missing, couple, and atomic-publication behavior.
3. **Policies**: Remove retired Donald/Jarosław entries. Add evidence-backed soft avoidance for `leszek` with `kuba_g` and `michal_z`, plus a newcomer work-cluster penalty at four or more work guests. Do not create a Bald Club policy. Encode the `T1` colleague composition as a hard rule.
4. **Planner**: For each eligible `T1` pair of non-Bartek work colleagues and each eligible seventh-chair table, construct a deterministic assignment that respects hard policies. Apply repeatable assignment improvements only when they improve the ordered policy objective. Compare complete candidates by objective, then canonical sorted table/guest vector.
5. **Tests**: Update helper scenarios to 31 guests plus an extra-seat policy. Add validations for capacity authorization, exact roster, selected seven-seat distribution, and `T1` composition. Add planner and CLI tests for `input/scenario2.json`: `[6,6,6,6,7]`, unique guest coverage, newcomer avoidance when a better candidate exists, and byte-identical output across repeated runs.

## Phase 0 and Phase 1 Artifacts

- [research.md](research.md): Scenario 2 technical decisions and alternatives.
- [data-model.md](data-model.md): `ExtraSeatPolicy`, base versus final capacity, and `T1` composition.
- [contracts/cli-contract.md](contracts/cli-contract.md): unchanged command interface with Scenario 2 invariants.
- [quickstart.md](quickstart.md): Scenario 2 run, structural, determinism, and failure-preservation checks.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Optional SwiftAgent policy assistant | Narrative extraction benefits from AI assistance, but a model cannot itself prove schema validity or repeatable optimal tie-breaking. | A model-only output path violates deterministic and contract invariants. |
