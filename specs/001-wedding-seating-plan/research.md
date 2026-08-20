# Research: Wedding Seating Plan

## Narrative Catalogue Amendment Decisions

## Pre-amendment baseline

- `swift test`: 24 tests passed on 2026-08-19 before catalogue implementation.
- `input/scenario2.json` generated SHA-256 `4fb5d87613082eecfb73ff1df5f5ae680396d0f028756d0c43519b5b0d498e30`.
- The baseline expanded `T1` to seven seats and assigned table sizes `[6, 6, 6, 6, 7]`; this assignment is recorded only for regression comparison and is not the amended target.

## Decision: Represent every input narrative as an auditable catalogue entry

- **Rationale**: A catalogue entry keyed by source type and source ID preserves the exact `description` or `notes` text, records one or more competition categories, and either yields soft policies or a non-actionable reason. An audit can prove coverage of all 31 guest descriptions and five table notes without exposing catalogue data in output JSON.
- **Alternatives considered**: Keeping only aggregate policy arrays loses evidence coverage and makes non-actionable descriptions invisible. Dynamically interpreting text on every run would weaken determinism.

## Decision: Keep only four hard-constraint classes

- **Rationale**: Capacity, complete unique assignment, Bartek and Nina at `T1`, and exact `T1` work composition remain candidate validity rules. Companion, separation, location, grouping, balance, and risk signals from descriptions and notes become soft effects, including Mariusz--Sławek and newcomer--Leszek relationships.
- **Alternatives considered**: Retaining `.companion` or `.separate` in hard-policy validation contradicts FR-009 and can reject structurally valid plans because of narrative wording.

## Decision: Score all six competition categories explicitly

- **Rationale**: Each policy carries one category and a documented within-category strength. A candidate receives six category totals; one evidence entry may contribute once per supported category but never twice within one category. Candidates compare by total policy value, then the vector in the published order (`Grupowanie zespołu`, `Lokalizacja`, `Relacje`, `T1 Production`, `Balans`, `Ryzyko`), then canonical arrangement. This gives every category observable influence without inventing an organizer-only category multiplier.
- **Alternatives considered**: One unlabelled scalar hides category performance. Making the first category lexicographically dominant would treat the user's list as a priority order without evidence. Category-specific external weights would invent private scoring rules.

## Decision: Use bounded deterministic pair-swap improvement

- **Rationale**: Existing greedy placement cannot reconsider guests assigned before their preferred companion or risk counterpart. After each complete candidate is built, evaluate guest swaps that preserve hard invariants, take the greatest objective improvement with canonical tie-breaking, and repeat until no improving swap exists. With 31 guests and five tables this bounded neighborhood remains comfortably within the 10-second goal.
- **Alternatives considered**: Leaving construction greedy misses obvious relationship improvements. Exhaustive assignment search is unnecessary and too large. A new optimization dependency adds build and review cost.

## Decision: Correct unsupported or incomplete existing inferences

- **Rationale**: Add strong soft Bartek/`T1` affinity for `kuba_g` and `michal_z`; classify Piotr's uncertain dance report as non-actionable; remove the false Maciek/Jakub food affinity; treat baldness, tattoos, Toyota ownership, and hair surgery as non-actionable unless another explicit seating implication exists. Retain evidence-backed dance, terrace, quiet, celebration-energy, drink, debate, disruption, group, and named relationship effects.
- **Alternatives considered**: Treating every colorful detail as actionable invents intent. Ignoring all personality and risk wording fails the competition categories and the amended specification.

## Decision: Validate assistant policies as soft, categorized additions only

- **Rationale**: Assistant candidates must identify a known evidence source, quote exact evidence, use known IDs/tables and a supported category/effect, and avoid a duplicate catalogue identity. They cannot propose mandatory, companion-hard, or separation-hard behavior.
- **Alternatives considered**: Allowing the model to alter hard constraints violates determinism and change control. Disabling the assistant entirely is unnecessary because strict validation preserves the authoritative built-in result.

## Scenario 2 Amendment Decisions

## Decision: Decode `extraSeatPolicy` as input-owned capacity authorization

- **Rationale**: `input/scenario2.json` provides five base six-seat tables and authorizes one extra chair at any table. Decoding and validating that policy preserves the venue layout while allowing exactly one seven-guest output table.
- **Alternatives considered**: Editing one input table to capacity seven loses the distinction between the base room and the solver's decision. Ignoring the field makes the 31-guest scenario impossible to validate.

## Decision: Select the seventh-chair table by deterministic candidate comparison

