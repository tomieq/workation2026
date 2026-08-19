import Foundation

enum SeatingPolicyCatalogue {
    static func policies(for scenario: SeatingScenario) -> [SeatingPolicy] {
        let guestIDs = Set(scenario.guests.map(\.id))
        var policies = [
            SeatingPolicy(kind: .mandatoryTable, guestIDs: ["bartek", "nina"], tableID: "T1", priority: .mandatory, evidence: "T1 is the couple's table."),
            SeatingPolicy(kind: .companion, guestIDs: ["mariusz", "slawek_m"], tableID: nil, priority: .companion, evidence: "Mariusz explicitly likes Sławek M."),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["chrzestna_ania", "swiadek_kuba"], tableID: "T1", priority: .location, evidence: "The named godmother and witness provide ceremonial support at the couple's table.", weight: 20_000),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["chrzestna_ania", "swiadek_kuba", "tetiana"], tableID: "T2", priority: .location, evidence: "Descriptions explicitly mention dancing or the dance floor.", weight: 300),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["zosia"], tableID: "T4", priority: .location, evidence: "Description explicitly mentions smoke breaks; T4 is nearest the exit/terrace.", weight: 300),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["jacek", "leszek", "pawel"], tableID: "T5", priority: .location, evidence: "Descriptions explicitly indicate conserving energy or avoiding toast competition; T5 is the quieter area.", weight: 200),
            SeatingPolicy(kind: .avoidancePreference, guestIDs: ["leszek", "kuba_g"], tableID: nil, priority: .avoidance, evidence: "Z Leszkiem relacja jest na tyle profesjonalna, że najlepiej działa przy odpowiedniej odległości między krzesłami.", weight: 150),
            SeatingPolicy(kind: .avoidancePreference, guestIDs: ["leszek", "michal_z"], tableID: nil, priority: .avoidance, evidence: "Wspólny stolik daje Leszkowi niebezpiecznie dużo czasu na rozwinięcie tej opinii.", weight: 150),
            SeatingPolicy(kind: .workClusterAvoidance, guestIDs: ["kuba_g", "michal_z"], tableID: nil, priority: .avoidance, evidence: "Na wesele przyjechał przede wszystkim do Bartka, nie na firmowy offsite.", weight: 150),
            SeatingPolicy(kind: .riskClusterAvoidance, guestIDs: ["ada", "agnieszka", "zdzisiek", "klara", "przemek", "tomek", "slawek_m", "kuba_s"], tableID: nil, priority: .avoidance, evidence: "Public guest descriptions identify direct feedback, plate throwing, rapid topic changes, drinks, debate, QA escalation, and wildcard behavior as high-intensity signals.", weight: 300),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["chrzestna_ania", "gosia", "kacper", "swiadek_kuba", "tetiana"], tableID: nil, priority: .affinity, evidence: "Descriptions explicitly indicate dancing, a performance, or keeping the celebration going.", weight: 100),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["klara", "przemek", "tomek"], tableID: nil, priority: .affinity, evidence: "Descriptions explicitly mention alcohol, spirits, or champagne.", weight: 75),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["jakub", "maciek"], tableID: nil, priority: .affinity, evidence: "Descriptions explicitly describe contrasting eating habits.", weight: 50),
        ]

        let groups = Dictionary(grouping: scenario.guests.filter {
            !($0.group?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }, by: { $0.group! })
        for guests in groups.values where guests.count > 1 {
            policies.append(SeatingPolicy(
                kind: .groupPreference,
                guestIDs: guests.map(\.id).sorted(),
                tableID: nil,
                priority: .group,
                evidence: "Supplied group membership is the final soft preference tier.",
                weight: 1
            ))
        }
        return policies.filter { Set($0.guestIDs).isSubset(of: guestIDs) }
    }

    static func validated(_ candidates: [SeatingPolicy], for scenario: SeatingScenario) -> [SeatingPolicy] {
        let guestIDs = Set(scenario.guests.map(\.id))
        let tableIDs = Set(scenario.tables.map(\.id))
        let evidenceSources = scenario.tables.compactMap(\.notes) + scenario.guests.compactMap(\.description)
        return candidates.filter { policy in
            guard !policy.guestIDs.isEmpty,
                  Set(policy.guestIDs).isSubset(of: guestIDs),
                  !policy.evidence.isEmpty,
                  evidenceSources.contains(where: { $0.range(of: policy.evidence, options: .caseInsensitive) != nil }) else { return false }
            switch policy.kind {
            case .mandatoryTable:
                return policy.priority == .mandatory && policy.tableID == "T1"
            case .separate:
                return policy.priority == .separation && policy.guestIDs.count == 2 && policy.tableID == nil
            case .companion:
                return policy.priority == .companion && policy.guestIDs.count == 2 && policy.tableID == nil
            case .locationPreference:
                return policy.priority == .location && policy.tableID.map(tableIDs.contains) == true
            case .avoidancePreference:
                return policy.priority == .avoidance && policy.guestIDs.count == 2 && policy.tableID == nil && policy.weight > 0
            case .workClusterAvoidance:
                return policy.priority == .avoidance && policy.guestIDs.count > 0 && policy.tableID == nil && policy.weight > 0
            case .riskClusterAvoidance:
                return policy.priority == .avoidance && policy.guestIDs.count > 0 && policy.tableID == nil && policy.weight > 0
            case .affinityPreference:
                return policy.priority == .affinity && policy.guestIDs.count > 1 && policy.tableID == nil
            case .groupPreference:
                return policy.priority == .group && policy.tableID == nil
            }
        }
    }
}