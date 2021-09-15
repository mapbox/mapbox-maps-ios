// This file is generated
import XCTest
@testable import MapboxMaps

final class PointAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PointAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let managerCreatedExpectation = XCTestExpectation(description: "Successfully created annotation manager.")
        didFinishLoadingStyle = { _ in
            guard let mapView = self.mapView else {
                return
            }
            self.manager = mapView.annotations.makePointAnnotationManager()
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
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        annotation.textSize = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer: SymbolLayer = try? self.style?.layer(withId: self.manager.layerId) else {
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
        let value = Bool.random()
        manager.iconAllowOverlap = value
        XCTAssertEqual(manager.iconAllowOverlap, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconAllowOverlap, .constant(value))

        // Test that the property can be reset to nil
        manager.iconAllowOverlap = nil
        XCTAssertNil(manager.iconAllowOverlap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconAllowOverlap, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-allow-overlap").value as! NSNumber).boolValue))
    }

    func testIconIgnorePlacement() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.iconIgnorePlacement = value
        XCTAssertEqual(manager.iconIgnorePlacement, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconIgnorePlacement, .constant(value))

        // Test that the property can be reset to nil
        manager.iconIgnorePlacement = nil
        XCTAssertNil(manager.iconIgnorePlacement)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconIgnorePlacement, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-ignore-placement").value as! NSNumber).boolValue))
    }

    func testIconKeepUpright() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.iconKeepUpright = value
        XCTAssertEqual(manager.iconKeepUpright, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconKeepUpright, .constant(value))

        // Test that the property can be reset to nil
        manager.iconKeepUpright = nil
        XCTAssertNil(manager.iconKeepUpright)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconKeepUpright, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-keep-upright").value as! NSNumber).boolValue))
    }

    func testIconOptional() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.iconOptional = value
        XCTAssertEqual(manager.iconOptional, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconOptional, .constant(value))

        // Test that the property can be reset to nil
        manager.iconOptional = nil
        XCTAssertNil(manager.iconOptional)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconOptional, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-optional").value as! NSNumber).boolValue))
    }

    func testIconPadding() throws {
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        manager.iconPadding = value
        XCTAssertEqual(manager.iconPadding, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconPadding, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.iconPadding = nil
        XCTAssertNil(manager.iconPadding)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconPadding, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-padding").value as! NSNumber).doubleValue))
    }

    func testIconPitchAlignment() throws {
        // Test that the setter and getter work
        let value = IconPitchAlignment.allCases.randomElement()!
        manager.iconPitchAlignment = value
        XCTAssertEqual(manager.iconPitchAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconPitchAlignment, .constant(value))

        // Test that the property can be reset to nil
        manager.iconPitchAlignment = nil
        XCTAssertNil(manager.iconPitchAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconPitchAlignment, .constant(IconPitchAlignment(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-pitch-alignment").value as! String)!))
    }

    func testIconRotationAlignment() throws {
        // Test that the setter and getter work
        let value = IconRotationAlignment.allCases.randomElement()!
        manager.iconRotationAlignment = value
        XCTAssertEqual(manager.iconRotationAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconRotationAlignment, .constant(value))

        // Test that the property can be reset to nil
        manager.iconRotationAlignment = nil
        XCTAssertNil(manager.iconRotationAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconRotationAlignment, .constant(IconRotationAlignment(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-rotation-alignment").value as! String)!))
    }

    func testIconTextFit() throws {
        // Test that the setter and getter work
        let value = IconTextFit.allCases.randomElement()!
        manager.iconTextFit = value
        XCTAssertEqual(manager.iconTextFit, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTextFit, .constant(value))

        // Test that the property can be reset to nil
        manager.iconTextFit = nil
        XCTAssertNil(manager.iconTextFit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTextFit, .constant(IconTextFit(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit").value as! String)!))
    }

    func testIconTextFitPadding() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: 4, generator: { Double.random(in: -100000...100000) })
        manager.iconTextFitPadding = value
        XCTAssertEqual(manager.iconTextFitPadding, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTextFitPadding, .constant(value.map { Double(Float($0)) }))

        // Test that the property can be reset to nil
        manager.iconTextFitPadding = nil
        XCTAssertNil(manager.iconTextFitPadding)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTextFitPadding, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit-padding").value as! [Double]))
    }

    func testSymbolAvoidEdges() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.symbolAvoidEdges = value
        XCTAssertEqual(manager.symbolAvoidEdges, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolAvoidEdges, .constant(value))

        // Test that the property can be reset to nil
        manager.symbolAvoidEdges = nil
        XCTAssertNil(manager.symbolAvoidEdges)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolAvoidEdges, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-avoid-edges").value as! NSNumber).boolValue))
    }

    func testSymbolPlacement() throws {
        // Test that the setter and getter work
        let value = SymbolPlacement.allCases.randomElement()!
        manager.symbolPlacement = value
        XCTAssertEqual(manager.symbolPlacement, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolPlacement, .constant(value))

        // Test that the property can be reset to nil
        manager.symbolPlacement = nil
        XCTAssertNil(manager.symbolPlacement)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolPlacement, .constant(SymbolPlacement(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-placement").value as! String)!))
    }

    func testSymbolSpacing() throws {
        // Test that the setter and getter work
        let value = Double.random(in: 1...100000)
        manager.symbolSpacing = value
        XCTAssertEqual(manager.symbolSpacing, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolSpacing, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.symbolSpacing = nil
        XCTAssertNil(manager.symbolSpacing)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolSpacing, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-spacing").value as! NSNumber).doubleValue))
    }

    func testSymbolZOrder() throws {
        // Test that the setter and getter work
        let value = SymbolZOrder.allCases.randomElement()!
        manager.symbolZOrder = value
        XCTAssertEqual(manager.symbolZOrder, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolZOrder, .constant(value))

        // Test that the property can be reset to nil
        manager.symbolZOrder = nil
        XCTAssertNil(manager.symbolZOrder)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolZOrder, .constant(SymbolZOrder(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-order").value as! String)!))
    }

    func testTextAllowOverlap() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.textAllowOverlap = value
        XCTAssertEqual(manager.textAllowOverlap, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textAllowOverlap, .constant(value))

        // Test that the property can be reset to nil
        manager.textAllowOverlap = nil
        XCTAssertNil(manager.textAllowOverlap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textAllowOverlap, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-allow-overlap").value as! NSNumber).boolValue))
    }

    func testTextFont() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        manager.textFont = value
        XCTAssertEqual(manager.textFont, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textFont, .constant(value))

        // Test that the property can be reset to nil
        manager.textFont = nil
        XCTAssertNil(manager.textFont)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textFont, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "text-font").value as! [String]))
    }

    func testTextIgnorePlacement() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.textIgnorePlacement = value
        XCTAssertEqual(manager.textIgnorePlacement, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textIgnorePlacement, .constant(value))

        // Test that the property can be reset to nil
        manager.textIgnorePlacement = nil
        XCTAssertNil(manager.textIgnorePlacement)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textIgnorePlacement, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-ignore-placement").value as! NSNumber).boolValue))
    }

    func testTextKeepUpright() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.textKeepUpright = value
        XCTAssertEqual(manager.textKeepUpright, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textKeepUpright, .constant(value))

        // Test that the property can be reset to nil
        manager.textKeepUpright = nil
        XCTAssertNil(manager.textKeepUpright)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textKeepUpright, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-keep-upright").value as! NSNumber).boolValue))
    }

    func testTextLineHeight() throws {
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        manager.textLineHeight = value
        XCTAssertEqual(manager.textLineHeight, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textLineHeight, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.textLineHeight = nil
        XCTAssertNil(manager.textLineHeight)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textLineHeight, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-line-height").value as! NSNumber).doubleValue))
    }

    func testTextMaxAngle() throws {
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        manager.textMaxAngle = value
        XCTAssertEqual(manager.textMaxAngle, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textMaxAngle, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.textMaxAngle = nil
        XCTAssertNil(manager.textMaxAngle)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textMaxAngle, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-max-angle").value as! NSNumber).doubleValue))
    }

    func testTextOptional() throws {
        // Test that the setter and getter work
        let value = Bool.random()
        manager.textOptional = value
        XCTAssertEqual(manager.textOptional, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textOptional, .constant(value))

        // Test that the property can be reset to nil
        manager.textOptional = nil
        XCTAssertNil(manager.textOptional)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textOptional, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-optional").value as! NSNumber).boolValue))
    }

    func testTextPadding() throws {
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        manager.textPadding = value
        XCTAssertEqual(manager.textPadding, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textPadding, .constant(Double(Float(value))))

        // Test that the property can be reset to nil
        manager.textPadding = nil
        XCTAssertNil(manager.textPadding)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textPadding, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-padding").value as! NSNumber).doubleValue))
    }

    func testTextPitchAlignment() throws {
        // Test that the setter and getter work
        let value = TextPitchAlignment.allCases.randomElement()!
        manager.textPitchAlignment = value
        XCTAssertEqual(manager.textPitchAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textPitchAlignment, .constant(value))

        // Test that the property can be reset to nil
        manager.textPitchAlignment = nil
        XCTAssertNil(manager.textPitchAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textPitchAlignment, .constant(TextPitchAlignment(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "text-pitch-alignment").value as! String)!))
    }

    func testTextRotationAlignment() throws {
        // Test that the setter and getter work
        let value = TextRotationAlignment.allCases.randomElement()!
        manager.textRotationAlignment = value
        XCTAssertEqual(manager.textRotationAlignment, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textRotationAlignment, .constant(value))

        // Test that the property can be reset to nil
        manager.textRotationAlignment = nil
        XCTAssertNil(manager.textRotationAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textRotationAlignment, .constant(TextRotationAlignment(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "text-rotation-alignment").value as! String)!))
    }

    func testTextVariableAnchor() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.allCases.randomElement()! })
        manager.textVariableAnchor = value
        XCTAssertEqual(manager.textVariableAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textVariableAnchor, .constant(value))

        // Test that the property can be reset to nil
        manager.textVariableAnchor = nil
        XCTAssertNil(manager.textVariableAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textVariableAnchor, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "text-variable-anchor").value as! [TextAnchor]))
    }

    func testTextWritingMode() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.allCases.randomElement()! })
        manager.textWritingMode = value
        XCTAssertEqual(manager.textWritingMode, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textWritingMode, .constant(value))

        // Test that the property can be reset to nil
        manager.textWritingMode = nil
        XCTAssertNil(manager.textWritingMode)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textWritingMode, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "text-writing-mode").value as! [TextWritingMode]))
    }

    func testIconTranslate() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: 2, generator: { Double.random(in: -100000...100000) })
        manager.iconTranslate = value
        XCTAssertEqual(manager.iconTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTranslate, .constant(value.map { Double(Float($0)) }))

        // Test that the property can be reset to nil
        manager.iconTranslate = nil
        XCTAssertNil(manager.iconTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTranslate, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "icon-translate").value as! [Double]))
    }

    func testIconTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = IconTranslateAnchor.allCases.randomElement()!
        manager.iconTranslateAnchor = value
        XCTAssertEqual(manager.iconTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTranslateAnchor, .constant(value))

        // Test that the property can be reset to nil
        manager.iconTranslateAnchor = nil
        XCTAssertNil(manager.iconTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconTranslateAnchor, .constant(IconTranslateAnchor(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-translate-anchor").value as! String)!))
    }

    func testTextTranslate() throws {
        // Test that the setter and getter work
        let value = Array.random(withLength: 2, generator: { Double.random(in: -100000...100000) })
        manager.textTranslate = value
        XCTAssertEqual(manager.textTranslate, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textTranslate, .constant(value.map { Double(Float($0)) }))

        // Test that the property can be reset to nil
        manager.textTranslate = nil
        XCTAssertNil(manager.textTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textTranslate, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "text-translate").value as! [Double]))
    }

    func testTextTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = TextTranslateAnchor.allCases.randomElement()!
        manager.textTranslateAnchor = value
        XCTAssertEqual(manager.textTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textTranslateAnchor, .constant(value))

        // Test that the property can be reset to nil
        manager.textTranslateAnchor = nil
        XCTAssertNil(manager.textTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.syncSourceAndLayerIfNeeded()
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textTranslateAnchor, .constant(TextTranslateAnchor(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "text-translate-anchor").value as! String)!))
    }

    func testIconAnchor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = IconAnchor.allCases.randomElement()!
        annotation.iconAnchor = value
        XCTAssertEqual(annotation.iconAnchor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconAnchor, .constant(IconAnchor(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-anchor").value as! String)!))
    }

    func testIconImage() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = String.randomASCII(withLength: .random(in: 0...100))
        annotation.iconImage = value
        XCTAssertEqual(annotation.iconImage, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconImage, .constant(.name(Style.layerPropertyDefaultValue(for: .symbol, property: "icon-image").value as! String)))
    }

    func testIconOffset() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Array.random(withLength: 2, generator: { Double.random(in: -100000...100000) })
        annotation.iconOffset = value
        XCTAssertEqual(annotation.iconOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconOffset, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "icon-offset").value as! [Double]))
    }

    func testIconRotate() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.iconRotate = value
        XCTAssertEqual(annotation.iconRotate, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconRotate, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-rotate").value as! NSNumber).doubleValue))
    }

    func testIconSize() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.iconSize = value
        XCTAssertEqual(annotation.iconSize, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconSize, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-size").value as! NSNumber).doubleValue))
    }

    func testSymbolSortKey() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.symbolSortKey = value
        XCTAssertEqual(annotation.symbolSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.symbolSortKey, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "symbol-sort-key").value as! NSNumber).doubleValue))
    }

    func testTextAnchor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = TextAnchor.allCases.randomElement()!
        annotation.textAnchor = value
        XCTAssertEqual(annotation.textAnchor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textAnchor, .constant(TextAnchor(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "text-anchor").value as! String)!))
    }

    func testTextField() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = String.randomASCII(withLength: .random(in: 0...100))
        annotation.textField = value
        XCTAssertEqual(annotation.textField, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textField, .expression(Exp(.format) {
            ""
            FormatOptions()
        }))
    }

    func testTextJustify() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = TextJustify.allCases.randomElement()!
        annotation.textJustify = value
        XCTAssertEqual(annotation.textJustify, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textJustify, .constant(TextJustify(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "text-justify").value as! String)!))
    }

    func testTextLetterSpacing() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.textLetterSpacing = value
        XCTAssertEqual(annotation.textLetterSpacing, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textLetterSpacing, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-letter-spacing").value as! NSNumber).doubleValue))
    }

    func testTextMaxWidth() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.textMaxWidth = value
        XCTAssertEqual(annotation.textMaxWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textMaxWidth, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-max-width").value as! NSNumber).doubleValue))
    }

    func testTextOffset() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Array.random(withLength: 2, generator: { Double.random(in: -100000...100000) })
        annotation.textOffset = value
        XCTAssertEqual(annotation.textOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textOffset, .constant(Style.layerPropertyDefaultValue(for: .symbol, property: "text-offset").value as! [Double]))
    }

    func testTextRadialOffset() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.textRadialOffset = value
        XCTAssertEqual(annotation.textRadialOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textRadialOffset, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-radial-offset").value as! NSNumber).doubleValue))
    }

    func testTextRotate() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: -100000...100000)
        annotation.textRotate = value
        XCTAssertEqual(annotation.textRotate, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textRotate, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-rotate").value as! NSNumber).doubleValue))
    }

    func testTextSize() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.textSize = value
        XCTAssertEqual(annotation.textSize, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textSize, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-size").value as! NSNumber).doubleValue))
    }

    func testTextTransform() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = TextTransform.allCases.randomElement()!
        annotation.textTransform = value
        XCTAssertEqual(annotation.textTransform, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textTransform, .constant(TextTransform(rawValue: Style.layerPropertyDefaultValue(for: .symbol, property: "text-transform").value as! String)!))
    }

    func testIconColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.iconColor = value
        XCTAssertEqual(annotation.iconColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-color").value as! [Any], options: []))))
    }

    func testIconHaloBlur() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.iconHaloBlur = value
        XCTAssertEqual(annotation.iconHaloBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconHaloBlur, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-blur").value as! NSNumber).doubleValue))
    }

    func testIconHaloColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.iconHaloColor = value
        XCTAssertEqual(annotation.iconHaloColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconHaloColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-color").value as! [Any], options: []))))
    }

    func testIconHaloWidth() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.iconHaloWidth = value
        XCTAssertEqual(annotation.iconHaloWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconHaloWidth, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-width").value as! NSNumber).doubleValue))
    }

    func testIconOpacity() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.iconOpacity = value
        XCTAssertEqual(annotation.iconOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.iconOpacity, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "icon-opacity").value as! NSNumber).doubleValue))
    }

    func testTextColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.textColor = value
        XCTAssertEqual(annotation.textColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .symbol, property: "text-color").value as! [Any], options: []))))
    }

    func testTextHaloBlur() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.textHaloBlur = value
        XCTAssertEqual(annotation.textHaloBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textHaloBlur, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-halo-blur").value as! NSNumber).doubleValue))
    }

    func testTextHaloColor() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = StyleColor.random()
        annotation.textHaloColor = value
        XCTAssertEqual(annotation.textHaloColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textHaloColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: Style.layerPropertyDefaultValue(for: .symbol, property: "text-halo-color").value as! [Any], options: []))))
    }

    func testTextHaloWidth() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.textHaloWidth = value
        XCTAssertEqual(annotation.textHaloWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textHaloWidth, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-halo-width").value as! NSNumber).doubleValue))
    }

    func testTextOpacity() throws {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
        // Test that the setter and getter work
        let value = Double.random(in: 0...100000)
        annotation.textOpacity = value
        XCTAssertEqual(annotation.textOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.syncSourceAndLayerIfNeeded()
        var layer: SymbolLayer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
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
        layer = try XCTUnwrap(self.style?.layer(withId: self.manager.layerId))
        XCTAssertEqual(layer.textOpacity, .constant((Style.layerPropertyDefaultValue(for: .symbol, property: "text-opacity").value as! NSNumber).doubleValue))
    }
}

// End of generated file