- **Rationale**: Evaluate a complete candidate for every eligible seven-seat table with the same hard constraints and ordered soft-policy objective; choose the highest-scoring valid candidate. Equal outcomes use the existing canonical sorted table/guest vector.
- **Alternatives considered**: Always expanding a fixed table contradicts the clarification. First-available placement makes capacity an incidental allocation artifact.

## Decision: Make the Scenario 2 `T1` composition a hard placement constraint

- **Rationale**: `T1` must contain Bartek, Nina, and exactly two other `work` guests; Bartek is excluded from that colleague count. Reserve and validate this composition before soft preferences.
- **Alternatives considered**: A high score for work colleagues cannot prove the exact count. The prior one-colleague preference contradicts the approved change.

## Decision: Replace retired policies with only evidence-backed newcomer policies

- **Rationale**: Add soft avoidance for `leszek` with `kuba_g` and `michal_z`, and a newcomer work-cluster penalty at four or more work-group guests. Treat Michał S. only as an active work-group guest; do not derive a Bald Club policy.
- **Alternatives considered**: Retaining departed-guest policies obscures the active rules. Interpreting Bald Club history as a preference invents organizer intent.

## Decision: Extend the deterministic planner without a new optimizer dependency

- **Rationale**: The fixed five-table scope permits deterministic construction plus bounded, repeatable assignment improvement for every seat-table candidate. Compare completed candidates by the documented objective and canonical vector.
- **Alternatives considered**: An external solver adds unrequested build and review surface. Brute-forcing every 31-guest assignment cannot meet the 10-second target.

## Decision: Use Swift 6.2, SwiftPM, and SwiftAgent

- **Rationale**: The repository already declares Swift 6.2 and an executable target. SwiftAgent publishes the `SwiftAgent` library product, supports OpenAI-compatible and Ollama providers, and can expose application-owned tools to an agent session.
- **Alternatives considered**: A separate service or a custom HTTP client would add an unrequested deployment boundary and would not satisfy the requested SwiftAgent architecture.

## Decision: Make the deterministic solver the main engine and SwiftAgent a policy-extraction sidecar

- **Rationale**: SwiftAgent supports chat and tool calling, but its README does not promise deterministic or schema-enforced model output. Use it only to propose structured policy candidates from free-form `notes` and `description` fields. A deterministic validator accepts candidates only when each guest/table reference exists, the rule class is allowed, and an exact supporting text span is present. The deterministic solver then produces and validates the canonical output itself.
- **Alternatives considered**: Parsing free-form model text directly into a seating plan is rejected because it cannot guarantee the output schema, complete assignment, or repeatability. Excluding SwiftAgent entirely is rejected because AI-assisted narrative transformation is a requested capability.

## Decision: Configure providers from environment, never from input

- **Rationale**: SwiftAgent requires an `AgentConfig` with a provider, model URL, optional bearer token, and selected model. Use environment variables such as `SWIFT_AGENT_PROVIDER`, `SWIFT_AGENT_MODEL_URL`, `SWIFT_AGENT_MODEL`, and optionally `SWIFT_AGENT_AUTH_TOKEN`. If they are absent, skip the optional extraction pass and use the deterministic built-in catalogue; do not fail a valid seating invocation. Keep those values out of plan output and diagnostics except for non-secret provider/model identifiers.
- **Alternatives considered**: Hard-coded endpoint, model, or credential values are rejected because they make the executable non-portable and leak deployment configuration.

## Decision: Define policy only from public, explicit evidence

- **Rationale**: The policy extractor maps explicit named references to soft relationship effects, dance wording to `T2`, smoke/terrace wording to `T4`, quiet or moderation wording to `T5`, and group membership to `Grupowanie zespołu`. Food/drink, activity, personality, and risk wording is used only where the exact evidence supports an effect. Workation-team lists remain excluded.
- **Alternatives considered**: Inferring personality compatibility from jokes, names, occupations, or unstated social assumptions is rejected by the constitution and specification.

## Decision: Search by assignments and canonicalize equal scores

- **Rationale**: The fixed 31-guest, five-table scope allows a bounded deterministic search over the five seventh-chair candidates and the eligible `T1` work-colleague pairs, followed by hard-constraint pruning and repeatable improvements. Table IDs and guest IDs are sorted before comparing candidate vectors. The best objective score wins; exact score ties use the lexicographically smallest vector ordered by table ID then guest ID.
- **Alternatives considered**: Randomized shuffling and first-feasible allocation are rejected because both violate the repeatability and tie-break requirements. A general database-backed optimizer is unnecessary at this fixed scope.

## Decision: Publish output atomically after complete validation

