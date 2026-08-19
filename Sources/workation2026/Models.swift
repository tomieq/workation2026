import Foundation

struct SeatingScenario: Codable, Equatable {
    let scenario: String
    let title: String
    let tables: [VenueTable]
    let guests: [Guest]
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

enum SeatingPolicyKind: String, Codable, CaseIterable {
    case mandatoryTable
    case separate
    case companion
    case locationPreference
    case affinityPreference
    case groupPreference
}

enum SeatingPolicyPriority: Int, Codable, Comparable, CaseIterable {
    case structural
    case mandatory
    case separation
    case companion
    case location
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
    let evidence: String
    let weight: Int

    init(
        kind: SeatingPolicyKind,
        guestIDs: [String],
        tableID: String?,
        priority: SeatingPolicyPriority,
        evidence: String,
        weight: Int? = nil
    ) {
        self.kind = kind
        self.guestIDs = guestIDs
        self.tableID = tableID
        self.priority = priority
        self.evidence = evidence
        self.weight = weight ?? priority.defaultWeight
    }
}

private extension SeatingPolicyPriority {
    var defaultWeight: Int {
        switch self {
        case .structural, .mandatory, .separation, .companion:
            return 0
        case .location:
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