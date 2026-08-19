# Feature Specification: Maximize Seating Satisfaction

**Feature Branch**: `001-maximize-seating-satisfaction`

**Created**: 2026-08-19

**Status**: Draft

**Input**: User description: "Create/update the feature specification for this repository using Spec Kit workflow. Generate seating plan for 30 guests across 5 tables of 6, maximizing satisfaction of Bartek and Nina."

## Clarifications

### Session 2026-08-19

- Q: Which guest identity format is authoritative in output guest lists? → A: Use canonical guest IDs from input.
- Q: Which source defines table capacity when artifacts conflict? → A: Textual rule is authoritative: 5 tables × 6 seats.
- Q: Which satisfaction policy is authoritative for optimization? → A: Use a weighted score with Nina priority.
- Q: Which table is the primary dance-priority localization? → A: T2 is the primary dance table ("near dancefloor").
- Q: How should explicit outside/smoking/external-networking signals be localized? → A: Treat T4 as hard-priority localization for those guests.
- Q: Which guests form the scenario-specific corporate-heavy cohort? → A: All 10 input guests with `group: work`, excluding Bartek, plus `swiadek_kuba` and `kacper`; both added guests remain classified as `friends`.
- Q: Which source is authoritative when BRIEF and input JSON conflict on scoring details? → A: Input JSON is the source of truth.
- Q: How should hard-localization overflow be handled when demand exceeds capacity? → A: Prioritize by textual-signal strength, then return overflow guests to soft optimization with canonical guest ID as the final tie-break.
- Q: How should narrative details influence optimization quality? → A: Treat suspiciously specific details as potentially meaningful placement signals (not mere story text), apply deterministic signal-precedence rules to separate meaningful cues from decorative noise, and optimize to reduce likely manual post-dinner seating hotfixes.
- Q: How must the corporate-heavy cohort be seated? → A: Fill exactly two complete tables, each with five corporate guests and one social catalyst: one with `swiadek_kuba` and the other with `kacper`.
- Q: Why are `swiadek_kuba` and `kacper` the social catalysts? → A: `swiadek_kuba` has explicit dance energy and `kacper` has an explicit music/performance signal; their inclusion is a stakeholder seating decision, not a change of source classification.
- Q: Which emergent-table anti-patterns must be treated as explicit bugs? → A: Treat political-panel clustering, unsupported handling of explicit sleep risk, and violations of the confirmed corporate-heavy cohort composition as explicit negative outcomes.
- Q: How should Mariusz and Sławek M. be seated despite their explicit affinity? → A: Seat them at different tables as a user-confirmed political-escalation precaution.
- Q: Which family members are mandatory at `T1`? → A: Mama Ela and Babcia Ela MUST sit with Bartek and Nina; Oliwia and Chrzestna Ania remain soft family preferences.
- Q: Which food-related pair must be separated? → A: Maciek and Jakub MUST sit at different tables; the source signal concerns Jakub, not either guest named Kuba.
- Q: How should Sławek M., Donald T., and Jarosław K. be seated without placing a politician at `T1`? → A: No politician may sit at `T1`; Sławek M. MUST sit separately, and Donald T. with Jarosław K. are the permitted pair that shares a non-`T1` table under the current scenario constraints.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate Valid Full Seating Plan (Priority: P1)

As a wedding organizer, I want the system to assign all guests to tables in one run so that a complete and valid seating plan is always produced for verification.

**Why this priority**: Without a fully valid plan, no satisfaction optimization matters.

**Independent Test**: Run the CLI with the provided scenario input and verify that exactly 30 unique guests are assigned once across 5 tables, with 6 guests per table, and Bartek, Nina, Mama Ela, and Babcia Ela seated at T1.

**Acceptance Scenarios**:

1. **Given** a valid guest list of 30 people and 5 tables of capacity 6, **When** the seating plan is generated, **Then** every guest appears exactly once and every table has exactly 6 guests.
2. **Given** the same input, **When** the seating plan is generated, **Then** Bartek, Nina, Mama Ela, and Babcia Ela are assigned to table `T1`.

---

### User Story 2 - Prefer Placements That Improve Couple Satisfaction (Priority: P2)

As Bartek and Nina, we want guest placements that favor compatible interactions and reduce likely social friction so that we are more satisfied with the final arrangement.

