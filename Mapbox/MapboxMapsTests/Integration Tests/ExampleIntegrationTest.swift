import XCTest

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsStyle
#endif

internal class StyleIntegrationTests: MapViewIntegrationTestCase {

    internal func testUpdateStyleLayer() throws {
        guard
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Manipulating style succeeded")
        expectation.expectedFulfillmentCount = 2

        style.styleURL = .streets

        didFinishLoadingStyle = { _ in

            var newBackgroundLayer = BackgroundLayer(id: "test-id")
            newBackgroundLayer.paint?.backgroundColor = .constant(.init(color: .white))

            let result1 = style.addLayer(layer: newBackgroundLayer)

            switch result1 {
            case .success(_):
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Could not add background layer due to error: \(error)")
            }

            let result2 = style.updateLayer(id: newBackgroundLayer.id, type: BackgroundLayer.self) { (layer) in
                layer.paint?.backgroundColor = .constant(.init(color: .blue))
            }

            switch result2 {
            case .success(_):
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Could not update background layer due to error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}
