import Foundation

struct Podspec: Decodable, SemanticValueProviding {
    enum Error: Swift.Error {
        case unsupportedDependencyRequirement(DependencyRequirement)
    }

    private static let cache = ManifestCache { (url) -> Self in
        let data = Process.shell("LANG=en_US.UTF-8 pod ipc spec \(url.path)").output
        return try JSONDecoder().decode(Self.self, from: data)
    }

    static func from(file fileURL: URL) throws -> Self {
        try cache.manifest(for: fileURL)
    }

    enum DependencyRequirement: Decodable, Equatable {
        enum Error: Swift.Error {
            case invalidDependencyVersionRequirements([String])
        }

        case any
        case exactly(SemanticVersion)
        case greaterThan(SemanticVersion)
        case greaterThanOrEqualTo(SemanticVersion)
        case lessThan(SemanticVersion)
        case lessThanOrEqualTo(SemanticVersion)
        case range(from: SemanticVersion, to: SemanticVersion)

        // swiftlint:disable:next cyclomatic_complexity
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let requirements = try container.decode([String].self)
            if requirements.count == 0 {
                self = .any
            } else if requirements.count == 1, let requirement = requirements.first {
                let components = requirement.components(separatedBy: .whitespacesAndNewlines)
                if components.count == 1, let versionString = components.first {
                    self = try .exactly(SemanticVersion(string: versionString))
                } else if components.count == 2,
                          let op = components.first,
                          let versionString = components.last {
                    let version = try SemanticVersion(string: versionString)
                    switch op {
                    case "=":
                        self = .exactly(version)
                    case ">":
                        self = .greaterThan(version)
                    case ">=":
                        self = .greaterThanOrEqualTo(version)
                    case "<":
                        self = .lessThan(version)
                    case "<=":
                        self = .lessThanOrEqualTo(version)
                    case "~>":
                        // In CocoaPods, the range is based on the last component specified.
                        // See https://guides.cocoapods.org/syntax/podfile.html#pod
                        self = .range(from: version, to: version.patch == nil ? version.nextMajor : version.nextMinor)
                    default:
                        throw Error.invalidDependencyVersionRequirements([requirement])
                    }
                } else {
                    throw Error.invalidDependencyVersionRequirements([requirement])
                }
            } else {
                throw Error.invalidDependencyVersionRequirements(requirements)
            }
        }
    }

    var dependencies: [String: DependencyRequirement]

    func semanticValue(for dependency: Dependency) throws -> SemanticValue {
        try .versionRequirement(SemanticVersionRequirement(dependencies[dependency.name(for: .podspec)]!))
    }
}

extension SemanticVersionRequirement {
    init(_ podspecDependencyRequirement: Podspec.DependencyRequirement) throws {
        switch podspecDependencyRequirement {
        case .any:
            self = .any
        case let .exactly(version):
            self = .exactly(version)
        case let .range(fromVersion, toVersion):
            self = .range(from: fromVersion, to: toVersion)
        default:
            throw Podspec.Error.unsupportedDependencyRequirement(podspecDependencyRequirement)
        }
    }
}
