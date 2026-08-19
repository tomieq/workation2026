import Foundation
import Env
import SwiftAgent

enum PolicyAssistant {
    static func proposedPolicies(
        for scenario: SeatingScenario,
        environment: [String: String] = environmentValues()
    ) async -> [SeatingPolicy] {
        guard let configuration = Configuration(environment: environment) else { return [] }
        do {
            let agent = SwiftAgent(config: AgentConfig(
                name: "Wedding policy assistant",
                provider: configuration.provider,
                modelUrl: configuration.modelURL,
                authToken: configuration.authToken,
                preferredModel: configuration.model
            ))
            let response = try await agent.session(systemMessage: "Return only JSON policy proposals based on exact evidence supplied in the prompt.")
                .ask(prompt(for: scenario), model: configuration.model)
            guard case let .text(text) = response.sessionReponse,
                  let proposal = try? JSONDecoder().decode(Proposal.self, from: Data(text.utf8)) else {
                return []
            }
            return SeatingPolicyCatalogue.validated(proposal.policies.compactMap(\.policy), for: scenario)
        } catch {
            return []
        }
    }

    private static func prompt(for scenario: SeatingScenario) -> String {
        let tables = scenario.tables.map { "\($0.id): \($0.notes ?? "")" }.joined(separator: "\n")
        let guests = scenario.guests.map { "\($0.id): \($0.description ?? "")" }.joined(separator: "\n")
        return """
        Propose zero or more policies as JSON: {"policies":[{"kind":"companion|separate|locationPreference|avoidancePreference|affinityPreference","guestIDs":["id"],"tableID":"optional","priority":"companion|separation|location|avoidance|affinity","evidence":"exact input excerpt"}]}.
        Use only explicit named references, dance/terrace cues, shared food/drink cues, or explicitly flagged discussion pairings with exact evidence. Do not invent intent.
        Tables:
        \(tables)
        Guests:
        \(guests)
        """
    }

    private struct Configuration {
        let provider: ModelProvider
        let modelURL: String
        let model: String
        let authToken: String?

        init?(environment: [String: String]) {
            let providerValue = environment["SWIFT_AGENT_PROVIDER"] ?? "openAI"
            let modelURL = environment["SWIFT_AGENT_MODEL_URL"] ?? "https://api.openai.com/v1/"
            let model = environment["SWIFT_AGENT_MODEL"] ?? "gpt-5.4-mini"
            guard !modelURL.isEmpty,
                !model.isEmpty,
                let authToken = environment["SWIFT_AGENT_AUTH_TOKEN"], !authToken.isEmpty else { return nil }
            switch providerValue {
            case "openAI": provider = .openAI
            case "ollama": provider = .ollama
            default: return nil
            }
            self.modelURL = modelURL
            self.model = model
            self.authToken = authToken
        }
    }

    private static func environmentValues() -> [String: String] {
        let env = Env()
        let keys = ["SWIFT_AGENT_PROVIDER", "SWIFT_AGENT_MODEL_URL", "SWIFT_AGENT_MODEL", "SWIFT_AGENT_AUTH_TOKEN"]
        return Dictionary(uniqueKeysWithValues: keys.compactMap { key in
            env.get(key).map { (key, $0) }
        })
    }

    private struct Proposal: Decodable {
        let policies: [Candidate]
    }

    private struct Candidate: Decodable {
        let kind: String
        let guestIDs: [String]
        let tableID: String?
        let priority: String
        let evidence: String

        var policy: SeatingPolicy? {
            guard let kind = SeatingPolicyKind(rawValue: kind),
                  let priority = SeatingPolicyPriority(name: priority) else { return nil }
            return SeatingPolicy(kind: kind, guestIDs: guestIDs, tableID: tableID, priority: priority, evidence: evidence)
        }
    }
}

private extension SeatingPolicyPriority {
    init?(name: String) {
        switch name {
        case "structural": self = .structural
        case "mandatory": self = .mandatory
        case "separation": self = .separation
        case "companion": self = .companion
        case "location": self = .location
        case "avoidance": self = .avoidance
        case "affinity": self = .affinity
        case "group": self = .group
        default: return nil
        }
    }
}