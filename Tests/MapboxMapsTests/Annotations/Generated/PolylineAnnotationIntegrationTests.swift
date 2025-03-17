// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolylineAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolylineAnnotationManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = mapView.annotations.makePolylineAnnotationManager()
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
        let secondAnnotationManager = mapView.annotations.makePolylineAnnotationManager(id: manager.id)

        XCTAssertTrue(mapView.annotations.annotationManagersById[manager.id] === secondAnnotationManager)
    }

    func testSynchronizesAnnotationsEventually() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        annotation.lineWidth = 10

        manager.annotations.append(annotation)

        expectation(for: NSPredicate(block: { (_, _) in
            guard let layer = try? self.mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self) else {
                return false
            }
            let fallbackValue = self.manager.lineWidth ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width").value
            let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
                ? (try? JSONSerialization.data(withJSONObject: fallbackValue)) ?? Data()
                : Data(String(describing: fallbackValue).utf8)
            let fallbackValueString = String(decoding: fallbackValueData, as: UTF8.self)
            let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-width\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
            let currentValueString = (try? layer.lineWidth.toString()) ?? "<nil>"
            return currentValueString == expectedString
        }), evaluatedWith: nil, handler: nil)

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testLineCap() throws {
        // Test that the setter and getter work
        let value = LineCap.testConstantValue()
        manager.lineCap = value
        XCTAssertEqual(manager.lineCap, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineCap {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineCap = nil
        XCTAssertNil(manager.lineCap)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineCap, .constant(LineCap(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-cap").value as! String)))
    }

    func testLineCrossSlope() throws {
        // Test that the setter and getter work
        let value = 0.0
        manager.lineCrossSlope = value
        XCTAssertEqual(manager.lineCrossSlope, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineCrossSlope {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineCrossSlope = nil
        XCTAssertNil(manager.lineCrossSlope)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineCrossSlope, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-cross-slope").value as! NSNumber).doubleValue))
    }

    func testLineElevationReference() throws {
        // Test that the setter and getter work
        let value = LineElevationReference.testConstantValue()
        manager.lineElevationReference = value
        XCTAssertEqual(manager.lineElevationReference, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineElevationReference {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineElevationReference = nil
        XCTAssertNil(manager.lineElevationReference)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineElevationReference, .constant(LineElevationReference(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-elevation-reference").value as! String)))
    }

    func testLineMiterLimit() throws {
        // Test that the setter and getter work
        let value = 0.0
        manager.lineMiterLimit = value
        XCTAssertEqual(manager.lineMiterLimit, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineMiterLimit {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineMiterLimit = nil
        XCTAssertNil(manager.lineMiterLimit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineMiterLimit, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-miter-limit").value as! NSNumber).doubleValue))
    }

    func testLineRoundLimit() throws {
        // Test that the setter and getter work
        let value = 0.0
        manager.lineRoundLimit = value
        XCTAssertEqual(manager.lineRoundLimit, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineRoundLimit {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineRoundLimit = nil
        XCTAssertNil(manager.lineRoundLimit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineRoundLimit, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-round-limit").value as! NSNumber).doubleValue))
    }

    func testLineWidthUnit() throws {
        // Test that the setter and getter work
        let value = LineWidthUnit.testConstantValue()
        manager.lineWidthUnit = value
        XCTAssertEqual(manager.lineWidthUnit, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineWidthUnit {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineWidthUnit = nil
        XCTAssertNil(manager.lineWidthUnit)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineWidthUnit, .constant(LineWidthUnit(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width-unit").value as! String)))
    }

    func testLineDasharray() throws {
        // Test that the setter and getter work
        let value = Array.testFixture(withLength: 10, generator: { 0.0 })
        manager.lineDasharray = value
        XCTAssertEqual(manager.lineDasharray, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineDasharray {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineDasharray = nil
        XCTAssertNil(manager.lineDasharray)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineDasharray, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-dasharray").value as! [Double]))
    }

    func testLineDepthOcclusionFactor() throws {
        // Test that the setter and getter work
        let value = 0.5
        manager.lineDepthOcclusionFactor = value
        XCTAssertEqual(manager.lineDepthOcclusionFactor, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineDepthOcclusionFactor {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineDepthOcclusionFactor = nil
        XCTAssertNil(manager.lineDepthOcclusionFactor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineDepthOcclusionFactor, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-depth-occlusion-factor").value as! NSNumber).doubleValue))
    }

    func testLineEmissiveStrength() throws {
        // Test that the setter and getter work
        let value = 50000.0
        manager.lineEmissiveStrength = value
        XCTAssertEqual(manager.lineEmissiveStrength, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineEmissiveStrength {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineEmissiveStrength = nil
        XCTAssertNil(manager.lineEmissiveStrength)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineEmissiveStrength, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-emissive-strength").value as! NSNumber).doubleValue))
    }

    func testLineOcclusionOpacity() throws {
        // Test that the setter and getter work
        let value = 0.5
        manager.lineOcclusionOpacity = value
        XCTAssertEqual(manager.lineOcclusionOpacity, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineOcclusionOpacity {
            XCTAssertEqual(actualValue, value, accuracy: 0.1)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineOcclusionOpacity = nil
        XCTAssertNil(manager.lineOcclusionOpacity)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOcclusionOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-occlusion-opacity").value as! NSNumber).doubleValue))
    }

    func testLineTranslate() throws {
        // Test that the setter and getter work
        let value = [0.0, 0.0]
        manager.lineTranslate = value
        XCTAssertEqual(manager.lineTranslate, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTranslate {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTranslate = nil
        XCTAssertNil(manager.lineTranslate)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslate, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate").value as! [Double]))
    }

    func testLineTranslateAnchor() throws {
        // Test that the setter and getter work
        let value = LineTranslateAnchor.testConstantValue()
        manager.lineTranslateAnchor = value
        XCTAssertEqual(manager.lineTranslateAnchor, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTranslateAnchor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTranslateAnchor = nil
        XCTAssertNil(manager.lineTranslateAnchor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTranslateAnchor, .constant(LineTranslateAnchor(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-translate-anchor").value as! String)))
    }

    func testLineTrimColor() throws {
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        manager.lineTrimColor = value
        XCTAssertEqual(manager.lineTrimColor, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTrimColor {
            XCTAssertEqual(actualValue, value)
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTrimColor = nil
        XCTAssertNil(manager.lineTrimColor)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTrimColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-color").value as! [Any], options: []))))
    }

    func testLineTrimFadeRange() throws {
        // Test that the setter and getter work
        let value = [0.5, 0.5]
        manager.lineTrimFadeRange = value
        XCTAssertEqual(manager.lineTrimFadeRange, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTrimFadeRange {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTrimFadeRange = nil
        XCTAssertNil(manager.lineTrimFadeRange)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTrimFadeRange, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-fade-range").value as! [Double]))
    }

    func testLineTrimOffset() throws {
        // Test that the setter and getter work
        let value = [0.5, 0.5].sorted()
        manager.lineTrimOffset = value
        XCTAssertEqual(manager.lineTrimOffset, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        if case .constant(let actualValue) = layer.lineTrimOffset {
            for (actual, expected) in zip(actualValue, value) {
                XCTAssertEqual(actual, expected, accuracy: 0.1)
            }
        } else {
            XCTFail("Expected constant")
        }

        // Test that the property can be reset to nil
        manager.lineTrimOffset = nil
        XCTAssertNil(manager.lineTrimOffset)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineTrimOffset, .constant(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-trim-offset").value as! [Double]))
    }

    func testSlot() throws {
        // Test that the setter and getter work
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let actualValue = layer.slot?.rawValue ?? ""
        XCTAssertEqual(actualValue, value)

        // Test that the property can be reset to nil
        manager.slot = nil
        XCTAssertNil(manager.slot)

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.slot, nil)
    }

    func testLineJoin() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = LineJoin.testConstantValue()
        annotation.lineJoin = value
        XCTAssertEqual(annotation.lineJoin, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineJoin ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-join").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-string\",[\"coalesce\",[\"get\",\"line-join\",[\"object\",[\"get\",\"layerProperties\"]]],\"\(fallbackValueString)\"]]"
        XCTAssertEqual(try layer.lineJoin.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineJoin = nil
        XCTAssertNil(annotation.lineJoin)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineJoin, .constant(LineJoin(rawValue: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-join").value as! String)))
    }

    func testLineSortKey() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.lineSortKey = value
        XCTAssertEqual(annotation.lineSortKey, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineSortKey ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-sort-key").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-sort-key\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineSortKey.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineSortKey = nil
        XCTAssertNil(annotation.lineSortKey)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineSortKey, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-sort-key").value as! NSNumber).doubleValue))
    }

    func testLineZOffset() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.lineZOffset = value
        XCTAssertEqual(annotation.lineZOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineZOffset ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-z-offset").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-z-offset\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineZOffset.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineZOffset = nil
        XCTAssertNil(annotation.lineZOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineZOffset, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-z-offset").value as! NSNumber).doubleValue))
    }

    func testLineBlur() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.lineBlur = value
        XCTAssertEqual(annotation.lineBlur, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineBlur ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-blur").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-blur\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineBlur.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineBlur = nil
        XCTAssertNil(annotation.lineBlur)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBlur, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-blur").value as! NSNumber).doubleValue))
    }

    func testLineBorderColor() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.lineBorderColor = value
        XCTAssertEqual(annotation.lineBorderColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineBorderColor ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"line-border-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineBorderColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineBorderColor = nil
        XCTAssertNil(annotation.lineBorderColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBorderColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-color").value as! [Any], options: []))))
    }

    func testLineBorderWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.lineBorderWidth = value
        XCTAssertEqual(annotation.lineBorderWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineBorderWidth ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-width").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-border-width\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineBorderWidth.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineBorderWidth = nil
        XCTAssertNil(annotation.lineBorderWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineBorderWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-border-width").value as! NSNumber).doubleValue))
    }

    func testLineColor() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = StyleColor(red: 255, green: 0, blue: 255, alpha: 1)
        annotation.lineColor = value
        XCTAssertEqual(annotation.lineColor, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineColor ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-color").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"to-color\",[\"coalesce\",[\"get\",\"line-color\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineColor.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineColor = nil
        XCTAssertNil(annotation.lineColor)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineColor, .constant(try! JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: StyleManager.layerPropertyDefaultValue(for: .line, property: "line-color").value as! [Any], options: []))))
    }

    func testLineGapWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.lineGapWidth = value
        XCTAssertEqual(annotation.lineGapWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineGapWidth ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-gap-width").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-gap-width\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineGapWidth.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineGapWidth = nil
        XCTAssertNil(annotation.lineGapWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineGapWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-gap-width").value as! NSNumber).doubleValue))
    }

    func testLineOffset() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.0
        annotation.lineOffset = value
        XCTAssertEqual(annotation.lineOffset, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineOffset ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-offset").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-offset\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineOffset.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineOffset = nil
        XCTAssertNil(annotation.lineOffset)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOffset, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-offset").value as! NSNumber).doubleValue))
    }

    func testLineOpacity() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 0.5
        annotation.lineOpacity = value
        XCTAssertEqual(annotation.lineOpacity, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineOpacity ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-opacity").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-opacity\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineOpacity.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineOpacity = nil
        XCTAssertNil(annotation.lineOpacity)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineOpacity, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-opacity").value as! NSNumber).doubleValue))
    }

    func testLinePattern() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = UUID().uuidString
        annotation.linePattern = value
        XCTAssertEqual(annotation.linePattern, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.linePattern ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-pattern").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"image\",[\"coalesce\",[\"get\",\"line-pattern\",[\"object\",[\"get\",\"layerProperties\"]]],\"\(fallbackValueString)\"]]"
        XCTAssertEqual(try layer.linePattern.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.linePattern = nil
        XCTAssertNil(annotation.linePattern)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.linePattern, .constant(.name(StyleManager.layerPropertyDefaultValue(for: .line, property: "line-pattern").value as! String)))
    }

    func testLineWidth() throws {
        let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
        var annotation = PolylineAnnotation(lineString: .init(lineCoordinates), isSelected: false, isDraggable: false)
        // Test that the setter and getter work
        let value = 50000.0
        annotation.lineWidth = value
        XCTAssertEqual(annotation.lineWidth, value)

        manager.annotations = [annotation]

        // Test that the value is synced to the layer
        manager.impl.syncSourceAndLayerIfNeeded()
        var layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        let fallbackValue = self.manager.lineWidth ?? StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width").value
        let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
            ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
            : Data(String(describing: fallbackValue).utf8)
        let fallbackValueString = try XCTUnwrap(String(decoding: fallbackValueData, as: UTF8.self))
        let expectedString = "[\"number\",[\"coalesce\",[\"get\",\"line-width\",[\"object\",[\"get\",\"layerProperties\"]]],\(fallbackValueString)]]"
        XCTAssertEqual(try layer.lineWidth.toString(), expectedString)

        // Test that the property can be reset to nil
        annotation.lineWidth = nil
        XCTAssertNil(annotation.lineWidth)

        manager.annotations = [annotation]

        // Verify that when the property is reset to nil,
        // the layer is returned to the default value
        manager.impl.syncSourceAndLayerIfNeeded()
        layer = try mapView.mapboxMap.layer(withId: self.manager.layerId, type: LineLayer.self)
        XCTAssertEqual(layer.lineWidth, .constant((StyleManager.layerPropertyDefaultValue(for: .line, property: "line-width").value as! NSNumber).doubleValue))
    }
}

// End of generated file
