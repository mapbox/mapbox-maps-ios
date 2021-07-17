import XCTest
@testable import DepsValidatorLibrary

private typealias Dependency = Package.Dependency

final class PackageTests: XCTestCase {
    func testInitialization() throws {
        let url = Bundle.module.url(forResource: "Package.swift", withExtension: "example")!

        let packageDir = FileManager.default.temporaryDirectory.appendingPathComponent("MyLibrary")
        try? FileManager.default.removeItem(at: packageDir)
        try FileManager.default.createDirectory(at: packageDir, withIntermediateDirectories: true, attributes: nil)
        let packageURL = packageDir.appendingPathComponent("Package.swift")
        try FileManager.default.copyItem(at: url, to: packageURL)

        let package = try Package.from(file: packageURL)

        try XCTAssertEqual(package.dependencies, [
            Dependency(name: "A", requirement: .range(lowerBound: SemanticVersion(string: "1.0.0"),
                                                      upperBound: SemanticVersion(string: "2.0.0"))),
            Dependency(name: "B", requirement: .branch("abranch")),
            Dependency(name: "C", requirement: .exact(SemanticVersion(string: "1.2.0"))),
            Dependency(name: "D", requirement: .revision("abcdef")),
            Dependency(name: "E", requirement: .range(lowerBound: SemanticVersion(string: "1.2.0"),
                                                      upperBound: SemanticVersion(string: "2.0.0"))),
            Dependency(name: "F", requirement: .range(lowerBound: SemanticVersion(string: "1.2.0"),
                                                      upperBound: SemanticVersion(string: "1.3.0"))),
        ])
    }
}
