# Research: Wedding Seating Plan

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

- **Rationale**: The policy extractor maps explicit named guest references to hard companion/separation candidates, dance wording to `T2`, smoke/terrace wording to `T4`, and group membership to the final soft tier. It also treats an explicit shared drinking or food signal as a lower-priority table-mate affinity, rather than inventing a bar or buffet location. Descriptions that explicitly conserve energy or avoid toast competition prefer quiet `T5`. The brief establishes `T2` by the dance floor, `T4` by the exit/terrace, and `T5` as quiet. Workation-team lists are categorically excluded.
- **Alternatives considered**: Inferring personality compatibility from jokes, names, occupations, or unstated social assumptions is rejected by the constitution and specification.

## Decision: Search by assignments and canonicalize equal scores

- **Rationale**: The fixed 30-guest, five-table scope allows a bounded backtracking/branch-and-bound search with mandatory placements and hard relationship pruning. Table IDs and guest IDs are sorted before comparing candidate vectors. The best objective score wins; exact score ties use the lexicographically smallest vector ordered by table ID then guest ID.
- **Alternatives considered**: Randomized shuffling and first-feasible allocation are rejected because both violate the repeatability and tie-break requirements. A general database-backed optimizer is unnecessary at this fixed scope.

## Decision: Publish output atomically after complete validation

- **Rationale**: Encode the fully validated output to a sibling temporary file and replace the requested destination only after a successful write. On decode, validation, planning, agent, or write error, remove only the temporary file and preserve an existing destination.
- **Alternatives considered**: Streaming directly to the destination can leave malformed or partial output and violates FR-011.

## Verified supplied-scenario policy outcome

- The deterministic run seats `chrzestna_ania`, `swiadek_kuba`, and `tetiana` at `T2` for the explicit dance-floor preference, and `zosia` at `T4` for the explicit smoke/terrace preference.
- It keeps `jacek` and `pawel` at quiet `T5` for explicit energy-conservation and low-toast signals, and favors the alcohol-related table-mate affinity among `klara`, `przemek`, and `tomek`. The food-related `maciek`/`jakub` affinity remains soft because the brief gives no food-service location.
- No lower-priority group preference is treated as a hard rule. Any group distribution needed to preserve table capacity or a higher priority preference is therefore an expected trade-off, not a failure.