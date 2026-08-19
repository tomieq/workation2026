import Testing
@testable import workation2026

@Suite
struct PolicyTests {
    @Test
    func catalogueUsesOnlyKnownGuestsAndVenueLocations() {
        let scenario = policyScenario()
        let policies = SeatingPolicyCatalogue.policies(for: scenario)

        #expect(policies.contains { $0.kind == .locationPreference && $0.guestIDs == ["zosia"] && $0.tableID == "T4" })
        #expect(policies.contains { $0.kind == .locationPreference && $0.tableID == "T2" })
        #expect(policies.allSatisfy { !$0.evidence.isEmpty })
    }

    @Test
    func rejectsUnsupportedPolicyCandidates() {
        let scenario = policyScenario()
        let invalid = SeatingPolicy(kind: .companion, guestIDs: ["unknown", "zosia"], tableID: nil, priority: .companion, evidence: "invented")

        #expect(SeatingPolicyCatalogue.validated([invalid], for: scenario).isEmpty)
    }

    private func policyScenario() -> SeatingScenario {
        SeatingScenario(
            scenario: "test",
            title: "Test",
            tables: (1...5).map { VenueTable(id: "T\($0)", name: "Table", capacity: 6, notes: nil) },
            guests: [
                Guest(id: "zosia", name: "Zosia", group: "friends", description: "smoke"),
                Guest(id: "chrzestna_ania", name: "Ania", group: "family", description: "dance"),
                Guest(id: "swiadek_kuba", name: "Kuba", group: "friends", description: "dance"),
                Guest(id: "tetiana", name: "Tetiana", group: "work", description: "dance"),
                Guest(id: "bartek", name: "Bartek", group: nil, description: nil),
                Guest(id: "nina", name: "Nina", group: nil, description: nil),
            ]
        )
    }
}