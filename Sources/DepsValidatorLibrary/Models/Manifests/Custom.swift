import Foundation

struct Custom: SemanticValueProviding {
    var url: URL
    var command: String
    var manifestName: ManifestName
    var type: CustomManifestDefinitionType

    func semanticValue(for dependency: Dependency) throws -> SemanticValue {
        let environment = [
            "DEPSVALIDATOR_MANIFEST_PATH": url.path,
            "DEPSVALIDATOR_DEPENDENCY_NAME": dependency.name(for: manifestName)]
        switch type {
        case .semanticVersion:
            let string = Process.shell(command, environment: environment).outputString
            return try .version(SemanticVersion(string: string.trimmingCharacters(in: .whitespacesAndNewlines)))
        case .semanticVersionRequirement:
            let data = Process.shell(command, environment: environment).output
            return try .versionRequirement(JSONDecoder().decode(SemanticVersionRequirement.self, from: data))
        }
    }
}
