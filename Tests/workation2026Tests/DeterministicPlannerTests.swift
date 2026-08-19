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

    private func plannerScenario() -> SeatingScenario {
        let guests = (1...28).map { Guest(id: "guest\($0)", name: "Guest \($0)", group: nil, description: nil) }
            + [Guest(id: "bartek", name: "Bartek", group: nil, description: nil), Guest(id: "nina", name: "Nina", group: nil, description: nil)]
        let tables = (1...5).reversed().map { VenueTable(id: "T\($0)", name: "Table \($0)", capacity: 6, notes: nil) }
        return SeatingScenario(scenario: "test", title: "Test", tables: tables, guests: guests)
    }
}