# Implementation Plan: Wedding Seating Plan

**Branch**: `001-wedding-seating-plan` | **Date**: 2026-08-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-wedding-seating-plan/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Build a SwiftPM command-line program that validates a fixed five-table wedding scenario and writes only a schema-valid seating plan. A deterministic constraint optimizer is the main engine: it applies a public-evidence policy catalogue, scores only documented soft preferences, and selects the canonical arrangement. SwiftAgent is an optional sidecar that converts free-form table notes and guest descriptions into proposed policy candidates; a strict policy validator accepts only evidence-backed, closed-vocabulary rules before the solver sees them. The solver validates the result before it can be written.

## Technical Context

**Language/Version**: Swift 6.2

**Primary Dependencies**: `SwiftAgent` from `https://github.com/tomieq/SwiftAgent.git` (branch `master`); Foundation

**Storage**: Input and output JSON files only; no persistent data store

**Testing**: Swift Testing via `swift test`; shell-level integration checks through `./run.sh`

**Target Platform**: macOS challenge environment; SwiftAgent also supports Linux for portable SwiftPM builds

**Project Type**: SwiftPM command-line executable

**Performance Goals**: Generate or clearly reject the supplied 30-guest scenario within 10 seconds

**Constraints**: Exactly five six-seat tables; every input guest once; Bartek and Nina at `T1`; output has only the published schema fields; deterministic canonical result; leave a pre-existing output untouched on failure. Runtime model credentials/configuration are read only from environment and are never written to output or logs.

**Scale/Scope**: One scenario per invocation, 30 guests, five tables, and a finite catalogue of public-evidence policies

## Constitution Check

*GATE: Passed before Phase 0 research. Re-checked after Phase 1 design: passed.*

| Constitution principle | Design response | Status |
|---|---|---|
| Evidence-Based Requirement Extraction | Policies are a static catalogue sourced only from the brief, scenario fields, and table notes. Workation teams are excluded. | Pass |
| Swift Package Manager Implementation | `Package.swift` declares SwiftAgent and the `workation2026` executable; all source and Swift Testing targets use SwiftPM. | Pass |
| Contract-Valid Swift Executable Is Non-Negotiable | `run.sh` delegates to the executable; decoding, structural validation, result validation, and atomic publication guard the contract. | Pass |
| Deterministic, Verifiable Optimization | The application-owned optimizer enforces hard rules, scores documented preferences, and chooses the lexicographically smallest tied arrangement. SwiftAgent policy suggestions require deterministic validation and cannot bypass this result. | Pass |
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

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Optional SwiftAgent policy assistant | Narrative extraction benefits from AI assistance, but a model cannot itself prove schema validity or repeatable optimal tie-breaking. | A model-only output path violates deterministic and contract invariants. |
