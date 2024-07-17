// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolygonAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PolygonAnnotationManager!
    var harness: AnnotationManagerTestingHarness!
    var annotations = [PolygonAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
        super.setUp()

        harness = AnnotationManagerTestingHarness()
        manager = PolygonAnnotationManager(
            params: harness.makeParams(),
            deps: harness.makeDeps())

        for _ in 0...10 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        harness = nil
        manager = nil
        super.tearDown()
    }

    func testInitialFillAntialias() {
        let initialValue = manager.fillAntialias
        XCTAssertNil(initialValue)
    }

    func testSetFillAntialias() {
        let value = true
        manager.fillAntialias = value
        XCTAssertEqual(manager.fillAntialias, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-antialias"] as! Bool, value)
    }

    func testSetToNilFillAntialias() {
        let newFillAntialiasProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-antialias").value as! Bool
        manager.fillAntialias = newFillAntialiasProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-antialias"])
        harness.triggerDisplayLink()

        manager.fillAntialias = nil
        XCTAssertNil(manager.fillAntialias)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, defaultValue)
    }
    func testInitialFillEmissiveStrength() {
        let initialValue = manager.fillEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetFillEmissiveStrength() {
        let value = 50000.0
        manager.fillEmissiveStrength = value
        XCTAssertEqual(manager.fillEmissiveStrength, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-emissive-strength"] as! Double, value)
    }

    func testSetToNilFillEmissiveStrength() {
        let newFillEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-emissive-strength").value as! Double
        manager.fillEmissiveStrength = newFillEmissiveStrengthProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-emissive-strength"])
        harness.triggerDisplayLink()

        manager.fillEmissiveStrength = nil
        XCTAssertNil(manager.fillEmissiveStrength)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"] as! Double, defaultValue)
    }
    func testInitialFillTranslate() {
        let initialValue = manager.fillTranslate
        XCTAssertNil(initialValue)
    }

    func testSetFillTranslate() {
        let value = [0.0, 0.0]
        manager.fillTranslate = value
        XCTAssertEqual(manager.fillTranslate, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-translate"] as! [Double], value)
    }

    func testSetToNilFillTranslate() {
        let newFillTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate").value as! [Double]
        manager.fillTranslate = newFillTranslateProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-translate"])
        harness.triggerDisplayLink()

        manager.fillTranslate = nil
        XCTAssertNil(manager.fillTranslate)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], defaultValue)
    }
    func testInitialFillTranslateAnchor() {
        let initialValue = manager.fillTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetFillTranslateAnchor() {
        let value = FillTranslateAnchor.testConstantValue()
        manager.fillTranslateAnchor = value
        XCTAssertEqual(manager.fillTranslateAnchor, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-translate-anchor"] as! String, value.rawValue)
    }

    func testSetToNilFillTranslateAnchor() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate-anchor").value as! String
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-translate-anchor"])
        harness.triggerDisplayLink()

        manager.fillTranslateAnchor = nil
        XCTAssertNil(manager.fillTranslateAnchor)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, defaultValue)
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
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "slot").value as! String
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