**Why this priority**: The challenge objective is not only correctness, but maximizing satisfaction of the couple.

**Independent Test**: Evaluate the generated plan and deterministic valid alternatives that swap guests implicated in explicit signals; the selected plan must satisfy all hard constraints and must not score lower than those alternatives under the documented policy.

**Acceptance Scenarios**:

1. **Given** guest descriptions containing social compatibility hints, **When** a plan is generated, **Then** the output reflects a deliberate optimization toward the couple's satisfaction objective rather than arbitrary placement.
2. **Given** conflicting social preferences, **When** a plan is generated, **Then** hard seating constraints remain satisfied while best-effort tradeoffs are applied for soft preferences.
3. **Given** table location contexts (e.g., near dancefloor, calmer zone), **When** a plan is generated, **Then** guests with matching behavioral preferences are preferentially assigned to compatible table locations.
4. **Given** narrative descriptions that contain jokes, anecdotes, and specific interpersonal context, **When** a plan is generated, **Then** concrete social signals are used for optimization and purely decorative details do not dominate decisions.
5. **Given** more guests with explicit outside/smoking/external-networking signals than fit at `T4`, **When** a plan is generated, **Then** assignments are prioritized by textual-signal strength and overflow returns to soft optimization with canonical guest ID as the final tie-break.
6. **Given** the provided scenario, **When** a plan is generated, **Then** the 12-member corporate-heavy cohort fills exactly two tables of six, each containing five corporate guests and exactly one designated social catalyst, with `swiadek_kuba` and `kacper` at different cohort tables.
7. **Given** that `T2` is the primary dance table, **When** the two cohort tables are selected, **Then** optimization may select the second cohort table while favoring `T2` for the strongest dance signals.
8. **Given** the provided scenario, **When** a plan is generated, **Then** Maciek and Jakub are at different cohort tables, no politician is at `T1`, Sławek M. is separate from the other politicians, and Donald T. and Jarosław K. share a non-`T1` table.

---

### User Story 3 - Handle Source Ambiguities Transparently (Priority: P3)

As a challenge reviewer, I want ambiguities from source artifacts to be explicitly documented so that evaluation decisions are consistent and traceable.

**Why this priority**: Source materials contain inconsistencies and under-specified rules that can change interpretation of validity and quality.

**Independent Test**: Review the specification and confirm ambiguity decisions are explicitly documented for layout interpretation, guest identity format, and satisfaction policy so evaluation remains consistent.

**Acceptance Scenarios**:

1. **Given** potentially conflicting source artifacts, **When** requirements are defined, **Then** the specification records explicit, testable decision rules before planning.

---

### Edge Cases

