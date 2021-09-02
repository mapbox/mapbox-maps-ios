import XCTest
@testable import MapboxMaps

final class Puck3DTests: XCTestCase {

    func testModelLayerTypeIsLocationIndicator() {
        let style = MockLocationStyle()
        let puck3D = Puck3D(
            puckStyle: .precise,
            puckBearingSource: .heading,
            style: style,
            configuration: Puck3DConfiguration(model: Model()))

        XCTAssertEqual(puck3D.modelLayer.paint?.modelLayerType, .constant(.locationIndicator))
    }
}
