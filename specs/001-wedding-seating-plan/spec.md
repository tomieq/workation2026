# Feature Specification: Wedding Seating Plan

**Feature Branch**: `001-wedding-seating-plan`

**Created**: 2026-08-19

**Status**: Draft - Updated for Scenario 2 narrative policy catalogue

**Input**: User description: "Update Scenario 2 and add a deterministic policy catalogue derived from every guest description and table note, classified under the six competition categories, while preserving only the approved hard constraints and the unchanged output schema."

## Clarifications

### Session 2026-08-19

- Q: How should the solver turn guest narratives into seating rules? -> A: Named relationships, shared traits, character signals, and venue cues create deterministic soft preferences. Narrative evidence does not create hard companion or separation rules.
- Q: Should the solver treat a guest's group value, such as family or work, as a soft seating preference? -> A: Use group membership as a lowest-priority soft preference.
- Q: When soft preferences conflict at the same priority, how should the solver choose between equally valid plans? -> A: Choose the lexicographically smallest final table and guest-ID arrangement.
- Q: How should explicit dining and drinking signals influence seating when the venue has no food or bar location? -> A: Treat shared, explicit drinking and food-related descriptions as a soft table-mate affinity; place energy-conserving or low-toast guests at the quiet table when feasible.
- Q: If generation fails and the output path already contains an earlier valid plan, should the program keep or delete that existing file? -> A: Keep any existing output unchanged on failure.
- Q: How should the solver use the confirmed locations of Table 2 by the dance floor and Table 4 by the exit/terrace? -> A: Dance-related descriptions prefer Table 2; smoke/terrace-related descriptions prefer Table 4.

### Scenario 2 Amendment 2026-08-19

- The active guest list excludes Donald T. and Jarosław K. and includes Jakub G., Michał Z., and Michał S.
- The fixed venue remains five tables, with exactly one table expanded to seven seats and the other four retaining six seats.
- The named Leszek--Michał Z. and Leszek--Jakub G. tensions are soft discussion-pair avoidances. They do not create hard separation rules because the narrative describes avoidable awkwardness rather than an impossibility of sharing a table.
- Jakub G. and Michał Z. prefer social company over spending the evening in a work-team cluster. This is a soft preference and does not override higher-priority structural or named-person rules.
- Michał S.'s former membership in the Bald Club is social context only; it does not name a required companion, a required separation, or a measurable seating preference.
- `T1` must include exactly two active work-group guests in addition to Bartek; Bartek is not counted as one of those colleagues.
- `input/scenario2.json` is the canonical supplied fixture for validating the updated program.
- Q: When should a table count as dominated by work-group guests for Michał Z. and Jakub G.? → A: Four or more work-group guests.
- Q: How should the program choose which table receives the seventh chair? → A: Choose the table yielding the best overall seating plan, using the existing lexicographic tie-break for equal outcomes.

### Narrative Catalogue Amendment 2026-08-19

- Every guest `description` and table `notes` value in `input/scenario2.json` is authoritative evidence that must be catalogued exactly.
- Every evidence item is classified under `Grupowanie zespołu`, `Lokalizacja`, `Relacje`, `T1 Production`, `Balans`, or `Ryzyko`, or documented as non-actionable.
- All narrative-derived relationships, character signals, activity, food/drink behavior, team grouping, location cues, and disruption risks are soft preferences.
- Only capacity, unique and complete assignment, Bartek and Nina at `T1`, and the approved exact `T1` composition are hard constraints.
- The policy catalogue affects assignment decisions but does not add fields to the published output JSON.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate a Valid Complete Plan (Priority: P1)

A wedding organizer supplies one scenario containing the available tables and all invited guests, then receives a seating plan that assigns every guest exactly once and meets every table's capacity.

**Why this priority**: A complete, structurally valid plan is the minimum usable result; no seating-quality decision matters if a guest is missing, duplicated, or seated at a nonexistent table.

**Independent Test**: Run the program with `input/scenario2.json` and validate the generated file against the published output schema and all seating invariants.

**Acceptance Scenarios**:

