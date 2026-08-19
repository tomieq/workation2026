# Quickstart Validation Guide — Maximize Seating Satisfaction

## Prerequisites

- Java 21 available
- Gradle wrapper executable (`./gradlew`)
- Repository root as working directory

## Build

```bash
./gradlew clean compile
```

## Run

```bash
./run.sh input/scenario1.json output/scenario1-result.json
```

## Validate Basic Output Shape

Check generated file exists and is valid JSON structure per contract:
- Contract reference: `contract/output-schema.json`
- Feature contract: `specs/001-maximize-seating-satisfaction/contracts/seating-cli-contract.md`

## Validate Business Rules (must all pass)

1. Exactly 5 tables in output.
2. Exactly 6 guests per table.
3. All 30 canonical guest IDs present exactly once.
4. `T1` contains `bartek`, `nina`, `mama_ela`, `babcia_ela`.
5. `maciek` and `jakub` at different tables.
6. No politician at `T1`; `slawek_m` separate from `donald_t` and `jaroslaw_k`; `donald_t` and `jaroslaw_k` share non-`T1` table.
7. Corporate-heavy cohort occupies exactly two full tables with 5 corporate + 1 catalyst each (`swiadek_kuba` and `kacper` split).

## Determinism Check

Run twice with same input and compare outputs byte-for-byte (or semantic equality after stable sorting). Results must match.

## References

- Plan: `specs/001-maximize-seating-satisfaction/plan.md`
- Research: `specs/001-maximize-seating-satisfaction/research.md`
- Data model: `specs/001-maximize-seating-satisfaction/data-model.md`
