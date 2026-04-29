// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class CircleAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: CircleAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makeCircleAnnotationManager()
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
        let secondAnnotationManager = mapView.annotations.makeCircleAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.circleRadius = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self) else {
                return false
            }
            let fallbackValue = self.manager.circleRadius ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-radius").value
            let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
                ? (try? JSONSerialization.data(withJSONObject: fallbackValue)) ?? Data()
                : Data(String(describing: fallbackValue).utf8)
            let fallbackValueString = String(decoding: fallbackValueData, as: UTF8.self)
            let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-radius\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
            let currentValueString = (try? layer.circleRadius.toString()) ?? "<nil>"
            return currentValueString == expectedString
        }), evaluatedWith: nil, handler: nil)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCircleElevationReference() throws {
        // Test that the setter and getter work
        let value = CircleElevationReference.testConstantValue()
        manager.circleElevationReference = value
        XCTAssertEqual(manager.circleElevationReference, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        if case .constant(let actualValue) = layer.circleElevationReference {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.circleElevationReference = nil
        XCTAssertNil(manager.circleElevationReference)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.circleElevationReference, .constant(CircleElevationReference(rawValue: StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-elevation-reference").value as! String)))
    }

    func testCircleEmissiveStrength() throws {
        // Test that the setter and getter work
        let value = 50000.0
        manager.circleEmissiveStrength = value
        XCTAssertEqual(manager.circleEmissiveStrength, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        if case .constant(let actualValue) = layer.circleEmissiveStrength {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.circleEmissiveStrength = nil
        XCTAssertNil(manager.circleEmissiveStrength)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.circleEmissiveStrength, .constant((StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-emissive-strength").value as! NSNumber).doubleValue))
    }

    func testCirclePitchAlignment() throws {
        // Test that the setter and getter work
        let value = CirclePitchAlignment.testConstantValue()
        manager.circlePitchAlignment = value
        XCTAssertEqual(manager.circlePitchAlignment, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        if case .constant(let actualValue) = layer.circlePitchAlignment {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.circlePitchAlignment = nil
        XCTAssertNil(manager.circlePitchAlignment)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.circlePitchAlignment, .constant(CirclePitchAlignment(rawValue: StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-alignment").value as! String)))
    }

    func testCirclePitchScale() throws {
        // Test that the setter and getter work
        let value = CirclePitchScale.testConstantValue()
        manager.circlePitchScale = value
        XCTAssertEqual(manager.circlePitchScale, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        if case .constant(let actualValue) = layer.circlePitchScale {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.circlePitchScale = nil
        XCTAssertNil(manager.circlePitchScale)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.circlePitchScale, .constant(CirclePitchScale(rawValue: StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-scale").value as! String)))
    }

    func testCircleTranslate() throws {
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        manager.circleTranslate = value
        XCTAssertEqual(manager.circleTranslate, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        if case .constant(let actualValue) = layer.circleTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.circleTranslate = nil
        XCTAssertNil(manager.circleTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.circleTranslate, .constant(StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate").value as! [Double]))
    }

    func testCircleTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = CircleTranslateAnchor.testConstantValue()
        manager.circleTranslateAnchor = value
        XCTAssertEqual(manager.circleTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        if case .constant(let actualValue) = layer.circleTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.circleTranslateAnchor = nil
        XCTAssertNil(manager.circleTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.circleTranslateAnchor, .constant(CircleTranslateAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate-anchor").value as! String)))
    }

    func testSlot() throws {
        // Test that the setter and getter work
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let actualValue = layer.slot?.rawValue ?? ""
        XCTAssertEqual(actualValue, value)

        // Test that the property can be reset to nil
        manager.slot = nil
        XCTAssertNil(manager.slot)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(layer.slot, nil)
    }

    func testCircleSortKey() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.circleSortKey = value
        XCTAssertEqual(annotation.circleSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleSortKey ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-sort-key").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-sort-key\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleSortKey.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleSortKey = nil
        XCTAssertNil(annotation.circleSortKey)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleSortKey.toString(), expectedString)
    }

    func testCircleBlur() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.circleBlur = value
        XCTAssertEqual(annotation.circleBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleBlur ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-blur").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-blur\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleBlur.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleBlur = nil
        XCTAssertNil(annotation.circleBlur)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleBlur.toString(), expectedString)
    }

    func testCircleColor() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.circleColor = value
        XCTAssertEqual(annotation.circleColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleColor ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"circle-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleColor = nil
        XCTAssertNil(annotation.circleColor)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleColor.toString(), expectedString)
    }

    func testCircleOpacity() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.circleOpacity = value
        XCTAssertEqual(annotation.circleOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleOpacity ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-opacity").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-opacity\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleOpacity.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleOpacity = nil
        XCTAssertNil(annotation.circleOpacity)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleOpacity.toString(), expectedString)
    }

    func testCircleRadius() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.circleRadius = value
        XCTAssertEqual(annotation.circleRadius, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleRadius ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-radius").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-radius\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleRadius.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleRadius = nil
        XCTAssertNil(annotation.circleRadius)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleRadius.toString(), expectedString)
    }

    func testCircleStrokeColor() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.circleStrokeColor = value
        XCTAssertEqual(annotation.circleStrokeColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleStrokeColor ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"circle-stroke-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleStrokeColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleStrokeColor = nil
        XCTAssertNil(annotation.circleStrokeColor)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleStrokeColor.toString(), expectedString)
    }

    func testCircleStrokeOpacity() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.circleStrokeOpacity = value
        XCTAssertEqual(annotation.circleStrokeOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleStrokeOpacity ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-opacity").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-stroke-opacity\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleStrokeOpacity.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleStrokeOpacity = nil
        XCTAssertNil(annotation.circleStrokeOpacity)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleStrokeOpacity.toString(), expectedString)
    }

    func testCircleStrokeWidth() throws {
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.circleStrokeWidth = value
        XCTAssertEqual(annotation.circleStrokeWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        let fallbackValue = self.manager.circleStrokeWidth ?? StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-stroke-width").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"circle-stroke-width\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.circleStrokeWidth.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.circleStrokeWidth = nil
        XCTAssertNil(annotation.circleStrokeWidth)

        manager.annotations = [annotation]

        // Verify that when the annotation's property is reset to nil, the layer retains
        // the coalesce expression falling back to the style default (or manager value).
        // This keeps stale features rendering their own stored values during async source
        // updates — the fix for MAPSIOS-2180. Expression form is visually equivalent to a
        // literal default when no feature carries the property.
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: CircleLayer.self)
        XCTAssertEqual(try layer.circleStrokeWidth.toString(), expectedString)
    }
}

// End of generated file
