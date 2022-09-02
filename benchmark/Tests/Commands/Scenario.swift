import Foundation
import MapboxMaps

struct Scenario {
    let name: String
    let setupCommands: [AsyncCommand]
    let benchmarkCommands: [AsyncCommand]

    init(filePath: URL, name: String, splitAt condition: ((AsyncCommand) -> Bool)? = nil) throws {
        self.name = name

        let data = try Data(contentsOf: filePath)
        let scenarioData = try JSONDecoder().decode(ScenarioData.self, from: data)

        if let condition = condition,
            let splitIndex = scenarioData.commands.firstIndex(where: condition),
            splitIndex < scenarioData.commands.count {
            self.setupCommands = Array(scenarioData.commands.prefix(upTo: splitIndex))
            self.benchmarkCommands = Array(scenarioData.commands.suffix(from: splitIndex))
        } else {
            self.setupCommands = []
            self.benchmarkCommands = scenarioData.commands
        }
    }

    init(name: String, setupCommands: [AsyncCommand] = [], benchmarkCommands: [AsyncCommand] = []) {
        self.name = name
        self.setupCommands = setupCommands
        self.benchmarkCommands = benchmarkCommands
    }

    func runSetup(for metrics: [Metric]) async throws {
        print(">> Start setup for: \(name))")
        try await runCommands(setupCommands, for: metrics)
        print("<< Finish setup for: \(name))")
    }

    func runBenchmark(for metrics: [Metric]) async throws {
        print(">> Start benchmark for: \(name))")
        try await runCommands(benchmarkCommands, for: metrics)
        print(">> Finish benchmark for: \(name))")
    }

    private func runCommands(_ commands: [AsyncCommand], for metrics: [Metric]) async throws {
        for command in commands {
            metrics.forEach { $0.commandWillStartExecuting(command) }
            print(">> Start command: \(type(of: command))")
            try await command.execute()
            print("<< Finish command: \(type(of: command))\n")
            metrics.forEach { $0.commandDidFinishExecuting(command) }
        }
    }

    func cleanup() {
       (setupCommands + benchmarkCommands).forEach { $0.cleanup() }
    }

    enum SupportedCommands: String {
        case createMap = "CreateMap"
        case setOnlineState = "SetOnlineState"
        case clearOfflineData = "ClearOfflineData"
        case createOfflinePacks = "CreateOfflinePacks"
        case playSequence = "PlaySequence"
        case addRoute = "AddRoute"
        case setMemoryBudget = "SetMemoryBudget"
        case setRenderCache = "SetRenderCache"
        case enableTerrain = "EnableTerrain"
        case takeSnapshot = "TakeSnapshot"
    }

    struct ScenarioData: Decodable {
        let commands: [AsyncCommand]

        init(from decoder: Decoder) throws {
            var rootContainer = try decoder.unkeyedContainer()

            var commands: [AsyncCommand] = []

            while !rootContainer.isAtEnd {
                var commandContainer = try rootContainer.nestedUnkeyedContainer()

                let commandName = try commandContainer.decode(String.self)
                guard let commandType = SupportedCommands(rawValue: commandName) else {
                    print("Unsupported command type: \(commandName)")
                    continue
                }

                let command: AsyncCommand
                switch commandType {
                case .createMap:
                    command = try commandContainer.decode(CreateMapCommand.self)
                case .setOnlineState:
                    command = try commandContainer.decode(SetOnlineStateCommand.self)
                case .clearOfflineData:
                    command = ClearOfflineDataCommand()
                case .createOfflinePacks:
                    command = try commandContainer.decode(CreateOfflinePacksCommand.self)
                case .playSequence:
                    command = try commandContainer.decode(PlaySequenceCommand.self)
                case .addRoute:
                    command = try commandContainer.decode(AddRouteCommand.self)
                case .setMemoryBudget:
                    command = try commandContainer.decode(SetMemoryBudgetCommand.self)
                case .setRenderCache:
                    command = try commandContainer.decode(SetRenderCacheCommand.self)
                case .enableTerrain:
                    command = try commandContainer.decode(EnableTerrainCommand.self)
                case .takeSnapshot:
                    command = try commandContainer.decode(TakeSnapshotCommand.self)
                }
                commands.append(command)
            }

            self.commands = commands
        }
    }
}
