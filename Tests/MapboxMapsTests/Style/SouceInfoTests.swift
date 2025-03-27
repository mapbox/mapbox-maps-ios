import XCTest
import MapboxMaps

final class SourceInfoTests: XCTestCase {
    func testMemberwiseInit() {
        let id = String.testConstantASCII(withLength: 20)
        let type = SourceType.testConstantValue()

        let sourceInfo = SourceInfo(id: id, type: type)

        XCTAssertEqual(sourceInfo.id, id)
        XCTAssertEqual(sourceInfo.type, type)
    }
}