- Input includes a different guest count than total table capacity.
- A guest appears multiple times in input or is missing required identity fields.
- Output contract permits structurally valid JSON that still violates business rules (duplicate guests, wrong table sizes, missing bride/groom placement).
- Ambiguous same-first-name guests (e.g., "Świadek Kuba" and "Kuba S. „Gangus”") can be confused if non-unique labels are used.
- Room diagram appears to visually imply fewer chairs at some tables while textual rules require 6 seats at each table.
- Guest descriptions contain Polish idioms, sarcasm, or culturally specific phrasing that can change social-signal interpretation.
- Some guests have sparse or neutral descriptions, requiring a defined neutral-scoring fallback.
- A guest has mixed signals (e.g., likes dancing but also prefers calm), requiring deterministic tradeoff handling.
- Table-level location affinity signals conflict with interpersonal compatibility signals.
- A story detail can be interpreted either as a meaningful compatibility/conflict hint or as humor, requiring consistent relevance filtering.
- A pair-level signal (shared history/conflict/topic risk between two people) conflicts with each person's individual location preference.
- More guests qualify for hard-priority `T4` localization than available seats at `T4`.
- The two complete corporate-heavy cohort tables must preserve a five-corporate-plus-one-catalyst composition even when other affinity signals favor a different arrangement.
- BRIEF narrative guidance conflicts with scoring-detail fields provided in input JSON.
- Multiple politically polarizing guests are clustered at one table, causing sustained political escalation dynamics.
- A guest with explicit sleep-risk evidence is placed without considering whether the table composition is likely to sustain engagement.
- Selecting the second corporate-heavy cohort table must remain an optimization decision; no table ID other than dance-priority `T2` is implied by the confirmed rules.
- Mariusz and Sławek M. have an explicit affinity, but must be separated because the stakeholder-confirmed political-escalation precaution overrides that affinity.
- The two cohort tables must place Maciek and Jakub separately despite their shared `work` classification.
- The two remaining seats at `T1` must be filled without seating any politician there.
- The table availability left by two complete cohort tables forces two politicians to share a non-`T1` table; the confirmed pair is Donald T. and Jarosław K.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST accept an input scenario containing table definitions and guest definitions, then produce exactly one seating plan JSON output per execution.
- **FR-002**: The system MUST assign each input guest to exactly one table in the output.
- **FR-003**: The system MUST produce exactly five tables in output and assign exactly six guests to each table.
- **FR-004**: The system MUST always place Bartek, Nina, Mama Ela (`mama_ela`), and Babcia Ela (`babcia_ela`) at table `T1`.
- **FR-005**: The system MUST reject or clearly fail execution when a valid assignment satisfying hard constraints cannot be formed from input data.
- **FR-006**: The system MUST optimize placement to maximize couple satisfaction using social signals from guest descriptions while preserving all hard constraints.
- **FR-007**: The system MUST enforce business constraints beyond the minimal JSON schema, including uniqueness of all guests, complete coverage of all guests, and mandatory placement constraints.
- **FR-008**: The system MUST include a deterministic tie-break policy so repeated runs with identical input produce the same seating plan.
- **FR-009**: The output `guests` entries MUST use canonical guest IDs from the input scenario (exact input `id` values), not display names.
- **FR-010**: Table-capacity interpretation MUST follow the textual rule as authoritative: exactly 5 tables with exactly 6 guests each (30 seats total), regardless of room-diagram depiction.
- **FR-011**: Satisfaction maximization MUST use a weighted combined score for Bartek and Nina where Nina's score has strictly higher weight than Bartek's.
- **FR-012**: The system MUST interpret Polish-language guest descriptions into normalized social signals used by the satisfaction policy, using the input description as authoritative and BRIEF details only as non-conflicting supplementary evidence.
- **FR-013**: The social-signal interpretation used for scoring MUST be consistent and reproducible for identical text inputs, including handling of Polish diacritics and common colloquial forms.
- **FR-014**: When a guest description cannot be confidently mapped to a specific preference or conflict signal, the system MUST apply an explicit neutral-impact fallback instead of implicit omission.
- **FR-015**: The satisfaction policy MUST incorporate table-location affinity signals from table context (for example, dancefloor-adjacent vs calmer areas) as soft optimization factors.
- **FR-016**: The system MUST prefer seating dance-oriented guests at dance-friendly table locations and calm-oriented guests at calmer table locations when this does not violate hard constraints.
- **FR-017**: When location affinity and other soft preferences conflict, the system MUST apply explicit deterministic priority rules within the weighted satisfaction policy.
- **FR-018**: The satisfaction policy MUST treat guest narratives as semantically meaningful input and use directly supported evidence of interpersonal history, conversation-topic affinity, and likely conflict.
- **FR-019**: The system MUST distinguish clear placement-relevant evidence from decorative humor; a detail MUST NOT affect scoring unless its relevance to behavior, location, compatibility, or conflict can be stated explicitly.
- **FR-020**: The scoring model MUST support pair-level signals when source text explicitly identifies both guests or clearly describes a relationship between identifiable guests.
- **FR-021**: The system MUST apply deterministic precedence when pair-level, individual-level, and table-location signals disagree, consistent with the Nina-priority weighted objective.
- **FR-022**: The system MUST treat table `T2` as the primary dance-priority table when applying dance-oriented location affinity signals.
- **FR-023**: Guests with explicit outside/smoking/external-networking preference signals MUST receive hard-priority localization to table `T4`, subject to table capacity.
- **FR-024**: For the provided scenario, the corporate-heavy cohort MUST consist of all 10 input guests whose `group` is `work`, excluding Bartek, plus `swiadek_kuba` and `kacper`.
- **FR-025**: Mariusz (`mariusz`) and Sławek M. (`slawek_m`) MUST be seated at different tables as a stakeholder-confirmed political-escalation precaution, despite their explicit affinity.
- **FR-026**: If hard-priority localization demand exceeds capacity, the system MUST rank affected guests by strength and explicitness of the relevant input signal; unplaced overflow MUST revert to soft optimization, with canonical guest ID as the final deterministic tie-break.
- **FR-027**: If BRIEF text and input JSON conflict, input JSON MUST take precedence; BRIEF text MAY supplement an input description only when it does not contradict it.
- **FR-028**: Narrative-signal interpretation MUST use deterministic relevance precedence: hard constraints first, then explicit pair-level conflict, explicit pair-level affinity/shared history, explicit individual location or behavior signals, and finally neutral treatment for unsupported or decorative details.
- **FR-029**: A suspiciously specific narrative detail MUST be evaluated as a candidate signal, but MUST remain neutral unless a clear placement-relevant interpretation is documented under FR-019.
- **FR-030**: When hard constraints permit, explicitly identified high-risk pairs MUST be seated separately.
- **FR-031**: For the provided scenario, Sławek M. (`slawek_m`) MUST be seated separately from Donald T. (`donald_t`) and Jarosław K. (`jaroslaw_k`), while Donald T. and Jarosław K. MUST share a non-`T1` table.
- **FR-032**: Explicit sleep-risk evidence MUST contribute a negative score to placements whose table composition lacks any supported engagement or compatibility signal for that guest; it MUST NOT be generalized to guests without such evidence.
- **FR-033**: The 12 members of the scenario-specific corporate-heavy cohort MUST fill exactly two complete tables of six; each cohort table MUST contain exactly five corporate guests and exactly one social catalyst, with `swiadek_kuba` at one cohort table and `kacper` at the other.
- **FR-034**: `swiadek_kuba` MUST remain classified as `friends` and serve as the dance-energy social catalyst, while `kacper` MUST remain classified as `friends` and serve as the music/performance social catalyst. `T2` remains the primary dance table and SHOULD host the strongest dance signals, but the second cohort table MUST be selected through optimization rather than fixed to an unsupported table ID.
- **FR-035**: Maciek (`maciek`) and Jakub (`jakub`) MUST be seated at different tables.
- **FR-036**: Sławek M., Donald T., and Jarosław K. MUST NOT be seated at `T1`.

