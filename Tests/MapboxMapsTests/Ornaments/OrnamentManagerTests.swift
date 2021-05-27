import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsOrnaments
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class OrnamentManagerTests: MapViewIntegrationTestCase {

    var ornamentSupportableView: OrnamentSupportableView!
    var options: OrnamentOptions!
    var ornamentsManager: OrnamentsManager!

    override func setUp() {
        ornamentSupportableView = OrnamentSupportableMapViewMock(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        options = OrnamentOptions()
        ornamentsManager = OrnamentsManager(view: ornamentSupportableView, options: options)

    }

    override func tearDown() {
        ornamentSupportableView = nil
    }

    func testInitializer() {
        XCTAssertEqual(ornamentSupportableView.subviews.count, 4)
        XCTAssertEqual(ornamentsManager.options.attributionButton.margins, options.attributionButton.margins)

    }

    func testHidingOrnament() {
        let initialSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isInitialCompassHidden = initialSubviews.first?.isHidden else {
            XCTFail("Failed to access the compass' isHidden property.")
            return
        }

        XCTAssertEqual(options.compass.visibility, .adaptive)
        options.compass.visibility = .hidden

        ornamentsManager.options = options

        XCTAssertEqual(options.compass.visibility, .hidden)

        let updatedSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isUpdatedCompassHidden = updatedSubviews.first?.isHidden else {
            XCTFail("Failed to access the updated compass' isHidden property.")
            return
        }

        XCTAssertNotEqual(isInitialCompassHidden, isUpdatedCompassHidden)
    }

    func testCompassTapped() {
        guard let mapView = mapView else {
            XCTFail("Map view could not be found")
            return
        }
        let initialSubviews = mapView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let compass = initialSubviews.first as? MapboxCompassOrnamentView else {
            XCTFail("Failed because compass could not be found")
            return
        }

        mapView.camera.setCamera(to: CameraOptions(bearing: 0))

        XCTAssertTrue(compass.containerView.isHidden)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, compass.currentBearing)

        mapView.camera.setCamera(to: CameraOptions(bearing: 30))
        XCTAssertFalse(compass.containerView.isHidden)
        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing, compass.currentBearing)

        ornamentSupportableView.compassTapped()

        let expectation = XCTestExpectation(description: "The compass' bearing should be 0 after a tap gesture")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if mapView.mapboxMap.cameraState.bearing == 0 {
                expectation.fulfill()
            } else {
                XCTFail("The compass' bearing is not 0.")
            }
        }


        wait(for: [expectation], timeout: 5)
    }
}

