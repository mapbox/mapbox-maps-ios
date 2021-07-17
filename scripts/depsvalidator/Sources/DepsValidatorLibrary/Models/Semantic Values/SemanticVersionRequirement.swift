enum SemanticVersionRequirement: CustomStringConvertible, Hashable, Decodable {
    case any
    case exactly(SemanticVersion)
    case range(from: SemanticVersion, to: SemanticVersion)

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case from
        case to
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "any":
            self = .any
        case "exactly":
            self = try .exactly(container.decode(SemanticVersion.self, forKey: .value))
        case "range":
            self = try .range(
                from: container.decode(SemanticVersion.self, forKey: .from),
                to: container.decode(SemanticVersion.self, forKey: .to))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Value for key 'type' must be one of 'any', 'exactly', or 'range'.")
        }
    }

    func isSatisfied(by version: SemanticVersion) -> Bool {
        switch self {
        case .any:
            return true
        case let .exactly(v):
            return v == version
        case let .range(fromVersion, toVersion):
            return version >= fromVersion && version < toVersion
        }
    }

    var description: String {
        switch self {
        case .any:
            return "any"
        case let .exactly(v):
            return "exactly \(v)"
        case let .range(fromVersion, toVersion):
            return "from \(fromVersion) up to \(toVersion)"
        }
    }
}
