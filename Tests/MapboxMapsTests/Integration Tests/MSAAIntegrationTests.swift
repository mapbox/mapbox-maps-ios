import XCTest
@testable import MapboxMaps

class MSAAIntegrationTests: XCTestCase {
    func testDefaultConfigurationMSAA() throws {
        let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 400)))
        let metalDevice = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let metalView = try XCTUnwrap(mapView.getMetalView(for: metalDevice))

        XCTAssertEqual(metalView.sampleCount, 1)
    }

    func testCustomConfigurationMSAA() throws {
        let customAntialiasingSampleCount = 2
        let mapView = MapView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 400)),
                              mapInitOptions: MapInitOptions(antialiasingSampleCount: customAntialiasingSampleCount))
        let metalDevice = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let metalView = try XCTUnwrap(mapView.getMetalView(for: metalDevice))

        XCTAssertEqual(metalView.sampleCount, customAntialiasingSampleCount)
    }
}
