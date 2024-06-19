// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PointAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PointAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makePointAnnotationManager()
    }

    override func tearDownWithError() throws {
        manager = nil
        try super.tearDownWithError()
    }

    internal func testSourceAndLayerSetup() throws {
        XCTAssertTrue(mapView.mapboxMap.layerExists(withId: manager.layerId))
        XCTAssertTrue(try mapView.mapboxMap.isPersistentLayer(id: manager.layerId),
                      "The layer with id \(manager.layerId) should be persistent.")
        XCTAssertTrue(mapView.mapboxMap.sourceExists(withId: manager.sourceId))
    }

    func testSourceAndLayerRemovedUponDestroy() {
        manager.destroy()

        XCTAssertFalse(mapView.mapboxMap.allLayerIdentifiers.map { $0.id }.contains(manager.layerId))
        XCTAssertFalse(mapView.mapboxMap.allSourceIdentifiers.map { $0.id }.contains(manager.sourceId))
    }

    func testCreatingSecondAnnotationManagerWithTheSameId() throws {
        let secondAnnotationManager = mapView.annotations.makePointAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.textSize = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self) else {
                return false
            }
            return layer.textSize == .expression(Exp(.number) {
                Exp(.get) {
                    "text-size"
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

    func testIconAllowOverlap() throws {
        // Test that the setter and getter work
        let value = true
        manager.iconAllowOverlap = value
        XCTAssertEqual(manager.iconAllowOverlap, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconAllowOverlap {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconAllowOverlap = nil
        XCTAssertNil(manager.iconAllowOverlap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconAllowOverlap, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-allow-overlap").value as! NSNumber).boolValue))
    }

    func testIconIgnorePlacement() throws {
        // Test that the setter and getter work
        let value = true
        manager.iconIgnorePlacement = value
        XCTAssertEqual(manager.iconIgnorePlacement, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconIgnorePlacement {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconIgnorePlacement = nil
        XCTAssertNil(manager.iconIgnorePlacement)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconIgnorePlacement, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-ignore-placement").value as! NSNumber).boolValue))
    }

    func testIconKeepUpright() throws {
        // Test that the setter and getter work
        let value = true
        manager.iconKeepUpright = value
        XCTAssertEqual(manager.iconKeepUpright, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconKeepUpright {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconKeepUpright = nil
        XCTAssertNil(manager.iconKeepUpright)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconKeepUpright, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-keep-upright").value as! NSNumber).boolValue))
    }

    func testIconOptional() throws {
        // Test that the setter and getter work
        let value = true
        manager.iconOptional = value
        XCTAssertEqual(manager.iconOptional, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconOptional {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconOptional = nil
        XCTAssertNil(manager.iconOptional)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconOptional, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-optional").value as! NSNumber).boolValue))
    }

    func testIconPadding() throws {
        // Test that the setter and getter work
        let value = 50000.0
        manager.iconPadding = value
        XCTAssertEqual(manager.iconPadding, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconPadding {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconPadding = nil
        XCTAssertNil(manager.iconPadding)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconPadding, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-padding").value as! NSNumber).doubleValue))
    }

    func testIconPitchAlignment() throws {
        // Test that the setter and getter work
        let value = IconPitchAlignment.testConstantValue()
        manager.iconPitchAlignment = value
        XCTAssertEqual(manager.iconPitchAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconPitchAlignment {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconPitchAlignment = nil
        XCTAssertNil(manager.iconPitchAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconPitchAlignment, .constant(IconPitchAlignment(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-pitch-alignment").value as! String)))
    }

    func testIconRotationAlignment() throws {
        // Test that the setter and getter work
        let value = IconRotationAlignment.testConstantValue()
        manager.iconRotationAlignment = value
        XCTAssertEqual(manager.iconRotationAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconRotationAlignment {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconRotationAlignment = nil
        XCTAssertNil(manager.iconRotationAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconRotationAlignment, .constant(IconRotationAlignment(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-rotation-alignment").value as! String)))
    }

    func testSymbolAvoidEdges() throws {
        // Test that the setter and getter work
        let value = true
        manager.symbolAvoidEdges = value
        XCTAssertEqual(manager.symbolAvoidEdges, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.symbolAvoidEdges {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.symbolAvoidEdges = nil
        XCTAssertNil(manager.symbolAvoidEdges)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolAvoidEdges, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-avoid-edges").value as! NSNumber).boolValue))
    }

    func testSymbolPlacement() throws {
        // Test that the setter and getter work
        let value = SymbolPlacement.testConstantValue()
        manager.symbolPlacement = value
        XCTAssertEqual(manager.symbolPlacement, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.symbolPlacement {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.symbolPlacement = nil
        XCTAssertNil(manager.symbolPlacement)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolPlacement, .constant(SymbolPlacement(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-placement").value as! String)))
    }

    func testSymbolSpacing() throws {
        // Test that the setter and getter work
        let value = 50000.5
        manager.symbolSpacing = value
        XCTAssertEqual(manager.symbolSpacing, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.symbolSpacing {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.symbolSpacing = nil
        XCTAssertNil(manager.symbolSpacing)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolSpacing, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-spacing").value as! NSNumber).doubleValue))
    }

    func testSymbolZElevate() throws {
        // Test that the setter and getter work
        let value = true
        manager.symbolZElevate = value
        XCTAssertEqual(manager.symbolZElevate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.symbolZElevate {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.symbolZElevate = nil
        XCTAssertNil(manager.symbolZElevate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolZElevate, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-elevate").value as! NSNumber).boolValue))
    }

    func testSymbolZOrder() throws {
        // Test that the setter and getter work
        let value = SymbolZOrder.testConstantValue()
        manager.symbolZOrder = value
        XCTAssertEqual(manager.symbolZOrder, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.symbolZOrder {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.symbolZOrder = nil
        XCTAssertNil(manager.symbolZOrder)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolZOrder, .constant(SymbolZOrder(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-order").value as! String)))
    }

    func testTextAllowOverlap() throws {
        // Test that the setter and getter work
        let value = true
        manager.textAllowOverlap = value
        XCTAssertEqual(manager.textAllowOverlap, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textAllowOverlap {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textAllowOverlap = nil
        XCTAssertNil(manager.textAllowOverlap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textAllowOverlap, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-allow-overlap").value as! NSNumber).boolValue))
    }

    func testTextFont() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { UUID().uuidString })
        manager.textFont = value
        XCTAssertEqual(manager.textFont, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textFont {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textFont = nil
        XCTAssertNil(manager.textFont)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textFont, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-font").value as! [String]))
    }

    func testTextIgnorePlacement() throws {
        // Test that the setter and getter work
        let value = true
        manager.textIgnorePlacement = value
        XCTAssertEqual(manager.textIgnorePlacement, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textIgnorePlacement {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textIgnorePlacement = nil
        XCTAssertNil(manager.textIgnorePlacement)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textIgnorePlacement, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-ignore-placement").value as! NSNumber).boolValue))
    }

    func testTextKeepUpright() throws {
        // Test that the setter and getter work
        let value = true
        manager.textKeepUpright = value
        XCTAssertEqual(manager.textKeepUpright, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textKeepUpright {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textKeepUpright = nil
        XCTAssertNil(manager.textKeepUpright)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textKeepUpright, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-keep-upright").value as! NSNumber).boolValue))
    }

    func testTextMaxAngle() throws {
        // Test that the setter and getter work
        let value = 0.0
        manager.textMaxAngle = value
        XCTAssertEqual(manager.textMaxAngle, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textMaxAngle {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textMaxAngle = nil
        XCTAssertNil(manager.textMaxAngle)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textMaxAngle, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-max-angle").value as! NSNumber).doubleValue))
    }

    func testTextOptional() throws {
        // Test that the setter and getter work
        let value = true
        manager.textOptional = value
        XCTAssertEqual(manager.textOptional, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textOptional {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textOptional = nil
        XCTAssertNil(manager.textOptional)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textOptional, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-optional").value as! NSNumber).boolValue))
    }

    func testTextPadding() throws {
        // Test that the setter and getter work
        let value = 50000.0
        manager.textPadding = value
        XCTAssertEqual(manager.textPadding, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textPadding {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textPadding = nil
        XCTAssertNil(manager.textPadding)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textPadding, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-padding").value as! NSNumber).doubleValue))
    }

    func testTextPitchAlignment() throws {
        // Test that the setter and getter work
        let value = TextPitchAlignment.testConstantValue()
        manager.textPitchAlignment = value
        XCTAssertEqual(manager.textPitchAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textPitchAlignment {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textPitchAlignment = nil
        XCTAssertNil(manager.textPitchAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textPitchAlignment, .constant(TextPitchAlignment(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-pitch-alignment").value as! String)))
    }

    func testTextRotationAlignment() throws {
        // Test that the setter and getter work
        let value = TextRotationAlignment.testConstantValue()
        manager.textRotationAlignment = value
        XCTAssertEqual(manager.textRotationAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textRotationAlignment {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textRotationAlignment = nil
        XCTAssertNil(manager.textRotationAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textRotationAlignment, .constant(TextRotationAlignment(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-rotation-alignment").value as! String)))
    }

    func testTextVariableAnchor() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.testConstantValue() })
        manager.textVariableAnchor = value
        XCTAssertEqual(manager.textVariableAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textVariableAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textVariableAnchor = nil
        XCTAssertNil(manager.textVariableAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textVariableAnchor, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-variable-anchor").value as! [TextAnchor]))
    }

    func testTextWritingMode() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.testConstantValue() })
        manager.textWritingMode = value
        XCTAssertEqual(manager.textWritingMode, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textWritingMode {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textWritingMode = nil
        XCTAssertNil(manager.textWritingMode)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textWritingMode, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-writing-mode").value as! [TextWritingMode]))
    }

    func testIconColorSaturation() throws {
        // Test that the setter and getter work
        let value = 0.0
        manager.iconColorSaturation = value
        XCTAssertEqual(manager.iconColorSaturation, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconColorSaturation {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconColorSaturation = nil
        XCTAssertNil(manager.iconColorSaturation)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconColorSaturation, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-color-saturation").value as! NSNumber).doubleValue))
    }

    func testIconOcclusionOpacity() throws {
        // Test that the setter and getter work
        let value = 0.5
        manager.iconOcclusionOpacity = value
        XCTAssertEqual(manager.iconOcclusionOpacity, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconOcclusionOpacity {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconOcclusionOpacity = nil
        XCTAssertNil(manager.iconOcclusionOpacity)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconOcclusionOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-occlusion-opacity").value as! NSNumber).doubleValue))
    }

    func testIconTranslate() throws {
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        manager.iconTranslate = value
        XCTAssertEqual(manager.iconTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconTranslate = nil
        XCTAssertNil(manager.iconTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconTranslate, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-translate").value as! [Double]))
    }

    func testIconTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = IconTranslateAnchor.testConstantValue()
        manager.iconTranslateAnchor = value
        XCTAssertEqual(manager.iconTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.iconTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.iconTranslateAnchor = nil
        XCTAssertNil(manager.iconTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconTranslateAnchor, .constant(IconTranslateAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-translate-anchor").value as! String)))
    }

    func testTextOcclusionOpacity() throws {
        // Test that the setter and getter work
        let value = 0.5
        manager.textOcclusionOpacity = value
        XCTAssertEqual(manager.textOcclusionOpacity, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textOcclusionOpacity {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textOcclusionOpacity = nil
        XCTAssertNil(manager.textOcclusionOpacity)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textOcclusionOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-occlusion-opacity").value as! NSNumber).doubleValue))
    }

    func testTextTranslate() throws {
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        manager.textTranslate = value
        XCTAssertEqual(manager.textTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textTranslate = nil
        XCTAssertNil(manager.textTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textTranslate, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-translate").value as! [Double]))
    }

    func testTextTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = TextTranslateAnchor.testConstantValue()
        manager.textTranslateAnchor = value
        XCTAssertEqual(manager.textTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        if case .constant(let actualValue) = layer.textTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.textTranslateAnchor = nil
        XCTAssertNil(manager.textTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textTranslateAnchor, .constant(TextTranslateAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-translate-anchor").value as! String)))
    }

    func testSlot() throws {
        // Test that the setter and getter work
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        let actualValue = layer.slot?.rawValue ?? ""
        XCTAssertEqual(actualValue, value)

        // Test that the property can be reset to nil
        manager.slot = nil
        XCTAssertNil(manager.slot)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.slot, nil)
    }

    func testIconAnchor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = IconAnchor.testConstantValue()
        annotation.iconAnchor = value
        XCTAssertEqual(annotation.iconAnchor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconAnchor, .expression(Exp(.toString) {
                Exp(.get) {
                    "icon-anchor"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconAnchor = nil
        XCTAssertNil(annotation.iconAnchor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconAnchor, .constant(IconAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-anchor").value as! String)))
    }

    func testIconImage() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = UUID().uuidString
        annotation.iconImage = value
        XCTAssertEqual(annotation.iconImage, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconImage, .expression(Exp(.image) {
                Exp(.get) {
                    "icon-image"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconImage = nil
        XCTAssertNil(annotation.iconImage)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconImage, .constant(.name(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-image").value as! String)))
    }

    func testIconOffset() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        annotation.iconOffset = value
        XCTAssertEqual(annotation.iconOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconOffset, .expression(Exp(.array) {
                "number"
                2
                Exp(.get) {
                    "icon-offset"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconOffset = nil
        XCTAssertNil(annotation.iconOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconOffset, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-offset").value as! [Double]))
    }

    func testIconRotate() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.iconRotate = value
        XCTAssertEqual(annotation.iconRotate, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconRotate, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-rotate"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconRotate = nil
        XCTAssertNil(annotation.iconRotate)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconRotate, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-rotate").value as! NSNumber).doubleValue))
    }

    func testIconSize() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.iconSize = value
        XCTAssertEqual(annotation.iconSize, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconSize, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-size"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconSize = nil
        XCTAssertNil(annotation.iconSize)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconSize, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-size").value as! NSNumber).doubleValue))
    }

    func testIconTextFit() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = IconTextFit.testConstantValue()
        annotation.iconTextFit = value
        XCTAssertEqual(annotation.iconTextFit, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconTextFit, .expression(Exp(.toString) {
                Exp(.get) {
                    "icon-text-fit"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconTextFit = nil
        XCTAssertNil(annotation.iconTextFit)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconTextFit, .constant(IconTextFit(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit").value as! String)))
    }

    func testIconTextFitPadding() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = [0.0, 0.0, 0.0, 0.0]
        annotation.iconTextFitPadding = value
        XCTAssertEqual(annotation.iconTextFitPadding, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconTextFitPadding, .expression(Exp(.array) {
                "number"
                4
                Exp(.get) {
                    "icon-text-fit-padding"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconTextFitPadding = nil
        XCTAssertNil(annotation.iconTextFitPadding)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconTextFitPadding, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit-padding").value as! [Double]))
    }

    func testSymbolSortKey() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.symbolSortKey = value
        XCTAssertEqual(annotation.symbolSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolSortKey, .expression(Exp(.number) {
                Exp(.get) {
                    "symbol-sort-key"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.symbolSortKey = nil
        XCTAssertNil(annotation.symbolSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.symbolSortKey, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-sort-key").value as! NSNumber).doubleValue))
    }

    func testTextAnchor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = TextAnchor.testConstantValue()
        annotation.textAnchor = value
        XCTAssertEqual(annotation.textAnchor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textAnchor, .expression(Exp(.toString) {
                Exp(.get) {
                    "text-anchor"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textAnchor = nil
        XCTAssertNil(annotation.textAnchor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textAnchor, .constant(TextAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-anchor").value as! String)))
    }

    func testTextField() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = UUID().uuidString
        annotation.textField = value
        XCTAssertEqual(annotation.textField, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textField, .expression(Exp(.format) {
                Exp(.get) {
                    "text-field"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
                FormatOptions()
            }))

        // Test that the property can be reset to nil
        annotation.textField = nil
        XCTAssertNil(annotation.textField)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textField, .expression(Exp(.format) {
            ""
            FormatOptions()
        }))
    }

    func testTextJustify() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = TextJustify.testConstantValue()
        annotation.textJustify = value
        XCTAssertEqual(annotation.textJustify, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textJustify, .expression(Exp(.toString) {
                Exp(.get) {
                    "text-justify"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textJustify = nil
        XCTAssertNil(annotation.textJustify)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textJustify, .constant(TextJustify(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-justify").value as! String)))
    }

    func testTextLetterSpacing() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.textLetterSpacing = value
        XCTAssertEqual(annotation.textLetterSpacing, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textLetterSpacing, .expression(Exp(.number) {
                Exp(.get) {
                    "text-letter-spacing"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textLetterSpacing = nil
        XCTAssertNil(annotation.textLetterSpacing)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textLetterSpacing, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-letter-spacing").value as! NSNumber).doubleValue))
    }

    func testTextLineHeight() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.textLineHeight = value
        XCTAssertEqual(annotation.textLineHeight, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textLineHeight, .expression(Exp(.number) {
                Exp(.get) {
                    "text-line-height"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textLineHeight = nil
        XCTAssertNil(annotation.textLineHeight)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textLineHeight, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-line-height").value as! NSNumber).doubleValue))
    }

    func testTextMaxWidth() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.textMaxWidth = value
        XCTAssertEqual(annotation.textMaxWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textMaxWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "text-max-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textMaxWidth = nil
        XCTAssertNil(annotation.textMaxWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textMaxWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-max-width").value as! NSNumber).doubleValue))
    }

    func testTextOffset() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        annotation.textOffset = value
        XCTAssertEqual(annotation.textOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textOffset, .expression(Exp(.array) {
                "number"
                2
                Exp(.get) {
                    "text-offset"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textOffset = nil
        XCTAssertNil(annotation.textOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textOffset, .constant(StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-offset").value as! [Double]))
    }

    func testTextRadialOffset() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.textRadialOffset = value
        XCTAssertEqual(annotation.textRadialOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textRadialOffset, .expression(Exp(.number) {
                Exp(.get) {
                    "text-radial-offset"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textRadialOffset = nil
        XCTAssertNil(annotation.textRadialOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textRadialOffset, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-radial-offset").value as! NSNumber).doubleValue))
    }

    func testTextRotate() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.textRotate = value
        XCTAssertEqual(annotation.textRotate, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textRotate, .expression(Exp(.number) {
                Exp(.get) {
                    "text-rotate"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textRotate = nil
        XCTAssertNil(annotation.textRotate)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textRotate, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-rotate").value as! NSNumber).doubleValue))
    }

    func testTextSize() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.textSize = value
        XCTAssertEqual(annotation.textSize, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textSize, .expression(Exp(.number) {
                Exp(.get) {
                    "text-size"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textSize = nil
        XCTAssertNil(annotation.textSize)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textSize, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-size").value as! NSNumber).doubleValue))
    }

    func testTextTransform() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = TextTransform.testConstantValue()
        annotation.textTransform = value
        XCTAssertEqual(annotation.textTransform, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textTransform, .expression(Exp(.toString) {
                Exp(.get) {
                    "text-transform"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textTransform = nil
        XCTAssertNil(annotation.textTransform)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textTransform, .constant(TextTransform(rawValue: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-transform").value as! String)))
    }

    func testIconColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255)
        annotation.iconColor = value
        XCTAssertEqual(annotation.iconColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "icon-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconColor = nil
        XCTAssertNil(annotation.iconColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-color").value as! [Any], options: []))))
    }

    func testIconEmissiveStrength() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.iconEmissiveStrength = value
        XCTAssertEqual(annotation.iconEmissiveStrength, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconEmissiveStrength, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-emissive-strength"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconEmissiveStrength = nil
        XCTAssertNil(annotation.iconEmissiveStrength)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconEmissiveStrength, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-emissive-strength").value as! NSNumber).doubleValue))
    }

    func testIconHaloBlur() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.iconHaloBlur = value
        XCTAssertEqual(annotation.iconHaloBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconHaloBlur, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-halo-blur"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconHaloBlur = nil
        XCTAssertNil(annotation.iconHaloBlur)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconHaloBlur, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-blur").value as! NSNumber).doubleValue))
    }

    func testIconHaloColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255)
        annotation.iconHaloColor = value
        XCTAssertEqual(annotation.iconHaloColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconHaloColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "icon-halo-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconHaloColor = nil
        XCTAssertNil(annotation.iconHaloColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconHaloColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-color").value as! [Any], options: []))))
    }

    func testIconHaloWidth() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.iconHaloWidth = value
        XCTAssertEqual(annotation.iconHaloWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconHaloWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-halo-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconHaloWidth = nil
        XCTAssertNil(annotation.iconHaloWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconHaloWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-width").value as! NSNumber).doubleValue))
    }

    func testIconImageCrossFade() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.iconImageCrossFade = value
        XCTAssertEqual(annotation.iconImageCrossFade, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconImageCrossFade, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-image-cross-fade"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconImageCrossFade = nil
        XCTAssertNil(annotation.iconImageCrossFade)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconImageCrossFade, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-image-cross-fade").value as! NSNumber).doubleValue))
    }

    func testIconOpacity() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.iconOpacity = value
        XCTAssertEqual(annotation.iconOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "icon-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.iconOpacity = nil
        XCTAssertNil(annotation.iconOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.iconOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-opacity").value as! NSNumber).doubleValue))
    }

    func testTextColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255)
        annotation.textColor = value
        XCTAssertEqual(annotation.textColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "text-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textColor = nil
        XCTAssertNil(annotation.textColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-color").value as! [Any], options: []))))
    }

    func testTextEmissiveStrength() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.textEmissiveStrength = value
        XCTAssertEqual(annotation.textEmissiveStrength, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textEmissiveStrength, .expression(Exp(.number) {
                Exp(.get) {
                    "text-emissive-strength"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textEmissiveStrength = nil
        XCTAssertNil(annotation.textEmissiveStrength)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textEmissiveStrength, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-emissive-strength").value as! NSNumber).doubleValue))
    }

    func testTextHaloBlur() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.textHaloBlur = value
        XCTAssertEqual(annotation.textHaloBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textHaloBlur, .expression(Exp(.number) {
                Exp(.get) {
                    "text-halo-blur"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textHaloBlur = nil
        XCTAssertNil(annotation.textHaloBlur)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textHaloBlur, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-halo-blur").value as! NSNumber).doubleValue))
    }

    func testTextHaloColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255)
        annotation.textHaloColor = value
        XCTAssertEqual(annotation.textHaloColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textHaloColor, .expression(Exp(.toColor) {
                Exp(.get) {
                    "text-halo-color"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textHaloColor = nil
        XCTAssertNil(annotation.textHaloColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textHaloColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-halo-color").value as! [Any], options: []))))
    }

    func testTextHaloWidth() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.textHaloWidth = value
        XCTAssertEqual(annotation.textHaloWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textHaloWidth, .expression(Exp(.number) {
                Exp(.get) {
                    "text-halo-width"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textHaloWidth = nil
        XCTAssertNil(annotation.textHaloWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textHaloWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-halo-width").value as! NSNumber).doubleValue))
    }

    func testTextOpacity() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.textOpacity = value
        XCTAssertEqual(annotation.textOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textOpacity, .expression(Exp(.number) {
                Exp(.get) {
                    "text-opacity"
                    Exp(.objectExpression) {
                        Exp(.get) {
                            "layerProperties"
                        }
                    }
                }
            }))

        // Test that the property can be reset to nil
        annotation.textOpacity = nil
        XCTAssertNil(annotation.textOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: SymbolLayer.self)
        XCTAssertEqual(layer.textOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-opacity").value as! NSNumber).doubleValue))
    }

    func testImagesAddedToStyleIfNotExist() throws {
        let existingImage = PointAnnotation.Image(image: try XCTUnwrap(UIImage.emptyImage()), name: UUID().uuidString)
        try mapView.mapboxMap.addImage(existingImage.image, id: existingImage.name)

        var annotation1 = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0))
        annotation1.image = existingImage
        var annotation2 = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0))
        annotation2.image = .init(image: try XCTUnwrap(UIImage.emptyImage()), name: "test-image-2")
        manager.annotations = [annotation1, annotation2]
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertTrue(mapView.mapboxMap.imageExists(withId: existingImage.name))
        XCTAssertTrue(mapView.mapboxMap.imageExists(withId: "test-image-2"))

        manager.annotations = []
        manager.syncSourceAndLayerIfNeeded()

        // Images added externally will not be removed from Style when PointAnnotationManager is updated.
        XCTAssertTrue(mapView.mapboxMap.imageExists(withId: existingImage.name))
        XCTAssertFalse(mapView.mapboxMap.imageExists(withId: "test-image-2"))
    }

    func testStyleImagesSharedBetweenMultipleManagers() throws {
        let otherManager = mapView.annotations.makePointAnnotationManager()

        let sharedImageID = UUID().uuidString
        let sharedImage = PointAnnotation.Image(image: try XCTUnwrap(UIImage.emptyImage()), name: sharedImageID)

        var pointAnnotation1 = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0))
        pointAnnotation1.image = sharedImage
        manager.annotations = [pointAnnotation1]

        var pointAnnotation2 = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0))
        pointAnnotation2.image = sharedImage
        otherManager.annotations = [pointAnnotation2]

        manager.syncSourceAndLayerIfNeeded()
        otherManager.syncSourceAndLayerIfNeeded()

        XCTAssertTrue(mapView.mapboxMap.imageExists(withId: sharedImageID))
        XCTAssertTrue(manager.isUsingStyleImage(sharedImageID))
        XCTAssertTrue(otherManager.isUsingStyleImage(sharedImageID))

        manager.annotations = []
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertTrue(mapView.mapboxMap.imageExists(withId: sharedImageID))
        XCTAssertFalse(manager.isUsingStyleImage(sharedImageID))
        XCTAssertTrue(otherManager.isUsingStyleImage(sharedImageID))

        otherManager.annotations = []
        otherManager.syncSourceAndLayerIfNeeded()

        XCTAssertFalse(mapView.mapboxMap.imageExists(withId: sharedImageID))
        XCTAssertFalse(manager.isUsingStyleImage(sharedImageID))
        XCTAssertFalse(otherManager.isUsingStyleImage(sharedImageID))
    }
}

// End of generated file
