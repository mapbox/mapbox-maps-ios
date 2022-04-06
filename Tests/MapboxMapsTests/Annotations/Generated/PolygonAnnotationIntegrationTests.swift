// This file is generated
import XCTest
@testable import MapboxMaps

final class PolygonAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolygonAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makePolygonAnnotationManager()
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
        let secondAnnotationManager = mapView.annotations.makePolygonAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        annotation.fillOpacity = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.style.layer(withId: self.manager.layerId, type: FillLayer.self) else {
                return false
            }
            return layer.fillOpacity == .expression(Exp(.number) {
                Exp(.get) {
                    "fill-opacity"
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

    func testFillAntialias() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.fillAntialias = value
        XCTAssertEqual(manager.fillAntialias, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillAntialias {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillAntialias = nil
        XCTAssertNil(manager.fillAntialias)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillAntialias, .constant((Style.layerPropertyDefaultValue(for: .fill, property: "fill-antialias").value as! NSNumber).boolValue))
    }

    func testFillTranslate() throws {
        // Test that the setter and getter work
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.fillTranslate = value
        XCTAssertEqual(manager.fillTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillTranslate = nil
        XCTAssertNil(manager.fillTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillTranslate, .constant(Style.layerPropertyDefaultValue(for: .fill, property: "fill-translate").value as! [Double]))
    }

    func testFillTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = FillTranslateAnchor.allCases.randomElement()!
        manager.fillTranslateAnchor = value
        XCTAssertEqual(manager.fillTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillTranslateAnchor = nil
        XCTAssertNil(manager.fillTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillTranslateAnchor, .constant(FillTranslateAnchor(rawValue: Style.layerPropertyDefaultValue(for: .fill, property: "fill-translate-anchor").value as! String)!))
    }

    func testFillSortKey() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.fillSortKey = value
        XCTAssertEqual(annotation.fillSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillSortKey, .expression(Exp(.number) {
                Exp(.get) {
                    "fill-sort-key"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.fillSortKey = nil
        XCTAssertNil(annotation.fillSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillSortKey, .constant((Style.layerPropertyDefaultValue(for: .fill, property: "fill-sort-key").value as! NSNumber).doubleValue))
    }

    func testFillColor() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.fillColor = value
        XCTAssertEqual(annotation.fillColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "fill-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.fillColor = nil
        XCTAssertNil(annotation.fillColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .fill, property: "fill-color").value as! [Any], options: []))))
    }

    func testFillOpacity() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...1)
        annotation.fillOpacity = value
        XCTAssertEqual(annotation.fillOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "fill-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.fillOpacity = nil
        XCTAssertNil(annotation.fillOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillOpacity, .constant((Style.layerPropertyDefaultValue(for: .fill, property: "fill-opacity").value as! NSNumber).doubleValue))
    }

    func testFillOutlineColor() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.fillOutlineColor = value
        XCTAssertEqual(annotation.fillOutlineColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillOutlineColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "fill-outline-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.fillOutlineColor = nil
        XCTAssertNil(annotation.fillOutlineColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillOutlineColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .fill, property: "fill-outline-color").value as! [Any], options: []))))
    }

    func testFillPattern() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
        // Test that the setter and getter work
        let value = String.randomASCII(withLength: .random(in: 0...100))
        annotation.fillPattern = value
        XCTAssertEqual(annotation.fillPattern, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillPattern, .expression(Exp(.image) {
                Exp(.get) {
                    "fill-pattern"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.fillPattern = nil
        XCTAssertNil(annotation.fillPattern)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try style.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillPattern, .constant(.name(Style.layerPropertyDefaultValue(for: .fill, property: "fill-pattern").value as! String)))
    }
}

// End of generated file
