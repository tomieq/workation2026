import Foundation
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
    func catalogueMapsScenario2RequirementsToExplicitPolicies() throws {
        let policies = SeatingPolicyCatalogue.policies(for: try scenario2())
        func policy(for guestIDs: [String]) -> SeatingPolicy? {
            policies.first { $0.guestIDs == guestIDs }
        }

        #expect(policy(for: ["mariusz", "slawek_m"])?.kind == .companion)
        #expect(policy(for: ["chrzestna_ania", "swiadek_kuba", "tetiana"])?.tableID == "T2")
        #expect(policy(for: ["chrzestna_ania", "swiadek_kuba", "tetiana"])?.weight == 300)
        #expect(policy(for: ["zosia"])?.tableID == "T4")
        #expect(policy(for: ["zosia"])?.weight == 300)
        #expect(policy(for: ["jacek", "leszek", "pawel"])?.tableID == "T5")
        #expect(policy(for: ["jacek", "leszek", "pawel"])?.weight == 200)
        #expect(policy(for: ["leszek", "kuba_g"])?.kind == .avoidancePreference)
        #expect(policy(for: ["leszek", "michal_z"])?.kind == .avoidancePreference)
        #expect(policy(for: ["kuba_g", "michal_z"])?.kind == .workClusterAvoidance)
        #expect(!policies.contains { $0.guestIDs.contains("michal_s") && $0.evidence.localizedCaseInsensitiveContains("Turcji") })
        #expect(!policies.contains { $0.guestIDs.contains("donald_t") || $0.guestIDs.contains("jaroslaw_k") })
        #expect(policy(for: ["klara", "przemek", "tomek"])?.weight == 75)
        #expect(policy(for: ["jakub", "maciek"])?.weight == 50)
        #expect(policy(for: ["chrzestna_ania", "gosia", "kacper", "swiadek_kuba", "tetiana"])?.weight == 100)
    }

    @Test
    func rejectsUnsupportedPolicyCandidates() {
        let scenario = policyScenario()
        let invalid = SeatingPolicy(kind: .companion, guestIDs: ["unknown", "zosia"], tableID: nil, priority: .companion, evidence: "invented")

        #expect(SeatingPolicyCatalogue.validated([invalid], for: scenario).isEmpty)
    }

    @Test
    func missingAssistantConfigurationFallsBackWithoutPolicies() async {
        #expect(await PolicyAssistant.proposedPolicies(for: policyScenario(), environment: [:]).isEmpty)
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

    private func scenario2() throws -> SeatingScenario {
        let input = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("input/scenario2.json")
        return try JSONDecoder().decode(SeatingScenario.self, from: Data(contentsOf: input))
    }
}