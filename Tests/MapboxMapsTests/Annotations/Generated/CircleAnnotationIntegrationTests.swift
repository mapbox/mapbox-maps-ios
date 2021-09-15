// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: CircleAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let managerCreatedExpectation = XCTestExpectation(description: "Successfully created annotation manager.")
        didFinishLoadingStyle = { _ in
            guard let mapView = self.mapView else {
                return
            }
            self.manager = mapView.annotations.makeCircleAnnotationManager()
            managerCreatedExpectation.fulfill()
        }
        continueAfterFailure = false
        style?.uri = .streets
        wait(for: [managerCreatedExpectation], timeout: 5.0)
        continueAfterFailure = true
    }

    override func tearDownWithError() throws {
        manager = nil
        try super.tearDownWithError()
    }

    internal func testSourceAndLayerSetup() throws {
        let style = try XCTUnwrap(self.style)
        XCTAssertTrue(style.layerExists(withId: manager.layerId))
        XCTAssertTrue(try style.isPersistentLayer(id: manager.layerId),
                      "The layer with id \(manager.layerId) should be persistent.")
        XCTAssertTrue(style.sourceExists(withId: manager.sourceId))
    }

    func testSynchronizesAnnotationsEventually() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        annotation.circleRadius = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer: CircleLayer = try? self.style?.layer(withId: self.manager.layerId) else {
                return false
            }
            return layer.circleRadius == .expression(Exp(.number) {
                Exp(.get) {
                    "circle-radius"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            })
        }), evaluatedWith: nil, handler: nil)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCirclePitchAlignment() throws {
        // Test that the setter and getter work
        let value = CirclePitchAlignment.allCases.randomElement()!
        manager.circlePitchAlignment = value
        XCTAssertEqual(manager.circlePitchAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circlePitchAlignment, .constant(value))

        // Test that the property can be reset to nil
        manager.circlePitchAlignment = nil
        XCTAssertNil(manager.circlePitchAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circlePitchAlignment, .constant(CirclePitchAlignment(rawValue: Style.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-alignment").value as! String)!))
    }

    func testCirclePitchScale() throws {
        // Test that the setter and getter work
        let value = CirclePitchScale.allCases.randomElement()!
        manager.circlePitchScale = value
        XCTAssertEqual(manager.circlePitchScale, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circlePitchScale, .constant(value))

        // Test that the property can be reset to nil
        manager.circlePitchScale = nil
        XCTAssertNil(manager.circlePitchScale)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circlePitchScale, .constant(CirclePitchScale(rawValue: Style.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-scale").value as! String)!))
    }

    func testCircleTranslate() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: 2, generator: { Double.random(in: -100000...100000) })
        manager.circleTranslate = value
        XCTAssertEqual(manager.circleTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleTranslate, .constant(value.map { Double(Float($0)) }))

        // Test that the property can be reset to nil
        manager.circleTranslate = nil
        XCTAssertNil(manager.circleTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleTranslate, .constant(Style.layerPropertyDefaultValue(for: .circle, property: "circle-translate").value as! [Double]))
    }

    func testCircleTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = CircleTranslateAnchor.allCases.randomElement()!
        manager.circleTranslateAnchor = value
        XCTAssertEqual(manager.circleTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleTranslateAnchor, .constant(value))

        // Test that the property can be reset to nil
        manager.circleTranslateAnchor = nil
        XCTAssertNil(manager.circleTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleTranslateAnchor, .constant(CircleTranslateAnchor(rawValue: Style.layerPropertyDefaultValue(for: .circle, property: "circle-translate-anchor").value as! String)!))
    }

    func testCircleSortKey() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.circleSortKey = value
        XCTAssertEqual(annotation.circleSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleSortKey, .expression(Exp(.number) {
                Exp(.get) {
                    "circle-sort-key"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleSortKey = nil
        XCTAssertNil(annotation.circleSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleSortKey, .constant((Style.layerPropertyDefaultValue(for: .circle, property: "circle-sort-key").value as! NSNumber).doubleValue))
    }

    func testCircleBlur() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.circleBlur = value
        XCTAssertEqual(annotation.circleBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleBlur, .expression(Exp(.number) {
                Exp(.get) {
                    "circle-blur"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleBlur = nil
        XCTAssertNil(annotation.circleBlur)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleBlur, .constant((Style.layerPropertyDefaultValue(for: .circle, property: "circle-blur").value as! NSNumber).doubleValue))
    }

    func testCircleColor() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.circleColor = value
        XCTAssertEqual(annotation.circleColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "circle-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleColor = nil
        XCTAssertNil(annotation.circleColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .circle, property: "circle-color").value as! [Any], options: []))))
    }

    func testCircleOpacity() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.circleOpacity = value
        XCTAssertEqual(annotation.circleOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "circle-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleOpacity = nil
        XCTAssertNil(annotation.circleOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleOpacity, .constant((Style.layerPropertyDefaultValue(for: .circle, property: "circle-opacity").value as! NSNumber).doubleValue))
    }

    func testCircleRadius() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.circleRadius = value
        XCTAssertEqual(annotation.circleRadius, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleRadius, .expression(Exp(.number) {
                Exp(.get) {
                    "circle-radius"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleRadius = nil
        XCTAssertNil(annotation.circleRadius)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleRadius, .constant((Style.layerPropertyDefaultValue(for: .circle, property: "circle-radius").value as! NSNumber).doubleValue))
    }

    func testCircleStrokeColor() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.circleStrokeColor = value
        XCTAssertEqual(annotation.circleStrokeColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleStrokeColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "circle-stroke-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleStrokeColor = nil
        XCTAssertNil(annotation.circleStrokeColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleStrokeColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-color").value as! [Any], options: []))))
    }

    func testCircleStrokeOpacity() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.circleStrokeOpacity = value
        XCTAssertEqual(annotation.circleStrokeOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleStrokeOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "circle-stroke-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleStrokeOpacity = nil
        XCTAssertNil(annotation.circleStrokeOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleStrokeOpacity, .constant((Style.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-opacity").value as! NSNumber).doubleValue))
    }

    func testCircleStrokeWidth() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.circleStrokeWidth = value
        XCTAssertEqual(annotation.circleStrokeWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: CircleLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleStrokeWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "circle-stroke-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.circleStrokeWidth = nil
        XCTAssertNil(annotation.circleStrokeWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.circleStrokeWidth, .constant((Style.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-width").value as! NSNumber).doubleValue))
    }
}

// End of generated file
