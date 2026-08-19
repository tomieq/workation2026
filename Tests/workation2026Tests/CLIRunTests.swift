import Foundation
import Testing
@testable import workation2026

@Suite
struct CLIRunTests {
    @Test
    func applicationProducesRepeatableSchemaShapedOutput() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let input = directory.appendingPathComponent("input.json")
        let first = directory.appendingPathComponent("first.json")
        let second = directory.appendingPathComponent("second.json")
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("input/scenario2.json")
        try FileManager.default.copyItem(at: source, to: input)

        try await Application.run(arguments: [input.path, first.path])
        try await Application.run(arguments: [input.path, second.path])
        let plan = try JSONDecoder().decode(SeatingPlan.self, from: Data(contentsOf: first))
        let firstData = try Data(contentsOf: first)
        let secondData = try Data(contentsOf: second)

        #expect(plan.tables.count == 5)
        #expect(plan.tables.map { $0.guests.count }.sorted() == [6, 6, 6, 6, 7])
        let t1Guests = plan.tables.first(where: { $0.tableId == "T1" })?.guests ?? []
        #expect(t1Guests.contains("bartek"))
        #expect(t1Guests.contains("nina"))
        #expect(firstData == secondData)
    }

    @Test
    func scenario2PlanCoversScoringAreas() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let output = directory.appendingPathComponent("plan.json")
        let scenario = try scenario2()

        try await Application.run(arguments: [scenario.inputURL.path, output.path])
        let plan = try JSONDecoder().decode(SeatingPlan.self, from: Data(contentsOf: output))
        let guestsByID = Dictionary(uniqueKeysWithValues: scenario.value.guests.map { ($0.id, $0) })
        let tableForGuest = Dictionary(uniqueKeysWithValues: plan.tables.flatMap { table in
            table.guests.map { ($0, table.tableId) }
        })
        let t1Guests = plan.tables.first(where: { $0.tableId == "T1" })?.guests ?? []

        #expect(plan.tables.map { $0.guests.count }.sorted() == [6, 6, 6, 6, 7])
        #expect(tableForGuest.count == 31)
        #expect(tableForGuest["zosia"] == "T4")
        #expect(tableForGuest["tetiana"] == "T2")
        #expect(tableForGuest["mariusz"] == tableForGuest["slawek_m"])
        #expect(tableForGuest["leszek"] != tableForGuest["kuba_g"])
        #expect(tableForGuest["leszek"] != tableForGuest["michal_z"])
        let highIntensityGuests: Set<String> = ["ada", "agnieszka", "zdzisiek", "klara", "przemek", "tomek", "slawek_m", "kuba_s"]
        #expect(plan.tables.allSatisfy { table in
            table.guests.filter(highIntensityGuests.contains).count <= 3
        })
        #expect(t1Guests.contains("bartek"))
        #expect(t1Guests.contains("nina"))
        #expect(t1Guests.contains("chrzestna_ania"))
        #expect(t1Guests.contains("swiadek_kuba"))
        #expect(tableForGuest["mariusz"] == tableForGuest["slawek_m"])
        #expect(t1Guests.filter { guestID in
            guestID != "bartek" && guestsByID[guestID]?.group == "work"
        }.count == 2)
        #expect(tableForGuest["michal_s"] != nil)
    }

    @Test
    func malformedInputFailsWithoutReplacingExistingOutput() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let input = directory.appendingPathComponent("invalid.json")
        let output = directory.appendingPathComponent("plan.json")
        try Data("not json".utf8).write(to: input)
        try Data("existing plan".utf8).write(to: output)

        var didFail = false
        do {
            try await Application.run(arguments: [input.path, output.path])
        } catch {
            didFail = true
            #expect(String(describing: error).contains("Could not decode input JSON"))
        }

        #expect(didFail)
        #expect(try String(contentsOf: output) == "existing plan")
    }

    @Test
    func suppliedScenarioCompletesQuicklyWithoutConfigurationInOutput() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let output = directory.appendingPathComponent("plan.json")
        let input = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("input/scenario2.json")
        let startedAt = Date()

        try await Application.run(arguments: [input.path, output.path])

        let outputText = try String(contentsOf: output)
        #expect(Date().timeIntervalSince(startedAt) < 10)
        #expect(!outputText.contains("SWIFT_AGENT_AUTH_TOKEN"))
        #expect(!outputText.contains("SWIFT_AGENT_MODEL_URL"))
    }

    private func scenario2() throws -> (inputURL: URL, value: SeatingScenario) {
        let inputURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("input/scenario2.json")
        return (inputURL, try JSONDecoder().decode(SeatingScenario.self, from: Data(contentsOf: inputURL)))
    }
}