1. **Given** a Scenario 2 input with five base tables of capacity six and 31 uniquely identified guests, **When** the organizer generates a plan, **Then** the result contains the five supplied table IDs, assigns every input guest exactly once, and uses four tables of six guests plus the seventh chair at the table that yields the best overall seating plan.
2. **Given** a valid scenario containing Bartek and Nina, **When** the organizer generates a plan, **Then** both are assigned to table `T1`.
3. **Given** a valid scenario, **When** the organizer generates a plan twice without changing the scenario, **Then** both generated plans contain the same table assignments and guest order.

---

### User Story 2 - Produce a Considered Social Arrangement (Priority: P2)

A wedding organizer receives a complete plan that uses the supplied guest groups, descriptions, and table-location notes to favor compatible company and appropriate access to the lively or quiet parts of the venue, while avoiding explicitly signaled disruptive combinations whenever a valid alternative exists.

**Why this priority**: The challenge evaluates more than JSON validity: the couple's satisfaction depends on a plan that reflects the interpersonal signals in the scenario rather than arbitrary grouping.

**Independent Test**: Review the generated plan for the supplied scenario against the documented seating-policy catalogue and confirm every identified companion, separation, and location preference is either honored or has a recorded constraint-based reason it cannot be honored.

**Acceptance Scenarios**:

1. **Given** a scenario whose guest description unambiguously names a compatible companion, **When** a feasible table assignment can keep them together without reducing a higher-value outcome, **Then** the plan prefers placing them at the same table.
2. **Given** a scenario whose descriptions explicitly identify a high-risk conversational combination, **When** a feasible assignment can separate those guests without reducing a higher-value outcome, **Then** the plan prefers assigning them to different tables.
3. **Given** guest descriptions indicating a preference for dancing, quiet conversation, food, or early departure, **When** a venue table has a relevant location note, **Then** the plan uses that location note when it does not conflict with a higher-priority seating constraint.
4. **Given** the workation team lists in the challenge brief, **When** the organizer generates a seating plan, **Then** the plan does not treat those lists as wedding seating requirements.
5. **Given** a guest whose description explicitly indicates dancing or smoke/terrace breaks, **When** the relevant venue table is available after higher-priority constraints, **Then** the plan prefers `T2` for dancing and `T4` for smoke/terrace breaks.
6. **Given** the Scenario 2 roster, **When** a valid alternative exists after higher-priority constraints, **Then** Michał Z. and Jakub G. are not seated with Leszek and are not placed at a table containing four or more work-group guests.
7. **Given** the Scenario 2 roster, **When** the organizer generates a plan, **Then** Michał S. is included exactly once and the plan does not turn the Bald Club history into a mandatory companion or separation rule.
8. **Given** a valid Scenario 2 roster with at least two work-group guests other than Bartek, **When** the organizer generates a plan, **Then** `T1` contains Bartek, Nina, and exactly two additional guests whose group is `work`.
9. **Given** `input/scenario2.json`, **When** the seating catalogue is reviewed, **Then** every guest `description` and every table `notes` value appears as exact evidence and is classified under at least one competition category or explicitly marked non-actionable.
10. **Given** two valid candidate plans, **When** they are compared, **Then** narrative policies contribute only soft preferences across `Grupowanie zespołu`, `Lokalizacja`, `Relacje`, `T1 Production`, `Balans`, and `Ryzyko`; they never invalidate a plan satisfying the approved hard constraints.

---

### User Story 3 - Receive Clear Feedback for Invalid Scenarios (Priority: P3)

A wedding organizer is told why a scenario cannot produce a valid plan instead of receiving a partial, malformed, or misleading output file.

**Why this priority**: Clear failure handling prevents an invalid guest list or room configuration from being mistaken for an acceptable wedding plan.

**Independent Test**: Supply malformed scenarios covering a duplicate guest ID, an invalid five-table capacity distribution, a missing required couple member, and an unknown table reference; verify that each run fails with a specific reason and does not create a valid-looking plan.

**Acceptance Scenarios**:

1. **Given** a Scenario 2 input whose guest count does not equal 31 or whose five base tables are not all capacity six, **When** the organizer generates a plan, **Then** generation fails with a message that states the invalid capacity or count and no output plan is produced.
2. **Given** a scenario with duplicate guest IDs or a guest missing an ID, **When** the organizer generates a plan, **Then** generation fails with a message that identifies the invalid guest data and no output plan is produced.
3. **Given** a scenario without Bartek, Nina, or table `T1`, **When** the organizer generates a plan, **Then** generation fails with a message that identifies the missing mandatory seating element and no output plan is produced.

