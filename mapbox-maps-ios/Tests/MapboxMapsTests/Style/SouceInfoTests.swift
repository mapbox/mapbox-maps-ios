import XCTest
import MapboxMaps

final class SourceInfoTests: XCTestCase {
    func testMemberwiseInit() {
        let id = String.randomASCII(withLength: .random(in: 0..<20))
        let type = SourceType.random()

        let sourceInfo = SourceInfo(id: id, type: type)

        XCTAssertEqual(sourceInfo.id, id)
        XCTAssertEqual(sourceInfo.type, type)
    }
}
