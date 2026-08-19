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
}

struct SeatingPlan: Codable, Equatable {
    let tables: [SeatedTable]
}

struct SeatedTable: Codable, Equatable {
    let tableId: String
    let guests: [String]
}