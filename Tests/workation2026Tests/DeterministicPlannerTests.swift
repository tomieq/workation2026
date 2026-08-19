import Testing
@testable import workation2026

@Suite
struct DeterministicPlannerTests {
    @Test
    func producesCompleteCanonicalPlanWithCoupleAtT1() throws {
        let scenario = plannerScenario()
        let plan = try DeterministicPlanner.plan(for: scenario)

        try PlanValidator.validate(plan, for: scenario)
        #expect(plan.tables.map(\.tableId) == ["T1", "T2", "T3", "T4", "T5"])
        #expect(plan.tables.allSatisfy { $0.guests == $0.guests.sorted() })
        #expect(plan.tables[0].guests.contains("bartek"))
        #expect(plan.tables[0].guests.contains("nina"))
    }

    @Test
    func resolvesEquivalentAssignmentsLexicographically() throws {
        let scenario = plannerScenario()
        let first = try DeterministicPlanner.plan(for: scenario)
        let second = try DeterministicPlanner.plan(for: scenario)

        #expect(first == second)
        #expect(first.tables[0].guests == ["bartek", "guest1", "guest10", "guest11", "guest12", "nina"])
    }

    @Test
    func enforcesCompanionAndSeparationPoliciesBeforeSoftPreferences() throws {
        let scenario = plannerScenario()
        let policies = [
            SeatingPolicy(kind: .companion, guestIDs: ["guest1", "guest20"], tableID: nil, priority: .companion, evidence: "named companions"),
            SeatingPolicy(kind: .separate, guestIDs: ["guest2", "guest3"], tableID: nil, priority: .separation, evidence: "named conflict"),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["guest4"], tableID: "T4", priority: .location, evidence: "location cue"),
        ]

        let plan = try DeterministicPlanner.plan(for: scenario, policies: policies)
        let tableForGuest = Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in
            table.guests.map { ($0, table.tableId) }
        })

        #expect(tableForGuest["guest1"] == tableForGuest["guest20"])
        #expect(tableForGuest["guest2"] != tableForGuest["guest3"])
        #expect(tableForGuest["guest4"] == "T4")
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
    func spreadsExplicitlyHighVolumeConversationalGuests() throws {
        let scenario = plannerScenario()
        let policies = [
            SeatingPolicy(kind: .conversationAvoidance, guestIDs: ["guest1", "guest2", "guest3"], tableID: nil, priority: .conversation, evidence: "Each guest is explicitly described as high-volume or debate-prone.", weight: 125),
        ]

        let plan = try DeterministicPlanner.plan(for: scenario, policies: policies)
        let tableForGuest = Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in
            table.guests.map { ($0, table.tableId) }
        })

        #expect(Set([tableForGuest["guest1"], tableForGuest["guest2"], tableForGuest["guest3"]]).count == 3)
    }

    private func plannerScenario() -> SeatingScenario {
        let guests = (1...28).map { Guest(id: "guest\($0)", name: "Guest \($0)", group: nil, description: nil) }
            + [Guest(id: "bartek", name: "Bartek", group: nil, description: nil), Guest(id: "nina", name: "Nina", group: nil, description: nil)]
        let tables = (1...5).reversed().map { VenueTable(id: "T\($0)", name: "Table \($0)", capacity: 6, notes: nil) }
        return SeatingScenario(scenario: "test", title: "Test", tables: tables, guests: guests)
    }
}