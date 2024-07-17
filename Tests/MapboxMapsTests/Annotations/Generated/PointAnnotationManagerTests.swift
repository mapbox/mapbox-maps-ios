// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PointAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PointAnnotationManager!
    var harness: AnnotationManagerTestingHarness!
    var annotations = [PointAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
        super.setUp()

        harness = AnnotationManagerTestingHarness()
        manager = PointAnnotationManager(
            params: harness.makeParams(),
            deps: harness.makeDeps())

        for _ in 0...10 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        harness = nil
        manager = nil
        super.tearDown()
    }

    func testInitialIconAllowOverlap() {
        let initialValue = manager.iconAllowOverlap
        XCTAssertNil(initialValue)
    }

    func testSetIconAllowOverlap() {
        let value = true
        manager.iconAllowOverlap = value
        XCTAssertEqual(manager.iconAllowOverlap, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-allow-overlap"] as! Bool, value)
    }

    func testSetToNilIconAllowOverlap() {
        let newIconAllowOverlapProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-allow-overlap").value as! Bool
        manager.iconAllowOverlap = newIconAllowOverlapProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-allow-overlap"])
        harness.triggerDisplayLink()

        manager.iconAllowOverlap = nil
        XCTAssertNil(manager.iconAllowOverlap)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, defaultValue)
    }
    func testInitialIconIgnorePlacement() {
        let initialValue = manager.iconIgnorePlacement
        XCTAssertNil(initialValue)
    }

    func testSetIconIgnorePlacement() {
        let value = true
        manager.iconIgnorePlacement = value
        XCTAssertEqual(manager.iconIgnorePlacement, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-ignore-placement"] as! Bool, value)
    }

    func testSetToNilIconIgnorePlacement() {
        let newIconIgnorePlacementProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-ignore-placement").value as! Bool
        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-ignore-placement"])
        harness.triggerDisplayLink()

        manager.iconIgnorePlacement = nil
        XCTAssertNil(manager.iconIgnorePlacement)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, defaultValue)
    }
    func testInitialIconKeepUpright() {
        let initialValue = manager.iconKeepUpright
        XCTAssertNil(initialValue)
    }

    func testSetIconKeepUpright() {
        let value = true
        manager.iconKeepUpright = value
        XCTAssertEqual(manager.iconKeepUpright, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-keep-upright"] as! Bool, value)
    }

    func testSetToNilIconKeepUpright() {
        let newIconKeepUprightProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-keep-upright").value as! Bool
        manager.iconKeepUpright = newIconKeepUprightProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-keep-upright"])
        harness.triggerDisplayLink()

        manager.iconKeepUpright = nil
        XCTAssertNil(manager.iconKeepUpright)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, defaultValue)
    }
    func testInitialIconOptional() {
        let initialValue = manager.iconOptional
        XCTAssertNil(initialValue)
    }

    func testSetIconOptional() {
        let value = true
        manager.iconOptional = value
        XCTAssertEqual(manager.iconOptional, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-optional"] as! Bool, value)
    }

    func testSetToNilIconOptional() {
        let newIconOptionalProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-optional").value as! Bool
        manager.iconOptional = newIconOptionalProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-optional"])
        harness.triggerDisplayLink()

        manager.iconOptional = nil
        XCTAssertNil(manager.iconOptional)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, defaultValue)
    }
    func testInitialIconPadding() {
        let initialValue = manager.iconPadding
        XCTAssertNil(initialValue)
    }

    func testSetIconPadding() {
        let value = 50000.0
        manager.iconPadding = value
        XCTAssertEqual(manager.iconPadding, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-padding"] as! Double, value)
    }

    func testSetToNilIconPadding() {
        let newIconPaddingProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-padding").value as! Double
        manager.iconPadding = newIconPaddingProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-padding"])
        harness.triggerDisplayLink()

        manager.iconPadding = nil
        XCTAssertNil(manager.iconPadding)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, defaultValue)
    }
    func testInitialIconPitchAlignment() {
        let initialValue = manager.iconPitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetIconPitchAlignment() {
        let value = IconPitchAlignment.testConstantValue()
        manager.iconPitchAlignment = value
        XCTAssertEqual(manager.iconPitchAlignment, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-pitch-alignment"] as! String, value.rawValue)
    }

    func testSetToNilIconPitchAlignment() {
        let newIconPitchAlignmentProperty = IconPitchAlignment.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-pitch-alignment").value as! String
        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-pitch-alignment"])
        harness.triggerDisplayLink()

        manager.iconPitchAlignment = nil
        XCTAssertNil(manager.iconPitchAlignment)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, defaultValue)
    }
    func testInitialIconRotationAlignment() {
        let initialValue = manager.iconRotationAlignment
        XCTAssertNil(initialValue)
    }

    func testSetIconRotationAlignment() {
        let value = IconRotationAlignment.testConstantValue()
        manager.iconRotationAlignment = value
        XCTAssertEqual(manager.iconRotationAlignment, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-rotation-alignment"] as! String, value.rawValue)
    }

    func testSetToNilIconRotationAlignment() {
        let newIconRotationAlignmentProperty = IconRotationAlignment.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-rotation-alignment").value as! String
        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-rotation-alignment"])
        harness.triggerDisplayLink()

        manager.iconRotationAlignment = nil
        XCTAssertNil(manager.iconRotationAlignment)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, defaultValue)
    }
    func testInitialSymbolAvoidEdges() {
        let initialValue = manager.symbolAvoidEdges
        XCTAssertNil(initialValue)
    }

    func testSetSymbolAvoidEdges() {
        let value = true
        manager.symbolAvoidEdges = value
        XCTAssertEqual(manager.symbolAvoidEdges, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-avoid-edges"] as! Bool, value)
    }

    func testSetToNilSymbolAvoidEdges() {
        let newSymbolAvoidEdgesProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-avoid-edges").value as! Bool
        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-avoid-edges"])
        harness.triggerDisplayLink()

        manager.symbolAvoidEdges = nil
        XCTAssertNil(manager.symbolAvoidEdges)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, defaultValue)
    }
    func testInitialSymbolPlacement() {
        let initialValue = manager.symbolPlacement
        XCTAssertNil(initialValue)
    }

    func testSetSymbolPlacement() {
        let value = SymbolPlacement.testConstantValue()
        manager.symbolPlacement = value
        XCTAssertEqual(manager.symbolPlacement, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-placement"] as! String, value.rawValue)
    }

    func testSetToNilSymbolPlacement() {
        let newSymbolPlacementProperty = SymbolPlacement.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-placement").value as! String
        manager.symbolPlacement = newSymbolPlacementProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-placement"])
        harness.triggerDisplayLink()

        manager.symbolPlacement = nil
        XCTAssertNil(manager.symbolPlacement)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, defaultValue)
    }
    func testInitialSymbolSpacing() {
        let initialValue = manager.symbolSpacing
        XCTAssertNil(initialValue)
    }

    func testSetSymbolSpacing() {
        let value = 50000.5
        manager.symbolSpacing = value
        XCTAssertEqual(manager.symbolSpacing, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-spacing"] as! Double, value)
    }

    func testSetToNilSymbolSpacing() {
        let newSymbolSpacingProperty = 50000.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-spacing").value as! Double
        manager.symbolSpacing = newSymbolSpacingProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-spacing"])
        harness.triggerDisplayLink()

        manager.symbolSpacing = nil
        XCTAssertNil(manager.symbolSpacing)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, defaultValue)
    }
    func testInitialSymbolZElevate() {
        let initialValue = manager.symbolZElevate
        XCTAssertNil(initialValue)
    }

    func testSetSymbolZElevate() {
        let value = true
        manager.symbolZElevate = value
        XCTAssertEqual(manager.symbolZElevate, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-z-elevate"] as! Bool, value)
    }

    func testSetToNilSymbolZElevate() {
        let newSymbolZElevateProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-elevate").value as! Bool
        manager.symbolZElevate = newSymbolZElevateProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-z-elevate"])
        harness.triggerDisplayLink()

        manager.symbolZElevate = nil
        XCTAssertNil(manager.symbolZElevate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-elevate"] as! Bool, defaultValue)
    }
    func testInitialSymbolZOrder() {
        let initialValue = manager.symbolZOrder
        XCTAssertNil(initialValue)
    }

    func testSetSymbolZOrder() {
        let value = SymbolZOrder.testConstantValue()
        manager.symbolZOrder = value
        XCTAssertEqual(manager.symbolZOrder, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-z-order"] as! String, value.rawValue)
    }

    func testSetToNilSymbolZOrder() {
        let newSymbolZOrderProperty = SymbolZOrder.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-order").value as! String
        manager.symbolZOrder = newSymbolZOrderProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-z-order"])
        harness.triggerDisplayLink()

        manager.symbolZOrder = nil
        XCTAssertNil(manager.symbolZOrder)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, defaultValue)
    }
    func testInitialTextAllowOverlap() {
        let initialValue = manager.textAllowOverlap
        XCTAssertNil(initialValue)
    }

    func testSetTextAllowOverlap() {
        let value = true
        manager.textAllowOverlap = value
        XCTAssertEqual(manager.textAllowOverlap, value)
        XCTAssertEqual(manager.impl.layerProperties["text-allow-overlap"] as! Bool, value)
    }

    func testSetToNilTextAllowOverlap() {
        let newTextAllowOverlapProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-allow-overlap").value as! Bool
        manager.textAllowOverlap = newTextAllowOverlapProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-allow-overlap"])
        harness.triggerDisplayLink()

        manager.textAllowOverlap = nil
        XCTAssertNil(manager.textAllowOverlap)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, defaultValue)
    }
    func testInitialTextFont() {
        let initialValue = manager.textFont
        XCTAssertNil(initialValue)
    }

    func testSetTextFont() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { UUID().uuidString })
        manager.textFont = value
        XCTAssertEqual(manager.textFont, value)
        XCTAssertEqual((manager.impl.layerProperties["text-font"] as! [Any])[1] as! [String], value)
    }

    func testSetToNilTextFont() {
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { UUID().uuidString })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-font").value as! [String]
        manager.textFont = newTextFontProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-font"])
        harness.triggerDisplayLink()

        manager.textFont = nil
        XCTAssertNil(manager.textFont)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [String], defaultValue)
    }
    func testInitialTextIgnorePlacement() {
        let initialValue = manager.textIgnorePlacement
        XCTAssertNil(initialValue)
    }

    func testSetTextIgnorePlacement() {
        let value = true
        manager.textIgnorePlacement = value
        XCTAssertEqual(manager.textIgnorePlacement, value)
        XCTAssertEqual(manager.impl.layerProperties["text-ignore-placement"] as! Bool, value)
    }

    func testSetToNilTextIgnorePlacement() {
        let newTextIgnorePlacementProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-ignore-placement").value as! Bool
        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-ignore-placement"])
        harness.triggerDisplayLink()

        manager.textIgnorePlacement = nil
        XCTAssertNil(manager.textIgnorePlacement)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, defaultValue)
    }
    func testInitialTextKeepUpright() {
        let initialValue = manager.textKeepUpright
        XCTAssertNil(initialValue)
    }

    func testSetTextKeepUpright() {
        let value = true
        manager.textKeepUpright = value
        XCTAssertEqual(manager.textKeepUpright, value)
        XCTAssertEqual(manager.impl.layerProperties["text-keep-upright"] as! Bool, value)
    }

    func testSetToNilTextKeepUpright() {
        let newTextKeepUprightProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-keep-upright").value as! Bool
        manager.textKeepUpright = newTextKeepUprightProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-keep-upright"])
        harness.triggerDisplayLink()

        manager.textKeepUpright = nil
        XCTAssertNil(manager.textKeepUpright)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, defaultValue)
    }
    func testInitialTextMaxAngle() {
        let initialValue = manager.textMaxAngle
        XCTAssertNil(initialValue)
    }

    func testSetTextMaxAngle() {
        let value = 0.0
        manager.textMaxAngle = value
        XCTAssertEqual(manager.textMaxAngle, value)
        XCTAssertEqual(manager.impl.layerProperties["text-max-angle"] as! Double, value)
    }

    func testSetToNilTextMaxAngle() {
        let newTextMaxAngleProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-max-angle").value as! Double
        manager.textMaxAngle = newTextMaxAngleProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-max-angle"])
        harness.triggerDisplayLink()

        manager.textMaxAngle = nil
        XCTAssertNil(manager.textMaxAngle)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, defaultValue)
    }
    func testInitialTextOptional() {
        let initialValue = manager.textOptional
        XCTAssertNil(initialValue)
    }

    func testSetTextOptional() {
        let value = true
        manager.textOptional = value
        XCTAssertEqual(manager.textOptional, value)
        XCTAssertEqual(manager.impl.layerProperties["text-optional"] as! Bool, value)
    }

    func testSetToNilTextOptional() {
        let newTextOptionalProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-optional").value as! Bool
        manager.textOptional = newTextOptionalProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-optional"])
        harness.triggerDisplayLink()

        manager.textOptional = nil
        XCTAssertNil(manager.textOptional)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, defaultValue)
    }
    func testInitialTextPadding() {
        let initialValue = manager.textPadding
        XCTAssertNil(initialValue)
    }

    func testSetTextPadding() {
        let value = 50000.0
        manager.textPadding = value
        XCTAssertEqual(manager.textPadding, value)
        XCTAssertEqual(manager.impl.layerProperties["text-padding"] as! Double, value)
    }

    func testSetToNilTextPadding() {
        let newTextPaddingProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-padding").value as! Double
        manager.textPadding = newTextPaddingProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-padding"])
        harness.triggerDisplayLink()

        manager.textPadding = nil
        XCTAssertNil(manager.textPadding)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, defaultValue)
    }
    func testInitialTextPitchAlignment() {
        let initialValue = manager.textPitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetTextPitchAlignment() {
        let value = TextPitchAlignment.testConstantValue()
        manager.textPitchAlignment = value
        XCTAssertEqual(manager.textPitchAlignment, value)
        XCTAssertEqual(manager.impl.layerProperties["text-pitch-alignment"] as! String, value.rawValue)
    }

    func testSetToNilTextPitchAlignment() {
        let newTextPitchAlignmentProperty = TextPitchAlignment.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-pitch-alignment").value as! String
        manager.textPitchAlignment = newTextPitchAlignmentProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-pitch-alignment"])
        harness.triggerDisplayLink()

        manager.textPitchAlignment = nil
        XCTAssertNil(manager.textPitchAlignment)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, defaultValue)
    }
    func testInitialTextRotationAlignment() {
        let initialValue = manager.textRotationAlignment
        XCTAssertNil(initialValue)
    }

    func testSetTextRotationAlignment() {
        let value = TextRotationAlignment.testConstantValue()
        manager.textRotationAlignment = value
        XCTAssertEqual(manager.textRotationAlignment, value)
        XCTAssertEqual(manager.impl.layerProperties["text-rotation-alignment"] as! String, value.rawValue)
    }

    func testSetToNilTextRotationAlignment() {
        let newTextRotationAlignmentProperty = TextRotationAlignment.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-rotation-alignment").value as! String
        manager.textRotationAlignment = newTextRotationAlignmentProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-rotation-alignment"])
        harness.triggerDisplayLink()

        manager.textRotationAlignment = nil
        XCTAssertNil(manager.textRotationAlignment)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, defaultValue)
    }
    func testInitialTextVariableAnchor() {
        let initialValue = manager.textVariableAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextVariableAnchor() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.testConstantValue() })
        manager.textVariableAnchor = value
        XCTAssertEqual(manager.textVariableAnchor, value)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(manager.impl.layerProperties["text-variable-anchor"] as! [String], valueAsString)
    }

    func testSetToNilTextVariableAnchor() {
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.testConstantValue() })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-variable-anchor").value as! [TextAnchor]
        manager.textVariableAnchor = newTextVariableAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-variable-anchor"])
        harness.triggerDisplayLink()

        manager.textVariableAnchor = nil
        XCTAssertNil(manager.textVariableAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [TextAnchor], defaultValue)
    }
    func testInitialTextWritingMode() {
        let initialValue = manager.textWritingMode
        XCTAssertNil(initialValue)
    }

    func testSetTextWritingMode() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.testConstantValue() })
        manager.textWritingMode = value
        XCTAssertEqual(manager.textWritingMode, value)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(manager.impl.layerProperties["text-writing-mode"] as! [String], valueAsString)
    }

    func testSetToNilTextWritingMode() {
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.testConstantValue() })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-writing-mode").value as! [TextWritingMode]
        manager.textWritingMode = newTextWritingModeProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-writing-mode"])
        harness.triggerDisplayLink()

        manager.textWritingMode = nil
        XCTAssertNil(manager.textWritingMode)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [TextWritingMode], defaultValue)
    }
    func testInitialIconColorSaturation() {
        let initialValue = manager.iconColorSaturation
        XCTAssertNil(initialValue)
    }

    func testSetIconColorSaturation() {
        let value = 0.0
        manager.iconColorSaturation = value
        XCTAssertEqual(manager.iconColorSaturation, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-color-saturation"] as! Double, value)
    }

    func testSetToNilIconColorSaturation() {
        let newIconColorSaturationProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-color-saturation").value as! Double
        manager.iconColorSaturation = newIconColorSaturationProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-color-saturation"])
        harness.triggerDisplayLink()

        manager.iconColorSaturation = nil
        XCTAssertNil(manager.iconColorSaturation)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color-saturation"] as! Double, defaultValue)
    }
    func testInitialIconTranslate() {
        let initialValue = manager.iconTranslate
        XCTAssertNil(initialValue)
    }

    func testSetIconTranslate() {
        let value = [0.0, 0.0]
        manager.iconTranslate = value
        XCTAssertEqual(manager.iconTranslate, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-translate"] as! [Double], value)
    }

    func testSetToNilIconTranslate() {
        let newIconTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-translate").value as! [Double]
        manager.iconTranslate = newIconTranslateProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-translate"])
        harness.triggerDisplayLink()

        manager.iconTranslate = nil
        XCTAssertNil(manager.iconTranslate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], defaultValue)
    }
    func testInitialIconTranslateAnchor() {
        let initialValue = manager.iconTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetIconTranslateAnchor() {
        let value = IconTranslateAnchor.testConstantValue()
        manager.iconTranslateAnchor = value
        XCTAssertEqual(manager.iconTranslateAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-translate-anchor"] as! String, value.rawValue)
    }

    func testSetToNilIconTranslateAnchor() {
        let newIconTranslateAnchorProperty = IconTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-translate-anchor").value as! String
        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-translate-anchor"])
        harness.triggerDisplayLink()

        manager.iconTranslateAnchor = nil
        XCTAssertNil(manager.iconTranslateAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, defaultValue)
    }
    func testInitialTextTranslate() {
        let initialValue = manager.textTranslate
        XCTAssertNil(initialValue)
    }

    func testSetTextTranslate() {
        let value = [0.0, 0.0]
        manager.textTranslate = value
        XCTAssertEqual(manager.textTranslate, value)
        XCTAssertEqual(manager.impl.layerProperties["text-translate"] as! [Double], value)
    }

    func testSetToNilTextTranslate() {
        let newTextTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-translate").value as! [Double]
        manager.textTranslate = newTextTranslateProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-translate"])
        harness.triggerDisplayLink()

        manager.textTranslate = nil
        XCTAssertNil(manager.textTranslate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], defaultValue)
    }
    func testInitialTextTranslateAnchor() {
        let initialValue = manager.textTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextTranslateAnchor() {
        let value = TextTranslateAnchor.testConstantValue()
        manager.textTranslateAnchor = value
        XCTAssertEqual(manager.textTranslateAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["text-translate-anchor"] as! String, value.rawValue)
    }

    func testSetToNilTextTranslateAnchor() {
        let newTextTranslateAnchorProperty = TextTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-translate-anchor").value as! String
        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-translate-anchor"])
        harness.triggerDisplayLink()

        manager.textTranslateAnchor = nil
        XCTAssertNil(manager.textTranslateAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, defaultValue)
    }
    func testInitialSlot() {
        let initialValue = manager.slot
        XCTAssertNil(initialValue)
    }

    func testSetSlot() {
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)
        XCTAssertEqual(manager.impl.layerProperties["slot"] as! String, value)
    }

    func testSetToNilSlot() {
        let newSlotProperty = UUID().uuidString
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "slot").value as! String
        manager.slot = newSlotProperty
        XCTAssertNotNil(manager.impl.layerProperties["slot"])
        harness.triggerDisplayLink()

        manager.slot = nil
        XCTAssertNil(manager.slot)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, defaultValue)
    }

    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        self.delegateAnnotations = annotations
        expectation?.fulfill()
        expectation = nil
    }

    // Add tests specific to PointAnnotationManager
    func testNewImagesAddedToStyle() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)

        // when
        manager.annotations = annotations
        harness.$displayLink.send()

        // then
        XCTAssertEqual(harness.imagesManager.addImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(harness.imagesManager.addImageStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(harness.imagesManager.addImageStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(harness.imagesManager.removeImageStub.invocations.count, 0)
        XCTAssertTrue(annotations.compactMap(\.image?.name).allSatisfy(manager.isUsingStyleImage(_:)))
    }

    func testUnusedImagesRemovedFromStyle() {
        // given
        let allAnnotations = Array.random(withLength: 10) {
            PointAnnotation(image: .init(image: UIImage(), name: UUID().uuidString))
        }
        manager.annotations = allAnnotations
        harness.$displayLink.send()
        harness.imagesManager.addImageStub.reset()
        XCTAssertTrue(allAnnotations.compactMap(\.image?.name).allSatisfy(manager.isUsingStyleImage(_:)))

        // when
        let (unusedAnnotations, remainingAnnotations) = (allAnnotations[0..<3], allAnnotations[3...])
        manager.annotations = Array(remainingAnnotations)
        harness.$displayLink.send()

        // then
        XCTAssertEqual(harness.imagesManager.addImageStub.invocations.count, remainingAnnotations.count)
        XCTAssertEqual(
            Set(harness.imagesManager.addImageStub.invocations.map(\.parameters.id)),
            Set(remainingAnnotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(harness.imagesManager.addImageStub.invocations.map(\.parameters.image)),
            Set(remainingAnnotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(harness.imagesManager.removeImageStub.invocations.count, unusedAnnotations.count)
        XCTAssertEqual(
            Set(harness.imagesManager.removeImageStub.invocations.map(\.parameters)),
            Set(unusedAnnotations.compactMap(\.image?.name))
        )
        XCTAssertTrue(remainingAnnotations.compactMap(\.image?.name).allSatisfy(manager.isUsingStyleImage(_:)))
        XCTAssertTrue(unusedAnnotations.compactMap(\.image?.name).filter(manager.isUsingStyleImage(_:)).isEmpty)
    }

    func testAllImagesRemovedFromStyleOnUpdate() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        harness.$displayLink.send()

        // when
        manager.annotations = []
        harness.$displayLink.send()

        // then
        XCTAssertEqual(harness.imagesManager.addImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(harness.imagesManager.addImageStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(harness.imagesManager.addImageStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(harness.imagesManager.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(harness.imagesManager.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertTrue(annotations.compactMap(\.image?.name).filter(manager.isUsingStyleImage(_:)).isEmpty)
    }

    func testAllImagesRemovedFromStyleOnDestroy() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        harness.$displayLink.send()

        // when
        manager.impl.destroy()

        // then
        XCTAssertEqual(harness.imagesManager.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(harness.imagesManager.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertTrue(annotations.compactMap(\.image?.name).filter(manager.isUsingStyleImage(_:)).isEmpty)
    }
}

private extension PointAnnotation {
    init(image: Image) {
        self.init(coordinate: .init(latitude: 0, longitude: 0))
        self.image = image
    }
}
// End of generated file
