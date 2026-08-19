import Foundation

enum Application {
    static func main() async {
        do {
            try await run(arguments: Array(CommandLine.arguments.dropFirst()))
        } catch {
            FileHandle.standardError.write(Data("Error: \(errorDescription(error))\n".utf8))
            Foundation.exit(1)
        }
    }

    static func run(arguments: [String]) async throws {
        guard arguments.count == 2 else {
            throw CLIError.invalidArguments
        }
        let inputURL = URL(fileURLWithPath: arguments[0])
        let outputURL = URL(fileURLWithPath: arguments[1])
        let data: Data
        do {
            data = try Data(contentsOf: inputURL)
        } catch {
            throw CLIError.inputReadFailed(inputURL.path, error)
        }
        let scenario: SeatingScenario
        do {
            scenario = try JSONDecoder().decode(SeatingScenario.self, from: data)
        } catch {
            throw CLIError.inputDecodeFailed(error)
        }
        try ScenarioValidator.validate(scenario)
        let builtInPolicies = SeatingPolicyCatalogue.policies(for: scenario)
        let assistantPolicies = await PolicyAssistant.proposedPolicies(for: scenario)
        let plan = try DeterministicPlanner.plan(for: scenario, policies: builtInPolicies + assistantPolicies)
        try PlanValidator.validate(plan, for: scenario)
        try PlanPublisher.publish(plan, to: outputURL)
    }

    private static func errorDescription(_ error: Error) -> String {
        String(describing: error)
    }
}

enum CLIError: Error, CustomStringConvertible {
    case invalidArguments
    case inputReadFailed(String, Error)
    case inputDecodeFailed(Error)

    var description: String {
        switch self {
        case .invalidArguments:
            return "Usage: ./run.sh <input.json> <output.json>"
        case let .inputReadFailed(path, error):
            return "Could not read input at \(path): \(error.localizedDescription)"
        case let .inputDecodeFailed(error):
            return "Could not decode input JSON: \(error.localizedDescription)"
        }
    }
}