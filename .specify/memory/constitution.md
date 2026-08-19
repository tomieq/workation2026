<!--
Sync Impact Report
Version change: 1.0.0 -> 2.0.0
Modified principles: II. prior platform policy -> II. Swift Package Manager Implementation;
III. Contract-Valid Seating Is Non-Negotiable -> III. Contract-Valid Swift Executable Is
Non-Negotiable
Added sections: none
Removed sections: none
Follow-up TODOs: none
-->

# Wedding Seating Challenge Constitution

## Core Principles

### I. Evidence-Based Requirement Extraction
The team MUST derive requirements only from the public challenge brief, input data, and published
output contract. Narrative guest descriptions MUST be examined for actionable seating signals, while
unsupported organizer intent, private scoring rules, and invented constraints MUST NOT be assumed.
This keeps decisions traceable to the material available to every participant.

### II. Swift Package Manager Implementation
The application MUST be implemented as a Swift Package Manager executable application. Its package
manifest, source layout, executable target, and tests MUST use standard SwiftPM conventions, and any
dependency MUST be declared in `Package.swift`. The domain model, algorithm design, and acceptance
criteria MUST use clear Swift types and APIs that support direct review and testing by the team.
This gives the selected platform a single, reproducible build and test path.

### III. Contract-Valid Swift Executable Is Non-Negotiable
Every produced seating plan MUST honor the published JSON output schema, assign exactly 30 distinct
guests to five tables of six, and place Bartek and Nina at `T1`. The SwiftPM executable MUST be
invoked through `./run.sh <input.json> <output.json>`, with the script delegating to the package's
executable target. These invariants define a usable result before any optimization quality is
considered.

### IV. Deterministic, Verifiable Optimization
The solver MUST be deterministic for identical input and configuration, and its outcome MUST be
verifiable against explicit rules derived during specification and clarification. Tests MUST cover
structural validity, mandatory placements, and representative preference or conflict cases before a
candidate implementation is accepted. Determinism and focused checks make behavior reviewable rather
than dependent on one fortunate run.

### V. Simplicity and Explainability
The team MUST select the simplest search or optimization strategy that demonstrably satisfies the
specified rules and quality criteria. New abstractions, heuristics, or dependencies MUST have a
written purpose in the plan and MUST be removable without changing the external contract. The plan
MUST explain how the chosen approach converts relevant guest information into seating decisions, so
reviewers can challenge assumptions and reproduce results.

## Delivery Constraints

The final deliverable MUST be a program, not a manually curated output JSON, and it MUST generate
its result from the supplied input. It MUST read the input path and write the output path passed to
`run.sh`; errors MUST be reported clearly and MUST NOT silently emit an invalid plan. `run.sh` MUST
build or run the SwiftPM executable without requiring Gradle, Kotlin, or another application runtime.
The technical plan MUST document the executable target name and the exact command path used by the
launcher.

## Spec-Driven Workflow

Work MUST proceed through this order: constitution, specify, clarify, plan, checklist, tasks, analyze,
implement, and converge. No application source, solver design, or final seating arrangement MAY be
considered authoritative before the relevant prior artifacts exist and their open ambiguities are
recorded or resolved. Each review MUST check this constitution, the output contract, and the current
Spec Kit artifacts for consistency before advancing to the next phase.

## Governance

This constitution supersedes informal development preferences for this challenge. Amendments MUST be
proposed as a documented change to this file, reviewed by the team, and accompanied by updates to
any affected Spec Kit artifacts before dependent work proceeds. Compliance review is required when
creating or approving specifications, plans, tasks, implementation changes, and the final convergence
assessment.

Versioning uses semantic versioning: MAJOR for incompatible principle removal or redefinition, MINOR
for a new principle or materially expanded governance, and PATCH for clarifications or wording that
does not alter policy. Swift and SwiftPM are mandatory platform requirements; a change to either
requires a MAJOR amendment and updates to affected implementation artifacts.

**Version**: 2.0.0 | **Ratified**: 2026-08-19 | **Last Amended**: 2026-08-19
