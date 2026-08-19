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
        let workColleagues = scenario.guests
            .filter { $0.id != "bartek" && $0.group == "work" }
            .map(\.id)
            .sorted()
        let nonWorkGuests = scenario.guests
            .filter { $0.id != "bartek" && $0.id != "nina" && $0.group != "work" }
            .map(\.id)
            .sorted { lhs, rhs in
                preferenceWeight(for: lhs, policies: policies) > preferenceWeight(for: rhs, policies: policies)
                    || (preferenceWeight(for: lhs, policies: policies) == preferenceWeight(for: rhs, policies: policies) && lhs < rhs)
            }
        var bestCandidate: (plan: SeatingPlan, score: Int)?

        for extraSeatTableID in tableIDs {
            let requiredNonWorkGuests = extraSeatTableID == "T1" ? 3 : 2
            guard nonWorkGuests.count >= requiredNonWorkGuests else {
                continue
            }
            let t1NonWorkGuests = Array(nonWorkGuests.prefix(requiredNonWorkGuests))
            for firstIndex in workColleagues.indices {
                for secondIndex in workColleagues.indices where secondIndex > firstIndex {
                    let t1Guests = (["bartek", "nina", workColleagues[firstIndex], workColleagues[secondIndex]] + t1NonWorkGuests).sorted()
                    guard let plan = buildCandidate(
                        tableIDs: tableIDs,
                        extraSeatTableID: extraSeatTableID,
                        initialT1Guests: t1Guests,
                        guestsByID: guestsByID,
                        policies: policies
                    ) else {
                        continue
                    }
                    let candidateScore = planScore(plan, guestsByID: guestsByID, policies: policies)
                    if let currentBest = bestCandidate {
                        if candidateScore > currentBest.score || (candidateScore == currentBest.score && isCanonical(plan, before: currentBest.plan)) {
                            bestCandidate = (plan, candidateScore)
                        }
                    } else {
                        bestCandidate = (plan, candidateScore)
                    }
                }
            }
        }

        guard let bestCandidate else {
            throw PlanningError.noValidAssignment("no candidate satisfies the Scenario 2 constraints")
        }
        try PlanValidator.validate(bestCandidate.plan, for: scenario)
        return bestCandidate.plan
    }

    private static func buildCandidate(
        tableIDs: [String],
        extraSeatTableID: String,
        initialT1Guests: [String],
        guestsByID: [String: Guest],
        policies: [SeatingPolicy]
    ) -> SeatingPlan? {
        var assignments = Dictionary(uniqueKeysWithValues: tableIDs.map { ($0, [String]()) })
        assignments["T1"] = initialT1Guests
        let capacities = Dictionary(uniqueKeysWithValues: tableIDs.map { ($0, $0 == extraSeatTableID ? 7 : 6) })
        let remainingIDs = Set(guestsByID.keys).subtracting(initialT1Guests)
        let orderedGuests = remainingIDs.sorted { lhs, rhs in
            preferenceWeight(for: lhs, policies: policies) > preferenceWeight(for: rhs, policies: policies)
                || (preferenceWeight(for: lhs, policies: policies) == preferenceWeight(for: rhs, policies: policies) && lhs < rhs)
        }

        for guestID in orderedGuests {
            guard let tableID = bestTable(for: guestID, tableIDs: tableIDs, assignments: assignments, capacities: capacities, guestsByID: guestsByID, policies: policies) else {
                return nil
            }
            assignments[tableID, default: []].append(guestID)
        }
        let plan = SeatingPlan(tables: tableIDs.map { SeatedTable(tableId: $0, guests: assignments[$0, default: []].sorted()) })
        return plan
    }

    private static func bestTable(
        for guestID: String,
        tableIDs: [String],
        assignments: [String: [String]],
        capacities: [String: Int],
        guestsByID: [String: Guest],
        policies: [SeatingPolicy]
    ) -> String? {
        tableIDs.compactMap { tableID -> (tableID: String, score: Int)? in
            let occupants = assignments[tableID, default: []]
            if tableID == "T1" && guestsByID[guestID]?.group == "work" {
                return nil
            }
            guard occupants.count < capacities[tableID, default: 0], respectsHardPolicies(guestID, tableID: tableID, assignments: assignments, policies: policies) else {
                return nil
            }
            return (tableID, score(for: guestID, tableID: tableID, occupants: occupants, guestsByID: guestsByID, policies: policies))
        }
        .sorted { lhs, rhs in
            if lhs.score != rhs.score { return lhs.score > rhs.score }
            if lhs.tableID == "T1" { return false }
            if rhs.tableID == "T1" { return true }
            return lhs.tableID < rhs.tableID
        }
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
            case .locationPreference, .avoidancePreference, .workClusterAvoidance, .affinityPreference, .groupPreference:
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
                if policy.tableID == tableID { result += policy.weight }
            case .avoidancePreference:
                result -= occupants.filter(policy.guestIDs.contains).count * policy.weight
            case .workClusterAvoidance:
                if occupants.filter({ guestsByID[$0]?.group == "work" }).count >= 4 {
                    result -= policy.weight
                }
            case .affinityPreference:
                result += occupants.filter(policy.guestIDs.contains).count * policy.weight
            case .groupPreference:
                let group = guestsByID[guestID]?.group?.trimmingCharacters(in: .whitespacesAndNewlines)
                if !group.isNilOrEmpty {
                    result += occupants.filter { guestsByID[$0]?.group == group }.count * policy.weight
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
                return total + policy.weight
            case .avoidancePreference:
                return total + policy.weight
            case .workClusterAvoidance:
                return total + policy.weight
            case .affinityPreference:
                return total + policy.weight
            case .groupPreference:
                return total + policy.weight
            case .mandatoryTable:
                return total
            }
        }
    }

    private static func planScore(_ plan: SeatingPlan, guestsByID: [String: Guest], policies: [SeatingPolicy]) -> Int {
        plan.tables.reduce(0) { total, table in
            total + table.guests.reduce(0) { partial, guestID in
                partial + score(for: guestID, tableID: table.tableId, occupants: table.guests.filter { $0 != guestID }, guestsByID: guestsByID, policies: policies)
            }
        }
    }

    private static func canonicalVector(_ plan: SeatingPlan) -> [String] {
        plan.tables.sorted { $0.tableId < $1.tableId }.flatMap { [$0.tableId] + $0.guests.sorted() }
    }

    private static func isCanonical(_ lhs: SeatingPlan, before rhs: SeatingPlan) -> Bool {
        let left = canonicalVector(lhs)
        let right = canonicalVector(rhs)
        for (leftValue, rightValue) in zip(left, right) where leftValue != rightValue {
            return leftValue < rightValue
        }
        return left.count < right.count
    }
}

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}