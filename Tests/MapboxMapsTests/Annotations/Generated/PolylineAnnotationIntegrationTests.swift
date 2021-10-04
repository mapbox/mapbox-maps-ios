// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolylineAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolylineAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makePolylineAnnotationManager()
    }

    override func tearDownWithError() throws {
        manager = nil
        try super.tearDownWithError()
    }

    internal func testSourceAndLayerSetup() throws {
        XCTAssertTrue(style.layerExists(withId: manager.layerId))
        XCTAssertTrue(try style.isPersistentLayer(id: manager.layerId),
                      "The layer with id \(manager.layerId) should be persistent.")
        XCTAssertTrue(style.sourceExists(withId: manager.sourceId))
    }

    func testSourceAndLayerRemovedUponDestroy() {
        manager.destroy()

        XCTAssertFalse(style.allLayerIdentifiers.map { $0.id }.contains(manager.layerId))
        XCTAssertFalse(style.allSourceIdentifiers.map { $0.id }.contains(manager.sourceId))
    }

    func testCreatingSecondAnnotationManagerWithTheSameId() throws {
        let secondAnnotationManager = mapView.annotations.makePolylineAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        annotation.lineWidth = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.style.layer(withId: self.manager.layerId, type: LineLayer.self) else {
                return false
            }
            return layer.lineWidth == .expression(Exp(.number) {
                Exp(.get) {
                    "line-width"
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

    func testLineCap() throws {
        // Test that the setter and getter work
        let value = LineCap.allCases.randomElement()!
        manager.lineCap = value
        XCTAssertEqual(manager.lineCap, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineCap, .constant(value))

        // Test that the property can be reset to nil
        manager.lineCap = nil
        XCTAssertNil(manager.lineCap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineCap, .constant(LineCap(rawValue: Style.layerPropertyDefaultValue(for: .line, property: "line-cap").value as! String)!))
    }

    func testLineMiterLimit() throws {
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        manager.lineMiterLimit = value
        XCTAssertEqual(manager.lineMiterLimit, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineMiterLimit, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.lineMiterLimit = nil
        XCTAssertNil(manager.lineMiterLimit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineMiterLimit, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-miter-limit").value as! NSNumber).doubleValue))
    }

    func testLineRoundLimit() throws {
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        manager.lineRoundLimit = value
        XCTAssertEqual(manager.lineRoundLimit, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineRoundLimit, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.lineRoundLimit = nil
        XCTAssertNil(manager.lineRoundLimit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineRoundLimit, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-round-limit").value as! NSNumber).doubleValue))
    }

    func testLineDasharray() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { Double.random(in: -100000...100000) })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineDasharray, .constant(value.map { Double(Float($0)) }))

        // Test that the property can be reset to nil
        manager.lineDasharray = nil
        XCTAssertNil(manager.lineDasharray)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineDasharray, .constant(Style.layerPropertyDefaultValue(for: .line, property: "line-dasharray").value as! [Double]))
    }

    func testLineTranslate() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: 2, generator: { Double.random(in: -100000...100000) })
        manager.lineTranslate = value
        XCTAssertEqual(manager.lineTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslate, .constant(value.map { Double(Float($0)) }))

        // Test that the property can be reset to nil
        manager.lineTranslate = nil
        XCTAssertNil(manager.lineTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslate, .constant(Style.layerPropertyDefaultValue(for: .line, property: "line-translate").value as! [Double]))
    }

    func testLineTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = LineTranslateAnchor.allCases.randomElement()!
        manager.lineTranslateAnchor = value
        XCTAssertEqual(manager.lineTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslateAnchor, .constant(value))

        // Test that the property can be reset to nil
        manager.lineTranslateAnchor = nil
        XCTAssertNil(manager.lineTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslateAnchor, .constant(LineTranslateAnchor(rawValue: Style.layerPropertyDefaultValue(for: .line, property: "line-translate-anchor").value as! String)!))
    }

    func testLineJoin() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = LineJoin.allCases.randomElement()!
        annotation.lineJoin = value
        XCTAssertEqual(annotation.lineJoin, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineJoin, .expression(Exp(.toString) {
                Exp(.get) {
                    "line-join"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineJoin = nil
        XCTAssertNil(annotation.lineJoin)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineJoin, .constant(LineJoin(rawValue: Style.layerPropertyDefaultValue(for: .line, property: "line-join").value as! String)!))
    }

    func testLineSortKey() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.lineSortKey = value
        XCTAssertEqual(annotation.lineSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineSortKey, .expression(Exp(.number) {
                Exp(.get) {
                    "line-sort-key"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineSortKey = nil
        XCTAssertNil(annotation.lineSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineSortKey, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-sort-key").value as! NSNumber).doubleValue))
    }

    func testLineBlur() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineBlur = value
        XCTAssertEqual(annotation.lineBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBlur, .expression(Exp(.number) {
                Exp(.get) {
                    "line-blur"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineBlur = nil
        XCTAssertNil(annotation.lineBlur)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBlur, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-blur").value as! NSNumber).doubleValue))
    }

    func testLineColor() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.lineColor = value
        XCTAssertEqual(annotation.lineColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "line-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineColor = nil
        XCTAssertNil(annotation.lineColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .line, property: "line-color").value as! [Any], options: []))))
    }

    func testLineGapWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineGapWidth = value
        XCTAssertEqual(annotation.lineGapWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineGapWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "line-gap-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineGapWidth = nil
        XCTAssertNil(annotation.lineGapWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineGapWidth, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-gap-width").value as! NSNumber).doubleValue))
    }

    func testLineOffset() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.lineOffset = value
        XCTAssertEqual(annotation.lineOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOffset, .expression(Exp(.number) {
                Exp(.get) {
                    "line-offset"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineOffset = nil
        XCTAssertNil(annotation.lineOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOffset, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-offset").value as! NSNumber).doubleValue))
    }

    func testLineOpacity() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineOpacity = value
        XCTAssertEqual(annotation.lineOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "line-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineOpacity = nil
        XCTAssertNil(annotation.lineOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOpacity, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-opacity").value as! NSNumber).doubleValue))
    }

    func testLinePattern() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = String.randomASCII(withLength: .random(in: 0...100))
        annotation.linePattern = value
        XCTAssertEqual(annotation.linePattern, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.linePattern, .expression(Exp(.image) {
                Exp(.get) {
                    "line-pattern"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.linePattern = nil
        XCTAssertNil(annotation.linePattern)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.linePattern, .constant(.name(Style.layerPropertyDefaultValue(for: .line, property: "line-pattern").value as! String)))
    }

    func testLineWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.lineWidth = value
        XCTAssertEqual(annotation.lineWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "line-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.lineWidth = nil
        XCTAssertNil(annotation.lineWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineWidth, .constant((Style.layerPropertyDefaultValue(for: .line, property: "line-width").value as! NSNumber).doubleValue))
    }
}

// End of generated file
