import Foundation

protocol SemanticVersionRequirementProviding {
    static func from(file url: URL) throws -> Self
    func semanticVersionRequirement(for dependency: Config.Dependency) throws -> SemanticVersionRequirement
}
