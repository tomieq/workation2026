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
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("input/scenario1.json")
        try FileManager.default.copyItem(at: source, to: input)

        try await Application.run(arguments: [input.path, first.path])
        try await Application.run(arguments: [input.path, second.path])
        let plan = try JSONDecoder().decode(SeatingPlan.self, from: Data(contentsOf: first))
        let firstData = try Data(contentsOf: first)
        let secondData = try Data(contentsOf: second)

        #expect(plan.tables.count == 5)
        #expect(firstData == secondData)
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
        let input = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("input/scenario1.json")
        let startedAt = Date()

        try await Application.run(arguments: [input.path, output.path])

        let outputText = try String(contentsOf: output)
        #expect(Date().timeIntervalSince(startedAt) < 10)
        #expect(!outputText.contains("SWIFT_AGENT_AUTH_TOKEN"))
        #expect(!outputText.contains("SWIFT_AGENT_MODEL_URL"))
    }
}