<!--
Sync Impact Report
- Version change: 1.0.0 → 2.0.0
- Modified principles:
  - 3. Separation of Concerns → 3. Separation of Concerns (CLI Boundaries)
  - 5. Backend Architecture → 5. CLI Architecture Boundaries
  - 6. Frontend Architecture → 6. I/O Adapters and Schema Contracts
  - 7. Testing (expanded for CLI contract coverage)
  - 10. Domain-Driven Design (DDD) and Domain Focus (aligned to CLI execution flow)
- Added sections: None
- Removed sections:
  - None
- Follow-up TODOs: None
-->
# Workation2026 Constitution

## Core Principles

### 1. Modularity
The codebase MUST be split into clearly defined modules with explicit
boundaries and a single responsibility per module. Cyclic dependencies are
forbidden. Shared code MUST remain minimal and may exist only in dedicated
common modules when a concrete reuse case justifies it.

Rationale: Explicit module ownership keeps the system evolvable and prevents
accidental coupling.

### 2. SOLID
Code MUST apply SOLID principles consistently. Classes and interfaces MUST stay
small and focused, dependencies MUST target abstractions instead of concrete
implementations, and stable code MUST be extended through clear seams rather
than frequent modification.

Rationale: SOLID design keeps modules replaceable, testable, and easier to
reason about.

### 3. Separation of Concerns (CLI Boundaries)
Domain, application, infrastructure, and CLI adapter concerns MUST remain
separate. Parsing input JSON, validating contracts, and writing output JSON MUST
stay in adapter/infrastructure layers, while business rules MUST stay in domain
and application layers.

Rationale: Clean separation limits cross-layer shortcuts and protects business
rules from delivery details.

### 4. Readability and Maintainability
The codebase MUST favor simple, readable implementations over cleverness.
Names MUST be explicit, public APIs MUST stay small and intentional, and new
abstractions MUST only be introduced when they reduce real complexity. Comments
MUST be avoided unless required by external constraints or necessary to clarify
non-obvious intent.

Rationale: Readable code lowers maintenance cost and makes safe change easier.

### 5. CLI Architecture Boundaries
The Kotlin application MUST follow clear domain/application/infrastructure
layering. Business logic MUST be framework-agnostic and MUST NOT depend on shell
or file-system details. Runtime wiring for `./run.sh <input.json> <output.json>`
MUST be isolated to boundary modules.

Rationale: Framework-independent business rules are easier to test and change.

### 6. I/O Adapters and Schema Contracts
The CLI entrypoint MUST expose a stable shell contract:
`./run.sh <input.json> <output.json>`. Input parsing and output serialization
MUST be implemented through adapters with explicit interfaces. JSON schema
contracts (input assumptions and `contract/output-schema.json`) MUST be treated
as boundary contracts and validated by tests when changed.

Rationale: Explicit CLI and schema boundaries keep delivery contracts stable and
safe to evolve.

### 7. Testing
Every meaningful change MUST be validated primarily through integration tests
that exercise user-visible behavior, module collaboration, and external
integration seams through stable interfaces. Contract tests MUST be added where
JSON schemas, CLI arguments, or adapter contracts change. Unit tests MAY be
added for isolated logic that cannot be covered efficiently through
integration-level checks, but they MUST remain targeted and secondary rather
than the default testing layer. Tests MUST validate observable behavior rather
than implementation details.

Rationale: Integration-first coverage provides stronger confidence that the
assembled system works as released while preserving targeted unit tests only
where they add clear value.

### 8. Dependency Rules
Inner layers MUST NOT depend on outer layers. Modules MUST communicate through
stable, explicit contracts. Direct cross-module access is forbidden unless the
dependency is intentionally defined in the architecture. Hidden coupling through
globals, singletons, or service locators is forbidden.

Rationale: Controlled dependencies preserve replaceability and keep
architectural drift visible.

### 9. Change Discipline
Changes MUST be small, incremental, and justified by the current requirement.
Teams MUST refactor before incidental complexity becomes architecture. Dead code
and unused abstractions MUST be removed when encountered in the affected area.
New frameworks or libraries MUST NOT be introduced without a clear need and a
documented simpler alternative considered first.

Rationale: Disciplined change keeps the codebase adaptable and prevents
unnecessary complexity.

### 10. Domain-Driven Design (DDD) and Domain Focus
The project MUST adopt Domain-Driven Design (DDD) and keep the domain model as
the primary design artifact. Technical choices MUST NOT reshape domain concepts;
the domain MUST guide design and naming.

Key expectations:
- Teams MUST use ubiquitous language across code, docs, and tests.
- Teams MUST partition the system into bounded contexts and document their
  boundaries.
- Teams MUST model aggregates with a clear root and keep transactions and
  invariants inside an aggregate.
- Teams MUST distinguish entities (identity) from value objects (immutable
  values).
- Teams MUST expose persistence through repository interfaces and keep domain
  types persistence-agnostic.
- Teams MUST use domain services and domain events for cross-entity operations
  and integration, while enforcing invariants in the domain layer.
- Teams MUST keep orchestration of CLI use-cases in application services and
  keep shell/file adapter logic outside the domain model.
- Teams MUST add domain-focused tests that validate invariants and aggregate
  rules in addition to integration tests.

Rationale: A domain-first model preserves business integrity and keeps technical
implementation choices subordinate to core problem semantics.

## Purpose and Scope
Purpose: Build and maintain a Kotlin CLI challenge deliverable executed as
`./run.sh <input.json> <output.json>`, using modular architecture and strict
separation between domain logic and I/O adapters.

Scope: This constitution applies to all code, architecture, tests, technical
decisions, and delivery artifacts in the project.

## Constitution Decision Rules
### Decision Rules
When choosing between implementations:
1. Teams MUST prefer the simplest design that satisfies the requirement.
2. Teams MUST prefer explicit module boundaries over convenience.
3. Teams MUST prefer abstractions only when they reduce real coupling.
4. Teams MUST prefer testability over shortcut implementations.
5. Teams MUST reject designs that blur domain/application/infrastructure/adapter
   boundaries.

### Architectural Expectations
- The project MUST be split into modules by responsibility.
- Domain, application, and infrastructure/adapter layers MUST be independently
  understandable.
- CLI and schema contracts MUST be explicit, stable, and versioned when changed.
- Public APIs MUST stay small and intentional.
- The canonical execution path MUST remain `./run.sh <input.json> <output.json>`.

### Forbidden Patterns
- Monolithic structure
- Cyclic module dependencies
- God classes
- Anemic service layers with leaked adapter or framework logic
- Cross-layer shortcuts
- Premature generalization
- Overengineering
- Business logic inside CLI argument parsing or JSON serialization code
- Persistence logic inside domain objects

## Governance
This constitution supersedes other development preferences where conflicts
exist. Amendments MUST be proposed in writing, include rationale and impact,
and be approved by designated project maintainers before adoption.

Versioning policy:
- MAJOR version increments for backward-incompatible governance changes,
  principle removals, or principle redefinitions.
- MINOR version increments for new principles/sections or materially expanded
  guidance.
- PATCH version increments for clarifications, wording edits, or non-semantic
  refinements.

Compliance review expectations:
- Every pull request MUST include a constitution compliance check in review.
- Reviewers MUST block merges that violate any MUST-level rule.
- Architecture-impacting changes MUST reference affected principles and
  document explicit compliance decisions.
- Periodic governance audits MUST be performed to detect drift and propose
  amendments.

**Version**: 2.0.0 | **Ratified**: 2026-08-19 | **Last Amended**: 2026-08-19
