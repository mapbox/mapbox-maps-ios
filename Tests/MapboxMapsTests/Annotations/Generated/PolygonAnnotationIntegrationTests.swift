// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolygonAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolygonAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makePolygonAnnotationManager()
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
        manager.impl.destroy()

        XCTAssertFalse(mapView.mapboxMap.allLayerIdentifiers.map { $0.id }.contains(manager.layerId))
        XCTAssertFalse(mapView.mapboxMap.allSourceIdentifiers.map { $0.id }.contains(manager.sourceId))
    }

    func testCreatingSecondAnnotationManagerWithTheSameId() throws {
        let secondAnnotationManager = mapView.annotations.makePolygonAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillOpacity = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self) else {
                return false
            }
            let fallbackValue = self.manager.fillOpacity ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-opacity").value
            let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
                ? (try? JSONSerialization.data(withJSONObject: fallbackValue)) ?? Data()
                : Data(String(describing: fallbackValue).utf8)
            let fallbackValueString = String(decoding: fallbackValueData, as: UTF8.self)
            let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"fill-opacity\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
            let currentValueString = (try? layer.fillOpacity.toString()) ?? "<nil>"
            return currentValueString == expectedString
        }), evaluatedWith: nil, handler: nil)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFillElevationReference() throws {
        // Test that the setter and getter work
        let value = FillElevationReference.testConstantValue()
        manager.fillElevationReference = value
        XCTAssertEqual(manager.fillElevationReference, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillElevationReference {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillElevationReference = nil
        XCTAssertNil(manager.fillElevationReference)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillElevationReference, .constant(FillElevationReference(rawValue: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-elevation-reference").value as! String)))
    }

    func testFillAntialias() throws {
        // Test that the setter and getter work
        let value = true
        manager.fillAntialias = value
        XCTAssertEqual(manager.fillAntialias, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillAntialias {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillAntialias = nil
        XCTAssertNil(manager.fillAntialias)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillAntialias, .constant((StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-antialias").value as! NSNumber).boolValue))
    }

    func testFillEmissiveStrength() throws {
        // Test that the setter and getter work
        let value = 50000.0
        manager.fillEmissiveStrength = value
        XCTAssertEqual(manager.fillEmissiveStrength, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillEmissiveStrength {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillEmissiveStrength = nil
        XCTAssertNil(manager.fillEmissiveStrength)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillEmissiveStrength, .constant((StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-emissive-strength").value as! NSNumber).doubleValue))
    }

    func testFillTranslate() throws {
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        manager.fillTranslate = value
        XCTAssertEqual(manager.fillTranslate, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillTranslate = nil
        XCTAssertNil(manager.fillTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillTranslate, .constant(StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate").value as! [Double]))
    }

    func testFillTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = FillTranslateAnchor.testConstantValue()
        manager.fillTranslateAnchor = value
        XCTAssertEqual(manager.fillTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        if case .constant(let actualValue) = layer.fillTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.fillTranslateAnchor = nil
        XCTAssertNil(manager.fillTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillTranslateAnchor, .constant(FillTranslateAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate-anchor").value as! String)))
    }

    func testSlot() throws {
        // Test that the setter and getter work
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let actualValue = layer.slot?.rawValue ?? ""
        XCTAssertEqual(actualValue, value)

        // Test that the property can be reset to nil
        manager.slot = nil
        XCTAssertNil(manager.slot)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.slot, nil)
    }

    func testFillConstructBridgeGuardRail() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = true
        annotation.fillConstructBridgeGuardRail = value
        XCTAssertEqual(annotation.fillConstructBridgeGuardRail, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillConstructBridgeGuardRail ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-construct-bridge-guard-rail").value as! Bool
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"boolean\",[\"coalesce\",[\"get\",\"fill-construct-bridge-guard-rail\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillConstructBridgeGuardRail.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillConstructBridgeGuardRail = nil
        XCTAssertNil(annotation.fillConstructBridgeGuardRail)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillConstructBridgeGuardRail, .constant((StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-construct-bridge-guard-rail").value as! NSNumber).boolValue))
    }

    func testFillSortKey() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.fillSortKey = value
        XCTAssertEqual(annotation.fillSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillSortKey ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-sort-key").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"fill-sort-key\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillSortKey.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillSortKey = nil
        XCTAssertNil(annotation.fillSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillSortKey, .constant((StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-sort-key").value as! NSNumber).doubleValue))
    }

    func testFillBridgeGuardRailColor() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.fillBridgeGuardRailColor = value
        XCTAssertEqual(annotation.fillBridgeGuardRailColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillBridgeGuardRailColor ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-bridge-guard-rail-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"fill-bridge-guard-rail-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillBridgeGuardRailColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillBridgeGuardRailColor = nil
        XCTAssertNil(annotation.fillBridgeGuardRailColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillBridgeGuardRailColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-bridge-guard-rail-color").value as! [Any], options: []))))
    }

    func testFillColor() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.fillColor = value
        XCTAssertEqual(annotation.fillColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillColor ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"fill-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillColor = nil
        XCTAssertNil(annotation.fillColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-color").value as! [Any], options: []))))
    }

    func testFillOpacity() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.fillOpacity = value
        XCTAssertEqual(annotation.fillOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillOpacity ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-opacity").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"fill-opacity\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillOpacity.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillOpacity = nil
        XCTAssertNil(annotation.fillOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-opacity").value as! NSNumber).doubleValue))
    }

    func testFillOutlineColor() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.fillOutlineColor = value
        XCTAssertEqual(annotation.fillOutlineColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillOutlineColor ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-outline-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"fill-outline-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillOutlineColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillOutlineColor = nil
        XCTAssertNil(annotation.fillOutlineColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillOutlineColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-outline-color").value as! [Any], options: []))))
    }

    func testFillPattern() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = UUID().uuidString
        annotation.fillPattern = value
        XCTAssertEqual(annotation.fillPattern, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillPattern ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-pattern").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"image\",[\"coalesce\",[\"get\",\"fill-pattern\",[\"object\",[\"get\",\"layerProperties\"]]],\"\(fallbackValueString)\"]]"
        XCTAssertEqual(try layer.fillPattern.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillPattern = nil
        XCTAssertNil(annotation.fillPattern)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillPattern, .constant(.name(StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-pattern").value as! String)))
    }

    func testFillTunnelStructureColor() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.fillTunnelStructureColor = value
        XCTAssertEqual(annotation.fillTunnelStructureColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillTunnelStructureColor ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-tunnel-structure-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"fill-tunnel-structure-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillTunnelStructureColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillTunnelStructureColor = nil
        XCTAssertNil(annotation.fillTunnelStructureColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillTunnelStructureColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-tunnel-structure-color").value as! [Any], options: []))))
    }

    func testFillZOffset() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.fillZOffset = value
        XCTAssertEqual(annotation.fillZOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        let fallbackValue = self.manager.fillZOffset ?? StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-z-offset").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"fill-z-offset\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.fillZOffset.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.fillZOffset = nil
        XCTAssertNil(annotation.fillZOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: FillLayer.self)
        XCTAssertEqual(layer.fillZOffset, .constant((StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-z-offset").value as! NSNumber).doubleValue))
    }
}

// End of generated file
