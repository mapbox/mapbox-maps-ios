// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolylineAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PolylineAnnotationManager!
    var harness: AnnotationManagerTestingHarness!
    var annotations = [PolylineAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
        super.setUp()

        harness = AnnotationManagerTestingHarness()
        manager = PolylineAnnotationManager(
            params: harness.makeParams(),
            deps: harness.makeDeps())

        for _ in 0...10 {
            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        harness = nil
        manager = nil
        super.tearDown()
    }

    func testInitialLineCap() {
        let initialValue = manager.lineCap
        XCTAssertNil(initialValue)
    }

    func testSetLineCap() {
        let value = LineCap.testConstantValue()
        manager.lineCap = value
        XCTAssertEqual(manager.lineCap, value)
        XCTAssertEqual(manager.impl.layerProperties["line-cap"] as! String, value.rawValue)
    }


    func testSetToNilLineCap() {
        let newLineCapProperty = LineCap.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-cap").value as! String
        manager.lineCap = newLineCapProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-cap"])
        harness.triggerDisplayLink()

        manager.lineCap = nil
        XCTAssertNil(manager.lineCap)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cap"] as! String, defaultValue)
    }
    func testInitialLineCrossSlope() {
        let initialValue = manager.lineCrossSlope
        XCTAssertNil(initialValue)
    }

    func testSetLineCrossSlope() {
        let value = 0.0
        manager.lineCrossSlope = value
        XCTAssertEqual(manager.lineCrossSlope, value)
        XCTAssertEqual(manager.impl.layerProperties["line-cross-slope"] as! Double, value)
    }


    func testSetToNilLineCrossSlope() {
        let newLineCrossSlopeProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-cross-slope").value as! Double
        manager.lineCrossSlope = newLineCrossSlopeProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-cross-slope"])
        harness.triggerDisplayLink()

        manager.lineCrossSlope = nil
        XCTAssertNil(manager.lineCrossSlope)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-cross-slope"] as! Double, defaultValue)
    }
    func testInitialLineElevationReference() {
        let initialValue = manager.lineElevationReference
        XCTAssertNil(initialValue)
    }

    func testSetLineElevationReference() {
        let value = LineElevationReference.testConstantValue()
        manager.lineElevationReference = value
        XCTAssertEqual(manager.lineElevationReference, value)
        XCTAssertEqual(manager.impl.layerProperties["line-elevation-reference"] as! String, value.rawValue)
    }


    func testSetToNilLineElevationReference() {
        let newLineElevationReferenceProperty = LineElevationReference.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-elevation-reference").value as! String
        manager.lineElevationReference = newLineElevationReferenceProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-elevation-reference"])
        harness.triggerDisplayLink()

        manager.lineElevationReference = nil
        XCTAssertNil(manager.lineElevationReference)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-elevation-reference"] as! String, defaultValue)
    }
    func testInitialLineJoin() {
        let initialValue = manager.lineJoin
        XCTAssertNil(initialValue)
    }

    func testSetLineJoin() {
        let value = LineJoin.testConstantValue()
        manager.lineJoin = value
        XCTAssertEqual(manager.lineJoin, value)
        XCTAssertEqual(manager.impl.layerProperties["line-join"] as! String, value.rawValue)
    }


    func testSetToNilLineJoin() {
        let newLineJoinProperty = LineJoin.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-join").value as! String
        manager.lineJoin = newLineJoinProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-join"])
        harness.triggerDisplayLink()

        manager.lineJoin = nil
        XCTAssertNil(manager.lineJoin)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-join"] as! String, defaultValue)
    }
    func testInitialLineMiterLimit() {
        let initialValue = manager.lineMiterLimit
        XCTAssertNil(initialValue)
    }

    func testSetLineMiterLimit() {
        let value = 0.0
        manager.lineMiterLimit = value
        XCTAssertEqual(manager.lineMiterLimit, value)
        XCTAssertEqual(manager.impl.layerProperties["line-miter-limit"] as! Double, value)
    }


    func testSetToNilLineMiterLimit() {
        let newLineMiterLimitProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-miter-limit").value as! Double
        manager.lineMiterLimit = newLineMiterLimitProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-miter-limit"])
        harness.triggerDisplayLink()

        manager.lineMiterLimit = nil
        XCTAssertNil(manager.lineMiterLimit)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-miter-limit"] as! Double, defaultValue)
    }
    func testInitialLineRoundLimit() {
        let initialValue = manager.lineRoundLimit
        XCTAssertNil(initialValue)
    }

    func testSetLineRoundLimit() {
        let value = 0.0
        manager.lineRoundLimit = value
        XCTAssertEqual(manager.lineRoundLimit, value)
        XCTAssertEqual(manager.impl.layerProperties["line-round-limit"] as! Double, value)
    }


    func testSetToNilLineRoundLimit() {
        let newLineRoundLimitProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-round-limit").value as! Double
        manager.lineRoundLimit = newLineRoundLimitProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-round-limit"])
        harness.triggerDisplayLink()

        manager.lineRoundLimit = nil
        XCTAssertNil(manager.lineRoundLimit)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-round-limit"] as! Double, defaultValue)
    }
    func testInitialLineSortKey() {
        let initialValue = manager.lineSortKey
        XCTAssertNil(initialValue)
    }

    func testSetLineSortKey() {
        let value = 0.0
        manager.lineSortKey = value
        XCTAssertEqual(manager.lineSortKey, value)
        XCTAssertEqual(manager.impl.layerProperties["line-sort-key"] as! Double, value)
    }


    func testSetToNilLineSortKey() {
        let newLineSortKeyProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-sort-key").value as! Double
        manager.lineSortKey = newLineSortKeyProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-sort-key"])
        harness.triggerDisplayLink()

        manager.lineSortKey = nil
        XCTAssertNil(manager.lineSortKey)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-sort-key"] as! Double, defaultValue)
    }
    func testInitialLineWidthUnit() {
        let initialValue = manager.lineWidthUnit
        XCTAssertNil(initialValue)
    }

    func testSetLineWidthUnit() {
        let value = LineWidthUnit.testConstantValue()
        manager.lineWidthUnit = value
        XCTAssertEqual(manager.lineWidthUnit, value)
        XCTAssertEqual(manager.impl.layerProperties["line-width-unit"] as! String, value.rawValue)
    }


    func testSetToNilLineWidthUnit() {
        let newLineWidthUnitProperty = LineWidthUnit.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width-unit").value as! String
        manager.lineWidthUnit = newLineWidthUnitProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-width-unit"])
        harness.triggerDisplayLink()

        manager.lineWidthUnit = nil
        XCTAssertNil(manager.lineWidthUnit)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-width-unit"] as! String, defaultValue)
    }
    func testInitialLineZOffset() {
        let initialValue = manager.lineZOffset
        XCTAssertNil(initialValue)
    }

    func testSetLineZOffset() {
        let value = 0.0
        manager.lineZOffset = value
        XCTAssertEqual(manager.lineZOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["line-z-offset"] as! Double, value)
    }


    func testSetToNilLineZOffset() {
        let newLineZOffsetProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-z-offset").value as! Double
        manager.lineZOffset = newLineZOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-z-offset"])
        harness.triggerDisplayLink()

        manager.lineZOffset = nil
        XCTAssertNil(manager.lineZOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-z-offset"] as! Double, defaultValue)
    }
    func testInitialLineBlur() {
        let initialValue = manager.lineBlur
        XCTAssertNil(initialValue)
    }

    func testSetLineBlur() {
        let value = 50000.0
        manager.lineBlur = value
        XCTAssertEqual(manager.lineBlur, value)
        XCTAssertEqual(manager.impl.layerProperties["line-blur"] as! Double, value)
    }


    func testSetToNilLineBlur() {
        let newLineBlurProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-blur").value as! Double
        manager.lineBlur = newLineBlurProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-blur"])
        harness.triggerDisplayLink()

        manager.lineBlur = nil
        XCTAssertNil(manager.lineBlur)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-blur"] as! Double, defaultValue)
    }
    func testInitialLineBorderColor() {
        let initialValue = manager.lineBorderColor
        XCTAssertNil(initialValue)
    }

    func testSetLineBorderColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.lineBorderColor = value
        XCTAssertEqual(manager.lineBorderColor, value)
        XCTAssertEqual(manager.impl.layerProperties["line-border-color"] as? String, value?.rawValue)
    }

    func testSetLineBorderColorUseTheme() {
        manager.lineBorderColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["line-border-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilLineBorderColor() {
        let newLineBorderColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-color").value as! [Any], options: []))
        manager.lineBorderColor = newLineBorderColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-border-color"])
        harness.triggerDisplayLink()

        manager.lineBorderColor = nil
        XCTAssertNil(manager.lineBorderColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-border-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialLineBorderWidth() {
        let initialValue = manager.lineBorderWidth
        XCTAssertNil(initialValue)
    }

    func testSetLineBorderWidth() {
        let value = 50000.0
        manager.lineBorderWidth = value
        XCTAssertEqual(manager.lineBorderWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["line-border-width"] as! Double, value)
    }


    func testSetToNilLineBorderWidth() {
        let newLineBorderWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-width").value as! Double
        manager.lineBorderWidth = newLineBorderWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-border-width"])
        harness.triggerDisplayLink()

        manager.lineBorderWidth = nil
        XCTAssertNil(manager.lineBorderWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-border-width"] as! Double, defaultValue)
    }
    func testInitialLineColor() {
        let initialValue = manager.lineColor
        XCTAssertNil(initialValue)
    }

    func testSetLineColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.lineColor = value
        XCTAssertEqual(manager.lineColor, value)
        XCTAssertEqual(manager.impl.layerProperties["line-color"] as? String, value?.rawValue)
    }

    func testSetLineColorUseTheme() {
        manager.lineColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["line-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilLineColor() {
        let newLineColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-color").value as! [Any], options: []))
        manager.lineColor = newLineColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-color"])
        harness.triggerDisplayLink()

        manager.lineColor = nil
        XCTAssertNil(manager.lineColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialLineDasharray() {
        let initialValue = manager.lineDasharray
        XCTAssertNil(initialValue)
    }

    func testSetLineDasharray() {
        let value = Array.testFixture(withLength: 10, generator: { 0.0 })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)
        XCTAssertEqual(manager.impl.layerProperties["line-dasharray"] as! [Double], value)
    }


    func testSetToNilLineDasharray() {
        let newLineDasharrayProperty = Array.testFixture(withLength: 10, generator: { 0.0 })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-dasharray").value as! [Double]
        manager.lineDasharray = newLineDasharrayProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-dasharray"])
        harness.triggerDisplayLink()

        manager.lineDasharray = nil
        XCTAssertNil(manager.lineDasharray)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-dasharray"] as! [Double], defaultValue)
    }
    func testInitialLineDepthOcclusionFactor() {
        let initialValue = manager.lineDepthOcclusionFactor
        XCTAssertNil(initialValue)
    }

    func testSetLineDepthOcclusionFactor() {
        let value = 0.5
        manager.lineDepthOcclusionFactor = value
        XCTAssertEqual(manager.lineDepthOcclusionFactor, value)
        XCTAssertEqual(manager.impl.layerProperties["line-depth-occlusion-factor"] as! Double, value)
    }


    func testSetToNilLineDepthOcclusionFactor() {
        let newLineDepthOcclusionFactorProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-depth-occlusion-factor").value as! Double
        manager.lineDepthOcclusionFactor = newLineDepthOcclusionFactorProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-depth-occlusion-factor"])
        harness.triggerDisplayLink()

        manager.lineDepthOcclusionFactor = nil
        XCTAssertNil(manager.lineDepthOcclusionFactor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-depth-occlusion-factor"] as! Double, defaultValue)
    }
    func testInitialLineEmissiveStrength() {
        let initialValue = manager.lineEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetLineEmissiveStrength() {
        let value = 50000.0
        manager.lineEmissiveStrength = value
        XCTAssertEqual(manager.lineEmissiveStrength, value)
        XCTAssertEqual(manager.impl.layerProperties["line-emissive-strength"] as! Double, value)
    }


    func testSetToNilLineEmissiveStrength() {
        let newLineEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-emissive-strength").value as! Double
        manager.lineEmissiveStrength = newLineEmissiveStrengthProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-emissive-strength"])
        harness.triggerDisplayLink()

        manager.lineEmissiveStrength = nil
        XCTAssertNil(manager.lineEmissiveStrength)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-emissive-strength"] as! Double, defaultValue)
    }
    func testInitialLineGapWidth() {
        let initialValue = manager.lineGapWidth
        XCTAssertNil(initialValue)
    }

    func testSetLineGapWidth() {
        let value = 50000.0
        manager.lineGapWidth = value
        XCTAssertEqual(manager.lineGapWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["line-gap-width"] as! Double, value)
    }


    func testSetToNilLineGapWidth() {
        let newLineGapWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-gap-width").value as! Double
        manager.lineGapWidth = newLineGapWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-gap-width"])
        harness.triggerDisplayLink()

        manager.lineGapWidth = nil
        XCTAssertNil(manager.lineGapWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-gap-width"] as! Double, defaultValue)
    }
    func testInitialLineOcclusionOpacity() {
        let initialValue = manager.lineOcclusionOpacity
        XCTAssertNil(initialValue)
    }

    func testSetLineOcclusionOpacity() {
        let value = 0.5
        manager.lineOcclusionOpacity = value
        XCTAssertEqual(manager.lineOcclusionOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["line-occlusion-opacity"] as! Double, value)
    }


    func testSetToNilLineOcclusionOpacity() {
        let newLineOcclusionOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-occlusion-opacity").value as! Double
        manager.lineOcclusionOpacity = newLineOcclusionOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-occlusion-opacity"])
        harness.triggerDisplayLink()

        manager.lineOcclusionOpacity = nil
        XCTAssertNil(manager.lineOcclusionOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-occlusion-opacity"] as! Double, defaultValue)
    }
    func testInitialLineOffset() {
        let initialValue = manager.lineOffset
        XCTAssertNil(initialValue)
    }

    func testSetLineOffset() {
        let value = 0.0
        manager.lineOffset = value
        XCTAssertEqual(manager.lineOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["line-offset"] as! Double, value)
    }


    func testSetToNilLineOffset() {
        let newLineOffsetProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-offset").value as! Double
        manager.lineOffset = newLineOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-offset"])
        harness.triggerDisplayLink()

        manager.lineOffset = nil
        XCTAssertNil(manager.lineOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-offset"] as! Double, defaultValue)
    }
    func testInitialLineOpacity() {
        let initialValue = manager.lineOpacity
        XCTAssertNil(initialValue)
    }

    func testSetLineOpacity() {
        let value = 0.5
        manager.lineOpacity = value
        XCTAssertEqual(manager.lineOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["line-opacity"] as! Double, value)
    }


    func testSetToNilLineOpacity() {
        let newLineOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-opacity").value as! Double
        manager.lineOpacity = newLineOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-opacity"])
        harness.triggerDisplayLink()

        manager.lineOpacity = nil
        XCTAssertNil(manager.lineOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-opacity"] as! Double, defaultValue)
    }
    func testInitialLinePattern() {
        let initialValue = manager.linePattern
        XCTAssertNil(initialValue)
    }

    func testSetLinePattern() {
        let value = UUID().uuidString
        manager.linePattern = value
        XCTAssertEqual(manager.linePattern, value)
        XCTAssertEqual(manager.impl.layerProperties["line-pattern"] as! String, value)
    }


    func testSetToNilLinePattern() {
        let newLinePatternProperty = UUID().uuidString
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-pattern").value as! String
        manager.linePattern = newLinePatternProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-pattern"])
        harness.triggerDisplayLink()

        manager.linePattern = nil
        XCTAssertNil(manager.linePattern)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-pattern"] as! String, defaultValue)
    }
    func testInitialLineTranslate() {
        let initialValue = manager.lineTranslate
        XCTAssertNil(initialValue)
    }

    func testSetLineTranslate() {
        let value = [0.0, 0.0]
        manager.lineTranslate = value
        XCTAssertEqual(manager.lineTranslate, value)
        XCTAssertEqual(manager.impl.layerProperties["line-translate"] as! [Double], value)
    }


    func testSetToNilLineTranslate() {
        let newLineTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate").value as! [Double]
        manager.lineTranslate = newLineTranslateProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-translate"])
        harness.triggerDisplayLink()

        manager.lineTranslate = nil
        XCTAssertNil(manager.lineTranslate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate"] as! [Double], defaultValue)
    }
    func testInitialLineTranslateAnchor() {
        let initialValue = manager.lineTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetLineTranslateAnchor() {
        let value = LineTranslateAnchor.testConstantValue()
        manager.lineTranslateAnchor = value
        XCTAssertEqual(manager.lineTranslateAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["line-translate-anchor"] as! String, value.rawValue)
    }


    func testSetToNilLineTranslateAnchor() {
        let newLineTranslateAnchorProperty = LineTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate-anchor").value as! String
        manager.lineTranslateAnchor = newLineTranslateAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-translate-anchor"])
        harness.triggerDisplayLink()

        manager.lineTranslateAnchor = nil
        XCTAssertNil(manager.lineTranslateAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-translate-anchor"] as! String, defaultValue)
    }
    func testInitialLineTrimColor() {
        let initialValue = manager.lineTrimColor
        XCTAssertNil(initialValue)
    }

    func testSetLineTrimColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.lineTrimColor = value
        XCTAssertEqual(manager.lineTrimColor, value)
        XCTAssertEqual(manager.impl.layerProperties["line-trim-color"] as? String, value?.rawValue)
    }

    func testSetLineTrimColorUseTheme() {
        manager.lineTrimColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["line-trim-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilLineTrimColor() {
        let newLineTrimColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-color").value as! [Any], options: []))
        manager.lineTrimColor = newLineTrimColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-trim-color"])
        harness.triggerDisplayLink()

        manager.lineTrimColor = nil
        XCTAssertNil(manager.lineTrimColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialLineTrimFadeRange() {
        let initialValue = manager.lineTrimFadeRange
        XCTAssertNil(initialValue)
    }

    func testSetLineTrimFadeRange() {
        let value = [0.5, 0.5]
        manager.lineTrimFadeRange = value
        XCTAssertEqual(manager.lineTrimFadeRange, value)
        XCTAssertEqual(manager.impl.layerProperties["line-trim-fade-range"] as! [Double], value)
    }


    func testSetToNilLineTrimFadeRange() {
        let newLineTrimFadeRangeProperty = [0.5, 0.5]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-fade-range").value as! [Double]
        manager.lineTrimFadeRange = newLineTrimFadeRangeProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-trim-fade-range"])
        harness.triggerDisplayLink()

        manager.lineTrimFadeRange = nil
        XCTAssertNil(manager.lineTrimFadeRange)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-fade-range"] as! [Double], defaultValue)
    }
    func testInitialLineTrimOffset() {
        let initialValue = manager.lineTrimOffset
        XCTAssertNil(initialValue)
    }

    func testSetLineTrimOffset() {
        let value = [0.5, 0.5].sorted()
        manager.lineTrimOffset = value
        XCTAssertEqual(manager.lineTrimOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["line-trim-offset"] as! [Double], value)
    }


    func testSetToNilLineTrimOffset() {
        let newLineTrimOffsetProperty = [0.5, 0.5].sorted()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-offset").value as! [Double]
        manager.lineTrimOffset = newLineTrimOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-trim-offset"])
        harness.triggerDisplayLink()

        manager.lineTrimOffset = nil
        XCTAssertNil(manager.lineTrimOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-trim-offset"] as! [Double], defaultValue)
    }
    func testInitialLineWidth() {
        let initialValue = manager.lineWidth
        XCTAssertNil(initialValue)
    }

    func testSetLineWidth() {
        let value = 50000.0
        manager.lineWidth = value
        XCTAssertEqual(manager.lineWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["line-width"] as! Double, value)
    }


    func testSetToNilLineWidth() {
        let newLineWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width").value as! Double
        manager.lineWidth = newLineWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["line-width"])
        harness.triggerDisplayLink()

        manager.lineWidth = nil
        XCTAssertNil(manager.lineWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["line-width"] as! Double, defaultValue)
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
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .line, property: "slot").value as! String
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

}

// End of generated file
