import Foundation
import Testing
@testable import workation2026

@Suite
struct CLIRunTests {
    @Test
    func applicationProducesRepeatableSchemaShapedOutput() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let input = directory.appendingPathComponent("input.json")
        let first = directory.appendingPathComponent("first.json")
        let second = directory.appendingPathComponent("second.json")
        let source = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("input/scenario1.json")
        try FileManager.default.copyItem(at: source, to: input)

        try Application.run(arguments: [input.path, first.path])
        try Application.run(arguments: [input.path, second.path])
        let plan = try JSONDecoder().decode(SeatingPlan.self, from: Data(contentsOf: first))
        let firstData = try Data(contentsOf: first)
        let secondData = try Data(contentsOf: second)

        #expect(plan.tables.count == 5)
        #expect(firstData == secondData)
    }
}