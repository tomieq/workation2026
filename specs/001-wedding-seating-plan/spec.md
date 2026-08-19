# Feature Specification: Wedding Seating Plan

**Feature Branch**: `001-wedding-seating-plan`

**Created**: 2026-08-19

**Status**: Draft

**Input**: User description: "Prepare specification based on project requirements"

## Clarifications

### Session 2026-08-19

- Q: How should the solver turn guest narratives into seating rules? -> A: Direct named references create hard rules; shared traits and venue cues are soft preferences.
- Q: Should the solver treat a guest's group value, such as family or work, as a soft seating preference? -> A: Use group membership as a lowest-priority soft preference.
- Q: When soft preferences conflict at the same priority, how should the solver choose between equally valid plans? -> A: Choose the lexicographically smallest final table and guest-ID arrangement.
- Q: How should explicit dining and drinking signals influence seating when the venue has no food or bar location? -> A: Treat shared, explicit drinking and food-related descriptions as a soft table-mate affinity; place energy-conserving or low-toast guests at the quiet table when feasible.
- Q: If generation fails and the output path already contains an earlier valid plan, should the program keep or delete that existing file? -> A: Keep any existing output unchanged on failure.
- Q: How should the solver use the confirmed locations of Table 2 by the dance floor and Table 4 by the exit/terrace? -> A: Dance-related descriptions prefer Table 2; smoke/terrace-related descriptions prefer Table 4.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate a Valid Complete Plan (Priority: P1)

A wedding organizer supplies one scenario containing the available tables and all invited guests, then receives a seating plan that assigns every guest exactly once and meets every table's capacity.

**Why this priority**: A complete, structurally valid plan is the minimum usable result; no seating-quality decision matters if a guest is missing, duplicated, or seated at a nonexistent table.

**Independent Test**: Run the program with the supplied 30-guest scenario and validate the generated file against the published output schema and all seating invariants.

**Acceptance Scenarios**:

1. **Given** a scenario with five tables of capacity six and 30 uniquely identified guests, **When** the organizer generates a plan, **Then** the result contains the five supplied table IDs, each with six guest IDs, and every input guest appears exactly once.
2. **Given** a valid scenario containing Bartek and Nina, **When** the organizer generates a plan, **Then** both are assigned to table `T1`.
3. **Given** a valid scenario, **When** the organizer generates a plan twice without changing the scenario, **Then** both generated plans contain the same table assignments and guest order.

---

### User Story 2 - Produce a Considered Social Arrangement (Priority: P2)

A wedding organizer receives a complete plan that uses the supplied guest groups, descriptions, and table-location notes to favor compatible company and appropriate access to the lively or quiet parts of the venue, while avoiding explicitly signaled disruptive combinations whenever a valid alternative exists.

**Why this priority**: The challenge evaluates more than JSON validity: the couple's satisfaction depends on a plan that reflects the interpersonal signals in the scenario rather than arbitrary grouping.

**Independent Test**: Review the generated plan for the supplied scenario against the documented seating-policy catalogue and confirm every identified companion, separation, and location preference is either honored or has a recorded constraint-based reason it cannot be honored.

**Acceptance Scenarios**:

1. **Given** a scenario whose guest description unambiguously names a compatible companion, **When** a feasible table assignment can keep them together, **Then** the plan places them at the same table.
2. **Given** a scenario whose descriptions explicitly identify a high-risk conversational combination, **When** a feasible assignment can separate those guests, **Then** the plan assigns them to different tables.
3. **Given** guest descriptions indicating a preference for dancing, quiet conversation, food, or early departure, **When** a venue table has a relevant location note, **Then** the plan uses that location note when it does not conflict with a higher-priority seating constraint.
4. **Given** the workation team lists in the challenge brief, **When** the organizer generates a seating plan, **Then** the plan does not treat those lists as wedding seating requirements.
5. **Given** a guest whose description explicitly indicates dancing or smoke/terrace breaks, **When** the relevant venue table is available after higher-priority constraints, **Then** the plan prefers `T2` for dancing and `T4` for smoke/terrace breaks.

---

### User Story 3 - Receive Clear Feedback for Invalid Scenarios (Priority: P3)

A wedding organizer is told why a scenario cannot produce a valid plan instead of receiving a partial, malformed, or misleading output file.

**Why this priority**: Clear failure handling prevents an invalid guest list or room configuration from being mistaken for an acceptable wedding plan.

**Independent Test**: Supply malformed scenarios covering a duplicate guest ID, mismatched total capacity, a missing required couple member, and an unknown table reference; verify that each run fails with a specific reason and does not create a valid-looking plan.

**Acceptance Scenarios**:

1. **Given** a scenario whose guest count does not equal total table capacity, **When** the organizer generates a plan, **Then** generation fails with a message that states the count mismatch and no output plan is produced.
2. **Given** a scenario with duplicate guest IDs or a guest missing an ID, **When** the organizer generates a plan, **Then** generation fails with a message that identifies the invalid guest data and no output plan is produced.
3. **Given** a scenario without Bartek, Nina, or table `T1`, **When** the organizer generates a plan, **Then** generation fails with a message that identifies the missing mandatory seating element and no output plan is produced.

---

### Edge Cases

