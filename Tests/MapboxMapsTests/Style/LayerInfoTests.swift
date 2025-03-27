import XCTest
import MapboxMaps

final class LayerInfoTests: XCTestCase {
    func testMemberwiseInit() {
        let id = String.testConstantASCII(withLength: 19)
        let type = LayerType.testConstantValue()

        let layerInfo = LayerInfo(id: id, type: type)

        XCTAssertEqual(layerInfo.id, id)
        XCTAssertEqual(layerInfo.type, type)
    }
}
