import Foundation

protocol SemanticValueProviding {
    func semanticValue(for dependency: Dependency) throws -> SemanticValue
}