- A table has a capacity other than six, or the scenario does not contain exactly five tables: generation fails because the challenge venue is fixed at five tables of six.
- A guest's group or description is absent or blank: the guest remains eligible for assignment, but no preference is inferred from the missing field.
- Several seating preferences cannot all be honored because of capacity or mandatory placement: the plan preserves structural and mandatory constraints first, then applies the documented priority order.
- An input table ID, guest ID, or description contains Polish characters, punctuation, or quotation marks: the plan preserves the corresponding guest IDs and remains valid JSON.
- The requested output path cannot be written: generation fails clearly and does not claim success.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST accept an input scenario path and an output plan path through `./run.sh <input.json> <output.json>`.
- **FR-002**: The system MUST validate that the scenario contains exactly five distinct tables, each with capacity six, and exactly 30 guests with unique non-empty IDs before producing a plan.
- **FR-003**: The system MUST validate that the scenario contains table `T1` and distinct guests identified as Bartek and Nina before producing a plan.
- **FR-004**: The system MUST generate a plan that contains exactly one entry for each input table ID and exactly six guest IDs in each table entry.
- **FR-005**: The system MUST assign every input guest exactly once and MUST NOT introduce a guest ID absent from the input.
- **FR-006**: The system MUST assign Bartek and Nina to `T1`.
- **FR-007**: The system MUST write a result that conforms to the published wedding seating output schema and contains no additional output fields.
- **FR-008**: The system MUST use a documented seating-policy catalogue derived from explicit signals in guest groups, guest descriptions, and table-location notes; it MUST NOT derive seating rules from workation team membership or unstated organizer intent.
- **FR-009**: The system MUST apply seating constraints in this order: structural validity, mandatory couple placement, explicit guest separation rules, explicit companion rules, location preferences, explicit named discussion-pair avoidance, explicit food/drink affinities, then group-membership preferences.
- **FR-010**: The system MUST produce the same plan for identical valid input.
- **FR-011**: The system MUST report input-validation and output-writing failures clearly, MUST publish a new output plan only after successful validation, and MUST leave any existing output file unchanged after a failed run.
- **FR-012**: Only an unambiguous narrative reference that names another guest may create a hard companion or separation rule; shared traits and table-location cues are soft preferences.
- **FR-013**: The system MAY use supplied guest group membership as the lowest-priority soft preference only after all higher-priority seating constraints and preferences are satisfied.
- **FR-014**: When multiple plans satisfy the same seating constraints and preferences, the system MUST choose the lexicographically smallest arrangement by table ID and then guest ID.
- **FR-015**: The system MUST treat `T2` as nearest the dance floor and `T4` as nearest the exit/terrace. After higher-priority constraints, it MUST prefer `T2` for guests whose descriptions explicitly indicate dancing and `T4` for guests whose descriptions explicitly indicate smoke or terrace breaks.
- **FR-016**: When no relevant food or bar table location is supplied, the system MUST treat only explicit food- or drink-related descriptions as a soft affinity among those named guests. It MUST prefer quiet `T5` for explicit low-energy, early-departure, or low-toast signals when feasible.
- **FR-017**: The system MUST use a documented soft avoidance score for an explicitly flagged discussion pair. The score MUST NOT create a hard separation or override structural, mandatory, companion, or separation constraints.
- **FR-018**: The system MUST prefer the named godmother and witness plus one work-group contact for the optional seats at the couple's table when feasible. This preference MUST remain soft and MUST take precedence over ordinary venue-location preferences; it MUST NOT cluster multiple work-group guests at `T1`.

### Key Entities *(include if feature involves data)*

- **Seating Scenario**: The supplied wedding data set containing its identifier, tables, and guests.
- **Table**: A venue location with an ID, display name, capacity, and location note that may affect seating preferences.
- **Guest**: An invited person identified by a unique ID, display name, group, and narrative description.
- **Seating Policy**: A documented, evidence-backed rule that expresses a mandatory placement, separation, companion, location preference, or named-pair avoidance preference and its priority.
- **Seating Plan**: The generated mapping of each table ID to the six assigned guest IDs.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every valid 30-guest challenge scenario, 100% of generated plans contain five tables of six guests, assign all 30 input guests exactly once, and place Bartek and Nina at `T1`.
- **SC-002**: 100% of generated plans validate against the published output schema with no additional properties.
- **SC-003**: Repeating generation 20 times with unchanged valid input produces 20 identical seating plans.
- **SC-004**: The supplied 30-guest scenario produces a plan or a clear validation failure within 10 seconds on the challenge machine.
- **SC-005**: In review of the supplied scenario, all documented high-priority seating policies are honored; any lower-priority policy not honored is accompanied by a capacity or higher-priority conflict explanation in the project artifacts.
- **SC-006**: A reviewer can complete the primary workflow, from a valid scenario to a schema-valid plan, on the first attempt using the documented command and without manual JSON editing.
- **SC-007**: Given an input with more than one equally preferred valid plan, generation selects the lexicographically smallest arrangement by table ID and then guest ID in 100% of runs.

## Assumptions

- The input follows the scenario structure represented by `input/scenario1.json`, including tables and guests with stable IDs.
- The challenge venue is fixed at five tables of six; support for alternate room sizes is outside this feature's scope.
- Bartek and Nina are identified by their guest IDs or names in the input scenario and must always be seated at `T1`.
- The public challenge brief, scenario descriptions, and table notes are the sole business evidence for seating-policy decisions; workation team composition is explicitly excluded.
- A later clarification and technical plan will publish the complete seating-policy catalogue and explain any unavoidable policy trade-offs without adding private organizer knowledge.
- The output file uses guest IDs, not display names, because the published output contract defines each seat occupant as a string and IDs uniquely identify input guests.
- The room-layout diagram is public challenge evidence that `T2` is nearest the dance floor and `T4` is nearest the exit/terrace.
