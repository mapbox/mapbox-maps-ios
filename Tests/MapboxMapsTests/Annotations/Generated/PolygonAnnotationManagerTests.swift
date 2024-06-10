// This file is generated
import XCTest
@testable import MapboxMaps

final class PolygonAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PolygonAnnotationManager!
    var style: MockStyle!
    var id = UUID().uuidString
    var annotations = [PolygonAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var offsetCalculator: OffsetPolygonCalculator!
    var mapboxMap: MockMapboxMap!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()

        style = MockStyle()
        mapboxMap = MockMapboxMap()
        offsetCalculator = OffsetPolygonCalculator(mapboxMap: mapboxMap)
        manager = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

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
        style = nil
        expectation = nil
        delegateAnnotations = nil
        mapboxMap = nil
        offsetCalculator = nil
        manager = nil

        super.tearDown()
    }

    func testSourceSetup() {
        style.addSourceStub.reset()

        _ = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.id, manager.id)
    }

    func testAddLayer() throws {
        style.addSourceStub.reset()
        let initializedManager = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.fill)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        let addedLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.last?.parameters.layer as? FillLayer)
        XCTAssertEqual(addedLayer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        var annotations2 = [PolygonAnnotation]()
        for _ in 0...50 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = PolygonAnnotationManager(
            id: manager.id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: LayerPosition.at(4),
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )
        manager3.annotations = annotations

        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroy() {
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id])

        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        manager.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testDestroyManagerWithDraggedAnnotations() {
        let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.isDraggable = true
        manager.annotations = [annotation]
        // adds drag source/layer
        _ = manager.handleDragBegin(with: annotation.id, context: .zero)

        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id, id + "_drag"])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id, id + "_drag"])

        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        manager.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testSyncSourceAndLayer() {
        manager.annotations = annotations
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testFeatureCollectionPassedtoGeoJSON() throws {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
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
        let expectedFeatures = annotations.map(\.feature)

        manager.annotations = annotations
        $displayLink.send()

        var invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
        XCTAssertEqual(invocation.parameters.features, expectedFeatures)
        XCTAssertEqual(invocation.parameters.sourceId, manager.id)

        do {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotations.append(annotation)

            manager.annotations = annotations
            $displayLink.send()

            invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
            XCTAssertEqual(invocation.parameters.features, [annotation].map(\.feature))
            XCTAssertEqual(invocation.parameters.sourceId, manager.id)
        }
    }

    @available(*, deprecated)
    func testHandleTap() throws {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
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
        var taps = [MapContentGestureContext]()
        annotations[0].tapHandler = { context in
            taps.append(context)
            return true
        }
        annotations[1].tapHandler = { _ in
            return false // skips handling
        }
        manager.delegate = self

        manager.annotations = annotations

        // first annotation, handles tap
        let context = MapContentGestureContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        var handled = manager.handleTap(layerId: "layerId", feature: annotations[0].feature, context: context)

        var result = try XCTUnwrap(delegateAnnotations)
        XCTAssertEqual(result[0].id, annotations[0].id)
        XCTAssertEqual(handled, true)

        XCTAssertEqual(taps.count, 1)
        XCTAssertEqual(taps.first?.point, context.point)
        XCTAssertEqual(taps.first?.coordinate, context.coordinate)

        // second annotation, skips handling tap
        delegateAnnotations = nil
        handled = manager.handleTap(layerId: "layerId", feature: annotations[1].feature, context: context)

        result = try XCTUnwrap(delegateAnnotations)
        XCTAssertEqual(result[0].id, annotations[1].id)
        XCTAssertEqual(handled, false)

        // invalid id
        delegateAnnotations = nil
        let invalidFeature = Feature(geometry: nil)
        handled = manager.handleTap(layerId: "layerId", feature: invalidFeature, context: context)

        XCTAssertNil(delegateAnnotations)
        XCTAssertEqual(handled, false)
        XCTAssertEqual(taps.count, 1)
    }

    func testInitialFillAntialias() {
        let initialValue = manager.fillAntialias
        XCTAssertNil(initialValue)
    }

    func testSetFillAntialias() {
        let value = true
        manager.fillAntialias = value
        XCTAssertEqual(manager.fillAntialias, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, value)
    }

    func testFillAntialiasAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillAntialiasProperty = true
        let secondFillAntialiasProperty = true

        manager.fillAntialias = newFillAntialiasProperty
        $displayLink.send()
        manager.fillAntialias = secondFillAntialiasProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, secondFillAntialiasProperty)
    }

    func testNewFillAntialiasPropertyMergedWithAnnotationProperties() {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotation.fillSortKey = 0.0
            annotation.fillColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillOpacity = 0.5
            annotation.fillOutlineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillPattern = UUID().uuidString
            annotations.append(annotation)
        }
        let newFillAntialiasProperty = true

        manager.annotations = annotations
        manager.fillAntialias = newFillAntialiasProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"])
    }

    func testSetToNilFillAntialias() {
        let newFillAntialiasProperty = true
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-antialias").value as! Bool
        manager.fillAntialias = newFillAntialiasProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"])

        manager.fillAntialias = nil
        $displayLink.send()
        XCTAssertNil(manager.fillAntialias)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, defaultValue)
    }

    func testInitialFillEmissiveStrength() {
        let initialValue = manager.fillEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetFillEmissiveStrength() {
        let value = 50000.0
        manager.fillEmissiveStrength = value
        XCTAssertEqual(manager.fillEmissiveStrength, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"] as! Double, value)
    }

    func testFillEmissiveStrengthAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillEmissiveStrengthProperty = 50000.0
        let secondFillEmissiveStrengthProperty = 50000.0

        manager.fillEmissiveStrength = newFillEmissiveStrengthProperty
        $displayLink.send()
        manager.fillEmissiveStrength = secondFillEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"] as! Double, secondFillEmissiveStrengthProperty)
    }

    func testNewFillEmissiveStrengthPropertyMergedWithAnnotationProperties() {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotation.fillSortKey = 0.0
            annotation.fillColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillOpacity = 0.5
            annotation.fillOutlineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillPattern = UUID().uuidString
            annotations.append(annotation)
        }
        let newFillEmissiveStrengthProperty = 50000.0

        manager.annotations = annotations
        manager.fillEmissiveStrength = newFillEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"])
    }

    func testSetToNilFillEmissiveStrength() {
        let newFillEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-emissive-strength").value as! Double
        manager.fillEmissiveStrength = newFillEmissiveStrengthProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"])

        manager.fillEmissiveStrength = nil
        $displayLink.send()
        XCTAssertNil(manager.fillEmissiveStrength)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"] as! Double, defaultValue)
    }

    func testInitialFillTranslate() {
        let initialValue = manager.fillTranslate
        XCTAssertNil(initialValue)
    }

    func testSetFillTranslate() {
        let value = [0.0, 0.0]
        manager.fillTranslate = value
        XCTAssertEqual(manager.fillTranslate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], value)
    }

    func testFillTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillTranslateProperty = [0.0, 0.0]
        let secondFillTranslateProperty = [0.0, 0.0]

        manager.fillTranslate = newFillTranslateProperty
        $displayLink.send()
        manager.fillTranslate = secondFillTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], secondFillTranslateProperty)
    }

    func testNewFillTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotation.fillSortKey = 0.0
            annotation.fillColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillOpacity = 0.5
            annotation.fillOutlineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillPattern = UUID().uuidString
            annotations.append(annotation)
        }
        let newFillTranslateProperty = [0.0, 0.0]

        manager.annotations = annotations
        manager.fillTranslate = newFillTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"])
    }

    func testSetToNilFillTranslate() {
        let newFillTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate").value as! [Double]
        manager.fillTranslate = newFillTranslateProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"])

        manager.fillTranslate = nil
        $displayLink.send()
        XCTAssertNil(manager.fillTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], defaultValue)
    }

    func testInitialFillTranslateAnchor() {
        let initialValue = manager.fillTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetFillTranslateAnchor() {
        let value = FillTranslateAnchor.testConstantValue()
        manager.fillTranslateAnchor = value
        XCTAssertEqual(manager.fillTranslateAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, value.rawValue)
    }

    func testFillTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.testConstantValue()
        let secondFillTranslateAnchorProperty = FillTranslateAnchor.testConstantValue()

        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        $displayLink.send()
        manager.fillTranslateAnchor = secondFillTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, secondFillTranslateAnchorProperty.rawValue)
    }

    func testNewFillTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotation.fillSortKey = 0.0
            annotation.fillColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillOpacity = 0.5
            annotation.fillOutlineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillPattern = UUID().uuidString
            annotations.append(annotation)
        }
        let newFillTranslateAnchorProperty = FillTranslateAnchor.testConstantValue()

        manager.annotations = annotations
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"])
    }

    func testSetToNilFillTranslateAnchor() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate-anchor").value as! String
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"])

        manager.fillTranslateAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.fillTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, defaultValue)
    }

    func testInitialSlot() {
        let initialValue = manager.slot
        XCTAssertNil(initialValue)
    }

    func testSetSlot() {
        let value = UUID().uuidString
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, value)
    }

    func testSlotAnnotationPropertiesAddedWithoutDuplicate() {
        let newSlotProperty = UUID().uuidString
        let secondSlotProperty = UUID().uuidString

        manager.slot = newSlotProperty
        $displayLink.send()
        manager.slot = secondSlotProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, secondSlotProperty)
    }

    func testNewSlotPropertyMergedWithAnnotationProperties() {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
            annotation.fillSortKey = 0.0
            annotation.fillColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillOpacity = 0.5
            annotation.fillOutlineColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.fillPattern = UUID().uuidString
            annotations.append(annotation)
        }
        let newSlotProperty = UUID().uuidString

        manager.annotations = annotations
        manager.slot = newSlotProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"])
    }

    func testSetToNilSlot() {
        let newSlotProperty = UUID().uuidString
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "slot").value as! String
        manager.slot = newSlotProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"])

        manager.slot = nil
        $displayLink.send()
        XCTAssertNil(manager.slot)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, defaultValue)
    }

    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        self.delegateAnnotations = annotations
        expectation?.fulfill()
        expectation = nil
    }

    func testGetAnnotations() {
        let annotations = Array.random(withLength: 10) {
            PolygonAnnotation(
                polygon: .init(outerRing: Ring(coordinates: .random(withLength: 5, generator: { CLLocationCoordinate2D(latitude: 0, longitude: 0) }))),
                isSelected: false,
                isDraggable: true)
        }
        manager.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        _ = manager.handleDragBegin(with: annotationToDrag.id, context: .zero)
        XCTAssertTrue(manager.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        manager.annotations = [
            PolygonAnnotation(id: "polygon1", polygon: .init([[
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]]), isSelected: false, isDraggable: false)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        _ = manager.handleDragBegin(with: "polygon1", context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
    }
    func testHandleDragBeginInvalidFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        _ = manager.handleDragBegin(with: "not-a-feature", context: .zero)

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addPersistentLayerStub.invocations.isEmpty)
    }

    func testDrag() throws {
        let annotation = PolygonAnnotation(id: "polygon1", polygon: .init([[
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]]), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        _ = manager.handleDragBegin(with: "polygon1", context: .zero)

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? FillLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(manager.id))
        XCTAssertEqual(addedLayer.id, manager.id + "_drag")

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, "\(manager.id)_drag")

        _ = manager.handleDragBegin(with: "polygon1", context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .init(latitude: 0, longitude: 0)
        mapboxMap.cameraState.zoom = 1

        manager.handleDragChange(with: .zero, context: .zero)

        $displayLink.send()

        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.source.id)
        if case .featureCollection(let collection) = updateSourceParameters.geojson {
            XCTAssertTrue(collection.features.contains(where: { $0.identifier?.rawValue as? String == annotation.id }))
        } else {
            XCTFail("GeoJSONObject should be a feature collection")
        }
    }

    func testDragHandlers() throws {
        struct GestureData {
            var annotation: PolygonAnnotation
            var context: MapContentGestureContext
        }

        let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.isDraggable = true

        let beginDragStub = Stub<GestureData, Bool>(defaultReturnValue: false)
        let changeDragStub = Stub<GestureData, Void>()
        let endDragStub = Stub<GestureData, Void>()
        annotation.dragBeginHandler = { annotation, context in
            beginDragStub.call(with: GestureData(annotation: annotation, context: context))
        }
        annotation.dragChangeHandler = { annotation, context in
            changeDragStub.call(with: GestureData(annotation: annotation, context: context))
        }
        annotation.dragEndHandler = { annotation, context in
            endDragStub.call(with: GestureData(annotation: annotation, context: context))
        }
        manager.annotations = [annotation]

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .init(latitude: 23.5432356, longitude: -12.5326744)
        mapboxMap.cameraState.zoom = 1

        var context = MapContentGestureContext(point: CGPoint(x: 0, y: 1), coordinate: .init(latitude: 2, longitude: 3))

        // test it twice to cover the case when annotation was already on drag layer.
        for _ in 0...1 {
            beginDragStub.reset()
            changeDragStub.reset()
            endDragStub.reset()

            // skipped gesture
            beginDragStub.defaultReturnValue = false
            var res = manager.handleDragBegin(with: annotation.id, context: context)
            XCTAssertEqual(beginDragStub.invocations.count, 1)
            XCTAssertEqual(res, false)
            var data = try XCTUnwrap(beginDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            manager.handleDragChange(with: CGPoint(x: 10, y: 20), context: context)
            manager.handleDragEnd(context: context)
            XCTAssertEqual(changeDragStub.invocations.count, 0)
            XCTAssertEqual(endDragStub.invocations.count, 0)

            // handled gesture
            context.point.x += 1
            context.coordinate.latitude += 1
            beginDragStub.defaultReturnValue = true
            res = manager.handleDragBegin(with: annotation.id, context: context)
            XCTAssertEqual(beginDragStub.invocations.count, 2)
            XCTAssertEqual(res, true)
            data = try XCTUnwrap(beginDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            context.point.x += 1
            context.coordinate.latitude += 1
            manager.handleDragChange(with: CGPoint(x: 10, y: 20), context: context)
            XCTAssertEqual(changeDragStub.invocations.count, 1)
            data = try XCTUnwrap(changeDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            context.point.x += 1
            context.coordinate.latitude += 1
            manager.handleDragEnd(context: context)
            XCTAssertEqual(endDragStub.invocations.count, 1)
            data = try XCTUnwrap(endDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)
        }
    }

    func testDoesNotUpdateDragSourceWhenNoDragged() {
        let annotation = PolygonAnnotation(id: "polygon1", polygon: .init([[
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]]), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testRemovingDuplicatedAnnotations() {
      let polygonCoords1 = [
                CLLocationCoordinate2DMake(25.51713945052515, -88.857177734375),
                CLLocationCoordinate2DMake(25.51713945052515, -86.967529296875),
                CLLocationCoordinate2DMake(27.244156283890756, -86.967529296875),
                CLLocationCoordinate2DMake(27.244156283890756, -88.857177734375),
                CLLocationCoordinate2DMake(25.51713945052515, -88.857177734375)
            ]
            let annotation1 = PolygonAnnotation(id: "A", polygon: .init(outerRing: .init(coordinates: polygonCoords1)), isSelected: false, isDraggable: false)
      let polygonCoords2 = [
                CLLocationCoordinate2DMake(26.51713945052515, -87.857177734375),
                CLLocationCoordinate2DMake(26.51713945052515, -85.967529296875),
                CLLocationCoordinate2DMake(28.244156283890756, -85.967529296875),
                CLLocationCoordinate2DMake(28.244156283890756, -87.857177734375),
                CLLocationCoordinate2DMake(26.51713945052515, -87.857177734375)
            ]
            let annotation2 = PolygonAnnotation(id: "B", polygon: .init(outerRing: .init(coordinates: polygonCoords2)), isSelected: false, isDraggable: false)
      let polygonCoords3 = [
                CLLocationCoordinate2DMake(27.51713945052515, -86.857177734375),
                CLLocationCoordinate2DMake(27.51713945052515, -84.967529296875),
                CLLocationCoordinate2DMake(29.244156283890756, -84.967529296875),
                CLLocationCoordinate2DMake(29.244156283890756, -86.857177734375),
                CLLocationCoordinate2DMake(27.51713945052515, -86.857177734375)
            ]
            let annotation3 = PolygonAnnotation(id: "A", polygon: .init(outerRing: .init(coordinates: polygonCoords3)), isSelected: false, isDraggable: false)
      manager.annotations = [annotation1, annotation2, annotation3]

      XCTAssertEqual(manager.annotations, [
          annotation1,
          annotation2
      ])
    }

    func testSetNewAnnotations() {
      let polygonCoords1 = [
                CLLocationCoordinate2DMake(25.51713945052515, -88.857177734375),
                CLLocationCoordinate2DMake(25.51713945052515, -86.967529296875),
                CLLocationCoordinate2DMake(27.244156283890756, -86.967529296875),
                CLLocationCoordinate2DMake(27.244156283890756, -88.857177734375),
                CLLocationCoordinate2DMake(25.51713945052515, -88.857177734375)
            ]
            let annotation1 = PolygonAnnotation(id: "A", polygon: .init(outerRing: .init(coordinates: polygonCoords1)), isSelected: false, isDraggable: false)
      let polygonCoords2 = [
                CLLocationCoordinate2DMake(26.51713945052515, -87.857177734375),
                CLLocationCoordinate2DMake(26.51713945052515, -85.967529296875),
                CLLocationCoordinate2DMake(28.244156283890756, -85.967529296875),
                CLLocationCoordinate2DMake(28.244156283890756, -87.857177734375),
                CLLocationCoordinate2DMake(26.51713945052515, -87.857177734375)
            ]
            let annotation2 = PolygonAnnotation(id: "B", polygon: .init(outerRing: .init(coordinates: polygonCoords2)), isSelected: false, isDraggable: false)
      let polygonCoords3 = [
                CLLocationCoordinate2DMake(27.51713945052515, -86.857177734375),
                CLLocationCoordinate2DMake(27.51713945052515, -84.967529296875),
                CLLocationCoordinate2DMake(29.244156283890756, -84.967529296875),
                CLLocationCoordinate2DMake(29.244156283890756, -86.857177734375),
                CLLocationCoordinate2DMake(27.51713945052515, -86.857177734375)
            ]
            let annotation3 = PolygonAnnotation(id: "C", polygon: .init(outerRing: .init(coordinates: polygonCoords3)), isSelected: false, isDraggable: false)

        manager.set(newAnnotations: [
            (1, annotation1),
            (2, annotation2)
        ])

        XCTAssertEqual(manager.annotations.map(\.id), ["A", "B"])

        manager.set(newAnnotations: [
            (1, annotation3),
            (2, annotation2)
        ])

        XCTAssertEqual(manager.annotations.map(\.id), ["A", "B"])

        manager.set(newAnnotations: [
            (3, annotation3),
            (2, annotation2)
        ])

        XCTAssertEqual(manager.annotations.map(\.id), ["C", "B"])
    }
}

// End of generated file
