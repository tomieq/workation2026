import Foundation

enum CatalogueValidationError: Error, Equatable, CustomStringConvertible {
    case duplicateSource(String)
    case missingSource(String)
    case unexpectedSource(String)
    case evidenceMismatch(String)
    case missingClassification(String)

    var description: String {
        switch self {
        case let .duplicateSource(id): "Catalogue contains duplicate source \(id)."
        case let .missingSource(id): "Catalogue is missing source \(id)."
        case let .unexpectedSource(id): "Catalogue contains unexpected source \(id)."
        case let .evidenceMismatch(id): "Catalogue evidence does not exactly match source \(id)."
        case let .missingClassification(id): "Catalogue source \(id) has no category or non-actionable reason."
        }
    }
}

enum SeatingPolicyCatalogue {
    static func entries(for scenario: SeatingScenario) -> [EvidenceCatalogueEntry] {
        let policiesBySource = Dictionary(grouping: builtInPolicies(for: scenario), by: \.evidenceSource)
        let tableEntries = scenario.tables.compactMap { table -> EvidenceCatalogueEntry? in
            guard let evidence = table.notes else { return nil }
            let source = EvidenceSource.table(table.id)
            let policies = policiesBySource[source, default: []]
            return EvidenceCatalogueEntry(
                source: source,
                evidence: evidence,
                categories: tableCategories[table.id, default: [.location]],
                policies: policies,
                nonActionableReason: policies.isEmpty ? "The note defines neutral fallback placement context." : nil
            )
        }
        let guestEntries = scenario.guests.compactMap { guest -> EvidenceCatalogueEntry? in
            guard let evidence = guest.description else { return nil }
            let source = EvidenceSource.guest(guest.id)
            let policies = policiesBySource[source, default: []]
            return EvidenceCatalogueEntry(
                source: source,
                evidence: evidence,
                categories: guestCategories[guest.id, default: [.balance]],
                policies: policies,
                nonActionableReason: policies.isEmpty ? nonActionableReason(for: guest.id) : nil
            )
        }
        return (tableEntries + guestEntries).sorted { lhs, rhs in
            if lhs.source.id != rhs.source.id { return lhs.source.id < rhs.source.id }
            return String(describing: lhs.source) < String(describing: rhs.source)
        }
    }

    static func validatedEntries(for scenario: SeatingScenario) throws -> [EvidenceCatalogueEntry] {
        let entries = entries(for: scenario)
        try validate(entries, for: scenario)
        return entries
    }

    static func policies(for scenario: SeatingScenario) -> [SeatingPolicy] {
        entries(for: scenario).flatMap(\.policies)
    }

    static func validate(_ entries: [EvidenceCatalogueEntry], for scenario: SeatingScenario) throws {
        let expected = expectedEvidence(for: scenario)
        var seen = Set<EvidenceSource>()
        for entry in entries {
            guard seen.insert(entry.source).inserted else {
                throw CatalogueValidationError.duplicateSource(entry.source.id)
            }
            guard let evidence = expected[entry.source] else {
                throw CatalogueValidationError.unexpectedSource(entry.source.id)
            }
            guard entry.evidence == evidence else {
                throw CatalogueValidationError.evidenceMismatch(entry.source.id)
            }
            guard !entry.categories.isEmpty,
                  entry.isActionable || !(entry.nonActionableReason?.isEmpty ?? true) else {
                throw CatalogueValidationError.missingClassification(entry.source.id)
            }
        }
        for source in expected.keys where !seen.contains(source) {
            throw CatalogueValidationError.missingSource(source.id)
        }
    }

