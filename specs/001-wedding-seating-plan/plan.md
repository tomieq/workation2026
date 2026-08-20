# Implementation Plan: Wedding Seating Plan

**Branch**: `001-wedding-seating-plan` | **Date**: 2026-08-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-wedding-seating-plan/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Amend the existing SwiftPM executable without changing `./run.sh <input.json> <output.json>` or the output schema. Preserve the four Scenario 2 hard-constraint classes, replace narrative hard companion/separation behavior with soft policies, and add an auditable built-in catalogue covering all 31 guest descriptions and five table notes across `Grupowanie zespołu`, `Lokalizacja`, `Relacje`, `T1 Production`, `Balans`, and `Ryzyko`. The deterministic planner remains authoritative; SwiftAgent may propose only validated soft policies.

## Technical Context

**Language/Version**: Swift 6.2

**Primary Dependencies**: `SwiftAgent` from `https://github.com/tomieq/SwiftAgent.git` (branch `master`); Foundation

**Storage**: Input and output JSON files only; no persistent data store

**Testing**: Swift Testing via `swift test`; shell-level integration checks through `./run.sh`

**Target Platform**: macOS challenge environment; SwiftAgent also supports Linux for portable SwiftPM builds

**Project Type**: SwiftPM command-line executable

**Performance Goals**: Generate or clearly reject `input/scenario2.json` within 10 seconds

**Constraints**: Five base six-seat tables plus exactly one authorized solver-selected chair; 31 active guests assigned exactly once; Bartek and Nina plus exactly two other work-group guests at `T1`; narrative evidence is soft; all 36 evidence sources are audited; no evidence contributes twice within one category; output has only the published schema fields; deterministic canonical result; leave a pre-existing output untouched on failure. Runtime model credentials/configuration are read only from environment and are never written to output or logs.

**Scale/Scope**: One Scenario 2 invocation, 31 guests, five tables, one extra chair, 36 evidence entries, six scoring categories, and a finite set of evidence-backed soft policies

## Constitution Check

*GATE: Passed before Phase 0 research. Re-checked after Phase 1 design: passed.*

| Constitution principle | Design response | Status |
|---|---|---|
| Evidence-Based Requirement Extraction | Every exact Scenario 2 description and note has one catalogue entry; actionable rules retain their evidence, and unsupported traits are explicitly non-actionable. | Pass |
| Swift Package Manager Implementation | `Package.swift` declares SwiftAgent and the `workation2026` executable; all source and Swift Testing targets use SwiftPM. | Pass |
| Contract-Valid, Change-Controlled Swift Executable Is Non-Negotiable | `run.sh` delegates to the executable; decoding, Scenario 2 structural validation, result validation, and atomic publication guard the contract. | Pass |
| Deterministic, Verifiable Optimization | The application-owned solver evaluates all allowed seventh-chair candidates, enforces only the four approved hard classes, compares six documented category scores, and chooses the canonical tied arrangement. SwiftAgent cannot create hard rules. | Pass |
| Simplicity and Explainability | A single executable module separates decoding, policy extraction, deterministic planning, agent orchestration, and JSON encoding without a persistence layer or framework. | Pass |

**Dependency justification**: SwiftAgent remains an optional narrative-policy sidecar. Its non-deterministic output is not authoritative: validation rejects unknown references, non-exact evidence, unsupported categories, duplicate evidence/category contributions, and every proposed hard rule.

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

1. **Hard invariants**: Keep capacity, complete unique assignment, couple placement, and exact `T1` work composition in `Validation.swift` and candidate construction. Remove narrative `.companion` and `.separate` checks from `respectsHardPolicies`.
2. **Evidence catalogue**: Add `CompetitionCategory`, `EvidenceSource`, and `EvidenceCatalogueEntry` types. `SeatingPolicyCatalogue` returns exactly 36 entries keyed by table or guest ID, preserving the exact input text, categories, actionability, and generated soft policies. Startup validation rejects catalogue drift against `input/scenario2.json` semantics before planning.
3. **Soft policies**: Add a category to every actionable policy and replace hard companion/separation kinds with relationship affinity/avoidance scoring. Encode table notes for `T1` through `T5`, Bartek affinities for `kuba_g` and `michal_z`, corrected non-affinity for the Maciek/Jakub food contrast, and explicit non-actionable reasons for uncertain or cosmetic signals.
4. **Objective**: Compute one `CategoryScore` per competition category. Each evidence entry contributes at most once to a category for a candidate. Compare candidates by total satisfied policy value, then by the six-category vector in the published category order, then by the canonical sorted table/guest vector. Positive and negative soft policies use documented integer strengths only within their category; no soft result invalidates a candidate.
5. **Search**: Retain enumeration of eligible `T1` work pairs and seventh-chair tables. Extend deterministic construction with bounded pair swaps until no swap improves the complete objective, so policies involving guests assigned early can influence the final plan.
6. **Assistant**: Restrict `PolicyAssistant` proposals to soft kinds and the six category names. Require known IDs, exact input evidence, a supported table reference, and a unique `(evidence source, category, effect)` identity; merge only proposals that do not duplicate the built-in catalogue.
7. **Tests**: Add an audit test for 31 guest descriptions plus five notes, one focused test per actionable catalogue policy/effect, non-actionable-entry tests, hard-constraint precedence tests, category-score and duplicate-suppression tests, unchanged-schema coverage, deterministic repeated output, and the existing sub-10-second check.

## Phase 0 and Phase 1 Artifacts

- [research.md](research.md): Catalogue, soft-policy, objective, and search decisions.
- [data-model.md](data-model.md): Evidence entries, competition categories, policies, category scores, and existing plan entities.
- [contracts/cli-contract.md](contracts/cli-contract.md): Unchanged external JSON contract plus internal catalogue guarantees.
- [quickstart.md](quickstart.md): Build, catalogue audit, category behavior, structure, determinism, and failure-preservation checks.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Optional SwiftAgent policy assistant | Narrative extraction benefits from AI assistance, but a model cannot itself prove schema validity or repeatable optimal tie-breaking. | A model-only output path violates deterministic and contract invariants. |
