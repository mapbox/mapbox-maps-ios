import Foundation

protocol SemanticVersionProviding {
    static func from(file url: URL) throws -> Self
    func semanticVersion(for dependency: Config.Dependency) throws -> SemanticVersion
}
