import XCTest
@testable import MapboxMaps

final class CameraDebugViewTests: XCTestCase {
    var cameraDebugView: CameraDebugView!
    let cameraState = CameraState(center: CLLocationCoordinate2D(latitude: -90, longitude: 90),
                                  padding: UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4),
                                  zoom: 14,
                                  bearing: 39,
                                  pitch: 23)
    let cameraState2 = CameraState(center: CLLocationCoordinate2D(latitude: -40, longitude: 40),
                                  padding: UIEdgeInsets(top: 4, left: 3, bottom: 2, right: 1),
                                  zoom: 11,
                                  bearing: 32,
                                  pitch: 54)

    override func setUpWithError() throws {
        cameraDebugView = CameraDebugView()
    }

    override func tearDownWithError() throws {
        cameraDebugView = nil
    }

    func testCameraState() throws {
        // Should start nil
        XCTAssertNil(cameraDebugView.cameraState)
        XCTAssertEqual(cameraDebugView.subviews.count, 2)

        cameraDebugView.cameraState = cameraState
        XCTAssertEqual(cameraState, cameraDebugView.cameraState)

        // new values should replace old values
        cameraDebugView.cameraState = cameraState2
        XCTAssertEqual(cameraState2, cameraDebugView.cameraState)
    }

    func testLogAndFormatString() {
        cameraDebugView.cameraState = cameraState
        let cameraStateLabel = cameraDebugView.subviews.compactMap { $0 as? UILabel }.first

        XCTAssertEqual(cameraStateLabel?.text?.contains("lat: -90"), true)
        XCTAssertEqual(cameraStateLabel?.text?.contains("lon: 90"), true)
        XCTAssertEqual(cameraStateLabel?.text?.contains("zoom: 14"), true)
        XCTAssertEqual(cameraStateLabel?.text?.contains("bearing: 39"), true)
        XCTAssertEqual(cameraStateLabel?.text?.contains("pitch: 23"), true)
    }

}
