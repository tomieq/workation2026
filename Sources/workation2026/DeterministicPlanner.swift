import Foundation

enum PlanningError: Error, CustomStringConvertible {
    case noValidAssignment(String)

    var description: String {
        switch self {
        case let .noValidAssignment(message):
            return "No valid seating assignment: \(message)"
        }
    }
}

enum DeterministicPlanner {
    static func plan(for scenario: SeatingScenario, policies: [SeatingPolicy] = []) throws -> SeatingPlan {
        try ScenarioValidator.validate(scenario)
        let tableIDs = scenario.tables.map(\.id).sorted()
        let guestsByID = Dictionary(uniqueKeysWithValues: scenario.guests.map { ($0.id, $0) })
        let mandatory = Set(["bartek", "nina"])
        var assignments = Dictionary(uniqueKeysWithValues: tableIDs.map { ($0, [String]()) })
        assignments["T1"] = mandatory.sorted()

        let remainingIDs = Set(guestsByID.keys).subtracting(mandatory)
        let orderedGuests = remainingIDs.sorted { lhs, rhs in
            preferenceWeight(for: lhs, policies: policies) > preferenceWeight(for: rhs, policies: policies)
                || (preferenceWeight(for: lhs, policies: policies) == preferenceWeight(for: rhs, policies: policies) && lhs < rhs)
        }

        for guestID in orderedGuests {
            guard let tableID = bestTable(for: guestID, tableIDs: tableIDs, assignments: assignments, guestsByID: guestsByID, policies: policies) else {
                throw PlanningError.noValidAssignment("could not seat \(guestID)")
            }
            assignments[tableID, default: []].append(guestID)
        }

        let plan = SeatingPlan(tables: tableIDs.map { tableID in
            SeatedTable(tableId: tableID, guests: assignments[tableID, default: []].sorted())
        })
        try PlanValidator.validate(plan, for: scenario)
        return plan
    }

    private static func bestTable(
        for guestID: String,
        tableIDs: [String],
        assignments: [String: [String]],
        guestsByID: [String: Guest],
        policies: [SeatingPolicy]
    ) -> String? {
        tableIDs.compactMap { tableID -> (tableID: String, score: Int)? in
            let occupants = assignments[tableID, default: []]
            guard occupants.count < 6, respectsHardPolicies(guestID, tableID: tableID, assignments: assignments, policies: policies) else {
                return nil
            }
            return (tableID, score(for: guestID, tableID: tableID, occupants: occupants, guestsByID: guestsByID, policies: policies))
        }
        .sorted { lhs, rhs in lhs.score != rhs.score ? lhs.score > rhs.score : lhs.tableID < rhs.tableID }
        .first?
        .tableID
    }

    private static func respectsHardPolicies(_ guestID: String, tableID: String, assignments: [String: [String]], policies: [SeatingPolicy]) -> Bool {
        let occupants = assignments[tableID, default: []]
        for policy in policies {
            switch policy.kind {
            case .mandatoryTable:
                if policy.guestIDs.contains(guestID), policy.tableID != tableID { return false }
            case .separate:
                if policy.guestIDs.contains(guestID), policy.guestIDs.contains(where: occupants.contains) { return false }
            case .companion:
                if policy.guestIDs.contains(guestID) {
                    let assignedTable = assignments.first { _, assignedGuests in
                        policy.guestIDs.contains { $0 != guestID && assignedGuests.contains($0) }
                    }?.key
                    if let assignedTable, assignedTable != tableID { return false }
                }
            case .locationPreference, .affinityPreference, .groupPreference:
                continue
            }
        }
        return true
    }

    private static func score(
        for guestID: String,
        tableID: String,
        occupants: [String],
        guestsByID: [String: Guest],
        policies: [SeatingPolicy]
    ) -> Int {
        var result = 0
        for policy in policies where policy.guestIDs.contains(guestID) {
            switch policy.kind {
            case .companion:
                if policy.guestIDs.contains(where: occupants.contains) { result += 10_000 }
            case .locationPreference:
                if policy.tableID == tableID { result += 100 }
            case .affinityPreference:
                result += occupants.filter(policy.guestIDs.contains).count * 10
            case .groupPreference:
                let group = guestsByID[guestID]?.group?.trimmingCharacters(in: .whitespacesAndNewlines)
                if !group.isNilOrEmpty {
                    result += occupants.filter { guestsByID[$0]?.group == group }.count
                }
            case .mandatoryTable, .separate:
                continue
            }
        }
        return result
    }

    private static func preferenceWeight(for guestID: String, policies: [SeatingPolicy]) -> Int {
        policies.filter { $0.guestIDs.contains(guestID) }.reduce(0) { total, policy in
            switch policy.kind {
            case .companion:
                return total + 10_000
            case .separate:
                return total + 1_000
            case .locationPreference:
                return total + 100
            case .affinityPreference:
                return total + 10
            case .mandatoryTable, .groupPreference:
                return total
            }
        }
    }
}

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}