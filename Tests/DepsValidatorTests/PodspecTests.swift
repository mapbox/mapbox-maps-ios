import XCTest
@testable import DepsValidatorLibrary

final class PodspecTests: XCTestCase {
    func testInitialization() throws {
        let url = Bundle.module.url(forResource: "Example", withExtension: "podspec")!

        let podspec = try Podspec.from(file: url)

        try XCTAssertEqual(podspec.dependencies, [
            "a": .exactly(SemanticVersion(string: "1.0")),
            "b": .exactly(SemanticVersion(string: "1.0")),
            "c": .greaterThan(SemanticVersion(string: "1.0")),
            "d": .greaterThanOrEqualTo(SemanticVersion(string: "1.0")),
            "e": .lessThan(SemanticVersion(string: "1.0")),
            "f": .lessThanOrEqualTo(SemanticVersion(string: "1.0")),
            "g": .range(from: SemanticVersion(string: "1.0"), to: SemanticVersion(string: "2.0")),
            "h": .range(from: SemanticVersion(string: "1.0.0"), to: SemanticVersion(string: "1.1")),
            "i": .range(from: SemanticVersion(string: "1.0.0-beta.1"), to: SemanticVersion(string: "1.1")),
            "j": .any,
        ])
    }
}
