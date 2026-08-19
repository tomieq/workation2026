<!--
Sync Impact Report
Version change: unversioned template -> 1.0.0
Modified principles: none; initial constitution created from template
Added sections: Delivery Constraints; Spec-Driven Workflow
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

### II. Language-Neutral, Replaceable Implementation
The specification, domain model, algorithm design, and acceptance criteria MUST remain independent
of Kotlin, Swift, SPM, Gradle, or any other implementation technology until the team records its
implementation choice in the technical plan. Each implementation-facing decision MUST identify the
stable behavior it preserves so either team member can implement or review it. This enables a joint
Swift/Kotlin team to choose tooling without prematurely constraining the solution.

### III. Contract-Valid Seating Is Non-Negotiable
Every produced seating plan MUST honor the published JSON output schema, assign exactly 30 distinct
guests to five tables of six, and place Bartek and Nina at `T1`. The executable delivery boundary MUST
remain `./run.sh <input.json> <output.json>` regardless of the chosen implementation language. These
invariants define a usable result before any optimization quality is considered.

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
`run.sh`; errors MUST be reported clearly and MUST NOT silently emit an invalid plan. The project MAY
choose Kotlin, Swift/SPM, or another agreed runtime only after the technical plan records how the
chosen toolchain supports the required invocation and contract.

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
does not alter policy. The current implementation-language choice belongs in the technical plan, not
in this constitution, unless the team later adopts a permanent language requirement.

**Version**: 1.0.0 | **Ratified**: 2026-08-19 | **Last Amended**: 2026-08-19
