import XCTest
@testable import struct DepsValidatorLibrary.SemanticVersion

final class SemanticVersionTests: XCTestCase {

    func testInitWithString() throws {
        let version = try SemanticVersion(string: "v1.2.3")

        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 3)
        XCTAssertNil(version.suffix)
    }

    func testInitWithStringNoV() throws {
        let version = try SemanticVersion(string: "1.2.3")

        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 3)
        XCTAssertNil(version.suffix)
    }

    func testInitWithStringWithSuffix() throws {
        let version = try SemanticVersion(string: "v1.2.3-beta.17")

        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 3)
        XCTAssertEqual(version.suffix, "-beta.17")
    }

    func testInitWithStringNoPatch() throws {
        let version = try SemanticVersion(string: "v1.2")

        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 2)
        XCTAssertNil(version.patch)
        XCTAssertNil(version.suffix)
    }

    func verifyInitWithStringsThatAreNotSemvers(_ versionString: String, line: UInt = #line) {
        XCTAssertThrowsError(try SemanticVersion(string: versionString), line: line) { (error) in
            XCTAssertEqual(error as? SemanticVersion.Error, .notASemanticVersion(versionString))
        }
    }

    func testInitWithStringsThatAreNotSemvers() {
        verifyInitWithStringsThatAreNotSemvers("")
        verifyInitWithStringsThatAreNotSemvers("v")
        verifyInitWithStringsThatAreNotSemvers("1")
        verifyInitWithStringsThatAreNotSemvers("v1")
        verifyInitWithStringsThatAreNotSemvers("v1.x")
        verifyInitWithStringsThatAreNotSemvers("v10.0-beta.1")
    }

    func verifyDescription(withVersionString versionString: String, line: UInt = #line) throws {
        try XCTAssertEqual(SemanticVersion(string: versionString).description, versionString)
    }

    func verifyDescriptionPrependsV(withVersionString versionString: String, line: UInt = #line) throws {
        try XCTAssertEqual(SemanticVersion(string: versionString).description, "v" + versionString)
    }

    func testDescription() throws {
        try verifyDescription(withVersionString: "v1.2.3-beta.1")
        try verifyDescription(withVersionString: "v1.2.3")
        try verifyDescription(withVersionString: "v1.2")
        try verifyDescriptionPrependsV(withVersionString: "1.2.3-beta.1")
        try verifyDescriptionPrependsV(withVersionString: "1.2.3")
        try verifyDescriptionPrependsV(withVersionString: "1.2")
    }

    func verifyNextMajor(of version: String, is nextVersion: String, line: UInt = #line) throws {
        let version = try SemanticVersion(string: version)
        let expected = try SemanticVersion(string: nextVersion)

        let actual = version.nextMajor

        XCTAssertEqual(actual, expected)
    }

    func testNextMajor() throws {
        try verifyNextMajor(of: "v1.2.0-beta", is: "v2.0")
        try verifyNextMajor(of: "v1.2.0", is: "v2.0")
        try verifyNextMajor(of: "v1.2", is: "v2.0")
    }

    func verifyNextMinor(of version: String, is nextVersion: String, line: UInt = #line) throws {
        let version = try SemanticVersion(string: version)
        let expected = try SemanticVersion(string: nextVersion)

        let actual = version.nextMinor

        XCTAssertEqual(actual, expected)
    }

    func testNextMinor() throws {
        try verifyNextMinor(of: "v1.2.0-beta", is: "v1.3")
        try verifyNextMinor(of: "v1.2.0", is: "v1.3")
        try verifyNextMinor(of: "v1.2", is: "v1.3")
    }

    func testComponents() throws {
        try XCTAssertEqual(SemanticVersion(string: "v1.2.0-beta").components, [1, 2, 0])
        try XCTAssertEqual(SemanticVersion(string: "1.2.0-beta").components, [1, 2, 0])
        try XCTAssertEqual(SemanticVersion(string: "v1.2.0").components, [1, 2, 0])
        try XCTAssertEqual(SemanticVersion(string: "1.2.0").components, [1, 2, 0])
        try XCTAssertEqual(SemanticVersion(string: "v1.2").components, [1, 2])
        try XCTAssertEqual(SemanticVersion(string: "1.2").components, [1, 2])
    }

    func testEquals() throws {
        try XCTAssertEqual(SemanticVersion(string: "v1.2.0"), SemanticVersion(string: "1.2.0"))
        try XCTAssertEqual(SemanticVersion(string: "v1.2.0-beta"), SemanticVersion(string: "1.2.0-beta"))
        try XCTAssertEqual(SemanticVersion(string: "v1.2"), SemanticVersion(string: "1.2.0"))
        try XCTAssertEqual(SemanticVersion(string: "v1.2"), SemanticVersion(string: "1.2"))
        try XCTAssertNotEqual(SemanticVersion(string: "v1.2.0"), SemanticVersion(string: "v1.2.0-beta"))
        try XCTAssertNotEqual(SemanticVersion(string: "v1.2"), SemanticVersion(string: "v1.2.1"))
        try XCTAssertNotEqual(SemanticVersion(string: "v1.2.1"), SemanticVersion(string: "v1.2.2"))
        try XCTAssertNotEqual(SemanticVersion(string: "v1.2"), SemanticVersion(string: "v1.3"))
        try XCTAssertNotEqual(SemanticVersion(string: "v2.0"), SemanticVersion(string: "v1.0"))
    }

    func testLessThan() throws {
        try XCTAssertLessThan(SemanticVersion(string: "1.0"), SemanticVersion(string: "1.0.1"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0"), SemanticVersion(string: "1.1.0"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0"), SemanticVersion(string: "1.1"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0"), SemanticVersion(string: "2.0"))

        try XCTAssertLessThan(SemanticVersion(string: "1.0.0"), SemanticVersion(string: "1.0.1"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0.0"), SemanticVersion(string: "1.1.0"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0.0"), SemanticVersion(string: "1.1"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0.0"), SemanticVersion(string: "2.0"))

        try XCTAssertLessThan(SemanticVersion(string: "1.0.0-beta1"), SemanticVersion(string: "1.0.1-beta0"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0.0-beta1"), SemanticVersion(string: "1.1.0-beta0"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0.0-beta1"), SemanticVersion(string: "1.1"))
        try XCTAssertLessThan(SemanticVersion(string: "1.0.0-beta1"), SemanticVersion(string: "2.0"))

        try XCTAssertFalse(SemanticVersion(string: "1.0.0-beta1") < SemanticVersion(string: "1.0.0-beta2"))
        try XCTAssertFalse(SemanticVersion(string: "1.0.0-beta2") < SemanticVersion(string: "1.0.0-beta1"))
        try XCTAssertFalse(SemanticVersion(string: "1.0.0-beta2") == SemanticVersion(string: "1.0.0-beta1"))
    }
}
