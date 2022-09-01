import Foundation
import MapboxMaps

struct Scenario {
    let name: String?
    let setupCommands: [AsyncCommand]
    let benchmarkCommands: [AsyncCommand]

    init(name: String?, commands: [AsyncCommand]) {
        self.name = name
        self.setupCommands = []
        self.benchmarkCommands = commands
    }

    init(filePath: URL, name: String? = nil) throws {
        self.name = name ?? (filePath.lastPathComponent as NSString).deletingPathExtension

        let data = try Data(contentsOf: filePath)
        let scenarioData = try JSONDecoder().decode(ScenarioData.self, from: data)
        self.setupCommands = []
        self.benchmarkCommands = scenarioData.commands
    }

    init(name: String?, setupCommands: [AsyncCommand], benchmarkCommands: [AsyncCommand]) {
        self.name = name
        self.setupCommands = setupCommands
        self.benchmarkCommands = benchmarkCommands
    }

    func runSetup(for metrics: [Metric]) async throws {
        for command in setupCommands {
            metrics.forEach { $0.commandWillStartExecuting(command) }
            print(">> Start setup command: \(type(of: command))")
            try await command.execute()
            print("<< Finish setup command: \(type(of: command))\n")
            metrics.forEach { $0.commandDidFinishExecuting(command) }
        }
    }

    func runBenchmark(for metrics: [Metric]) async throws {
        for command in benchmarkCommands {
            metrics.forEach { $0.commandWillStartExecuting(command) }
            print(">> Start benchmark command: \(type(of: command))")
            try await command.execute()
            print("<< Finish benchmark command: \(type(of: command))\n")
            metrics.forEach { $0.commandDidFinishExecuting(command) }
        }
    }

    func cleanupSetup() {
        for setupCommand in setupCommands {
            setupCommand.cleanup()
        }
    }

    func cleanupBenchmark() {
        for benchmarkCommand in benchmarkCommands {
            benchmarkCommand.cleanup()
        }
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
