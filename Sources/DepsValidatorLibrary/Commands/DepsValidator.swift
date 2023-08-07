import ArgumentParser

public struct DepsValidator: ParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: """
            DepsValidator is a command line utility that can ensure that a library is using a consistent set of \
            dependency versions across multiple Apple-ecosystem package managers.
            """,
        subcommands: [Validate.self],
        defaultSubcommand: Validate.self)

    public init() {
    }
}
