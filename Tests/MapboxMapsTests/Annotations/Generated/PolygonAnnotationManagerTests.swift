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
        manager.handleDragBegin(with: [annotation.id])

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

    func testHandleQueriedFeatureIdsPassesNotificationToDelegate() throws {
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
        let queriedFeatureIds = [annotations[0].id]
        manager.delegate = self

        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        let result = try XCTUnwrap(delegateAnnotations)
        XCTAssertEqual(result[0].id, annotations[0].id)
    }

    func testHandleQueriedFeatureIdsDoesNotPassNotificationToDelegateWhenNoMatch() throws {
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
        let queriedFeatureIds = ["NotAnAnnotationID"]
        manager.delegate = self

        expectation?.isInverted = true
        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        XCTAssertNil(delegateAnnotations)
    }

    func testInitialFillAntialias() {
        let initialValue = manager.fillAntialias
        XCTAssertNil(initialValue)
    }

    func testSetFillAntialias() {
        let value = Bool.random()
        manager.fillAntialias = value
        XCTAssertEqual(manager.fillAntialias, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, value)
    }

    func testFillAntialiasAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillAntialiasProperty = Bool.random()
        let secondFillAntialiasProperty = Bool.random()

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
            annotation.fillSortKey = Double.random(in: -100000...100000)
            annotation.fillColor = StyleColor.random()
            annotation.fillOpacity = Double.random(in: 0...1)
            annotation.fillOutlineColor = StyleColor.random()
            annotation.fillPattern = String.randomASCII(withLength: .random(in: 0...100))
            annotations.append(annotation)
        }
        let newFillAntialiasProperty = Bool.random()

        manager.annotations = annotations
        manager.fillAntialias = newFillAntialiasProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"])
    }

    func testSetToNilFillAntialias() {
        let newFillAntialiasProperty = Bool.random()
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
        let value = Double.random(in: 0...100000)
        manager.fillEmissiveStrength = value
        XCTAssertEqual(manager.fillEmissiveStrength, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"] as! Double, value)
    }

    func testFillEmissiveStrengthAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillEmissiveStrengthProperty = Double.random(in: 0...100000)
        let secondFillEmissiveStrengthProperty = Double.random(in: 0...100000)

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
            annotation.fillSortKey = Double.random(in: -100000...100000)
            annotation.fillColor = StyleColor.random()
            annotation.fillOpacity = Double.random(in: 0...1)
            annotation.fillOutlineColor = StyleColor.random()
            annotation.fillPattern = String.randomASCII(withLength: .random(in: 0...100))
            annotations.append(annotation)
        }
        let newFillEmissiveStrengthProperty = Double.random(in: 0...100000)

        manager.annotations = annotations
        manager.fillEmissiveStrength = newFillEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-emissive-strength"])
    }

    func testSetToNilFillEmissiveStrength() {
        let newFillEmissiveStrengthProperty = Double.random(in: 0...100000)
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
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.fillTranslate = value
        XCTAssertEqual(manager.fillTranslate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], value)
    }

    func testFillTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

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
            annotation.fillSortKey = Double.random(in: -100000...100000)
            annotation.fillColor = StyleColor.random()
            annotation.fillOpacity = Double.random(in: 0...1)
            annotation.fillOutlineColor = StyleColor.random()
            annotation.fillPattern = String.randomASCII(withLength: .random(in: 0...100))
            annotations.append(annotation)
        }
        let newFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.fillTranslate = newFillTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"])
    }

    func testSetToNilFillTranslate() {
        let newFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
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
        let value = FillTranslateAnchor.random()
        manager.fillTranslateAnchor = value
        XCTAssertEqual(manager.fillTranslateAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, value.rawValue)
    }

    func testFillTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.random()
        let secondFillTranslateAnchorProperty = FillTranslateAnchor.random()

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
            annotation.fillSortKey = Double.random(in: -100000...100000)
            annotation.fillColor = StyleColor.random()
            annotation.fillOpacity = Double.random(in: 0...1)
            annotation.fillOutlineColor = StyleColor.random()
            annotation.fillPattern = String.randomASCII(withLength: .random(in: 0...100))
            annotations.append(annotation)
        }
        let newFillTranslateAnchorProperty = FillTranslateAnchor.random()

        manager.annotations = annotations
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"])
    }

    func testSetToNilFillTranslateAnchor() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .fill, property: "fill-translate-anchor").value as! String
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"])

        manager.fillTranslateAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.fillTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, defaultValue)
    }

    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        self.delegateAnnotations = annotations
        expectation?.fulfill()
        expectation = nil
    }


    func testGetAnnotations() {
        let annotations = Array.random(withLength: 10) {
            PolygonAnnotation(
                polygon: .init(outerRing: Ring(coordinates: .random(withLength: 5, generator: LocationCoordinate2D.random))),
                isSelected: false,
                isDraggable: true)
        }
        manager.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        manager.handleDragBegin(with: [annotationToDrag.id])
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

        manager.handleDragBegin(with: ["polygon1"])

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
    }

    func testHandleDragBeginNoFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        manager.handleDragBegin(with: [])

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addPersistentLayerStub.invocations.isEmpty)
    }

    func testHandleDragBeginInvalidFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        manager.handleDragBegin(with: ["not-a-feature"])

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

        manager.handleDragBegin(with: ["polygon1"])

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? FillLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(manager.id))
        XCTAssertEqual(addedLayer.id, manager.id + "_drag")

        manager.handleDragBegin(with: ["polygon1"])

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .random()
        mapboxMap.cameraState.zoom = 1

        manager.handleDragChanged(with: .random())

        $displayLink.send()

        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.source.id)
        if case .featureCollection(let collection) = updateSourceParameters.geojson {
            XCTAssertTrue(collection.features.contains(where: { $0.identifier?.rawValue as? String == annotation.id }))
        } else {
            XCTFail("GeoJSONObject should be a feature collection")
        }
    }
}

// End of generated file