### Scenario-Specific Soft Preferences

- **SP-001**: Oliwia (`oliwia`) and Chrzestna Ania (`chrzestna_ania`) SHOULD receive a positive affinity for `T1` because of family proximity, without displacing mandatory `T1` guests.
- **SP-002**: Mama Ela and Oliwia SHOULD receive a positive pair affinity based on their explicit shared dress/fashion topic.
- **SP-003**: Świadek Kuba and Tetiana (`tetiana`) SHOULD receive the strongest positive `T2` dance-location affinity.
- **SP-004**: Chrzestna Ania and Gosia (`gosia`) SHOULD receive a strong positive `T2` party-location affinity and a smaller positive `T3` fallback affinity when `T2` is unavailable.
- **SP-005**: Piotr (`piotr`) SHOULD receive a positive `T5` affinity and MUST NOT receive a positive dance affinity for `T2`.
- **SP-006**: Jacek (`jacek`) SHOULD receive a positive affinity for active, engaging company and `T3`, and MUST NOT receive a positive calm-location affinity for `T5`.
- **SP-007**: Kacper SHOULD receive a positive active/music affinity, including `T3`, subject to the corporate-heavy cohort constraints.
- **SP-008**: Przemek (`przemek`) and Leszek (`leszek`) SHOULD receive a moderate positive pair affinity based on their explicit Toyota ownership.
- **SP-009**: Mariusz and Przemek SHOULD receive a negative pair affinity based on explicit teasing and SHOULD be separated when the cohort split permits.
- **SP-010**: Zdzisiek (`zdzisiek`) SHOULD receive a negative pair affinity with each politician because his rapid topic changes explicitly include monetary policy and can amplify political discussion.
- **SP-011**: Przemek, Mariusz, Leszek, and Jakub SHOULD be distributed across the two cohort tables rather than clustered, based on explicit toast/alcohol signals.
- **SP-012**: Paweł (`pawel`), Tomek (`tomek`), and Maciek SHOULD provide balancing lower-alcohol or food-oriented signals across the two cohort tables.
- **SP-013**: Amelka (`amelka`) SHOULD receive a positive affinity for a calm, supportive table composition because excessive choice creates decision overload.
- **SP-014**: Agnieszka (`agnieszka`), Ada (`ada`), and Kuba S. (`kuba_s`) SHOULD receive a penalty when all three are clustered at one table; their descriptions suggest feedback, plate-throwing, and wildcard risk, but do not justify hard separation.
- **SP-015**: Decorative baldness/reflection details for Tomek, Maciek, and Michał (`michal`), unidentified SRE relationships, Klara's (`klara`) drink goal, and Jarosław K.'s generic preference for attentive listeners MUST remain neutral unless additional authoritative evidence identifies a placement-relevant relationship.

