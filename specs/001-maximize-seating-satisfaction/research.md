# Phase 0 Research — Maximize Seating Satisfaction

## Decision 1: Kotlin CLI stack and build strategy

**Decision**: Implement as Kotlin/JVM 21 CLI with JSON handled by Kotlinx Serialization, tested with JUnit 5 + contract validation, and keep runtime contract `./run.sh <input.json> <output.json>`.

**Rationale**:
- Matches repository build configuration (`kotlin("jvm")`, toolchain 21).
- Keeps deterministic and type-safe parsing/serialization for canonical guest IDs.
- Supports constitution-mandated boundary separation (CLI adapter vs domain logic).

**Alternatives considered**:
- Jackson/Gson: workable, but less idiomatic for strict Kotlin data classes here.
- External service-based parsing/scoring: rejected (non-deterministic, violates challenge constraints).

---

## Decision 2: Optimization algorithm for this feature

**Decision**: Use a deterministic constraint-first search strategy:
1. Validate feasibility and hard constraints.
2. Pre-assign mandatory placements.
3. Enumerate feasible cohort/table split candidates.
4. Score candidates with weighted Nina-first objective.
5. Break ties deterministically by canonical guest IDs/table order.

**Rationale**:
- Guest count is small (30 guests, 5 tables), so constrained enumeration is feasible.
- Gives transparent, testable rule behavior and explicit failure when infeasible.
- Avoids stochastic behavior and “different answer per run”.

**Alternatives considered**:
- CP-SAT/MILP: powerful but heavier dependency/runtime setup for this repository.
- Pure greedy one-pass assignment: too brittle for interacting hard constraints.

---

## Decision 3: Narrative signal extraction from Polish descriptions

**Decision**: Use deterministic rule-based extraction (keyword/phrase lexicon + precedence rules + explicit neutral fallback), with no runtime AI calls.

**Rationale**:
- Spec requires reproducible interpretation for identical input text.
- Supports hard/soft distinction and explicit scoring explainability.
- Enables testing of signal interpretation and tie-break determinism.

**Alternatives considered**:
- LLM inference at runtime: rejected (non-deterministic and external dependency).
- Fully manual hardcoded seating output: rejected (not a solver, not generalizable).

---

## Decision 4: Precedence model for rule conflicts

**Decision**: Enforce this deterministic precedence:
1. Hard constraints/invariants
2. Explicit pair-level conflict
3. Explicit pair-level affinity/shared history
4. Individual behavior/location affinity
5. Neutral fallback (zero impact)

**Rationale**:
- Directly matches FR-028 and related acceptance criteria.
- Prevents decorative narrative details from dominating outcomes.
- Keeps “no hidden rules” principle by making precedence explicit.

**Alternatives considered**:
- Flat score-only model: rejected (hard constraints can be accidentally violated or weakened).
- Ad-hoc precedence inside code: rejected (untraceable and hard to review).

---

## Decision 5: Validation strategy

**Decision**: Integration-first validation with contract checks:
- Integration tests for full scenario validity and deterministic repeatability.
- Contract tests against `contract/output-schema.json`.
- Focused unit tests for constraints/scoring/signal extraction.

**Rationale**:
- Aligns with constitution testing principle and user-visible behavior focus.
- Ensures schema-valid JSON is also business-rule valid.
- Makes downstream `speckit.tasks` actionable by mapping test scopes to implementation seams.

**Alternatives considered**:
- Schema-only validation: rejected (insufficient for business constraints).
- Unit-only validation: rejected (weak confidence in assembled behavior).