---

### Edge Cases

- The scenario does not contain exactly five base tables of capacity six or does not contain exactly 31 guests: generation fails because Scenario 2 permits exactly one solver-selected extra chair, producing four tables of six and one table of seven.
- A Scenario 2 roster includes Donald T. or Jarosław K., omits Jakub G., Michał Z., or Michał S., or contains a guest other than the 31 active attendees: generation fails rather than silently generating a plan for a superseded guest list.
- Fewer than two active work-group guests other than Bartek are available: generation fails because the mandatory `T1` composition cannot be satisfied.
- A guest's group or description is absent or blank: the guest remains eligible for assignment, but no preference is inferred from the missing field.
- Several seating preferences cannot all be honored because of capacity or mandatory placement: the plan preserves the four approved hard-constraint classes first, then compares the documented soft outcomes deterministically.
- A guest description supplies no defensible seating implication: the catalogue preserves the exact evidence and marks it non-actionable instead of inventing a preference.
- One description supports more than one competition category: every supported category is recorded, but the description remains one evidence item and cannot be counted repeatedly within the same category.
- An input table ID, guest ID, or description contains Polish characters, punctuation, or quotation marks: the plan preserves the corresponding guest IDs and remains valid JSON.
- The requested output path cannot be written: generation fails clearly and does not claim success.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST accept an input scenario path and an output plan path through `./run.sh <input.json> <output.json>`.
- **FR-002**: The system MUST validate that the Scenario 2 input contains exactly five distinct base tables, each with capacity six, and exactly 31 guests with unique non-empty IDs before producing a plan.
- **FR-003**: The system MUST validate that the scenario contains table `T1` and distinct guests identified as Bartek and Nina before producing a plan.
- **FR-004**: The system MUST generate a plan that contains exactly one entry for each input table ID, with four six-guest entries and one seven-guest entry. It MUST choose the seven-guest table as part of maximizing the overall seating plan and use the lexicographically smallest final arrangement to break equal outcomes.
- **FR-005**: The system MUST assign every input guest exactly once and MUST NOT introduce a guest ID absent from the input.
- **FR-006**: The system MUST assign Bartek and Nina to `T1`.
- **FR-007**: The system MUST write a result that conforms to the published wedding seating output schema and contains no additional output fields.
- **FR-008**: The system MUST use the documented Scenario 2 seating-policy catalogue derived from every guest `description`, every table `notes` value, guest groups, and approved change requests; it MUST NOT derive additional seating rules from workation team membership or unstated organizer intent.
- **FR-009**: The system MUST satisfy the hard constraints before evaluating soft preferences. The only hard-constraint classes are approved table capacity, unique and complete guest assignment, Bartek and Nina at `T1`, and the approved exact `T1` composition. All narrative-derived policies are soft.
- **FR-010**: The system MUST produce the same plan for identical valid input.
- **FR-011**: The system MUST report input-validation and output-writing failures clearly, MUST publish a new output plan only after successful validation, and MUST leave any existing output file unchanged after a failed run.
- **FR-012**: An unambiguous narrative reference that names another guest MUST create an auditable soft relationship preference when it expresses compatibility or tension. Shared traits, character signals, activity level, food/drink behavior, team membership, disruption risks, and table-location cues MAY create only soft preferences.
- **FR-013**: Except for the mandatory `T1` composition, the system MAY use supplied guest group membership as the lowest-priority soft preference only after all higher-priority seating constraints and preferences are satisfied.
- **FR-014**: When multiple plans satisfy the same seating constraints and preferences, the system MUST choose the lexicographically smallest arrangement by table ID and then guest ID.
- **FR-015**: The system MUST treat `T2` as nearest the dance floor and `T4` as nearest the exit/terrace. After higher-priority constraints, it MUST prefer `T2` for guests whose descriptions explicitly indicate dancing and `T4` for guests whose descriptions explicitly indicate smoke or terrace breaks.
- **FR-016**: When no relevant food or bar table location is supplied, the system MUST treat only explicit food- or drink-related descriptions as a soft affinity among those named guests. It MUST prefer quiet `T5` for explicit low-energy, early-departure, or low-toast signals when feasible.
- **FR-017**: The system MUST use a documented soft avoidance preference for an explicitly flagged discussion pair. The preference MUST NOT create a hard separation or override any approved hard constraint.
- **FR-018**: The system MUST assign Bartek and Nina to `T1` together with exactly two additional active guests whose group is `work`; Bartek does not count toward those two colleagues. This is a mandatory composition rule and takes precedence over all soft seating preferences.
- **FR-019**: The system MUST reject a Scenario 2 roster that includes Donald T. or Jarosław K. or that omits Jakub G., Michał Z., or Michał S.
- **FR-020**: After satisfying the approved hard constraints, the system MUST treat the Leszek--Michał Z. and Leszek--Jakub G. combinations as soft discussion-pair avoidances and MUST prefer not to place either newcomer at a table containing four or more work-group guests.
- **FR-021**: The system MUST NOT infer a mandatory companion, separation, or table placement for Michał S. from the Bald Club narrative alone.
- **FR-022**: The system MUST maintain one deterministic built-in policy-catalogue entry for each of the 31 guest `description` values and each of the five table `notes` values in `input/scenario2.json`.
- **FR-023**: Every catalogue entry MUST preserve its exact input evidence and classify it under one or more of `Grupowanie zespołu`, `Lokalizacja`, `Relacje`, `T1 Production`, `Balans`, and `Ryzyko`, or explicitly state that the evidence is non-actionable.
- **FR-024**: The table-note catalogue MUST interpret `T1` as the couple's table, `T2` as nearest the dance floor, `T3` as neutral central seating, `T4` as nearest the exit or terrace, and `T5` as the quietest seating area.
- **FR-025**: Named relationships, personality and conversation style, activity level, food and drink behavior, team membership, and disruption risk MUST contribute deterministic soft preferences whenever the exact evidence supports a seating implication.
- **FR-026**: A catalogue entry marked non-actionable MUST contribute no preference, and the catalogue MUST state why no defensible seating implication can be derived.
- **FR-027**: The system MUST assess valid plans across all six competition categories without counting one evidence item more than once within the same category.
- **FR-028**: Every actionable catalogue policy MUST have a focused acceptance test that demonstrates its intended positive or negative influence and demonstrates that it cannot override an approved hard constraint.
- **FR-029**: The expanded policy catalogue MUST NOT change the published output structure or add policy, evidence, category, explanation, or score fields to the generated seating-plan JSON.

