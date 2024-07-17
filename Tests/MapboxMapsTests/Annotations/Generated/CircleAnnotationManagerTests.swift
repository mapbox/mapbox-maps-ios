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
