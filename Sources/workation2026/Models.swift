import Foundation

struct SeatingScenario: Codable, Equatable {
    let scenario: String
    let title: String
    let extraSeatPolicy: ExtraSeatPolicy?
    let tables: [VenueTable]
    let guests: [Guest]

    init(
        scenario: String,
        title: String,
        extraSeatPolicy: ExtraSeatPolicy? = nil,
        tables: [VenueTable],
        guests: [Guest]
    ) {
        self.scenario = scenario
        self.title = title
        self.extraSeatPolicy = extraSeatPolicy
        self.tables = tables
        self.guests = guests
    }
}

struct ExtraSeatPolicy: Codable, Equatable {
    let extraSeats: Int
    let canBeAddedToAnyTable: Bool
}

struct VenueTable: Codable, Equatable {
    let id: String
    let name: String
    let capacity: Int
    let notes: String?
}

struct Guest: Codable, Equatable {
    let id: String
    let name: String
    let group: String?
    let description: String?
}

enum CompetitionCategory: String, Codable, CaseIterable, Comparable {
    case teamGrouping = "Grupowanie zespołu"
    case location = "Lokalizacja"
    case relationships = "Relacje"
    case t1Production = "T1 Production"
    case balance = "Balans"
    case risk = "Ryzyko"

    static func < (lhs: CompetitionCategory, rhs: CompetitionCategory) -> Bool {
        guard let left = allCases.firstIndex(of: lhs), let right = allCases.firstIndex(of: rhs) else {
            return lhs.rawValue < rhs.rawValue
        }
        return left < right
    }
}

enum EvidenceSource: Hashable, Equatable {
    case table(String)
    case guest(String)

    var id: String {
        switch self {
        case let .table(id), let .guest(id): id
        }
    }
}

enum SeatingPolicyKind: String, Codable, CaseIterable {
    case mandatoryTable
    case separate
    case companion
    case locationPreference
    case avoidancePreference
    case workClusterAvoidance
    case riskClusterAvoidance
    case affinityPreference
    case groupPreference
}

enum SeatingPolicyPriority: Int, Codable, Comparable, CaseIterable {
    case structural
    case mandatory
    case separation
    case companion
    case location
    case avoidance
    case affinity
    case group

    static func < (lhs: SeatingPolicyPriority, rhs: SeatingPolicyPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct SeatingPolicy: Equatable {
    let kind: SeatingPolicyKind
    let guestIDs: [String]
    let tableID: String?
    let priority: SeatingPolicyPriority
    let category: CompetitionCategory
    let evidenceSource: EvidenceSource
    let evidence: String
    let weight: Int

    init(
        kind: SeatingPolicyKind,
        guestIDs: [String],
        tableID: String?,
        priority: SeatingPolicyPriority,
        evidence: String,
        weight: Int? = nil,
        category: CompetitionCategory? = nil,
        evidenceSource: EvidenceSource? = nil
    ) {
        self.kind = kind
        self.guestIDs = guestIDs
        self.tableID = tableID
        self.priority = priority
        self.category = category ?? priority.defaultCategory
        self.evidenceSource = evidenceSource ?? .guest(guestIDs.first ?? "unknown")
        self.evidence = evidence
        self.weight = weight ?? priority.defaultWeight
    }

    var identity: String {
        "\(evidenceSource.id)|\(category.rawValue)|\(kind.rawValue)|\(guestIDs.sorted().joined(separator: ","))|\(tableID ?? "")"
    }
}

struct EvidenceCatalogueEntry: Equatable {
    let source: EvidenceSource
    let evidence: String
    let categories: [CompetitionCategory]
    let policies: [SeatingPolicy]
    let nonActionableReason: String?

    var isActionable: Bool { !policies.isEmpty }
}

struct CategoryScore: Equatable {
    private(set) var values: [CompetitionCategory: Int] = [:]
    private(set) var countedIdentities: Set<String> = []

    mutating func add(_ value: Int, category: CompetitionCategory, identity: String) {
        guard countedIdentities.insert("\(category.rawValue)|\(identity)").inserted else { return }
        values[category, default: 0] += value
    }

    subscript(category: CompetitionCategory) -> Int {
        values[category, default: 0]
    }

    var total: Int { values.values.reduce(0, +) }
    var vector: [Int] { CompetitionCategory.allCases.map { self[$0] } }
}

struct PlanObjective: Equatable, Comparable {
    let score: CategoryScore
    let canonicalVector: [String]

    static func < (lhs: PlanObjective, rhs: PlanObjective) -> Bool {
        if lhs.score.total != rhs.score.total { return lhs.score.total < rhs.score.total }
        for (left, right) in zip(lhs.score.vector, rhs.score.vector) where left != right {
            return left < right
        }
        return canonicalPrecedes(rhs.canonicalVector, lhs.canonicalVector)
    }

    private static func canonicalPrecedes(_ lhs: [String], _ rhs: [String]) -> Bool {
        for (left, right) in zip(lhs, rhs) where left != right { return left < right }
        return lhs.count < rhs.count
    }
}

private extension SeatingPolicyPriority {
    var defaultCategory: CompetitionCategory {
        switch self {
        case .structural, .mandatory, .companion:
            return .t1Production
        case .separation, .avoidance:
            return .risk
        case .location:
            return .location
        case .affinity:
            return .relationships
        case .group:
            return .teamGrouping
        }
    }

    var defaultWeight: Int {
        switch self {
        case .structural, .mandatory, .separation, .companion:
            return 0
        case .location:
            return 100
        case .avoidance:
            return 100
        case .affinity:
            return 10
        case .group:
            return 1
        }
    }
}

struct SeatingPlan: Codable, Equatable {
    let tables: [SeatedTable]
}

struct SeatedTable: Codable, Equatable {
    let tableId: String
    let guests: [String]
}