enum SemanticValue: Hashable {
    case version(SemanticVersion)
    case versionRequirement(SemanticVersionRequirement)

    var version: SemanticVersion? {
        switch self {
        case let .version(version):
            return version
        case .versionRequirement:
            return nil
        }
    }

    var versionRequirement: SemanticVersionRequirement? {
        switch self {
        case let .versionRequirement(versionRequirement):
            return versionRequirement
        case .version:
            return nil
        }
    }
}
