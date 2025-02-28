// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class CircleAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: CircleAnnotationManager!
    var harness: AnnotationManagerTestingHarness!
    var annotations = [CircleAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
        super.setUp()

        harness = AnnotationManagerTestingHarness()
        manager = CircleAnnotationManager(
            params: harness.makeParams(),
            deps: harness.makeDeps())

        for _ in 0...10 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        harness = nil
        manager = nil
        super.tearDown()
    }

    func testInitialCircleSortKey() {
        let initialValue = manager.circleSortKey
        XCTAssertNil(initialValue)
    }

    func testSetCircleSortKey() {
        let value = 0.0
        manager.circleSortKey = value
        XCTAssertEqual(manager.circleSortKey, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-sort-key"] as! Double, value)
    }

    func testSetToNilCircleSortKey() {
        let newCircleSortKeyProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-sort-key").value as! Double
        manager.circleSortKey = newCircleSortKeyProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-sort-key"])
        harness.triggerDisplayLink()

        manager.circleSortKey = nil
        XCTAssertNil(manager.circleSortKey)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-sort-key"] as! Double, defaultValue)
    }
    func testInitialCircleBlur() {
        let initialValue = manager.circleBlur
        XCTAssertNil(initialValue)
    }

    func testSetCircleBlur() {
        let value = 0.0
        manager.circleBlur = value
        XCTAssertEqual(manager.circleBlur, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-blur"] as! Double, value)
    }

    func testSetToNilCircleBlur() {
        let newCircleBlurProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-blur").value as! Double
        manager.circleBlur = newCircleBlurProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-blur"])
        harness.triggerDisplayLink()

        manager.circleBlur = nil
        XCTAssertNil(manager.circleBlur)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-blur"] as! Double, defaultValue)
    }
    func testInitialCircleColor() {
        let initialValue = manager.circleColor
        XCTAssertNil(initialValue)
    }

    func testSetCircleColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.circleColor = value
        XCTAssertEqual(manager.circleColor, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-color"] as? String, value?.rawValue)
    }

    func testSetToNilCircleColor() {
        let newCircleColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-color").value as! [Any], options: []))
        manager.circleColor = newCircleColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-color"])
        harness.triggerDisplayLink()

        manager.circleColor = nil
        XCTAssertNil(manager.circleColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialCircleEmissiveStrength() {
        let initialValue = manager.circleEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetCircleEmissiveStrength() {
        let value = 50000.0
        manager.circleEmissiveStrength = value
        XCTAssertEqual(manager.circleEmissiveStrength, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-emissive-strength"] as! Double, value)
    }

    func testSetToNilCircleEmissiveStrength() {
        let newCircleEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-emissive-strength").value as! Double
        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-emissive-strength"])
        harness.triggerDisplayLink()

        manager.circleEmissiveStrength = nil
        XCTAssertNil(manager.circleEmissiveStrength)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, defaultValue)
    }
    func testInitialCircleOpacity() {
        let initialValue = manager.circleOpacity
        XCTAssertNil(initialValue)
    }

    func testSetCircleOpacity() {
        let value = 0.5
        manager.circleOpacity = value
        XCTAssertEqual(manager.circleOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-opacity"] as! Double, value)
    }

    func testSetToNilCircleOpacity() {
        let newCircleOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-opacity").value as! Double
        manager.circleOpacity = newCircleOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-opacity"])
        harness.triggerDisplayLink()

        manager.circleOpacity = nil
        XCTAssertNil(manager.circleOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-opacity"] as! Double, defaultValue)
    }
    func testInitialCirclePitchAlignment() {
        let initialValue = manager.circlePitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchAlignment() {
        let value = CirclePitchAlignment.testConstantValue()
        manager.circlePitchAlignment = value
        XCTAssertEqual(manager.circlePitchAlignment, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-pitch-alignment"] as! String, value.rawValue)
    }

    func testSetToNilCirclePitchAlignment() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-alignment").value as! String
        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-pitch-alignment"])
        harness.triggerDisplayLink()

        manager.circlePitchAlignment = nil
        XCTAssertNil(manager.circlePitchAlignment)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, defaultValue)
    }
    func testInitialCirclePitchScale() {
        let initialValue = manager.circlePitchScale
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchScale() {
        let value = CirclePitchScale.testConstantValue()
        manager.circlePitchScale = value
        XCTAssertEqual(manager.circlePitchScale, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-pitch-scale"] as! String, value.rawValue)
    }

    func testSetToNilCirclePitchScale() {
        let newCirclePitchScaleProperty = CirclePitchScale.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-scale").value as! String
        manager.circlePitchScale = newCirclePitchScaleProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-pitch-scale"])
        harness.triggerDisplayLink()

        manager.circlePitchScale = nil
        XCTAssertNil(manager.circlePitchScale)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, defaultValue)
    }
    func testInitialCircleRadius() {
        let initialValue = manager.circleRadius
        XCTAssertNil(initialValue)
    }

    func testSetCircleRadius() {
        let value = 50000.0
        manager.circleRadius = value
        XCTAssertEqual(manager.circleRadius, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-radius"] as! Double, value)
    }

    func testSetToNilCircleRadius() {
        let newCircleRadiusProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-radius").value as! Double
        manager.circleRadius = newCircleRadiusProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-radius"])
        harness.triggerDisplayLink()

        manager.circleRadius = nil
        XCTAssertNil(manager.circleRadius)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-radius"] as! Double, defaultValue)
    }
    func testInitialCircleStrokeColor() {
        let initialValue = manager.circleStrokeColor
        XCTAssertNil(initialValue)
    }

    func testSetCircleStrokeColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.circleStrokeColor = value
        XCTAssertEqual(manager.circleStrokeColor, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-stroke-color"] as? String, value?.rawValue)
    }

    func testSetToNilCircleStrokeColor() {
        let newCircleStrokeColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-color").value as! [Any], options: []))
        manager.circleStrokeColor = newCircleStrokeColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-stroke-color"])
        harness.triggerDisplayLink()

        manager.circleStrokeColor = nil
        XCTAssertNil(manager.circleStrokeColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-stroke-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialCircleStrokeOpacity() {
        let initialValue = manager.circleStrokeOpacity
        XCTAssertNil(initialValue)
    }

    func testSetCircleStrokeOpacity() {
        let value = 0.5
        manager.circleStrokeOpacity = value
        XCTAssertEqual(manager.circleStrokeOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-stroke-opacity"] as! Double, value)
    }

    func testSetToNilCircleStrokeOpacity() {
        let newCircleStrokeOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-opacity").value as! Double
        manager.circleStrokeOpacity = newCircleStrokeOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-stroke-opacity"])
        harness.triggerDisplayLink()

        manager.circleStrokeOpacity = nil
        XCTAssertNil(manager.circleStrokeOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-stroke-opacity"] as! Double, defaultValue)
    }
    func testInitialCircleStrokeWidth() {
        let initialValue = manager.circleStrokeWidth
        XCTAssertNil(initialValue)
    }

    func testSetCircleStrokeWidth() {
        let value = 50000.0
        manager.circleStrokeWidth = value
        XCTAssertEqual(manager.circleStrokeWidth, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-stroke-width"] as! Double, value)
    }

    func testSetToNilCircleStrokeWidth() {
        let newCircleStrokeWidthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-width").value as! Double
        manager.circleStrokeWidth = newCircleStrokeWidthProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-stroke-width"])
        harness.triggerDisplayLink()

        manager.circleStrokeWidth = nil
        XCTAssertNil(manager.circleStrokeWidth)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-stroke-width"] as! Double, defaultValue)
    }
    func testInitialCircleTranslate() {
        let initialValue = manager.circleTranslate
        XCTAssertNil(initialValue)
    }

    func testSetCircleTranslate() {
        let value = [0.0, 0.0]
        manager.circleTranslate = value
        XCTAssertEqual(manager.circleTranslate, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-translate"] as! [Double], value)
    }

    func testSetToNilCircleTranslate() {
        let newCircleTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate").value as! [Double]
        manager.circleTranslate = newCircleTranslateProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-translate"])
        harness.triggerDisplayLink()

        manager.circleTranslate = nil
        XCTAssertNil(manager.circleTranslate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], defaultValue)
    }
    func testInitialCircleTranslateAnchor() {
        let initialValue = manager.circleTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetCircleTranslateAnchor() {
        let value = CircleTranslateAnchor.testConstantValue()
        manager.circleTranslateAnchor = value
        XCTAssertEqual(manager.circleTranslateAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["circle-translate-anchor"] as! String, value.rawValue)
    }

    func testSetToNilCircleTranslateAnchor() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate-anchor").value as! String
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["circle-translate-anchor"])
        harness.triggerDisplayLink()

        manager.circleTranslateAnchor = nil
        XCTAssertNil(manager.circleTranslateAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, defaultValue)
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
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "slot").value as! String
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
