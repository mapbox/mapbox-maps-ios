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
    func testInitialLineDasharray() {
        let initialValue = manager.lineDasharray
        XCTAssertNil(initialValue)
    }

    func testSetLineDasharray() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)
        XCTAssertEqual(manager.impl.layerProperties["line-dasharray"] as! [Double], value)
    }

    func testSetToNilLineDasharray() {
        let newLineDasharrayProperty = Array.random(withLength: .random(in: 0...10), generator: { 0.0 })
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
