import ArgumentParser

@main
struct MainCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "xcparty",
        subcommands: [
            FailuresCommand.self,
            MetricsCommand.self
        ],
        defaultSubcommand: FailuresCommand.self)
}
