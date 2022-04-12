@testable import MapboxMaps
import XCTest

final class HighZoomToLowZoomAnimationSpecProviderTests: XCTestCase {

    var provider: HighZoomToLowZoomAnimationSpecProvider!

    override func setUp() {
        super.setUp()
        provider = HighZoomToLowZoomAnimationSpecProvider()
    }

    override func tearDown() {
        provider = nil
        super.tearDown()
    }

    func testMakeAnimationSpecs() {
        let cameraOptions = CameraOptions.random()

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        guard specs.count == 5 else {
            XCTFail("Expected 5 specs")
            return
        }

        XCTAssertEqual(specs[0].duration, 1)
        XCTAssertEqual(specs[0].delay, 0.8)
        XCTAssertEqual(specs[0].cameraOptionsComponent.cameraOptions, CameraOptions(center: cameraOptions.center))

        XCTAssertEqual(specs[1].duration, 1.8)
        XCTAssertEqual(specs[1].delay, 0)
        XCTAssertEqual(specs[1].cameraOptionsComponent.cameraOptions, CameraOptions(zoom: cameraOptions.zoom))

        XCTAssertEqual(specs[2].duration, 1.2)
        XCTAssertEqual(specs[2].delay, 0.6)
        XCTAssertEqual(specs[2].cameraOptionsComponent.cameraOptions, CameraOptions(bearing: cameraOptions.bearing))

        XCTAssertEqual(specs[3].duration, 1)
        XCTAssertEqual(specs[3].delay, 0)
        XCTAssertEqual(specs[3].cameraOptionsComponent.cameraOptions, CameraOptions(pitch: cameraOptions.pitch))

        XCTAssertEqual(specs[4].duration, 1.2)
        XCTAssertEqual(specs[4].delay, 0)
        XCTAssertEqual(specs[4].cameraOptionsComponent.cameraOptions, CameraOptions(padding: cameraOptions.padding))
    }

    func testMakeAnimationSpecsWithEmptyCameraOptions() {
        let cameraOptions = CameraOptions()

        let specs = provider.makeAnimationSpecs(cameraOptions: cameraOptions)

        XCTAssertTrue(specs.isEmpty)
    }
}
