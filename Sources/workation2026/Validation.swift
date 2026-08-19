import Foundation

enum ScenarioValidationError: Error, Equatable, CustomStringConvertible {
    case invalidTableCount(Int)
    case invalidTableIDs
    case invalidTableCapacity(tableID: String, capacity: Int)
    case invalidGuestCount(Int)
    case blankGuestID
    case duplicateGuestID(String)
    case missingMandatoryGuest(String)

    var description: String {
        switch self {
        case let .invalidTableCount(count):
            return "Expected exactly 5 tables, found \(count)."
        case .invalidTableIDs:
            return "Expected distinct table IDs T1 through T5."
        case let .invalidTableCapacity(tableID, capacity):
            return "Table \(tableID) must have capacity 6, found \(capacity)."
        case let .invalidGuestCount(count):
            return "Expected exactly 30 guests, found \(count)."
        case .blankGuestID:
            return "Guest IDs must be non-empty."
        case let .duplicateGuestID(id):
            return "Guest ID \(id) appears more than once."
        case let .missingMandatoryGuest(id):
            return "Missing mandatory guest \(id)."
        }
    }
}

enum PlanValidationError: Error, Equatable, CustomStringConvertible {
    case invalidTableIDs
    case invalidTableSize(tableID: String, count: Int)
    case duplicateGuestID(String)
    case unknownGuestID(String)
    case missingGuestID(String)
    case mandatoryGuestNotAtT1(String)

    var description: String {
        switch self {
        case .invalidTableIDs:
            return "Plan must contain exactly the input table IDs."
        case let .invalidTableSize(tableID, count):
            return "Table \(tableID) must contain 6 guests, found \(count)."
        case let .duplicateGuestID(id):
            return "Guest ID \(id) appears more than once in the plan."
        case let .unknownGuestID(id):
            return "Plan contains unknown guest ID \(id)."
        case let .missingGuestID(id):
            return "Plan is missing guest ID \(id)."
        case let .mandatoryGuestNotAtT1(id):
            return "Mandatory guest \(id) must be seated at T1."
        }
    }
}

enum PlanPublicationError: Error, CustomStringConvertible {
    case encodingFailed(Error)
    case writeFailed(path: String, error: Error)

    var description: String {
        switch self {
        case let .encodingFailed(error):
            return "Could not encode seating plan: \(error.localizedDescription)"
        case let .writeFailed(path, error):
            return "Could not publish seating plan to \(path): \(error.localizedDescription)"
        }
    }
}

enum ScenarioValidator {
    static func validate(_ scenario: SeatingScenario) throws {
        guard scenario.tables.count == 5 else {
            throw ScenarioValidationError.invalidTableCount(scenario.tables.count)
        }
        guard Set(scenario.tables.map(\.id)) == Set(["T1", "T2", "T3", "T4", "T5"]) else {
            throw ScenarioValidationError.invalidTableIDs
        }
        for table in scenario.tables where table.capacity != 6 {
            throw ScenarioValidationError.invalidTableCapacity(tableID: table.id, capacity: table.capacity)
        }
        guard scenario.guests.count == 30 else {
            throw ScenarioValidationError.invalidGuestCount(scenario.guests.count)
        }

        var guestIDs = Set<String>()
        for guest in scenario.guests {
            guard !guest.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ScenarioValidationError.blankGuestID
            }
            guard guestIDs.insert(guest.id).inserted else {
                throw ScenarioValidationError.duplicateGuestID(guest.id)
            }
        }
        for mandatoryID in ["bartek", "nina"] where !guestIDs.contains(mandatoryID) {
            throw ScenarioValidationError.missingMandatoryGuest(mandatoryID)
        }
    }
}

enum PlanValidator {
    static func validate(_ plan: SeatingPlan, for scenario: SeatingScenario) throws {
        let expectedTableIDs = Set(scenario.tables.map(\.id))
        guard plan.tables.count == expectedTableIDs.count,
              Set(plan.tables.map(\.tableId)) == expectedTableIDs else {
            throw PlanValidationError.invalidTableIDs
        }

        let expectedGuestIDs = Set(scenario.guests.map(\.id))
        var assignedGuestIDs = Set<String>()
        for table in plan.tables {
            guard table.guests.count == 6 else {
                throw PlanValidationError.invalidTableSize(tableID: table.tableId, count: table.guests.count)
            }
            for guestID in table.guests {
                guard expectedGuestIDs.contains(guestID) else {
                    throw PlanValidationError.unknownGuestID(guestID)
                }
                guard assignedGuestIDs.insert(guestID).inserted else {
                    throw PlanValidationError.duplicateGuestID(guestID)
                }
            }
        }
        for guestID in expectedGuestIDs where !assignedGuestIDs.contains(guestID) {
            throw PlanValidationError.missingGuestID(guestID)
        }
        let t1Guests = plan.tables.first(where: { $0.tableId == "T1" })?.guests ?? []
        for mandatoryID in ["bartek", "nina"] where !t1Guests.contains(mandatoryID) {
            throw PlanValidationError.mandatoryGuestNotAtT1(mandatoryID)
        }
    }
}

enum PlanPublisher {
    static func publish<Plan: Encodable>(_ plan: Plan, to destination: URL) throws {
        let temporary = destination.deletingLastPathComponent()
            .appendingPathComponent(".\(destination.lastPathComponent).\(UUID().uuidString).tmp")
        defer { try? FileManager.default.removeItem(at: temporary) }

        let data: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            data = try encoder.encode(plan)
        } catch {
            throw PlanPublicationError.encodingFailed(error)
        }

        do {
            try data.write(to: temporary, options: .atomic)
            if FileManager.default.fileExists(atPath: destination.path) {
                _ = try FileManager.default.replaceItemAt(destination, withItemAt: temporary)
            } else {
                try FileManager.default.moveItem(at: temporary, to: destination)
            }
        } catch {
            throw PlanPublicationError.writeFailed(path: destination.path, error: error)
        }
    }
}