### Scenario 2 Table-Note Catalogue

| Table | Exact `notes` evidence | Categories | Required soft interpretation |
|---|---|---|---|
| `T1` | `Stół Pary Młodej` | `T1 Production`, `Relacje` | Beyond mandatory Bartek and Nina placement, prefer guests with explicit ceremonial or close personal support for the couple. |
| `T2` | `Najbliżej parkietu` | `Lokalizacja`, `Balans` | Prefer explicitly dance-oriented and high-activity guests while avoiding an excessive concentration of disruptive energy. |
| `T3` | `Środek sali` | `Lokalizacja`, `Balans` | Treat as the neutral central table for guests without a stronger location cue and use it to improve overall balance. |
| `T4` | `Najbliżej wyjścia / tarasu` | `Lokalizacja`, `Ryzyko` | Prefer explicit smoking, terrace, or easy-exit needs and use the access cue when it reduces disruption. |
| `T5` | `Spokojniejsza część sali` | `Lokalizacja`, `Balans`, `Ryzyko` | Prefer explicit low-energy, early-sleep, moderation, or quiet-conversation signals. |

### Scenario 2 Guest-Description Catalogue

| Guest | Exact `description` evidence | Categories | Required soft interpretation |
|---|---|---|---|
| `mama_ela` | `Samodzielnie uszyła sobie kreację. Projekt, implementacja i QA wykonane in-house.` | `Relacje`, `Balans` | Prefer a fashion or dress-topic affinity with Oliwia; otherwise use as a conversational-interest signal only. |
| `oliwia` | `Czeka na zwrot pieniędzy za siedem odesłanych sukienek.` | `Relacje`, `Balans` | Prefer a fashion or dress-topic affinity with Mama Ela; do not infer a location requirement. |
| `babcia_ela` | `Nie mogła odpuścić takiej imprezy. Weselne doświadczenie ma większe niż większość sali.` | `Balans` | Treat as a socially experienced family presence that can balance a less experienced table; do not force `T1`. |
| `piotr` | `Podobno ktoś kiedyś widział go na parkiecie. Dowodów brak.` | Non-actionable | The description explicitly makes the dance signal uncertain, so it creates no dance-floor preference. |
| `agnieszka` | `Jeśli coś się nie spodoba, obsługa dostanie bardzo bezpośredni feedback.` | `Ryzyko`, `Balans` | Disperse from concentrations of other explicitly disruptive or confrontational guests. |
| `zdzisiek` | `Rekord Polski: 8,7 poruszonego tematu na minutę.` | `Ryzyko`, `Balans` | Treat as high conversational intensity and avoid concentrating similar high-intensity speakers. |
| `chrzestna_ania` | `Rodzinny wodzirej. Mikrofon nie jest jej potrzebny.` | `T1 Production`, `Lokalizacja`, `Balans` | Prefer `T1` for ceremonial family support or `T2` for party leadership; distribute high-energy guests if `T1` is unavailable. |
| `zosia` | `Szuka kompana na papieroska. Networking zewnętrzny.` | `Lokalizacja`, `Relacje` | Prefer `T4` and soft affinity with another explicit terrace or smoking-break participant if one exists. |
| `gosia` | `Na wesele czeka bardziej niż Para Młoda.` | `Balans` | Treat as strong celebration energy and use it to support a less energetic table without assuming a specific location. |
| `amelka` | `Za dużo jedzenia do wyboru powoduje deadlock decyzyjny.` | `Ryzyko`, `Balans` | Avoid concentrating her with other guests whose descriptions imply high service demands or decision disruption. |
| `ada` | `Srebro olimpijskie w nieoficjalnym rzucie talerzem.` | `Ryzyko`, `Balans` | Treat as a disruption signal and disperse from other explicit high-risk behavior. |
| `kacper` | `Zagra koncert na Sparkling Piano.` | `Lokalizacja`, `Balans` | Prefer a lively or centrally accessible table and avoid concentrating too many performance-dominant guests. |
| `klara` | `Czeka aż ktoś poda jej drinka alkoholowego.` | `Relacje`, `Ryzyko` | Prefer soft affinity with explicit drink-oriented guests while balancing alcohol-related risk. |
| `jacek` | `KPI wieczoru: nie zasnąć przed 21:00.` | `Lokalizacja`, `Balans` | Prefer quiet `T5` and avoid relying on him to provide table energy. |
| `swiadek_kuba` | `Świadek z nieskromnym stylem tańca.` | `T1 Production`, `Lokalizacja`, `Balans` | Prefer `T1` for ceremonial support or `T2` for dancing; account for his high activity when balancing tables. |
| `przemek` | `Reprezentant działu QA. Nigdy się nie uśmiecha, chyba że Pan Młody przebierze się za gwiazdę estrady. Ma dojścia do taniego spirytusu i naturalną potrzebę reprodukowania błędów.` | `Grupowanie zespołu`, `Relacje`, `Ryzyko` | Apply lowest-tier work grouping, a soft Bartek interaction cue, drink affinity, and a critical-conversation risk that should be dispersed. |
| `pawel` | `Lider techniczny, perfekcyjny, nigdy się nie myli. Ostatnio na imprezach raczej zachowuje pełny monitoring niż ściga się w toastach.` | `Grupowanie zespołu`, `Lokalizacja`, `Balans` | Apply lowest-tier work grouping and prefer quiet `T5` because of explicit moderation. |
| `leszek` | `Członek Klubu Toyoty. Ma mocno wyrobione zdanie o współpracy z SRE. Szczególnie wobec Michała Z. uważa, że poziom jego zaangażowania zawodowego pozostawia sporo przestrzeni do dyskusji.` | `Grupowanie zespołu`, `Relacje`, `Ryzyko` | Apply lowest-tier work grouping and soft avoidance with Michał Z.; Toyota membership alone creates no companion rule. |
| `mariusz` | `Do rany przyłóż, każdego wytłumaczy, pilnuje kosztów, lubi docinać Przemkowi i lubi Sławka M.` | `Grupowanie zespołu`, `Relacje`, `Balans` | Prefer Mariusz with Sławek M.; treat Przemek as friendly banter rather than hostility and use Mariusz as a calming social counterweight. |
| `tomek` | `Łysy, na wypożyczeniu w innym zespole, zamawia szampana i winogrona.` | `Grupowanie zespołu`, `Relacje`, `Balans` | Apply weak work grouping and drink/food affinity; baldness alone is non-actionable. |
| `slawek_m` | `Ekonomista i polityk kojarzony z gospodarką, podatkami i bardzo bezpośrednią debatą. Cisza przy stole może szybko zamienić się w panel ekonomiczny.` | `Relacje`, `Ryzyko`, `Balans` | Honor Mariusz's explicit affinity and disperse from excessive debate or conversational-intensity risk. |
| `maciek` | `Trenuje CrossFit, zamawia kilogramy jedzenia, łysy.` | `Grupowanie zespołu`, `Relacje`, `Balans` | Apply lowest-tier work grouping and food-oriented affinity; CrossFit supplies an active conversation cue, while baldness is non-actionable. |
| `michal` | `Niby lider zespołu, release robi tydzień, łysy, autor pomysłu aplikacji do obsługi cmentarzy.` | `Grupowanie zespołu`, `Balans` | Apply lowest-tier work grouping and treat the unusual business interest as a conversation-diversity signal; baldness is non-actionable. |
| `jakub` | `Nowy w zespole, świeża krew, prawie nie je, mieszka w Radomiu.` | `Grupowanie zespołu`, `Balans` | Apply lowest-tier work grouping, avoid isolating the newcomer, and use the low-food signal only for table balance, not as affinity with heavy eaters. |
| `tetiana` | `Spokojna osoba, królowa parkietu, na co dzień biega.` | `Grupowanie zespołu`, `Lokalizacja`, `Balans` | Apply lowest-tier work grouping, strongly prefer `T2`, and use her calm/high-activity combination to balance energetic tables. |
| `kuba_s` | `Były kolega z zespołu, więcej tatuaży niż lat, wpadł na przepustce.` | `Grupowanie zespołu`, `Ryzyko`, `Balans` | Apply weak former-team grouping and treat the wildcard framing as a risk to disperse; tattoos alone are non-actionable. |
| `bartek` | `Pan Młody. Programista i właściciel problemu.` | `T1 Production` | Require `T1`; do not count him among the exactly two additional work-group guests. |
| `nina` | `Panna Młoda i finalny Product Owner wesela.` | `T1 Production` | Require `T1`; her bride group does not create an additional grouping preference. |
| `kuba_g` | `Drugi z bliskich przyjaciół Bartka. Znają się jak łyse konie i beczkę soli razem zjedli. Bartek czasem uważa, że Jakub nie pracuje na 120% możliwości. Na wesele przyjechał przede wszystkim do Bartka, nie na firmowy offsite. Z Leszkiem relacja jest na tyle profesjonalna, że najlepiej działa przy odpowiedniej odległości między krzesłami.` | `Relacje`, `T1 Production`, `Grupowanie zespołu`, `Ryzyko` | Strongly prefer proximity to Bartek and `T1`, softly avoid Leszek, and avoid a work-dominated table; none of these preferences alters the exact `T1` work count. |
| `michal_z` | `Przyjaciel Bartka z zespołu SRE. Z Bartkiem są jak bracia: poza pracą bardzo blisko, w pracy z okresowymi packet lossami. Na wesele przyjechał do Bartka, nie na kolejny firmowy sync. Z Leszkiem sytuacja jest jednostronna: Michał Z. raczej nie przejmuje się tematem, za to Leszek uważa, że Michał pracę traktuje czasem bardziej jak sugestię niż zobowiązanie. Wspólny stolik daje Leszkowi niebezpiecznie dużo czasu na rozwinięcie tej opinii.` | `Relacje`, `T1 Production`, `Grupowanie zespołu`, `Ryzyko` | Strongly prefer proximity to Bartek and `T1`, softly avoid Leszek, and avoid a work-dominated table; treat the Bartek work tension as weaker than their explicit personal closeness. |
| `michal_s` | `Product Owner zespołu i pełnoprawny członek ekipy. Pojawia się jako dodatkowy 31. gość. Dawny reprezentant Klubu Łysych, ale ostatnio pojechał do Turcji na operację włosów i tym samym zdradził jego ideały.` | `Grupowanie zespołu`, `Balans` | Apply work-group preference; the hair-club story names no guest and creates no companion, avoidance, or location policy. |

