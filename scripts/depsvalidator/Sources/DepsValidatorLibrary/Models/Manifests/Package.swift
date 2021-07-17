import Foundation

struct Package: Decodable, SemanticValueProviding {
    enum Error: Swift.Error {
        case unsupportedVersionRequirements(String)
    }

    private static let cache = ManifestCache { (url) -> Self in
        let data = Process
            .shell("swift package --package-path \(url.deletingLastPathComponent().path) dump-package")
            .output
        return try JSONDecoder().decode(Self.self, from: data)
    }

    static func from(file fileURL: URL) throws -> Self {
        try cache.manifest(for: fileURL)
    }

    var dependencies: [Dependency]

    struct Dependency: Decodable, Equatable {
        var name: String
        var requirement: Requirement

        enum Requirement: Decodable, Equatable {
            enum Error: Swift.Error {
                case unrecognizedRequirementValue
            }

            case range(lowerBound: SemanticVersion, upperBound: SemanticVersion)
            case branch(String)
            case exact(SemanticVersion)
            case revision(String)

            enum CodingKeys: String, CodingKey {
                case range
                case branch
                case exact
                case revision
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if let range = try container.decodeIfPresent([[String: String]].self, forKey: .range),
                   range.count == 1,
                   let dict = range.first,
                   dict.count == 2,
                   let lowerBound = dict["lowerBound"],
                   let upperBound = dict["upperBound"] {
                    self = try .range(
                        lowerBound: SemanticVersion(string: lowerBound),
                        upperBound: SemanticVersion(string: upperBound))
                } else if let branch = try container.decodeIfPresent([String].self, forKey: .branch),
                          branch.count == 1,
                          let branchString = branch.first {
                    self = .branch(branchString)
                } else if let exact = try container.decodeIfPresent([String].self, forKey: .exact),
                          exact.count == 1,
                          let exactString = exact.first {
                    self = try .exact(SemanticVersion(string: exactString))
                } else if let revision = try container.decodeIfPresent([String].self, forKey: .revision),
                          revision.count == 1,
                          let revisionString = revision.first {
                    self = .revision(revisionString)
                } else {
                    throw Error.unrecognizedRequirementValue
                }
            }
        }
    }

    func semanticValue(for dependency: DepsValidatorLibrary.Dependency) throws -> SemanticValue {
        try .versionRequirement(SemanticVersionRequirement(dependencies.first { $0.name == dependency.name(for: .package) }!.requirement))
    }
}

extension SemanticVersionRequirement {
    init(_ packageDependencyRequirement: Package.Dependency.Requirement) throws {
        switch packageDependencyRequirement {
        case let .range(lowerBound, upperBound):
            self = .range(from: lowerBound, to: upperBound)
        case let .exact(version):
            self = .exactly(version)
        default:
            throw Package.Error.unsupportedVersionRequirements("\(packageDependencyRequirement) is unsupported")
        }
    }
}
