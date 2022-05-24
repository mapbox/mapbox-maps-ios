import Foundation
import MapboxMaps

struct Scenario {
    let name: String?
    let commands: [AsyncCommand]

    func run() async throws {
        for command in commands {
            print("Start command: \(command)")
            try await command.execute()
            print("Finish command: \(command)")
        }
    }

    enum SupportedCommands: String {
        case createMap = "CreateMap"
        case setOnlineState = "SetOnlineState"
        case clearOfflineData = "ClearOfflineData"
        case createOfflinePacks = "CreateOfflinePacks"
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
                }
                commands.append(command)
            }

            self.commands = commands
        }
    }
}

extension Scenario {
    init(filePath: URL, name: String? = nil) throws {
        self.name = name ?? (filePath.lastPathComponent as NSString).deletingPathExtension

        let data = try Data(contentsOf: filePath)
        let scenarioData = try JSONDecoder().decode(ScenarioData.self, from: data)
        self.commands = scenarioData.commands
    }
}
