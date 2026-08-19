import Foundation

enum SeatingPolicyCatalogue {
    static func policies(for scenario: SeatingScenario) -> [SeatingPolicy] {
        let guestIDs = Set(scenario.guests.map(\.id))
        var policies = [
            SeatingPolicy(kind: .mandatoryTable, guestIDs: ["bartek", "nina"], tableID: "T1", priority: .mandatory, evidence: "T1 is the couple's table."),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["chrzestna_ania", "swiadek_kuba", "tetiana"], tableID: "T2", priority: .location, evidence: "Descriptions explicitly mention dancing or the dance floor."),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["zosia"], tableID: "T4", priority: .location, evidence: "Description explicitly mentions smoke breaks; T4 is nearest the exit/terrace."),
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
        return candidates.filter { policy in
            guard !policy.guestIDs.isEmpty,
                  Set(policy.guestIDs).isSubset(of: guestIDs),
                  !policy.evidence.isEmpty else { return false }
            switch policy.kind {
            case .mandatoryTable:
                return policy.priority == .mandatory && policy.tableID == "T1"
            case .separate:
                return policy.priority == .separation && policy.guestIDs.count == 2 && policy.tableID == nil
            case .companion:
                return policy.priority == .companion && policy.guestIDs.count == 2 && policy.tableID == nil
            case .locationPreference:
                return policy.priority == .location && policy.tableID.map(tableIDs.contains) == true
            case .groupPreference:
                return policy.priority == .group && policy.tableID == nil
            }
        }
    }
}