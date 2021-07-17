import Foundation
import CarthageKit

protocol ManifestDefinition {
    var defaultPath: String { get }
    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding
}

struct PackageManifestDefinition: ManifestDefinition {
    let defaultPath = "Package.swift"

    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding {
        try Package.from(file: url)
    }
}

struct ResolvedPackageManifestDefinition: ManifestDefinition {
    let defaultPath = "Package.resolved"

    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding {
        try ResolvedPackage.from(file: url)
    }
}

struct PodspecManifestDefinition: ManifestDefinition {
    let defaultPath = "*.podspec"

    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding {
        try Podspec.from(file: url)
    }
}

struct CartfileManifestDefinition: ManifestDefinition {
    let defaultPath = "Cartfile"

    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding {
        try Cartfile.from(file: url)
    }
}

struct ResolvedCartfileManifestDefinition: ManifestDefinition {
    let defaultPath = "Cartfile.resolved"

    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding {
        try ResolvedCartfile.from(file: url)
    }
}

enum CustomManifestDefinitionType: String, Decodable {
    case semanticVersion = "SemanticVersion"
    case semanticVersionRequirement = "SemanticVersionRequirement"
}

struct CustomManifestDefinition: Decodable, ManifestDefinition {
    var name: ManifestName
    var type: CustomManifestDefinitionType
    var defaultPath: String
    var command: String

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case defaultPath = "default_path"
        case command
    }

    func semanticValueProvider(with url: URL) throws -> SemanticValueProviding {
        Custom(url: url, command: command, manifestName: name, type: type)
    }
}
