import CarthageKit
import Foundation

enum CarthageError: Swift.Error {
    case compatibleWithUsedWithPrereleaseVersion
    case unsupportedCarthageVersionSpecifier(VersionSpecifier)
}

extension SemanticVersionRequirement {
    init(_ versionSpecifier: VersionSpecifier) throws {
        switch versionSpecifier {
        case .any:
            self = .any
        case let .exactly(semanticVersion):
            self = try .exactly(SemanticVersion(string: semanticVersion.description))
        case let .compatibleWith(semanticVersion):
            let fromVersion = try SemanticVersion(string: semanticVersion.description)
            guard fromVersion.suffix == nil else {
                throw CarthageError.compatibleWithUsedWithPrereleaseVersion
            }
            self = .range(
                from: fromVersion,
                to: fromVersion.nextMajor)
        default:
            throw CarthageError.unsupportedCarthageVersionSpecifier(versionSpecifier)
        }
    }
}

private let cartfileCache = ManifestCache {
    try Cartfile.from(file: $0).get()
}

extension Cartfile: SemanticVersionRequirementProviding {
    static func from(file fileURL: URL) throws -> Cartfile {
        try cartfileCache.manifest(for: fileURL)
    }

    func semanticVersionRequirement(for dependency: Config.Dependency) throws -> SemanticVersionRequirement {
        try SemanticVersionRequirement(dependencies.first { $0.key.name == dependency.name(for: .carthage) }!.value)
    }
}

extension SemanticVersion {
    init(_ pinnedVersion: PinnedVersion) throws {
        try self.init(string: pinnedVersion.commitish)
    }
}

private let resolvedCartfileCache = ManifestCache {
    try ResolvedCartfile.from(string: String(contentsOf: $0)).get()
}

extension ResolvedCartfile: SemanticVersionProviding {
    static func from(file fileURL: URL) throws -> ResolvedCartfile {
        try resolvedCartfileCache.manifest(for: fileURL)
    }

    func semanticVersion(for dependency: Config.Dependency) throws -> SemanticVersion {
        try SemanticVersion(dependencies.first { $0.key.name == dependency.name(for: .carthage) }!.value)
    }
}
