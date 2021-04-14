import Foundation

struct JSONManifest: SemanticVersionProviding {
    private static let cache = ManifestCache { (url) -> Self in
        let data = try Data(contentsOf: url)
        let dependencies = try JSONDecoder().decode([String: SemanticVersion].self, from: data)
        return JSONManifest(dependencies: dependencies)
    }

    static func from(file fileURL: URL) throws -> Self {
        try cache.manifest(for: fileURL)
    }

    var dependencies: [String: SemanticVersion]

    func semanticVersion(for dependency: Config.Dependency) -> SemanticVersion {
        dependencies[dependency.name(for: .json)]!
    }
}