    private static func builtInPolicies(for scenario: SeatingScenario) -> [SeatingPolicy] {
        let guestIDs = Set(scenario.guests.map(\.id))
        let guests = Dictionary(uniqueKeysWithValues: scenario.guests.map { ($0.id, $0) })
        let tables = Dictionary(uniqueKeysWithValues: scenario.tables.map { ($0.id, $0) })
        func evidence(_ id: String) -> String { guests[id]?.description ?? "" }
        func note(_ id: String) -> String { tables[id]?.notes ?? "" }
        var policies = [
            SeatingPolicy(kind: .locationPreference, guestIDs: ["chrzestna_ania", "swiadek_kuba", "kuba_g", "michal_z"], tableID: "T1", priority: .location, evidence: note("T1"), weight: 500, category: .t1Production, evidenceSource: .table("T1")),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["chrzestna_ania", "swiadek_kuba", "tetiana"], tableID: "T2", priority: .location, evidence: note("T2"), weight: 300, category: .location, evidenceSource: .table("T2")),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["mama_ela", "oliwia", "babcia_ela", "piotr", "michal_s"], tableID: "T3", priority: .location, evidence: note("T3"), weight: 30, category: .location, evidenceSource: .table("T3")),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["zosia"], tableID: "T4", priority: .location, evidence: note("T4"), weight: 300, category: .location, evidenceSource: .table("T4")),
            SeatingPolicy(kind: .locationPreference, guestIDs: ["jacek", "pawel"], tableID: "T5", priority: .location, evidence: note("T5"), weight: 250, category: .location, evidenceSource: .table("T5")),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["mama_ela", "oliwia"], tableID: nil, priority: .affinity, evidence: evidence("mama_ela"), weight: 80, category: .relationships, evidenceSource: .guest("mama_ela")),
            SeatingPolicy(kind: .companion, guestIDs: ["mariusz", "slawek_m"], tableID: nil, priority: .companion, evidence: evidence("mariusz"), weight: 250, category: .relationships, evidenceSource: .guest("mariusz")),
            SeatingPolicy(kind: .avoidancePreference, guestIDs: ["leszek", "michal_z"], tableID: nil, priority: .avoidance, evidence: evidence("leszek"), weight: 250, category: .relationships, evidenceSource: .guest("leszek")),
            SeatingPolicy(kind: .avoidancePreference, guestIDs: ["leszek", "kuba_g"], tableID: nil, priority: .avoidance, evidence: evidence("kuba_g"), weight: 250, category: .relationships, evidenceSource: .guest("kuba_g")),
            SeatingPolicy(kind: .companion, guestIDs: ["bartek", "kuba_g"], tableID: nil, priority: .companion, evidence: evidence("kuba_g"), weight: 400, category: .relationships, evidenceSource: .guest("kuba_g")),
            SeatingPolicy(kind: .companion, guestIDs: ["bartek", "michal_z"], tableID: nil, priority: .companion, evidence: evidence("michal_z"), weight: 400, category: .relationships, evidenceSource: .guest("michal_z")),
            SeatingPolicy(kind: .workClusterAvoidance, guestIDs: ["kuba_g"], tableID: nil, priority: .avoidance, evidence: evidence("kuba_g"), weight: 180, category: .teamGrouping, evidenceSource: .guest("kuba_g")),
            SeatingPolicy(kind: .workClusterAvoidance, guestIDs: ["michal_z"], tableID: nil, priority: .avoidance, evidence: evidence("michal_z"), weight: 180, category: .teamGrouping, evidenceSource: .guest("michal_z")),
            SeatingPolicy(kind: .riskClusterAvoidance, guestIDs: ["ada", "agnieszka", "zdzisiek", "amelka", "klara", "przemek", "slawek_m", "kuba_s"], tableID: nil, priority: .avoidance, evidence: evidence("agnieszka"), weight: 120, category: .risk, evidenceSource: .guest("agnieszka")),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["chrzestna_ania", "gosia", "kacper", "swiadek_kuba", "tetiana"], tableID: nil, priority: .affinity, evidence: evidence("gosia"), weight: 60, category: .balance, evidenceSource: .guest("gosia")),
            SeatingPolicy(kind: .affinityPreference, guestIDs: ["klara", "przemek", "tomek"], tableID: nil, priority: .affinity, evidence: evidence("klara"), weight: 40, category: .relationships, evidenceSource: .guest("klara")),
        ]

        let groups = Dictionary(grouping: scenario.guests.filter {
            !($0.group?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        }, by: { $0.group! })
        for guests in groups.values where guests.count > 1 {
            for guest in guests {
                guard guest.id != "piotr" else { continue }
                guard let description = guest.description else { continue }
                policies.append(SeatingPolicy(kind: .groupPreference, guestIDs: guests.map(\.id).sorted(), tableID: nil, priority: .group, evidence: description, weight: 1, category: .teamGrouping, evidenceSource: .guest(guest.id)))
            }
        }
        return policies.filter { !$0.evidence.isEmpty && Set($0.guestIDs).isSubset(of: guestIDs) }
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
                return false
            case .separate:
                return false
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

    private static func expectedEvidence(for scenario: SeatingScenario) -> [EvidenceSource: String] {
        var result = Dictionary(uniqueKeysWithValues: scenario.tables.compactMap { table in
            table.notes.map { (EvidenceSource.table(table.id), $0) }
        })
        for guest in scenario.guests {
            if let description = guest.description { result[.guest(guest.id)] = description }
        }
        return result
    }

    private static func nonActionableReason(for guestID: String) -> String {
        switch guestID {
        case "piotr": "The dance report is explicitly unconfirmed."
        case "michal_s": "The hair-club story does not imply placement, affinity, or avoidance."
        default: "The evidence is categorized for audit; concrete effects are defined by the built-in policy catalogue."
        }
    }

    private static let tableCategories: [String: [CompetitionCategory]] = [
        "T1": [.t1Production, .relationships], "T2": [.location, .balance], "T3": [.location, .balance],
        "T4": [.location, .risk], "T5": [.location, .balance, .risk],
    ]

    private static let guestCategories: [String: [CompetitionCategory]] = [
        "mama_ela": [.relationships, .balance], "oliwia": [.relationships, .balance], "babcia_ela": [.balance],
        "piotr": [.balance], "agnieszka": [.risk, .balance], "zdzisiek": [.risk, .balance],
        "chrzestna_ania": [.t1Production, .location, .balance], "zosia": [.location, .relationships], "gosia": [.balance],
        "amelka": [.risk, .balance], "ada": [.risk, .balance], "kacper": [.location, .balance],
        "klara": [.relationships, .risk], "jacek": [.location, .balance], "swiadek_kuba": [.t1Production, .location, .balance],
        "przemek": [.teamGrouping, .relationships, .risk], "pawel": [.teamGrouping, .location, .balance],
        "leszek": [.teamGrouping, .relationships, .risk], "mariusz": [.teamGrouping, .relationships, .balance],
        "tomek": [.teamGrouping, .relationships, .balance], "slawek_m": [.relationships, .risk, .balance],
        "maciek": [.teamGrouping, .relationships, .balance], "michal": [.teamGrouping, .balance],
        "jakub": [.teamGrouping, .balance], "tetiana": [.teamGrouping, .location, .balance],
        "kuba_s": [.teamGrouping, .risk, .balance], "bartek": [.t1Production], "nina": [.t1Production],
        "kuba_g": [.relationships, .t1Production, .teamGrouping, .risk],
        "michal_z": [.relationships, .t1Production, .teamGrouping, .risk], "michal_s": [.teamGrouping, .balance],
    ]
}