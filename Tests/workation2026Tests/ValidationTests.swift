import Foundation
import Testing
@testable import workation2026

@Suite
struct ValidationTests {
    @Test
    func acceptsCanonicalScenario2Fixture() throws {
        let input = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("input/scenario2.json")
        let scenario = try JSONDecoder().decode(SeatingScenario.self, from: Data(contentsOf: input))

        try ScenarioValidator.validate(scenario)
    }

    @Test
    func rejectsDuplicateGuestIDs() {
        var scenario = validScenario()
        scenario = SeatingScenario(
            scenario: scenario.scenario,
            title: scenario.title,
            tables: scenario.tables,
            guests: scenario.guests.dropLast() + [scenario.guests[0]]
        )

        #expect(throws: ScenarioValidationError.self) {
            try ScenarioValidator.validate(scenario)
        }
    }

    @Test
    func rejectsInvalidExtraSeatAuthorization() throws {
        let scenario = try scenario2()
        let invalidScenario = SeatingScenario(
            scenario: scenario.scenario,
            title: scenario.title,
            extraSeatPolicy: ExtraSeatPolicy(extraSeats: 0, canBeAddedToAnyTable: true),
            tables: scenario.tables,
            guests: scenario.guests
        )

        #expect(throws: ScenarioValidationError.invalidExtraSeatPolicy) {
            try ScenarioValidator.validate(invalidScenario)
        }
    }

    @Test
    func rejectsSupersededScenario2Roster() throws {
        let scenario = try scenario2()
        let guests = Array(scenario.guests.dropLast()) + [Guest(id: "donald_t", name: "Donald T.", group: "politics", description: nil)]
        let invalidScenario = SeatingScenario(
            scenario: scenario.scenario,
            title: scenario.title,
            extraSeatPolicy: scenario.extraSeatPolicy,
            tables: scenario.tables,
            guests: guests
        )

        #expect(throws: ScenarioValidationError.invalidActiveRoster) {
            try ScenarioValidator.validate(invalidScenario)
        }
    }

    @Test
    func rejectsPlanWithoutCoupleAtT1() {
        let scenario = validScenario()
        let plan = SeatingPlan(tables: scenario.tables.map { table in
            SeatedTable(tableId: table.id, guests: scenario.guests.filter { $0.id != "bartek" && $0.id != "nina" }.prefix(6).map(\.id))
        })

        #expect(throws: PlanValidationError.self) {
            try PlanValidator.validate(plan, for: scenario)
        }
    }

    @Test
    func preservesExistingOutputWhenEncodingFails() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let destination = directory.appendingPathComponent("plan.json")
        try Data("existing plan".utf8).write(to: destination)

        #expect(throws: PlanPublicationError.self) {
            try PlanPublisher.publish(NonEncodablePlan(), to: destination)
        }
        #expect(try String(contentsOf: destination) == "existing plan")
    }

    private func validScenario() -> SeatingScenario {
        let guests = (1...28).map { Guest(id: "guest\($0)", name: "Guest \($0)", group: nil, description: nil) }
            + [Guest(id: "bartek", name: "Bartek", group: nil, description: nil), Guest(id: "nina", name: "Nina", group: nil, description: nil)]
        let tables = (1...5).map { VenueTable(id: "T\($0)", name: "Table \($0)", capacity: 6, notes: nil) }
        return SeatingScenario(scenario: "test", title: "Test", tables: tables, guests: guests)
    }

    private func scenario2() throws -> SeatingScenario {
        let input = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("input/scenario2.json")
        return try JSONDecoder().decode(SeatingScenario.self, from: Data(contentsOf: input))
    }
}

private struct NonEncodablePlan: Encodable {
    func encode(to encoder: Encoder) throws {
        throw EncodingFailure.failed
    }

    private enum EncodingFailure: Error {
        case failed
    }
}