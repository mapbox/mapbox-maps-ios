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
    func testInitialIconAnchor() {
        let initialValue = manager.iconAnchor
        XCTAssertNil(initialValue)
    }

    func testSetIconAnchor() {
        let value = IconAnchor.testConstantValue()
        manager.iconAnchor = value
        XCTAssertEqual(manager.iconAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-anchor"] as! String, value.rawValue)
    }


    func testSetToNilIconAnchor() {
        let newIconAnchorProperty = IconAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-anchor").value as! String
        manager.iconAnchor = newIconAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-anchor"])
        harness.triggerDisplayLink()

        manager.iconAnchor = nil
        XCTAssertNil(manager.iconAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-anchor"] as! String, defaultValue)
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
    func testInitialIconImage() {
        let initialValue = manager.iconImage
        XCTAssertNil(initialValue)
    }

    func testSetIconImage() {
        let value = UUID().uuidString
        manager.iconImage = value
        XCTAssertEqual(manager.iconImage, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-image"] as! String, value)
    }


    func testSetToNilIconImage() {
        let newIconImageProperty = UUID().uuidString
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-image").value as! String
        manager.iconImage = newIconImageProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-image"])
        harness.triggerDisplayLink()

        manager.iconImage = nil
        XCTAssertNil(manager.iconImage)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-image"] as! String, defaultValue)
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
    func testInitialIconOffset() {
        let initialValue = manager.iconOffset
        XCTAssertNil(initialValue)
    }

    func testSetIconOffset() {
        let value = [0.0, 0.0]
        manager.iconOffset = value
        XCTAssertEqual(manager.iconOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-offset"] as! [Double], value)
    }


    func testSetToNilIconOffset() {
        let newIconOffsetProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-offset").value as! [Double]
        manager.iconOffset = newIconOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-offset"])
        harness.triggerDisplayLink()

        manager.iconOffset = nil
        XCTAssertNil(manager.iconOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-offset"] as! [Double], defaultValue)
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
    func testInitialIconRotate() {
        let initialValue = manager.iconRotate
        XCTAssertNil(initialValue)
    }

    func testSetIconRotate() {
        let value = 0.0
        manager.iconRotate = value
        XCTAssertEqual(manager.iconRotate, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-rotate"] as! Double, value)
    }


    func testSetToNilIconRotate() {
        let newIconRotateProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-rotate").value as! Double
        manager.iconRotate = newIconRotateProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-rotate"])
        harness.triggerDisplayLink()

        manager.iconRotate = nil
        XCTAssertNil(manager.iconRotate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotate"] as! Double, defaultValue)
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
    func testInitialIconSize() {
        let initialValue = manager.iconSize
        XCTAssertNil(initialValue)
    }

    func testSetIconSize() {
        let value = 50000.0
        manager.iconSize = value
        XCTAssertEqual(manager.iconSize, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-size"] as! Double, value)
    }


    func testSetToNilIconSize() {
        let newIconSizeProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-size").value as! Double
        manager.iconSize = newIconSizeProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-size"])
        harness.triggerDisplayLink()

        manager.iconSize = nil
        XCTAssertNil(manager.iconSize)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-size"] as! Double, defaultValue)
    }
    func testInitialIconSizeScaleRange() {
        let initialValue = manager.iconSizeScaleRange
        XCTAssertNil(initialValue)
    }

    func testSetIconSizeScaleRange() {
        let value = [0.0, 0.0]
        manager.iconSizeScaleRange = value
        XCTAssertEqual(manager.iconSizeScaleRange, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-size-scale-range"] as! [Double], value)
    }


    func testSetToNilIconSizeScaleRange() {
        let newIconSizeScaleRangeProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-size-scale-range").value as! [Double]
        manager.iconSizeScaleRange = newIconSizeScaleRangeProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-size-scale-range"])
        harness.triggerDisplayLink()

        manager.iconSizeScaleRange = nil
        XCTAssertNil(manager.iconSizeScaleRange)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-size-scale-range"] as! [Double], defaultValue)
    }
    func testInitialIconTextFit() {
        let initialValue = manager.iconTextFit
        XCTAssertNil(initialValue)
    }

    func testSetIconTextFit() {
        let value = IconTextFit.testConstantValue()
        manager.iconTextFit = value
        XCTAssertEqual(manager.iconTextFit, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-text-fit"] as! String, value.rawValue)
    }


    func testSetToNilIconTextFit() {
        let newIconTextFitProperty = IconTextFit.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit").value as! String
        manager.iconTextFit = newIconTextFitProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-text-fit"])
        harness.triggerDisplayLink()

        manager.iconTextFit = nil
        XCTAssertNil(manager.iconTextFit)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit"] as! String, defaultValue)
    }
    func testInitialIconTextFitPadding() {
        let initialValue = manager.iconTextFitPadding
        XCTAssertNil(initialValue)
    }

    func testSetIconTextFitPadding() {
        let value = [0.0, 0.0, 0.0, 0.0]
        manager.iconTextFitPadding = value
        XCTAssertEqual(manager.iconTextFitPadding, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-text-fit-padding"] as! [Double], value)
    }


    func testSetToNilIconTextFitPadding() {
        let newIconTextFitPaddingProperty = [0.0, 0.0, 0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-text-fit-padding").value as! [Double]
        manager.iconTextFitPadding = newIconTextFitPaddingProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-text-fit-padding"])
        harness.triggerDisplayLink()

        manager.iconTextFitPadding = nil
        XCTAssertNil(manager.iconTextFitPadding)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-text-fit-padding"] as! [Double], defaultValue)
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
    func testInitialSymbolElevationReference() {
        let initialValue = manager.symbolElevationReference
        XCTAssertNil(initialValue)
    }

    func testSetSymbolElevationReference() {
        let value = SymbolElevationReference.testConstantValue()
        manager.symbolElevationReference = value
        XCTAssertEqual(manager.symbolElevationReference, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-elevation-reference"] as! String, value.rawValue)
    }


    func testSetToNilSymbolElevationReference() {
        let newSymbolElevationReferenceProperty = SymbolElevationReference.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-elevation-reference").value as! String
        manager.symbolElevationReference = newSymbolElevationReferenceProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-elevation-reference"])
        harness.triggerDisplayLink()

        manager.symbolElevationReference = nil
        XCTAssertNil(manager.symbolElevationReference)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-elevation-reference"] as! String, defaultValue)
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
    func testInitialSymbolSortKey() {
        let initialValue = manager.symbolSortKey
        XCTAssertNil(initialValue)
    }

    func testSetSymbolSortKey() {
        let value = 0.0
        manager.symbolSortKey = value
        XCTAssertEqual(manager.symbolSortKey, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-sort-key"] as! Double, value)
    }


    func testSetToNilSymbolSortKey() {
        let newSymbolSortKeyProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-sort-key").value as! Double
        manager.symbolSortKey = newSymbolSortKeyProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-sort-key"])
        harness.triggerDisplayLink()

        manager.symbolSortKey = nil
        XCTAssertNil(manager.symbolSortKey)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-sort-key"] as! Double, defaultValue)
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
    func testInitialTextAnchor() {
        let initialValue = manager.textAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextAnchor() {
        let value = TextAnchor.testConstantValue()
        manager.textAnchor = value
        XCTAssertEqual(manager.textAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["text-anchor"] as! String, value.rawValue)
    }


    func testSetToNilTextAnchor() {
        let newTextAnchorProperty = TextAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-anchor").value as! String
        manager.textAnchor = newTextAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-anchor"])
        harness.triggerDisplayLink()

        manager.textAnchor = nil
        XCTAssertNil(manager.textAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-anchor"] as! String, defaultValue)
    }
    func testInitialTextField() {
        let initialValue = manager.textField
        XCTAssertNil(initialValue)
    }

    func testSetTextField() {
        let value = UUID().uuidString
        manager.textField = value
        XCTAssertEqual(manager.textField, value)
        XCTAssertEqual(manager.impl.layerProperties["text-field"] as! String, value)
    }


    func testSetToNilTextField() {
        let newTextFieldProperty = UUID().uuidString
        let defaultValue = Value<String>.expression(Exp(.format) {
            ""
            FormatOptions()
        })
        manager.textField = newTextFieldProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-field"])
        harness.triggerDisplayLink()

        manager.textField = nil
        XCTAssertNil(manager.textField)
        harness.triggerDisplayLink()

        let currentValueData = try! JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last!.parameters.properties["text-field"]!)
        let currentValueString = String(data: currentValueData, encoding: .utf8)
        XCTAssertEqual(currentValueString, try! defaultValue.jsonString())
    }
    func testInitialTextFont() {
        let initialValue = manager.textFont
        XCTAssertNil(initialValue)
    }

    func testSetTextFont() {
        let value = Array.testFixture(withLength: 10, generator: { UUID().uuidString })
        manager.textFont = value
        XCTAssertEqual(manager.textFont, value)
        XCTAssertEqual((manager.impl.layerProperties["text-font"] as! [Any])[1] as! [String], value)
    }


    func testSetToNilTextFont() {
        let newTextFontProperty = Array.testFixture(withLength: 10, generator: { UUID().uuidString })
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
    func testInitialTextJustify() {
        let initialValue = manager.textJustify
        XCTAssertNil(initialValue)
    }

    func testSetTextJustify() {
        let value = TextJustify.testConstantValue()
        manager.textJustify = value
        XCTAssertEqual(manager.textJustify, value)
        XCTAssertEqual(manager.impl.layerProperties["text-justify"] as! String, value.rawValue)
    }


    func testSetToNilTextJustify() {
        let newTextJustifyProperty = TextJustify.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-justify").value as! String
        manager.textJustify = newTextJustifyProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-justify"])
        harness.triggerDisplayLink()

        manager.textJustify = nil
        XCTAssertNil(manager.textJustify)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-justify"] as! String, defaultValue)
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
    func testInitialTextLetterSpacing() {
        let initialValue = manager.textLetterSpacing
        XCTAssertNil(initialValue)
    }

    func testSetTextLetterSpacing() {
        let value = 0.0
        manager.textLetterSpacing = value
        XCTAssertEqual(manager.textLetterSpacing, value)
        XCTAssertEqual(manager.impl.layerProperties["text-letter-spacing"] as! Double, value)
    }


    func testSetToNilTextLetterSpacing() {
        let newTextLetterSpacingProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-letter-spacing").value as! Double
        manager.textLetterSpacing = newTextLetterSpacingProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-letter-spacing"])
        harness.triggerDisplayLink()

        manager.textLetterSpacing = nil
        XCTAssertNil(manager.textLetterSpacing)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-letter-spacing"] as! Double, defaultValue)
    }
    func testInitialTextLineHeight() {
        let initialValue = manager.textLineHeight
        XCTAssertNil(initialValue)
    }

    func testSetTextLineHeight() {
        let value = 0.0
        manager.textLineHeight = value
        XCTAssertEqual(manager.textLineHeight, value)
        XCTAssertEqual(manager.impl.layerProperties["text-line-height"] as! Double, value)
    }


    func testSetToNilTextLineHeight() {
        let newTextLineHeightProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-line-height").value as! Double
        manager.textLineHeight = newTextLineHeightProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-line-height"])
        harness.triggerDisplayLink()

        manager.textLineHeight = nil
        XCTAssertNil(manager.textLineHeight)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-line-height"] as! Double, defaultValue)
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
    func testInitialTextMaxWidth() {
        let initialValue = manager.textMaxWidth
        XCTAssertNil(initialValue)
    }

    func testSetTextMaxWidth() {
        let value = 50000.0
        manager.textMaxWidth = value
        XCTAssertEqual(manager.textMaxWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["text-max-width"] as! Double, value)
    }


    func testSetToNilTextMaxWidth() {
        let newTextMaxWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-max-width").value as! Double
        manager.textMaxWidth = newTextMaxWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-max-width"])
        harness.triggerDisplayLink()

        manager.textMaxWidth = nil
        XCTAssertNil(manager.textMaxWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-width"] as! Double, defaultValue)
    }
    func testInitialTextOffset() {
        let initialValue = manager.textOffset
        XCTAssertNil(initialValue)
    }

    func testSetTextOffset() {
        let value = [0.0, 0.0]
        manager.textOffset = value
        XCTAssertEqual(manager.textOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["text-offset"] as! [Double], value)
    }


    func testSetToNilTextOffset() {
        let newTextOffsetProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-offset").value as! [Double]
        manager.textOffset = newTextOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-offset"])
        harness.triggerDisplayLink()

        manager.textOffset = nil
        XCTAssertNil(manager.textOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-offset"] as! [Double], defaultValue)
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
    func testInitialTextRadialOffset() {
        let initialValue = manager.textRadialOffset
        XCTAssertNil(initialValue)
    }

    func testSetTextRadialOffset() {
        let value = 0.0
        manager.textRadialOffset = value
        XCTAssertEqual(manager.textRadialOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["text-radial-offset"] as! Double, value)
    }


    func testSetToNilTextRadialOffset() {
        let newTextRadialOffsetProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-radial-offset").value as! Double
        manager.textRadialOffset = newTextRadialOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-radial-offset"])
        harness.triggerDisplayLink()

        manager.textRadialOffset = nil
        XCTAssertNil(manager.textRadialOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-radial-offset"] as! Double, defaultValue)
    }
    func testInitialTextRotate() {
        let initialValue = manager.textRotate
        XCTAssertNil(initialValue)
    }

    func testSetTextRotate() {
        let value = 0.0
        manager.textRotate = value
        XCTAssertEqual(manager.textRotate, value)
        XCTAssertEqual(manager.impl.layerProperties["text-rotate"] as! Double, value)
    }


    func testSetToNilTextRotate() {
        let newTextRotateProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-rotate").value as! Double
        manager.textRotate = newTextRotateProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-rotate"])
        harness.triggerDisplayLink()

        manager.textRotate = nil
        XCTAssertNil(manager.textRotate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotate"] as! Double, defaultValue)
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
    func testInitialTextSize() {
        let initialValue = manager.textSize
        XCTAssertNil(initialValue)
    }

    func testSetTextSize() {
        let value = 50000.0
        manager.textSize = value
        XCTAssertEqual(manager.textSize, value)
        XCTAssertEqual(manager.impl.layerProperties["text-size"] as! Double, value)
    }


    func testSetToNilTextSize() {
        let newTextSizeProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-size").value as! Double
        manager.textSize = newTextSizeProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-size"])
        harness.triggerDisplayLink()

        manager.textSize = nil
        XCTAssertNil(manager.textSize)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-size"] as! Double, defaultValue)
    }
    func testInitialTextSizeScaleRange() {
        let initialValue = manager.textSizeScaleRange
        XCTAssertNil(initialValue)
    }

    func testSetTextSizeScaleRange() {
        let value = [0.0, 0.0]
        manager.textSizeScaleRange = value
        XCTAssertEqual(manager.textSizeScaleRange, value)
        XCTAssertEqual(manager.impl.layerProperties["text-size-scale-range"] as! [Double], value)
    }


    func testSetToNilTextSizeScaleRange() {
        let newTextSizeScaleRangeProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-size-scale-range").value as! [Double]
        manager.textSizeScaleRange = newTextSizeScaleRangeProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-size-scale-range"])
        harness.triggerDisplayLink()

        manager.textSizeScaleRange = nil
        XCTAssertNil(manager.textSizeScaleRange)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-size-scale-range"] as! [Double], defaultValue)
    }
    func testInitialTextTransform() {
        let initialValue = manager.textTransform
        XCTAssertNil(initialValue)
    }

    func testSetTextTransform() {
        let value = TextTransform.testConstantValue()
        manager.textTransform = value
        XCTAssertEqual(manager.textTransform, value)
        XCTAssertEqual(manager.impl.layerProperties["text-transform"] as! String, value.rawValue)
    }


    func testSetToNilTextTransform() {
        let newTextTransformProperty = TextTransform.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-transform").value as! String
        manager.textTransform = newTextTransformProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-transform"])
        harness.triggerDisplayLink()

        manager.textTransform = nil
        XCTAssertNil(manager.textTransform)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-transform"] as! String, defaultValue)
    }
    func testInitialTextVariableAnchor() {
        let initialValue = manager.textVariableAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextVariableAnchor() {
        let value = Array.testFixture(withLength: 10, generator: { TextAnchor.testConstantValue() })
        manager.textVariableAnchor = value
        XCTAssertEqual(manager.textVariableAnchor, value)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(manager.impl.layerProperties["text-variable-anchor"] as! [String], valueAsString)
    }


    func testSetToNilTextVariableAnchor() {
        let newTextVariableAnchorProperty = Array.testFixture(withLength: 10, generator: { TextAnchor.testConstantValue() })
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
        let value = Array.testFixture(withLength: 10, generator: { TextWritingMode.testConstantValue() })
        manager.textWritingMode = value
        XCTAssertEqual(manager.textWritingMode, value)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(manager.impl.layerProperties["text-writing-mode"] as! [String], valueAsString)
    }


    func testSetToNilTextWritingMode() {
        let newTextWritingModeProperty = Array.testFixture(withLength: 10, generator: { TextWritingMode.testConstantValue() })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-writing-mode").value as! [TextWritingMode]
        manager.textWritingMode = newTextWritingModeProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-writing-mode"])
        harness.triggerDisplayLink()

        manager.textWritingMode = nil
        XCTAssertNil(manager.textWritingMode)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [TextWritingMode], defaultValue)
    }
    func testInitialIconColor() {
        let initialValue = manager.iconColor
        XCTAssertNil(initialValue)
    }

    func testSetIconColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.iconColor = value
        XCTAssertEqual(manager.iconColor, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-color"] as? String, value?.rawValue)
    }

    func testSetIconColorUseTheme() {
        manager.iconColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["icon-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilIconColor() {
        let newIconColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-color").value as! [Any], options: []))
        manager.iconColor = newIconColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-color"])
        harness.triggerDisplayLink()

        manager.iconColor = nil
        XCTAssertNil(manager.iconColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
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
    func testInitialIconEmissiveStrength() {
        let initialValue = manager.iconEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetIconEmissiveStrength() {
        let value = 50000.0
        manager.iconEmissiveStrength = value
        XCTAssertEqual(manager.iconEmissiveStrength, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-emissive-strength"] as! Double, value)
    }


    func testSetToNilIconEmissiveStrength() {
        let newIconEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-emissive-strength").value as! Double
        manager.iconEmissiveStrength = newIconEmissiveStrengthProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-emissive-strength"])
        harness.triggerDisplayLink()

        manager.iconEmissiveStrength = nil
        XCTAssertNil(manager.iconEmissiveStrength)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-emissive-strength"] as! Double, defaultValue)
    }
    func testInitialIconHaloBlur() {
        let initialValue = manager.iconHaloBlur
        XCTAssertNil(initialValue)
    }

    func testSetIconHaloBlur() {
        let value = 50000.0
        manager.iconHaloBlur = value
        XCTAssertEqual(manager.iconHaloBlur, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-halo-blur"] as! Double, value)
    }


    func testSetToNilIconHaloBlur() {
        let newIconHaloBlurProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-blur").value as! Double
        manager.iconHaloBlur = newIconHaloBlurProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-halo-blur"])
        harness.triggerDisplayLink()

        manager.iconHaloBlur = nil
        XCTAssertNil(manager.iconHaloBlur)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-halo-blur"] as! Double, defaultValue)
    }
    func testInitialIconHaloColor() {
        let initialValue = manager.iconHaloColor
        XCTAssertNil(initialValue)
    }

    func testSetIconHaloColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.iconHaloColor = value
        XCTAssertEqual(manager.iconHaloColor, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-halo-color"] as? String, value?.rawValue)
    }

    func testSetIconHaloColorUseTheme() {
        manager.iconHaloColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["icon-halo-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilIconHaloColor() {
        let newIconHaloColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-color").value as! [Any], options: []))
        manager.iconHaloColor = newIconHaloColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-halo-color"])
        harness.triggerDisplayLink()

        manager.iconHaloColor = nil
        XCTAssertNil(manager.iconHaloColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-halo-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialIconHaloWidth() {
        let initialValue = manager.iconHaloWidth
        XCTAssertNil(initialValue)
    }

    func testSetIconHaloWidth() {
        let value = 50000.0
        manager.iconHaloWidth = value
        XCTAssertEqual(manager.iconHaloWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-halo-width"] as! Double, value)
    }


    func testSetToNilIconHaloWidth() {
        let newIconHaloWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-halo-width").value as! Double
        manager.iconHaloWidth = newIconHaloWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-halo-width"])
        harness.triggerDisplayLink()

        manager.iconHaloWidth = nil
        XCTAssertNil(manager.iconHaloWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-halo-width"] as! Double, defaultValue)
    }
    func testInitialIconImageCrossFade() {
        let initialValue = manager.iconImageCrossFade
        XCTAssertNil(initialValue)
    }

    func testSetIconImageCrossFade() {
        let value = 0.5
        manager.iconImageCrossFade = value
        XCTAssertEqual(manager.iconImageCrossFade, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-image-cross-fade"] as! Double, value)
    }


    func testSetToNilIconImageCrossFade() {
        let newIconImageCrossFadeProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-image-cross-fade").value as! Double
        manager.iconImageCrossFade = newIconImageCrossFadeProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-image-cross-fade"])
        harness.triggerDisplayLink()

        manager.iconImageCrossFade = nil
        XCTAssertNil(manager.iconImageCrossFade)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-image-cross-fade"] as! Double, defaultValue)
    }
    func testInitialIconOcclusionOpacity() {
        let initialValue = manager.iconOcclusionOpacity
        XCTAssertNil(initialValue)
    }

    func testSetIconOcclusionOpacity() {
        let value = 0.5
        manager.iconOcclusionOpacity = value
        XCTAssertEqual(manager.iconOcclusionOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-occlusion-opacity"] as! Double, value)
    }


    func testSetToNilIconOcclusionOpacity() {
        let newIconOcclusionOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-occlusion-opacity").value as! Double
        manager.iconOcclusionOpacity = newIconOcclusionOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-occlusion-opacity"])
        harness.triggerDisplayLink()

        manager.iconOcclusionOpacity = nil
        XCTAssertNil(manager.iconOcclusionOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-occlusion-opacity"] as! Double, defaultValue)
    }
    func testInitialIconOpacity() {
        let initialValue = manager.iconOpacity
        XCTAssertNil(initialValue)
    }

    func testSetIconOpacity() {
        let value = 0.5
        manager.iconOpacity = value
        XCTAssertEqual(manager.iconOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["icon-opacity"] as! Double, value)
    }


    func testSetToNilIconOpacity() {
        let newIconOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-opacity").value as! Double
        manager.iconOpacity = newIconOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["icon-opacity"])
        harness.triggerDisplayLink()

        manager.iconOpacity = nil
        XCTAssertNil(manager.iconOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-opacity"] as! Double, defaultValue)
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
    func testInitialSymbolZOffset() {
        let initialValue = manager.symbolZOffset
        XCTAssertNil(initialValue)
    }

    func testSetSymbolZOffset() {
        let value = 50000.0
        manager.symbolZOffset = value
        XCTAssertEqual(manager.symbolZOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["symbol-z-offset"] as! Double, value)
    }


    func testSetToNilSymbolZOffset() {
        let newSymbolZOffsetProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-offset").value as! Double
        manager.symbolZOffset = newSymbolZOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["symbol-z-offset"])
        harness.triggerDisplayLink()

        manager.symbolZOffset = nil
        XCTAssertNil(manager.symbolZOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-offset"] as! Double, defaultValue)
    }
    func testInitialTextColor() {
        let initialValue = manager.textColor
        XCTAssertNil(initialValue)
    }

    func testSetTextColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.textColor = value
        XCTAssertEqual(manager.textColor, value)
        XCTAssertEqual(manager.impl.layerProperties["text-color"] as? String, value?.rawValue)
    }

    func testSetTextColorUseTheme() {
        manager.textColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["text-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilTextColor() {
        let newTextColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-color").value as! [Any], options: []))
        manager.textColor = newTextColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-color"])
        harness.triggerDisplayLink()

        manager.textColor = nil
        XCTAssertNil(manager.textColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialTextEmissiveStrength() {
        let initialValue = manager.textEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetTextEmissiveStrength() {
        let value = 50000.0
        manager.textEmissiveStrength = value
        XCTAssertEqual(manager.textEmissiveStrength, value)
        XCTAssertEqual(manager.impl.layerProperties["text-emissive-strength"] as! Double, value)
    }


    func testSetToNilTextEmissiveStrength() {
        let newTextEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-emissive-strength").value as! Double
        manager.textEmissiveStrength = newTextEmissiveStrengthProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-emissive-strength"])
        harness.triggerDisplayLink()

        manager.textEmissiveStrength = nil
        XCTAssertNil(manager.textEmissiveStrength)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-emissive-strength"] as! Double, defaultValue)
    }
    func testInitialTextHaloBlur() {
        let initialValue = manager.textHaloBlur
        XCTAssertNil(initialValue)
    }

    func testSetTextHaloBlur() {
        let value = 50000.0
        manager.textHaloBlur = value
        XCTAssertEqual(manager.textHaloBlur, value)
        XCTAssertEqual(manager.impl.layerProperties["text-halo-blur"] as! Double, value)
    }


    func testSetToNilTextHaloBlur() {
        let newTextHaloBlurProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-halo-blur").value as! Double
        manager.textHaloBlur = newTextHaloBlurProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-halo-blur"])
        harness.triggerDisplayLink()

        manager.textHaloBlur = nil
        XCTAssertNil(manager.textHaloBlur)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-halo-blur"] as! Double, defaultValue)
    }
    func testInitialTextHaloColor() {
        let initialValue = manager.textHaloColor
        XCTAssertNil(initialValue)
    }

    func testSetTextHaloColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.textHaloColor = value
        XCTAssertEqual(manager.textHaloColor, value)
        XCTAssertEqual(manager.impl.layerProperties["text-halo-color"] as? String, value?.rawValue)
    }

    func testSetTextHaloColorUseTheme() {
        manager.textHaloColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["text-halo-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilTextHaloColor() {
        let newTextHaloColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-halo-color").value as! [Any], options: []))
        manager.textHaloColor = newTextHaloColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-halo-color"])
        harness.triggerDisplayLink()

        manager.textHaloColor = nil
        XCTAssertNil(manager.textHaloColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-halo-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialTextHaloWidth() {
        let initialValue = manager.textHaloWidth
        XCTAssertNil(initialValue)
    }

    func testSetTextHaloWidth() {
        let value = 50000.0
        manager.textHaloWidth = value
        XCTAssertEqual(manager.textHaloWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["text-halo-width"] as! Double, value)
    }


    func testSetToNilTextHaloWidth() {
        let newTextHaloWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-halo-width").value as! Double
        manager.textHaloWidth = newTextHaloWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-halo-width"])
        harness.triggerDisplayLink()

        manager.textHaloWidth = nil
        XCTAssertNil(manager.textHaloWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-halo-width"] as! Double, defaultValue)
    }
    func testInitialTextOcclusionOpacity() {
        let initialValue = manager.textOcclusionOpacity
        XCTAssertNil(initialValue)
    }

    func testSetTextOcclusionOpacity() {
        let value = 0.5
        manager.textOcclusionOpacity = value
        XCTAssertEqual(manager.textOcclusionOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["text-occlusion-opacity"] as! Double, value)
    }


    func testSetToNilTextOcclusionOpacity() {
        let newTextOcclusionOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-occlusion-opacity").value as! Double
        manager.textOcclusionOpacity = newTextOcclusionOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-occlusion-opacity"])
        harness.triggerDisplayLink()

        manager.textOcclusionOpacity = nil
        XCTAssertNil(manager.textOcclusionOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-occlusion-opacity"] as! Double, defaultValue)
    }
    func testInitialTextOpacity() {
        let initialValue = manager.textOpacity
        XCTAssertNil(initialValue)
    }

    func testSetTextOpacity() {
        let value = 0.5
        manager.textOpacity = value
        XCTAssertEqual(manager.textOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["text-opacity"] as! Double, value)
    }


    func testSetToNilTextOpacity() {
        let newTextOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-opacity").value as! Double
        manager.textOpacity = newTextOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["text-opacity"])
        harness.triggerDisplayLink()

        manager.textOpacity = nil
        XCTAssertNil(manager.textOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-opacity"] as! Double, defaultValue)
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
        let allAnnotations = Array.testFixture(withLength: 10) {
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
