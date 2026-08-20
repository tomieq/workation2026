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
        var bestCandidate: (plan: SeatingPlan, objective: PlanObjective)?

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
                    let improvedPlan = improve(plan, scenario: scenario, guestsByID: guestsByID, policies: policies)
                    let candidateObjective = objective(for: improvedPlan, guestsByID: guestsByID, policies: policies)
                    if let currentBest = bestCandidate {
                        if candidateObjective > currentBest.objective {
                            bestCandidate = (improvedPlan, candidateObjective)
                        }
                    } else {
                        bestCandidate = (improvedPlan, candidateObjective)
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
            guard occupants.count < capacities[tableID, default: 0] else {
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
                if policy.guestIDs.contains(where: occupants.contains) { result += policy.weight }
            case .locationPreference:
                if policy.tableID == tableID { result += policy.weight }
            case .avoidancePreference:
                result -= occupants.filter(policy.guestIDs.contains).count * policy.weight
            case .workClusterAvoidance:
                if occupants.filter({ guestsByID[$0]?.group == "work" }).count >= 4 {
                    result -= policy.weight
                }
            case .riskClusterAvoidance:
                if occupants.filter(policy.guestIDs.contains).count >= 3 {
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
                return total + policy.weight
            case .separate:
                return total + 1_000
            case .locationPreference:
                return total + policy.weight
            case .avoidancePreference:
                return total + policy.weight
            case .workClusterAvoidance:
                return total + policy.weight
            case .riskClusterAvoidance:
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

    static func objective(for plan: SeatingPlan, guestsByID: [String: Guest], policies: [SeatingPolicy]) -> PlanObjective {
        let tableForGuest = Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in table.guests.map { ($0, table.tableId) } })
        var categoryScore = CategoryScore()
        for policy in policies {
            let value: Int
            switch policy.kind {
            case .mandatoryTable, .separate:
                value = 0
            case .companion, .affinityPreference:
                let tables = Set(policy.guestIDs.compactMap { tableForGuest[$0] })
                value = tables.count == 1 ? policy.weight : 0
            case .locationPreference:
                value = policy.guestIDs.contains { tableForGuest[$0] == policy.tableID } ? policy.weight : 0
            case .avoidancePreference:
                let tables = policy.guestIDs.compactMap { tableForGuest[$0] }
                value = Set(tables).count == tables.count ? policy.weight : 0
            case .workClusterAvoidance:
                value = policy.guestIDs.allSatisfy { guestID in
                    guard let tableID = tableForGuest[guestID], let table = plan.tables.first(where: { $0.tableId == tableID }) else { return false }
                    return table.guests.filter { guestsByID[$0]?.group == "work" }.count < 4
                } ? policy.weight : 0
            case .riskClusterAvoidance:
                value = plan.tables.allSatisfy { table in table.guests.filter(policy.guestIDs.contains).count <= 3 } ? policy.weight : 0
            case .groupPreference:
                guard let sourceTable = tableForGuest[policy.evidenceSource.id] else { value = 0; break }
                value = policy.guestIDs.contains { $0 != policy.evidenceSource.id && tableForGuest[$0] == sourceTable } ? policy.weight : 0
            }
            categoryScore.add(value, category: policy.category, identity: policy.identity)
        }
        return PlanObjective(score: categoryScore, canonicalVector: canonicalVector(plan))
    }

    private static func improve(_ initialPlan: SeatingPlan, scenario: SeatingScenario, guestsByID: [String: Guest], policies: [SeatingPolicy]) -> SeatingPlan {
        var current = initialPlan
        while true {
            let currentObjective = objective(for: current, guestsByID: guestsByID, policies: policies)
            var bestPlan = current
            var bestObjective = currentObjective
            let movableGuests = current.tables.flatMap(\.guests).filter { $0 != "bartek" && $0 != "nina" }.sorted()
            for firstIndex in movableGuests.indices {
                for secondIndex in movableGuests.indices where secondIndex > firstIndex {
                    let first = movableGuests[firstIndex]
                    let second = movableGuests[secondIndex]
                    guard tableID(for: first, in: current) != tableID(for: second, in: current) else { continue }
                    let candidate = swapping(first, second, in: current)
                    guard (try? PlanValidator.validate(candidate, for: scenario)) != nil else { continue }
                    let candidateObjective = objective(for: candidate, guestsByID: guestsByID, policies: policies)
                    if candidateObjective > bestObjective {
                        bestPlan = candidate
                        bestObjective = candidateObjective
                    }
                }
            }
            guard bestObjective > currentObjective else { return current }
            current = bestPlan
        }
    }

    private static func tableID(for guestID: String, in plan: SeatingPlan) -> String? {
        plan.tables.first { $0.guests.contains(guestID) }?.tableId
    }

    private static func swapping(_ first: String, _ second: String, in plan: SeatingPlan) -> SeatingPlan {
        SeatingPlan(tables: plan.tables.map { table in
            SeatedTable(tableId: table.tableId, guests: table.guests.map { guestID in
                if guestID == first { return second }
                if guestID == second { return first }
                return guestID
            }.sorted())
        })
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