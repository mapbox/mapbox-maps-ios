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
                if try validateSemanticVersionRequirements(for: dependency, in: config),
                   try validateSemanticVersions(for: dependency, in: config),
                   try validateRequirementsSatisfiedByVersions(for: dependency, in: config) {
                    print("  OK")
                } else {
                    success = false
                }
            } catch {
                // Print any parsing issues
                print("  Encountered an error while parsing dependency versions: '\(error)'")
                success = false
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

    // Ensure that all of the semantic version requirements are equivalent.
    // Does nothing if there are none.
    private func validateSemanticVersionRequirements(for dependency: Dependency,
                                                     in config: Config) throws -> Bool {
        let versionRequirements = try Set(config.semanticValues(for: dependency).compactMap(\.versionRequirement))
        // There's only an error if there's more than 1 version requirement
        guard versionRequirements.count > 1 else {
            return true
        }
        // If there were differing semantic version requirements, print them out
        let versionRequirementsString = versionRequirements
            .map { "'\($0.description)'" }
            .joined(separator: ", ")
        print("  Inconsistent version requirements: \(versionRequirementsString)")

        // Also print out which manifests contained each version requirement
        let groupedManifests = try config.manifestsGroupedBySemanticValue(for: dependency)
        for (semanticValue, manifests) in groupedManifests {
            guard let semanticVersionRequirement = semanticValue.versionRequirement else {
                continue
            }
            print("    Manifests with '\(semanticVersionRequirement)':")
            for manifest in manifests {
                print("      - \(manifest.url.relativePath)")
            }
        }
        return false
    }

    // Ensure that all of the semantic versions are equivalent.
    // Does nothing if there are none.
    private func validateSemanticVersions(for dependency: Dependency,
                                          in config: Config) throws -> Bool {
        let versions = try Set(config.semanticValues(for: dependency).compactMap(\.version))
        // There's only an error if there's more than 1 version
        guard versions.count > 1 else {
            return true
        }
        // If there were differing semantic versions, print them out
        let versionsString = versions
            .map { "'\($0.description)'" }
            .joined(separator: ", ")
        print("  Inconsistent pinned versions: \(versionsString)")

        // Also print out which manifests contained each version
        let groupedManifests = try config.manifestsGroupedBySemanticValue(for: dependency)
        for (semanticValue, manifests) in groupedManifests {
            guard let semanticVersion = semanticValue.version else {
                continue
            }
            print("    Manifests with '\(semanticVersion)':")
            for manifest in manifests {
                print("      - \(manifest.url.relativePath)")
            }
        }
        return false
    }

    private func validateRequirementsSatisfiedByVersions(for dependency: Dependency,
                                                         in config: Config) throws -> Bool {
        // Ensure that the semantic version requirement is satisfied by the semantic version.
        // Skip this step if we do not have one of each. A previous validation step ensures that
        // there is not more than one requirement or more than one version, so that is not
        // verified here.
        guard let versionRequirement = try config.semanticValues(for: dependency).compactMap(\.versionRequirement).first,
              let version = try config.semanticValues(for: dependency).compactMap(\.version).first,
              !versionRequirement.isSatisfied(by: version) else {
            return true
        }
        print("  Pinned version '\(version)' does not satisfy requirement '\(versionRequirement)'")
        return false
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
