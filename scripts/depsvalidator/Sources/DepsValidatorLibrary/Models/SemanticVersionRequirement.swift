enum SemanticVersionRequirement: CustomStringConvertible, Hashable {
    case any
    case exactly(SemanticVersion)
    case range(from: SemanticVersion, to: SemanticVersion)

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
