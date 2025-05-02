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

    func testInitialFillConstructBridgeGuardRail() {
        let initialValue = manager.fillConstructBridgeGuardRail
        XCTAssertNil(initialValue)
    }

    func testSetFillConstructBridgeGuardRail() {
        let value = true
        manager.fillConstructBridgeGuardRail = value
        XCTAssertEqual(manager.fillConstructBridgeGuardRail, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-construct-bridge-guard-rail"] as! Bool, value)
    }


    func testSetToNilFillConstructBridgeGuardRail() {
        let newFillConstructBridgeGuardRailProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-construct-bridge-guard-rail").value as! Bool
        manager.fillConstructBridgeGuardRail = newFillConstructBridgeGuardRailProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-construct-bridge-guard-rail"])
        harness.triggerDisplayLink()

        manager.fillConstructBridgeGuardRail = nil
        XCTAssertNil(manager.fillConstructBridgeGuardRail)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-construct-bridge-guard-rail"] as! Bool, defaultValue)
    }
    func testInitialFillElevationReference() {
        let initialValue = manager.fillElevationReference
        XCTAssertNil(initialValue)
    }

    func testSetFillElevationReference() {
        let value = FillElevationReference.testConstantValue()
        manager.fillElevationReference = value
        XCTAssertEqual(manager.fillElevationReference, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-elevation-reference"] as! String, value.rawValue)
    }


    func testSetToNilFillElevationReference() {
        let newFillElevationReferenceProperty = FillElevationReference.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-elevation-reference").value as! String
        manager.fillElevationReference = newFillElevationReferenceProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-elevation-reference"])
        harness.triggerDisplayLink()

        manager.fillElevationReference = nil
        XCTAssertNil(manager.fillElevationReference)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-elevation-reference"] as! String, defaultValue)
    }
    func testInitialFillSortKey() {
        let initialValue = manager.fillSortKey
        XCTAssertNil(initialValue)
    }

    func testSetFillSortKey() {
        let value = 0.0
        manager.fillSortKey = value
        XCTAssertEqual(manager.fillSortKey, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-sort-key"] as! Double, value)
    }


    func testSetToNilFillSortKey() {
        let newFillSortKeyProperty = 0.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-sort-key").value as! Double
        manager.fillSortKey = newFillSortKeyProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-sort-key"])
        harness.triggerDisplayLink()

        manager.fillSortKey = nil
        XCTAssertNil(manager.fillSortKey)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-sort-key"] as! Double, defaultValue)
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
    func testInitialFillBridgeGuardRailColor() {
        let initialValue = manager.fillBridgeGuardRailColor
        XCTAssertNil(initialValue)
    }

    func testSetFillBridgeGuardRailColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.fillBridgeGuardRailColor = value
        XCTAssertEqual(manager.fillBridgeGuardRailColor, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-bridge-guard-rail-color"] as? String, value?.rawValue)
    }

    func testSetFillBridgeGuardRailColorUseTheme() {
        manager.fillBridgeGuardRailColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["fill-bridge-guard-rail-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilFillBridgeGuardRailColor() {
        let newFillBridgeGuardRailColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-bridge-guard-rail-color").value as! [Any], options: []))
        manager.fillBridgeGuardRailColor = newFillBridgeGuardRailColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-bridge-guard-rail-color"])
        harness.triggerDisplayLink()

        manager.fillBridgeGuardRailColor = nil
        XCTAssertNil(manager.fillBridgeGuardRailColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-bridge-guard-rail-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialFillColor() {
        let initialValue = manager.fillColor
        XCTAssertNil(initialValue)
    }

    func testSetFillColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.fillColor = value
        XCTAssertEqual(manager.fillColor, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-color"] as? String, value?.rawValue)
    }

    func testSetFillColorUseTheme() {
        manager.fillColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["fill-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilFillColor() {
        let newFillColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-color").value as! [Any], options: []))
        manager.fillColor = newFillColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-color"])
        harness.triggerDisplayLink()

        manager.fillColor = nil
        XCTAssertNil(manager.fillColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
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
    func testInitialFillOpacity() {
        let initialValue = manager.fillOpacity
        XCTAssertNil(initialValue)
    }

    func testSetFillOpacity() {
        let value = 0.5
        manager.fillOpacity = value
        XCTAssertEqual(manager.fillOpacity, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-opacity"] as! Double, value)
    }


    func testSetToNilFillOpacity() {
        let newFillOpacityProperty = 0.5
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-opacity").value as! Double
        manager.fillOpacity = newFillOpacityProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-opacity"])
        harness.triggerDisplayLink()

        manager.fillOpacity = nil
        XCTAssertNil(manager.fillOpacity)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-opacity"] as! Double, defaultValue)
    }
    func testInitialFillOutlineColor() {
        let initialValue = manager.fillOutlineColor
        XCTAssertNil(initialValue)
    }

    func testSetFillOutlineColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.fillOutlineColor = value
        XCTAssertEqual(manager.fillOutlineColor, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-outline-color"] as? String, value?.rawValue)
    }

    func testSetFillOutlineColorUseTheme() {
        manager.fillOutlineColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["fill-outline-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilFillOutlineColor() {
        let newFillOutlineColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-outline-color").value as! [Any], options: []))
        manager.fillOutlineColor = newFillOutlineColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-outline-color"])
        harness.triggerDisplayLink()

        manager.fillOutlineColor = nil
        XCTAssertNil(manager.fillOutlineColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-outline-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialFillPattern() {
        let initialValue = manager.fillPattern
        XCTAssertNil(initialValue)
    }

    func testSetFillPattern() {
        let value = UUID().uuidString
        manager.fillPattern = value
        XCTAssertEqual(manager.fillPattern, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-pattern"] as! String, value)
    }


    func testSetToNilFillPattern() {
        let newFillPatternProperty = UUID().uuidString
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-pattern").value as! String
        manager.fillPattern = newFillPatternProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-pattern"])
        harness.triggerDisplayLink()

        manager.fillPattern = nil
        XCTAssertNil(manager.fillPattern)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-pattern"] as! String, defaultValue)
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
    func testInitialFillTunnelStructureColor() {
        let initialValue = manager.fillTunnelStructureColor
        XCTAssertNil(initialValue)
    }

    func testSetFillTunnelStructureColor() {
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.fillTunnelStructureColor = value
        XCTAssertEqual(manager.fillTunnelStructureColor, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-tunnel-structure-color"] as? String, value?.rawValue)
    }

    func testSetFillTunnelStructureColorUseTheme() {
        manager.fillTunnelStructureColorUseTheme = .default
        XCTAssertEqual(manager.impl.layerProperties["fill-tunnel-structure-color-use-theme"] as! String, ColorUseTheme.default.rawValue)
    }

    func testSetToNilFillTunnelStructureColor() {
        let newFillTunnelStructureColorProperty = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        let defaultValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-tunnel-structure-color").value as! [Any], options: []))
        manager.fillTunnelStructureColor = newFillTunnelStructureColorProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-tunnel-structure-color"])
        harness.triggerDisplayLink()

        manager.fillTunnelStructureColor = nil
        XCTAssertNil(manager.fillTunnelStructureColor)
        harness.triggerDisplayLink()

        let currentValue = try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-tunnel-structure-color"] as! [Any]))
        XCTAssertEqual(currentValue, defaultValue)
    }
    func testInitialFillZOffset() {
        let initialValue = manager.fillZOffset
        XCTAssertNil(initialValue)
    }

    func testSetFillZOffset() {
        let value = 50000.0
        manager.fillZOffset = value
        XCTAssertEqual(manager.fillZOffset, value)
        XCTAssertEqual(manager.impl.layerProperties["fill-z-offset"] as! Double, value)
    }


    func testSetToNilFillZOffset() {
        let newFillZOffsetProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-z-offset").value as! Double
        manager.fillZOffset = newFillZOffsetProperty
        XCTAssertNotNil(manager.impl.layerProperties["fill-z-offset"])
        harness.triggerDisplayLink()

        manager.fillZOffset = nil
        XCTAssertNil(manager.fillZOffset)
        harness.triggerDisplayLink()

        XCTAssertEqual(harness.style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-z-offset"] as! Double, defaultValue)
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
