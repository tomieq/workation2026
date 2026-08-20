import Testing
@testable import workation2026

@Suite
struct DeterministicPlannerTests {
    private func assignments(in plan: SeatingPlan) -> [String: String] {
        Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in
            table.guests.map { ($0, table.tableId) }
        })
    }

    private func satisfiesHardInvariants(_ plan: SeatingPlan, scenario: SeatingScenario) -> Bool {
        (try? PlanValidator.validate(plan, for: scenario)) != nil
    }

    @Test
    func producesCompleteCanonicalScenario2Plan() throws {
        let scenario = plannerScenario()
        let plan = try DeterministicPlanner.plan(for: scenario)

        try PlanValidator.validate(plan, for: scenario)
        #expect(plan.tables.map(\.tableId) == ["T1", "T2", "T3", "T4", "T5"])
        #expect(plan.tables.allSatisfy { $0.guests == $0.guests.sorted() })
        #expect(plan.tables.map { $0.guests.count }.sorted() == [6, 6, 6, 6, 7])
        #expect(plan.tables[0].guests.contains("bartek"))
        #expect(plan.tables[0].guests.contains("nina"))
        let guestsByID = Dictionary(uniqueKeysWithValues: scenario.guests.map { ($0.id, $0) })
        let workColleagueCount = plan.tables[0].guests.filter { guestID in
            guestID != "bartek" && guestsByID[guestID]?.group == "work"
        }.count
        #expect(workColleagueCount == 2)
    }

    @Test
    func resolvesEquivalentAssignmentsLexicographically() throws {
        let scenario = plannerScenario()
        let first = try DeterministicPlanner.plan(for: scenario)
        let second = try DeterministicPlanner.plan(for: scenario)

        #expect(first == second)
        #expect(first.tables.map { $0.guests.count }.sorted() == [6, 6, 6, 6, 7])
    }

    @Test
    func treatsCompanionAndSeparationNarrativesAsSoftPreferences() throws {
        let scenario = plannerScenario()
        let policies = [
            SeatingPolicy(kind: .companion, guestIDs: ["guest1", "guest20"], tableID: nil, priority: .companion, evidence: "named companions"),
            SeatingPolicy(kind: .separate, guestIDs: ["guest2", "guest3"], tableID: nil, priority: .separation, evidence: "named conflict"),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["guest4"], tableID: "T4", priority: .location, evidence: "location cue"),
        ]

        let plan = try DeterministicPlanner.plan(for: scenario, policies: policies)
        let tableForGuest = assignments(in: plan)

        #expect(satisfiesHardInvariants(plan, scenario: scenario))
        #expect(tableForGuest["guest1"] != nil)
        #expect(tableForGuest["guest20"] != nil)
        #expect(tableForGuest["guest2"] != nil)
        #expect(tableForGuest["guest3"] != nil)
        #expect(tableForGuest["guest4"] == "T4")
    }

    @Test
    func narrativeRelationshipsCannotInvalidateHardConstraints() throws {
        let scenario = plannerScenario()
        let policies = (1...8).map { index in
            SeatingPolicy(kind: .companion, guestIDs: ["bartek", "guest\(index)"], tableID: nil, priority: .companion, evidence: "soft relationship \(index)", weight: 100, category: .relationships)
        }

        let plan = try DeterministicPlanner.plan(for: scenario, policies: policies)

        #expect(satisfiesHardInvariants(plan, scenario: scenario))
    }

    @Test
    func favorsEvidenceBackedFoodAndDrinkAffinities() throws {
        let scenario = plannerScenario()
        let policies = [
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["guest1", "guest2"], tableID: nil, priority: .affinity, evidence: "both explicitly prefer champagne"),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["guest3", "guest4"], tableID: nil, priority: .affinity, evidence: "both explicitly discuss substantial meals"),
        ]

        let plan = try DeterministicPlanner.plan(for: scenario, policies: policies)
        let tableForGuest = Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in
            table.guests.map { ($0, table.tableId) }
        })

        #expect(tableForGuest["guest1"] == tableForGuest["guest2"])
        #expect(tableForGuest["guest3"] == tableForGuest["guest4"])
    }

    @Test
    func keepsTargetedDiscussionAvoidanceSoft() throws {
        let scenario = plannerScenario()
        let policies = [
            SeatingPolicy(kind: .avoidancePreference, guestIDs: ["guest1", "guest2"], tableID: nil, priority: .avoidance, evidence: "The narrative explicitly flags this discussion pairing.", weight: 150),
        ]

        let plan = try DeterministicPlanner.plan(for: scenario, policies: policies)
        let tableForGuest = Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in
            table.guests.map { ($0, table.tableId) }
        })

        #expect(tableForGuest["guest1"] != nil)
        #expect(tableForGuest["guest2"] != nil)
    }

    private func plannerScenario() -> SeatingScenario {
        let guests = (1...29).map { index in
            Guest(id: "guest\(index)", name: "Guest \(index)", group: index <= 2 ? "friends" : "work", description: nil)
        }
            + [Guest(id: "bartek", name: "Bartek", group: "work", description: nil), Guest(id: "nina", name: "Nina", group: "bride", description: nil)]
        let tables = (1...5).reversed().map { VenueTable(id: "T\($0)", name: "Table \($0)", capacity: 6, notes: nil) }
        return SeatingScenario(scenario: "test", title: "Test", extraSeatPolicy: ExtraSeatPolicy(extraSeats: 1, canBeAddedToAnyTable: true), tables: tables, guests: guests)
    }
}