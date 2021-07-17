import Foundation

struct ResolvedPackage: Decodable, SemanticValueProviding {
    enum Error: Swift.Error {
        case unsupportedPin(ResolvedPackageObject.Pin)
    }

    private static let cache = ManifestCache { (url) -> Self in
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Self.self, from: data)
    }

    static func from(file fileURL: URL) throws -> Self {
        try cache.manifest(for: fileURL)
    }

    var object: ResolvedPackageObject

    struct ResolvedPackageObject: Decodable {
        var pins: [Pin]

        struct Pin: Decodable {
            var package: String
            var state: State

            struct State: Decodable {
                var branch: String?
                var revision: String
                var version: String?
            }
        }
    }

    func semanticValue(for dependency: Dependency) throws -> SemanticValue {
        try .version(SemanticVersion(object.pins.first { $0.package == dependency.name(for: .resolvedPackage) }!))
    }
}

extension SemanticVersion {
    init(_ pin: ResolvedPackage.ResolvedPackageObject.Pin) throws {
        if let version = pin.state.version {
            self = try SemanticVersion(string: version)
        } else {
            throw ResolvedPackage.Error.unsupportedPin(pin)
        }
    }
}
