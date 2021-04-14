import CarthageKit
import Foundation
import Yams

struct Config: Decodable {
    struct Manifest: Decodable {
        var type: ManifestType
        var omitFor: [String]?
        var path: String?

        var resolvedPath: String {
            path ?? type.defaultPath
        }

        enum CodingKeys: String, CodingKey {
            case type
            case omitFor = "omit_for"
            case path
        }
    }

    struct Dependency: Decodable {
        var name: String
        var variations: [PackageManager: String]

        enum Error: Swift.Error {
            case invalidPackageManager(String)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case variations
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            let stringlyTypedVariations = try container.decode([String: String].self, forKey: .variations)
            variations = [:]
            try stringlyTypedVariations.forEach { (key, value) in
                guard let newKey = PackageManager(rawValue: key) else {
                    throw Error.invalidPackageManager(key)
                }
                variations[newKey] = value
            }
        }

        func name(for packageManager: PackageManager) -> String {
            variations[packageManager] ?? name
        }
    }

    var root: URL
    var manifests: [Manifest]
    var dependencies: [Dependency]

    static func from(file fileURL: URL) throws -> Self {
        let data = try Data(contentsOf: fileURL)
        return try YAMLDecoder()
            .decode(Config.self, from: data, userInfo: [CodingUserInfoKey(rawValue: "root")!: fileURL])
    }

    enum CodingKeys: String, CodingKey {
        case manifests
        case dependencies
    }

    init(from decoder: Decoder) throws {
        // swiftlint:disable:next force_cast
        root = decoder.userInfo[CodingUserInfoKey(rawValue: "root")!] as! URL
        let container = try decoder.container(keyedBy: CodingKeys.self)
        manifests = try container.decode([Manifest].self, forKey: .manifests)
        dependencies = try container.decode([Dependency].self, forKey: .dependencies)
    }

    // MARK: - SemanticVersionRequirement

    // swiftlint:disable:next type_name
    struct SemanticVersionRequirementProvidingManifest {
        var type: SemanticVersionRequirementProvidingManifestType
        var omitFor: [String]
        var url: URL

        init?(manifest: Manifest, root: URL) {
            guard let type = SemanticVersionRequirementProvidingManifestType(manifestType: manifest.type) else {
                return nil
            }
            self.type = type
            self.omitFor = manifest.omitFor ?? []
            self.url = URL(fileURLWithPath: manifest.resolvedPath, relativeTo: root)
        }

        func semanticVersionRequirement(for dependency: Dependency) throws -> SemanticVersionRequirement {
            try type.providerType
                .from(file: url)
                .semanticVersionRequirement(for: dependency)
        }
    }

    var semanticVersionRequirementProvidingManifests: [SemanticVersionRequirementProvidingManifest] {
        manifests.compactMap { SemanticVersionRequirementProvidingManifest.init(manifest: $0, root: root) }
    }

    private func semanticVersionRequirementProvidingManifests(for dependency: Dependency) -> [SemanticVersionRequirementProvidingManifest] {
        semanticVersionRequirementProvidingManifests
            .filter { !$0.omitFor.contains(dependency.name) }
    }

    func semanticVersionRequirements(for dependency: Dependency) throws -> [SemanticVersionRequirement] {
        try semanticVersionRequirementProvidingManifests(for: dependency)
            .map { try $0.semanticVersionRequirement(for: dependency) }
    }

    func manifestsGroupedBySemanticVersionRequirement(for dependency: Dependency) throws -> [SemanticVersionRequirement: [SemanticVersionRequirementProvidingManifest]] {
        try Dictionary(grouping: semanticVersionRequirementProvidingManifests(for: dependency)) {
            try $0.semanticVersionRequirement(for: dependency)
        }
    }

    // MARK: - SemanticVersion

    struct SemanticVersionProvidingManifest {
        var type: SemanticVersionProvidingManifestType
        var omitFor: [String]
        var url: URL

        init?(manifest: Manifest, root: URL) {
            guard let type = SemanticVersionProvidingManifestType(manifestType: manifest.type) else {
                return nil
            }
            self.type = type
            self.omitFor = manifest.omitFor ?? []
            self.url = URL(fileURLWithPath: manifest.resolvedPath, relativeTo: root)
        }

        func semanticVersion(for dependency: Dependency, root: URL) throws -> SemanticVersion {
            try type.providerType
                .from(file: url)
                .semanticVersion(for: dependency)
        }
    }

    var semanticVersionProvidingManifests: [SemanticVersionProvidingManifest] {
        manifests.compactMap { SemanticVersionProvidingManifest.init(manifest: $0, root: root) }
    }

    private func semanticVersionProvidingManifests(for dependency: Dependency) -> [SemanticVersionProvidingManifest] {
        semanticVersionProvidingManifests
            .filter { !$0.omitFor.contains(dependency.name) }
    }

    func semanticVersions(for dependency: Dependency) throws -> [SemanticVersion] {
        try semanticVersionProvidingManifests(for: dependency)
            .map { try $0.semanticVersion(for: dependency, root: root) }
    }

    func manifestsGroupedBySemanticVersion(for dependency: Dependency) throws -> [SemanticVersion: [SemanticVersionProvidingManifest]] {
        try Dictionary(grouping: semanticVersionProvidingManifests(for: dependency)) {
            try $0.semanticVersion(for: dependency, root: root)
        }
    }
}

enum ManifestType: String, Decodable {
    case package = "Package.swift"
    case resolvedPackage = "Package.resolved"
    case podspec = "Podspec"
    case cartfile = "Cartfile"
    case resolvedCartfile = "Cartfile.resolved"
    case json = "JSON"

    var defaultPath: String {
        switch self {
        case .package:
            return "Package.swift"
        case .resolvedPackage:
            return "Package.resolved"
        case .podspec:
            return "*.podspec"
        case .cartfile:
            return "Cartfile"
        case .resolvedCartfile:
            return "Cartfile.resolved"
        case .json:
            return "versions.json"
        }
    }
}

// swiftlint:disable:next type_name
enum SemanticVersionRequirementProvidingManifestType {
    case package
    case podspec
    case cartfile

    init?(manifestType: ManifestType) {
        switch manifestType {
        case .package:
            self = .package
        case .podspec:
            self = .podspec
        case .cartfile:
            self = .cartfile
        default:
            return nil
        }
    }

    var providerType: SemanticVersionRequirementProviding.Type {
        switch self {
        case .package:
            return Package.self
        case .podspec:
            return Podspec.self
        case .cartfile:
            return Cartfile.self
        }
    }
}

enum SemanticVersionProvidingManifestType {
    case resolvedPackage
    case resolvedCartfile
    case json

    init?(manifestType: ManifestType) {
        switch manifestType {
        case .resolvedPackage:
            self = .resolvedPackage
        case .resolvedCartfile:
            self = .resolvedCartfile
        case .json:
            self = .json
        default:
            return nil
        }
    }

    var providerType: SemanticVersionProviding.Type {
        switch self {
        case .resolvedPackage:
            return ResolvedPackage.self
        case .resolvedCartfile:
            return ResolvedCartfile.self
        case .json:
            return JSONManifest.self
        }
    }
}

enum PackageManager: String, Decodable {
    case spm = "SPM"
    case cocoapods = "CocoaPods"
    case carthage = "Carthage"
    case json = "JSON"
}