### Key Entities *(include if feature involves data)*

- **Seating Scenario**: The supplied wedding data set containing its identifier, tables, and guests.
- **Table**: A venue location with an ID, display name, base capacity, and location note that may affect seating preferences. Scenario 2 begins with five six-seat tables and allows the solver to add one chair to the table that yields the best plan.
- **Guest**: An invited person identified by a unique ID, display name, group, and narrative description.
- **Seating Policy**: A documented, evidence-backed rule that expresses an approved hard constraint or a soft preference classified by competition category, together with its exact source evidence.
- **Seating Plan**: The generated mapping of each table ID to its assigned guest IDs, with the count at each table equal to its approved capacity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For every valid Scenario 2 input, 100% of generated plans contain five tables with four groups of six guests and one group of seven guests, assign all 31 active guests exactly once, and place Bartek and Nina plus exactly two of Bartek's work-group colleagues at `T1`.
- **SC-002**: 100% of generated plans validate against the published output schema with no additional properties.
- **SC-003**: Repeating generation 20 times with unchanged valid input produces 20 identical seating plans.
- **SC-004**: The supplied `input/scenario2.json` fixture produces a plan or a clear validation failure within 10 seconds on the challenge machine.
- **SC-005**: In review of the supplied scenario, all documented high-priority seating policies are honored; any lower-priority policy not honored is accompanied by a capacity or higher-priority conflict explanation in the project artifacts.
- **SC-006**: A reviewer can complete the primary workflow, from a valid scenario to a schema-valid plan, on the first attempt using the documented command and without manual JSON editing.
- **SC-007**: Given an input with more than one equally preferred valid plan, generation selects the lexicographically smallest arrangement by table ID and then guest ID in 100% of runs.
- **SC-008**: A catalogue audit accounts for 100% of the 31 guest descriptions and five table notes in `input/scenario2.json`, with exact evidence, at least one competition category or a non-actionable reason, and no unsupported policy.
- **SC-009**: Focused tests cover 100% of actionable catalogue policies and show that narrative preferences never override capacity, uniqueness, couple placement, or approved `T1` composition.
- **SC-010**: Generated Scenario 2 output remains valid against the unchanged published output schema and contains zero policy-catalogue or scoring fields.

## Assumptions

- The updated program's canonical scenario fixture is `input/scenario2.json`; it follows the existing scenario structure and contains tables and guests with stable IDs.
- The Scenario 2 input represents five base tables of six. The generated plan must assign four tables six guests and one solver-selected table seven guests; alternate room sizes and more than one added chair are outside this feature's scope.
- The Scenario 2 active roster is exactly the 31 guests after removing Donald T. and Jarosław K. and adding Jakub G., Michał Z., and Michał S.
- Bartek and Nina are identified by their guest IDs or names in the input scenario and must always be seated at `T1`.
- Bartek's colleagues are guests whose group is `work`; Bartek is excluded when counting the exactly two work-group colleagues required at `T1`.
- The public challenge brief, scenario descriptions, and table notes are the sole business evidence for seating-policy decisions; workation team composition is explicitly excluded.
- The complete Scenario 2 evidence catalogue is normative in this specification; a later technical plan will define deterministic comparison within and across its six competition categories and explain unavoidable trade-offs without adding private organizer knowledge.
- The output file uses guest IDs, not display names, because the published output contract defines each seat occupant as a string and IDs uniquely identify input guests.
- The room-layout diagram is public challenge evidence that `T2` is nearest the dance floor and `T4` is nearest the exit/terrace.
