import XCTest
import MapboxMaps

final class LayerInfoTests: XCTestCase {
    func testMemberwiseInit() {
        let id = String.randomASCII(withLength: .random(in: 0..<20))
        let type = LayerType.random()

        let layerInfo = LayerInfo(id: id, type: type)

        XCTAssertEqual(layerInfo.id, id)
        XCTAssertEqual(layerInfo.type, type)
    }
}
