import XCTest
import MapboxMaps

final class Puck3DIntegrationTests: XCTestCase {

    var resourceOptions: ResourceOptions!

    override func setUpWithError() throws {
        try super.setUpWithError()
        resourceOptions = try ResourceOptions(accessToken: mapboxAccessToken())
    }

    func testPuck3DDeinitializationDoesNotCrash() {
        autoreleasepool {
            let mapView = MapView(frame: .zero)
            mapView.location.options.puckType = .puck3D(Puck3DConfiguration(
                                                            model: Model()))
        }
        // there is no assertion here because this test is
        // merely ensuring that Puck3D does not crash when
        // it gets deinited
    }
}
