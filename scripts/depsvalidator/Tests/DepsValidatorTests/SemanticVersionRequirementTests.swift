import XCTest
@testable import DepsValidatorLibrary

final class SemanticVersionRequirementTests: XCTestCase {
    func testIsSatisfiedBy() throws {
        try XCTAssertTrue(SemanticVersionRequirement.any.isSatisfied(by: SemanticVersion(string: "1.2.0")))

        let exactly = try SemanticVersionRequirement.exactly(SemanticVersion(string: "v1.2.0"))
        try XCTAssertTrue(exactly.isSatisfied(by: SemanticVersion(string: "v1.2.0")))
        try XCTAssertTrue(exactly.isSatisfied(by: SemanticVersion(string: "1.2.0")))
        try XCTAssertTrue(exactly.isSatisfied(by: SemanticVersion(string: "1.2")))

        let range = try SemanticVersionRequirement.range(
            from: SemanticVersion(string: "v1.2.0"),
            to: SemanticVersion(string: "v2.0"))
        try XCTAssertTrue(range.isSatisfied(by: SemanticVersion(string: "v1.2.0")))
        try XCTAssertTrue(range.isSatisfied(by: SemanticVersion(string: "v1.999999.123123123")))
        try XCTAssertFalse(range.isSatisfied(by: SemanticVersion(string: "v2.0")))

        // Suffixes are ignored during comparison
        let suffixRange = try SemanticVersionRequirement.range(
            from: SemanticVersion(string: "v1.2.0-beta1"),
            to: SemanticVersion(string: "v1.2.0-beta10"))
        try XCTAssertFalse(suffixRange.isSatisfied(by: SemanticVersion(string: "v1.2.0")))
        try XCTAssertFalse(suffixRange.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta0")))
        try XCTAssertFalse(suffixRange.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta1")))
        try XCTAssertFalse(suffixRange.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta2")))
        try XCTAssertFalse(suffixRange.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta10")))
        try XCTAssertFalse(suffixRange.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta11")))

        // Suffixes are ignored during comparison
        let suffixRange2 = try SemanticVersionRequirement.range(
            from: SemanticVersion(string: "v1.2.0-beta4"),
            to: SemanticVersion(string: "v1.2.1"))
        try XCTAssertTrue(suffixRange2.isSatisfied(by: SemanticVersion(string: "v1.2.0")))
        try XCTAssertTrue(suffixRange2.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta0")))
        try XCTAssertTrue(suffixRange2.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta1")))
        try XCTAssertTrue(suffixRange2.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta2")))
        try XCTAssertTrue(suffixRange2.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta10")))
        try XCTAssertTrue(suffixRange2.isSatisfied(by: SemanticVersion(string: "v1.2.0-beta11")))
    }
}
