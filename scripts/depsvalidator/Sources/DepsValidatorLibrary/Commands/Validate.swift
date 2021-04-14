import Foundation
import ArgumentParser

final class Validate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Validate that the dependency manager manifests are in a valid state.")

    @Option var configFile: URL = ".depsvalidator.yml"

    func run() throws {
        let config = try Config.from(file: configFile)
        var success = true
        for dependency in config.dependencies {
            print("\(dependency.name):")
            do {
                let versionRequirements = try Set(config.semanticVersionRequirements(for: dependency))
                guard versionRequirements.count == 1 else {
                    success = false
                    let versionRequirementsString = versionRequirements
                        .map { "'\($0.description)'" }
                        .joined(separator: ", ")
                    print("  Inconsistent version requirements: \(versionRequirementsString)")
                    let groupedManifests = try config.manifestsGroupedBySemanticVersionRequirement(for: dependency)
                    for (semanticVersionRequirement, manifests) in groupedManifests {
                        print("    Manifests with '\(semanticVersionRequirement)':")
                        for manifest in manifests {
                            print("      - \(manifest.url.relativePath)")
                        }
                    }
                    continue
                }
                let versions = try Set(config.semanticVersions(for: dependency))
                guard versions.count == 1 else {
                    success = false
                    let versionsString = versions
                        .map { "'\($0.description)'" }
                        .joined(separator: ", ")
                    print("  Inconsistent pinned versions: \(versionsString)")
                    let groupedManifests = try config.manifestsGroupedBySemanticVersion(for: dependency)
                    for (semanticVersion, manifests) in groupedManifests {
                        print("    Manifests with '\(semanticVersion)':")
                        for manifest in manifests {
                            print("      - \(manifest.url.relativePath)")
                        }
                    }
                    continue
                }
                let versionRequirement = versionRequirements.first!
                let version = versions.first!
                guard versionRequirement.isSatisfied(by: version) else {
                    success = false
                    print("  Pinned version '\(version)' does not satisfy requirement '\(versionRequirement)'")
                    continue
                }
                print("  OK")
            } catch {
                success = false
                print("  Encountered an error while parsing dependency versions: '\(error)'")
            }
        }
        if success {
            print("Success!")
        } else {
            throw ExitCode.failure
        }
    }
}

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self = URL(fileURLWithPath: argument)
    }
}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = URL(fileURLWithPath: value)
    }
}
