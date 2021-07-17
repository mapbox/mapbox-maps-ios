import CarthageKit
import Foundation
import Yams

struct Config: Decodable {
    var root: URL
    var manifests: [Manifest]
    var dependencies: [Dependency]
    var manifestDefinitions: [ManifestName: ManifestDefinition]

    static func from(file fileURL: URL) throws -> Self {
        let data = try Data(contentsOf: fileURL)
        return try YAMLDecoder()
            .decode(Config.self, from: data, userInfo: [CodingUserInfoKey(rawValue: "root")!: fileURL])
    }

    enum CodingKeys: String, CodingKey {
        case manifests
        case dependencies
        case manifestDefinitions = "manifest_definitions"
    }

    init(from decoder: Decoder) throws {
        // swiftlint:disable:next force_cast
        root = decoder.userInfo[CodingUserInfoKey(rawValue: "root")!] as! URL
        let container = try decoder.container(keyedBy: CodingKeys.self)
        manifests = try container.decode([Manifest].self, forKey: .manifests)
        dependencies = try container.decode([Dependency].self, forKey: .dependencies)
        manifestDefinitions = try container
            .decodeIfPresent([CustomManifestDefinition].self, forKey: .manifestDefinitions)
            .map { $0.map { ($0.name, $0) } }
            .map { Dictionary($0, uniquingKeysWith: { first, _ in first }) } ?? [:]
        let defaultManifestDefinitions: [ManifestName: ManifestDefinition] = [
            .package: PackageManifestDefinition(),
            .resolvedPackage: ResolvedPackageManifestDefinition(),
            .podspec: PodspecManifestDefinition(),
            .cartfile: CartfileManifestDefinition(),
            .resolvedCartfile: ResolvedCartfileManifestDefinition(),
        ]
        manifestDefinitions.merge(defaultManifestDefinitions) { (custom, _) in custom }
    }

    // swiftlint:disable:next type_name
    struct SemanticValueProvidingManifest {
        var manifest: Manifest
        var definition: ManifestDefinition
        var root: URL

        var url: URL {
            URL(fileURLWithPath: manifest.path ?? definition.defaultPath, relativeTo: root)
        }

        func semanticValue(for dependency: Dependency) throws -> SemanticValue {
            try definition
                .semanticValueProvider(with: url)
                .semanticValue(for: dependency)
        }
    }

    private func semanticValueProvidingManifests(for dependency: Dependency) -> [SemanticValueProvidingManifest] {
        manifests
            .filter { !($0.omitFor ?? []).contains(dependency.name) }
            .map { SemanticValueProvidingManifest(manifest: $0, definition: manifestDefinitions[$0.type]!, root: root) }
    }

    func semanticValues(for dependency: Dependency) throws -> [SemanticValue] {
        try semanticValueProvidingManifests(for: dependency)
            .map { try $0.semanticValue(for: dependency) }
    }

    func manifestsGroupedBySemanticValue(for dependency: Dependency) throws -> [SemanticValue: [SemanticValueProvidingManifest]] {
        try Dictionary(grouping: semanticValueProvidingManifests(for: dependency)) {
            try $0.semanticValue(for: dependency)
        }
    }
}