### Key Entities *(include if feature involves data)*

- **Guest**: A participant with unique identity, display name, group/category, and narrative social context used for compatibility inference.
- **Table**: A seating unit with table identifier, label, location context, and fixed capacity.
- **Table Location Profile**: Interpreted characteristics of each table location (for example, dance-adjacent, central traffic, quiet/exit-adjacent) used for both soft affinity scoring and hard-priority localization rules where explicitly required.
- **Seating Assignment**: Mapping of each guest identity to one table, constrained by total coverage, uniqueness, and mandatory placements.
- **Satisfaction Policy**: Set of interpretable rules used to evaluate quality of a seating assignment from the perspective of Bartek and Nina.
- **Narrative Signal**: Interpreted high-relevance clue extracted from a guest description, including individual traits, pairwise affinity/conflict, and topic-risk indicators.
- **Corporate Guest**: For the provided scenario, one of the 10 input guests whose `group` is `work`, excluding Bartek.
- **Corporate-Heavy Cohort**: The scenario-specific set of the 10 corporate guests plus the two stakeholder-selected social catalysts, `swiadek_kuba` and `kacper`.
- **Social Catalyst**: A non-corporate cohort member selected for a supported social signal; `swiadek_kuba` supplies dance energy and `kacper` supplies music/performance energy without changing either guest's `friends` classification.
- **Validation Result**: Outcome of checking that produced output satisfies structural schema and business-level hard constraints.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of generated plans for valid scenarios contain exactly 5 tables with exactly 6 guests each.
- **SC-002**: 100% of generated plans place Bartek, Nina, `mama_ela`, and `babcia_ela` at table `T1`.
- **SC-003**: 100% of generated plans include every input guest exactly once and no unknown guests.
- **SC-004**: The satisfaction policy publishes a deterministic scoring breakdown in project documentation, including Nina's higher weighting and the contribution of each supported signal category.
- **SC-005**: For repeated executions with identical inputs, 100% of runs produce the same seating plan.
- **SC-006**: In 100% of runs, each guest description contributes either at least one interpreted social signal or an explicit neutral-impact fallback used in scoring.
- **SC-007**: In all acceptance scenarios with explicit dance or calm signals, moving a guest from a matching location to a non-matching location cannot improve that guest's location-affinity score.
- **SC-008**: In all acceptance scenarios with an explicit pair-level affinity or conflict, the documented pair signal changes the score in the stated direction.
- **SC-009**: In scenarios where `T4` hard-priority demand exceeds capacity, 100% of runs resolve overflow with the same deterministic ranking-and-fallback outcome for identical input.
- **SC-010**: In 100% of valid plans for the provided scenario, all 12 corporate-heavy cohort members occupy exactly two tables, with six cohort members at each table.
- **SC-011**: In 100% of valid plans for the provided scenario, `mariusz` and `slawek_m` are seated at different tables.
- **SC-012**: In benchmark scenarios with tagged narrative cues, 100% of runs apply the same cue-priority ordering (pair-level conflict/shared-history cues > individual behavior-style cues > decorative humor/noise) for identical input.
- **SC-013**: In 100% of feasible acceptance scenarios containing explicitly identified high-risk pairs, those pairs are seated at different tables.
- **SC-014**: In 100% of valid plans for the provided scenario, no politician is at `T1`, `slawek_m` is separate from both other politicians, and `donald_t` and `jaroslaw_k` share a non-`T1` table.
- **SC-015**: In all acceptance scenarios with explicit sleep-risk evidence, a placement with supported engagement or compatibility signals scores higher than an otherwise equivalent placement without such signals.
- **SC-016**: In 100% of valid plans for the provided scenario, each of the two cohort tables contains exactly five corporate guests and one social catalyst, and `swiadek_kuba` and `kacper` occupy different cohort tables while retaining `friends` classification.
- **SC-017**: In 100% of valid plans, `maciek` and `jakub` are assigned to different tables.
- **SC-018**: For every SP-001 through SP-014 fixture, changing only the stated condition changes the documented score in the stated direction; SP-015 details have zero scoring impact.

