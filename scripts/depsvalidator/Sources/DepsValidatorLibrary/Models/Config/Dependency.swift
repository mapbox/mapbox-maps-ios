struct Dependency: Decodable {
    var name: String
    var variations: [ManifestName: String]?

    enum CodingKeys: String, CodingKey {
        case name
        case variations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        // The following is required since Yams doesn't handle the dictionary with ManifestName as a key
        variations = try container.decodeIfPresent([String: String].self, forKey: .variations)
            .map { (dict) in
                dict.map { (key, value) in
                    (ManifestName(rawValue: key), value)
                }
            }
            .map {
                Dictionary($0, uniquingKeysWith: { first, _ in first })
            }
    }

    func name(for manifestName: ManifestName) -> String {
        variations?[manifestName] ?? name
    }
}