- **Rationale**: Encode the fully validated output to a sibling temporary file and replace the requested destination only after a successful write. On decode, validation, planning, agent, or write error, remove only the temporary file and preserve an existing destination.
- **Alternatives considered**: Streaming directly to the destination can leave malformed or partial output and violates FR-011.

## Previous supplied-scenario outcome (requires regeneration after implementation)

- The previous Scenario 2 run selected `T1` for the seventh chair. Its exact assignments are no longer normative because the complete catalogue adds Bartek affinities, table-note coverage, and corrected food behavior.
- The amended implementation must regenerate and document the selected extra-seat table and category outcomes after focused tests pass.
- The Scenario 2 deterministic run must select one seventh-chair table while seating Bartek, Nina, and exactly two other work-group guests at `T1`; the chosen table is part of the scored candidate comparison.
- It prioritizes `chrzestna_ania` and `swiadek_kuba` at `T1` for ceremonial support over their ordinary dance-floor preference, keeps `tetiana` at `T2`, places `zosia` at `T4` for smoke/terrace access, and seats `jacek` and `pawel` at quiet `T5` for low-energy or low-toast signals.
- It treats Leszek with either `kuba_g` or `michal_z` as a soft avoidance and penalizes seating either newcomer with four or more work-group guests. The food-related `maciek`/`jakub` affinity remains soft because the brief gives no food-service location.
- It also caps a table at three explicitly high-intensity guests, dispersing direct-feedback, plate-throwing, rapid-topic, drink, QA-escalation, debate, and wildcard signals rather than allowing a single incident-heavy table.
- No lower-priority group preference is treated as a hard rule. Any group distribution needed to preserve table capacity or a higher priority preference is therefore an expected trade-off, not a failure.

## Brief-Derived Weight Map

| Evidence in the public brief | Policy | Weight / priority | Reasoning |
|---|---|---:|---|
| Mariusz explicitly likes Sławek M. | Soft relationship affinity: `mariusz` + `slawek_m` | `Relacje` | Narrative relationships are soft under FR-009. |
| Approved Scenario 2 requirement | Bartek, Nina, and exactly two other `work` guests at `T1` | Hard mandatory composition | The approved amendment defines an exact colleague count, not a soft `T1` preference. |
| Chrzestna Ania and Świadek Kuba are the named godmother and witness | Prefer `T1` | 20000 | Ceremonial support at the couple's table outranks ordinary location preferences. |
| Ania, Świadek Kuba, and Tetiana are explicitly dance-oriented | Prefer `T2` | 300 | The strongest soft location cue: `T2` is beside the dance floor. |
| Ania, Gosia, Kacper, Świadek Kuba, and Tetiana explicitly describe a lively, performance, or all-night celebration style | Shared table affinity | 100 per matching tablemate | Keeps compatible active participants together without forcing placement. |
| Zosia explicitly seeks smoke breaks | Prefer `T4` | 300 | The strongest soft location cue: `T4` is beside the exit/terrace. |
| Jacek, Leszek, and Paweł signal low energy, low-toast, or moderation needs | Prefer `T5` | 200 | A strong quiet-area preference, but below hard relationship rules. |
| Leszek's documented objections to Michał Z. and Jakub G. | Avoid `leszek` + `michal_z`; avoid `leszek` + `kuba_g` | Soft avoidance | The Scenario 2 narrative describes avoidable awkwardness, not a hard separation. |
| Michał Z. and Jakub G. attend for social company rather than a work offsite | Penalize either newcomer at a table with four or more `work` guests | Soft avoidance | The clarified threshold discourages a work-dominated table without overriding hard constraints. |
| Ada, Agnieszka, Zdzisiek, Klara, Przemek, Tomek, Sławek M., and Kuba S. each have an explicit high-impact behavior | Penalize a fourth such guest at the same table | Soft avoidance | Spreads the public incident signals without creating a hard separation or inventing pair-specific conflict. |
| Klara, Przemek, and Tomek explicitly mention alcoholic drinks, spirits, or champagne | Shared table affinity | 75 per matching tablemate | A moderate shared drink interest; no bar location is supplied. |
| Maciek eats heavily while Jakub nearly does not eat | No pair affinity; separate balance signals | `Balans` | A contrast is not evidence of compatibility. |
| Supplied `group` field | Shared table affinity | 1 per matching tablemate | The final tie-breaking social preference only. |

Hard structural and `T1` composition rules take precedence over every row above. The normative 36-entry mapping is in [spec.md](spec.md); this table records representative scoring decisions rather than duplicating it. Michał S.'s hair-club history and Piotr's unconfirmed dancing remain unscored. The workation-team lists remain excluded.