## Assumptions

- The runtime contract remains `./run.sh <input.json> <output.json>`.
- Source briefs may be in Polish, but all produced project artifacts and outputs for this workflow are in English.
- Input guest descriptions may remain in Polish and are treated as authoritative source text for social-signal inference.
- Table location notes in scenario input are treated as authoritative context for location-affinity scoring.
- Table `T2` is interpreted as the primary dancefloor-adjacent table for dance-priority signals.
- Table `T4` is interpreted as the exit/terrace-adjacent localization target for explicit outside/smoking/external-networking signals.
- The table text rules (5 tables × 6 seats) are the hard source of truth over visual style in diagrams.
- Input guest `id` fields are canonical identities and MUST be preserved in output guest references.
- If BRIEF narrative wording conflicts with scoring-specific data present in input JSON, input JSON is authoritative.
- The provided output JSON schema is treated as a minimal structural contract; additional business-rule validation is required by this feature.
- The target scenario contains 10 corporate guests (`group: work`, excluding Bartek) and two stakeholder-selected social catalysts, making two complete tables with a 5-corporate/1-catalyst composition feasible.
- `T1` has four mandatory guests (Bartek, Nina, Mama Ela, and Babcia Ela); its two remaining seats are optimized subject to the no-politician rule.
- Source evidence classifies `swiadek_kuba` and `kacper` as `friends`; neither is reclassified as corporate. In particular, source evidence does not classify `swiadek_kuba` as `work`, and his cohort inclusion is a stakeholder seating decision.
- `T2` is expected to host the strongest dance signals as the primary dance table, but the confirmed rules do not identify the second corporate-heavy cohort table.
- The scope of this feature is generation of a valid and optimized seating plan for provided input scenarios; interactive manual editing is out of scope.

### Source Inconsistencies and Translation Notes

- **Layout inconsistency captured**: The room drawing can be interpreted as showing fewer than six seat positions for some tables, while textual requirements explicitly require six seats per table.
- **Guest identity ambiguity captured**: "Świadek Kuba" and "Kuba S. „Gangus”" share the same first name and can be conflated if non-unique labels are used.
- **Schema-vs-rules gap captured**: `contract/output-schema.json` validates only structure and does not enforce critical business constraints (table cardinality, uniqueness, mandatory placements, and full guest coverage).
- **Translation handling**: Requirements were translated from Polish source artifacts into English while preserving intent; humor and narrative text were interpreted as potential behavioral hints, not only decoration.
- **Language-handling requirement captured**: Scoring depends on understanding Polish guest-description text while keeping all project artifacts in English.
- **Narrative-weighting requirement captured**: Story-like descriptions are treated as potential signal sources; concrete cues influence scoring while decorative noise is down-weighted.
- **Sławek M. interpretation**: His input identifies direct economic and tax debate and a tendency to fill conversational silence, supporting a strong political-escalation signal.
- **Donald T. interpretation**: His input identifies political negotiation and coalition-building even around ordinary choices, supporting a political-discussion and negotiation signal.
- **Jarosław K. interpretation**: His input identifies strategic political analysis and active participation in debate, supporting a political-escalation signal.
- **Political pair interpretation**: The sources do not establish a uniquely safer pair. To preserve the no-politician-at-`T1` decision alongside two complete cohort tables, the stakeholder permits Donald T. and Jarosław K. to share a table while requiring Sławek M. to sit separately.
- **Name correction**: The food-related contrast in the BRIEF is between Maciek and Jakub; it does not refer to Świadek Kuba or Kuba S.
