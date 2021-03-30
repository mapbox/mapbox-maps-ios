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
        expectation.expectedFulfillmentCount = 3

        style.styleURI = .streets

        didFinishLoadingStyle = { _ in

            var newBackgroundLayer = BackgroundLayer(id: "test-id")
            newBackgroundLayer.paint?.backgroundColor = .constant(.init(color: .white))

            let result1 = style.addLayer(layer: newBackgroundLayer)

            switch result1 {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Could not add background layer due to error: \(error)")
            }

            let result2 = style.updateLayer(id: newBackgroundLayer.id, type: BackgroundLayer.self) { (layer) in
                XCTAssert(layer.paint?.backgroundColor == newBackgroundLayer.paint?.backgroundColor)
                layer.paint?.backgroundColor = .constant(.init(color: .blue))
            }

            switch result2 {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Could not update background layer due to error: \(error)")
            }

            let result3 = style.getLayer(with: newBackgroundLayer.id, type: BackgroundLayer.self)

            switch result3 {
            case .success(let retrievedLayer):
                XCTAssert(retrievedLayer.paint?.backgroundColor == .constant(.init(color: .blue)))
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Could not retrieve background layer due to error: \(error)")
            }

        }

        wait(for: [expectation], timeout: 5.0)
    }

    internal func testMoveStyleLayer() throws {
        guard
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Move style layer succeeded")
        expectation.expectedFulfillmentCount = 2

        style.styleURI = .streets

        didFinishLoadingStyle = { _ in

            let layers = try! style.styleManager.getStyleLayers()
            let newBackgroundLayer = BackgroundLayer(id: "test-id")

            let result = style.addLayer(layer: newBackgroundLayer)

            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Could not add background layer due to error: \(error)")
            }

            // Move layer, repeatedly
            do {
                for step in stride(from: 0, to: layers.count, by: 3) {

                    let newLayerPosition = LayerPosition(above: nil, below: nil, at: step)
                    try style._moveLayer(with: "test-id", to: newLayerPosition)

                    // Get layer position
                    let layers = try style.styleManager.getStyleLayers()
                    let layerIds = layers.map { $0.id }

                    let position = layerIds.firstIndex(of: "test-id")
                    XCTAssertEqual(position, step)
                }

                expectation.fulfill()
            } catch {
                XCTFail("_moveLayer failed with \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetLayers() {
        guard
            let mapView = mapView, let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Getting style layers succeeded")
        expectation.expectedFulfillmentCount = 111
        didFinishLoadingStyle = { _ in
            let layers = try! mapView.__map.getStyleLayers()
            do {
                for layer in layers {
                     switch layer.type {
                     case "line":
                        let result = style.getLayer(with: layer.id, type: LineLayer.self)
                        switch result {
                        case .success:
                            expectation.fulfill()
                        default:
                            XCTFail("Failed to get layer with id \(layer.id), error \(result)")
                        }
                     }
                     case "symbol":
                        let result = style.getLayer(with: layer.id, type: SymbolLayer.self)
                        switch result {
                        case .success:
                            expectation.fulfill()
                        default:
                            XCTFail("Failed to get layer with id \(layer.id), error \(result)")
                        } // getting 17 failures
                     case "fill":
                        let result = style.getLayer(with: layer.id, type: FillLayer.self)
                        switch result {
                        case .success:
                            expectation.fulfill()
                        default:
                            XCTFail("Failed to get layer with id \(layer.id)")
                        }
                     case "background":
                        let result = style.getLayer(with: layer.id, type: BackgroundLayer.self)
                        switch result {
                        case .success:
                            expectation.fulfill()
                        default:
                            XCTFail("Failed to get layer with id \(layer.id), error \(result)")
                        }
                     default:
                         print("Unable to match type for layer of type \(layer.type)")
                     }
                }
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
