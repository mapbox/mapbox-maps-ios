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

        var expectation: XCTestExpectation
        didFinishLoadingStyle = { _ in
            let layers = try! mapView.__map.getStyleLayers()

            expectation = XCTestExpectation(description: "Getting style layers succeeded")
            expectation.expectedFulfillmentCount = layers.count
            do {
                for layer in layers {
//                    var layerType : Layer
//                    switch layer.type {
//                    case "line":
//                        layerType = LineLayer.self as! Layer
//                    case "symbol":
//                        layerType = SymbolLayer.self as! Layer
//                    case "fill":
//                        layerType = FillLayer.self as! Layer
//                    case "background":
//                        layerType = BackgroundLayer.self as! Layer
//                    default:
//                        print("Unable to match type for layer of type \(layer.type)")
//                    }
//
                    let layerResponse = style.getLayer(with: layer.id, type: getLayerClass(type: layer.type).self) // Cannot convert value of type 'Layer' to expected argument type 'T.Type'

                    // let layerResponse = style.getLayer(with: layer.id, type: getLayerClass(type: layer.type).self as! T.Type) // Cannot find type 'T' in scope
                    switch layerResponse {
                    case .success:
                        expectation.fulfill()
                    default:
                        XCTFail("Failed to get layer with id \(layer.id)")
                    }
                    
//                     var result : Any
//                     switch layer.type {
//                     case "line":
//                         result = style.getLayer(with: layer.id, type: LineLayer.self)
//                     case "symbol":
//                         result = style.getLayer(with: layer.id, type: SymbolLayer.self)
//                     case "fill":
//                         result = style.getLayer(with: layer.id, type: FillLayer.self)
//                     case "background":
//                         result = style.getLayer(with: layer.id, type: BackgroundLayer.self)
//                     default:
//                         print("Unable to match type for layer of type \(layer.type)")
//                     }
//                     switch result as! Result{
//                     case .success:
//                         expectation.fulfill()
//                     default:
//                         XCTFail("Failed to get layer with id \(layer.id)")
//                     }

                }
            } catch {
                XCTFail("Failed to get layer")
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func getLayerClass(type: String) -> Layer {
        switch type {
        case "line":
            return LineLayer as! Layer
        case "symbol":
            return SymbolLayer.self as! Layer
        case "fill":
            return FillLayer.self as! Layer
        case "background":
            return BackgroundLayer.self as! Layer
        default:
            XCTFail("Could not convert \(type)to Layer")
        }
    }
}
