import XCTest
import Hammer
import MapboxMaps

@MainActor
class GestureTestCase: MapViewIntegrationTestCase {
    enum Constants {
        static let pinchThreshold = 8.0
        static let pinchDuration = EventGenerator.pinchDuration
    }

    @MainActor
    var eventGenerator: EventGenerator!

    @MainActor
    var camera: CameraState {
        get {
            mapView.cameraState
        }
        set {
            mapView.mapboxMap.setCamera(to: CameraOptions(cameraState: newValue))
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        // There are no `setUpWithError` method that accepts async context
        // That why we wrap MainActor methods into DispatchQueue.main.async
        let initMain = expectation(description: "UI related initialisation")
        DispatchQueue.main.async {
            self.camera.center.latitude = 39.32
            self.camera.center.longitude = -92.72
            self.camera.zoom = 5

            self.eventGenerator = try! EventGenerator(view: self.mapView)
            self.eventGenerator.showTouches = true

            self.addTeardownBlock {
                self.eventGenerator = nil
            }

            initMain.fulfill()
        }

        wait(for: [initMain], timeout: 0.5)
    }
}
