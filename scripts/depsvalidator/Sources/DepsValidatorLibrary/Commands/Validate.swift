import Foundation
import ArgumentParser

final class Validate: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Validate that the dependency manager manifests are in a valid state.")

    @Option var configFile: URL = ".depsvalidator.yml"

    func run() throws {
        // Load the config file
        let config = try Config.from(file: configFile)

        // Validate each dependency, keeping track of whether we encounter any errors
        var success = true
        for dependency in config.dependencies {
            print("\(dependency.name):")
            do {
                // Ensure that all of the semantic version requirements are equivalent.
                // Skip this step if there are none.
                let versionRequirements = try Set(config.semanticVersionRequirements(for: dependency))
                if !versionRequirements.isEmpty {
                    guard versionRequirements.count == 1 else {
                        success = false

                        // If there were differing semantic version requirements, print them out
                        let versionRequirementsString = versionRequirements
                            .map { "'\($0.description)'" }
                            .joined(separator: ", ")
                        print("  Inconsistent version requirements: \(versionRequirementsString)")

                        // Also print out which manifests contained each version requirement
                        let groupedManifests = try config.manifestsGroupedBySemanticVersionRequirement(for: dependency)
                        for (semanticVersionRequirement, manifests) in groupedManifests {
                            print("    Manifests with '\(semanticVersionRequirement)':")
                            for manifest in manifests {
                                print("      - \(manifest.url.relativePath)")
                            }
                        }
                        continue
                    }
                }
                // Ensure that all of the semantic versions are equivalent.
                // Skip this step if there are none.
                let versions = try Set(config.semanticVersions(for: dependency))
                if !versions.isEmpty {
                    guard versions.count == 1 else {
                        success = false

                        // If there were differing semantic versions, print them out
                        let versionsString = versions
                            .map { "'\($0.description)'" }
                            .joined(separator: ", ")
                        print("  Inconsistent pinned versions: \(versionsString)")

                        // Also print out which manifests contained each version
                        let groupedManifests = try config.manifestsGroupedBySemanticVersion(for: dependency)
                        for (semanticVersion, manifests) in groupedManifests {
                            print("    Manifests with '\(semanticVersion)':")
                            for manifest in manifests {
                                print("      - \(manifest.url.relativePath)")
                            }
                        }
                        continue
                    }
                }
                // Ensure that the semantic version requirement is satisfied by the semantic version.
                // Skip this step if we do not have one of each.
                if let versionRequirement = versionRequirements.first,
                   let version = versions.first {
                    guard versionRequirement.isSatisfied(by: version) else {
                        success = false
                        print("  Pinned version '\(version)' does not satisfy requirement '\(versionRequirement)'")
                        continue
                    }
                }
                // If we made it here, this dependency passed validation
                print("  OK")
            } catch {
                // Print any parsing issues
                success = false
                print("  Encountered an error while parsing dependency versions: '\(error)'")
            }
        }
        // After checking each dependency, print success (and implicitly exit 0) or exit with failure and no additional
        // message
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
