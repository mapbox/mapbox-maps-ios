struct ManifestName: Hashable, RawRepresentable, Decodable {
    static let package = ManifestName(rawValue: "Package.swift")
    static let resolvedPackage = ManifestName(rawValue: "Package.resolved")
    static let podspec = ManifestName(rawValue: "Podspec")
    static let cartfile = ManifestName(rawValue: "Cartfile")
    static let resolvedCartfile = ManifestName(rawValue: "Cartfile.resolved")

    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}

struct Manifest: Decodable {
    var type: ManifestName
    var path: String?
    var omitFor: [String]?

    enum CodingKeys: String, CodingKey {
        case type
        case path
        case omitFor = "omit_for"
    }
}
