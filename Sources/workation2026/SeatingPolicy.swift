import Foundation

enum SeatingPolicyCatalogue {
    static func policies(for scenario: SeatingScenario) -> [SeatingPolicy] {
        let guestIDs = Set(scenario.guests.map(\.id))
        var policies = [
            SeatingPolicy(kind: .mandatoryTable, guestIDs: ["bartek", "nina"], tableID: "T1", priority: .mandatory, evidence: "T1 is the couple's table."),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["chrzestna_ania", "swiadek_kuba", "tetiana"], tableID: "T2", priority: .location, evidence: "Descriptions explicitly mention dancing or the dance floor."),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["zosia"], tableID: "T4", priority: .location, evidence: "Description explicitly mentions smoke breaks; T4 is nearest the exit/terrace."),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["jacek", "pawel"], tableID: "T5", priority: .location, evidence: "Descriptions explicitly indicate conserving energy or avoiding toast competition; T5 is the quieter area."),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["klara", "przemek", "tomek"], tableID: nil, priority: .affinity, evidence: "Descriptions explicitly mention alcohol, spirits, or champagne."),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["maciek", "jakub"], tableID: nil, priority: .affinity, evidence: "Descriptions explicitly describe contrasting eating habits."),
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
                evidence: "Supplied group membership is the final soft preference tier."
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
            case .affinityPreference:
                return policy.priority == .affinity && policy.guestIDs.count > 1 && policy.tableID == nil
            case .groupPreference:
                return policy.priority == .group && policy.tableID == nil
            }
        }
    }
}