// This file is generated
import XCTest
@testable import MapboxMaps

final class PolygonAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PolygonAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [PolygonAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var offsetPolygonCalculator: OffsetPolygonCalculator!

    var mapboxMap = MockMapboxMap()

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: mapboxMap)
        manager = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator
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
        displayLinkCoordinator = nil
        manager = nil
        expectation = nil
        delegateAnnotations = nil

        super.tearDown()
    }

    func testSourceSetup() {
        style.addSourceStub.reset()

        _ = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        style.addSourceStub.reset()
        let initializedManager = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.fill)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.source, initializedManager.sourceId)
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
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator
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
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator
        )
        manager3.annotations = annotations

        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroyManager() {
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id + "_drag-layer", id])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id + "_drag-source", id])
    }

    func testDestroyManagerTwice() {
        manager.destroy()
        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), [id + "_drag-layer", id])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id + "_drag-source", id])
        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        manager.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testSyncSourceAndLayer() {
        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testManagerSubscribestoDisplayLinkCoordinator() {
        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 1)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 0)
    }

    func testDestroyManagerRemovesDisplayLinkParticipant() {
        manager.destroy()

        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 1)
    }

    func testFeatureCollectionPassedtoGeoJSON() {
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
        let expectedFeatureCollection = FeatureCollection(features: annotations.map(\.feature))

        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, manager.id)
        if case .featureCollection(let collection) = style.updateGeoJSONSourceStub.invocations[0].parameters.geojson {
            XCTAssertTrue(collection.features.allSatisfy(expectedFeatureCollection.features.contains(_:)))
        } else {
            XCTFail("GeoJSON object should be a feature collection")
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
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, value)
    }

    func testFillAntialiasAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillAntialiasProperty = Bool.random()
        let secondFillAntialiasProperty = Bool.random()

        manager.fillAntialias = newFillAntialiasProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.fillAntialias = secondFillAntialiasProperty
        manager.syncSourceAndLayerIfNeeded()

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
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"])
    }

    func testSetToNilFillAntialias() {
        let newFillAntialiasProperty = Bool.random()
        let defaultValue = Style.layerPropertyDefaultValue(for: .fill, property: "fill-antialias").value as! Bool
        manager.fillAntialias = newFillAntialiasProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"])

        manager.fillAntialias = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.fillAntialias)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-antialias"] as! Bool, defaultValue)
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
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], value)
    }

    func testFillTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.fillTranslate = newFillTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.fillTranslate = secondFillTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

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
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"])
    }

    func testSetToNilFillTranslate() {
        let newFillTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = Style.layerPropertyDefaultValue(for: .fill, property: "fill-translate").value as! [Double]
        manager.fillTranslate = newFillTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"])

        manager.fillTranslate = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.fillTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate"] as! [Double], defaultValue)
    }

    func testInitialFillTranslateAnchor() {
        let initialValue = manager.fillTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetFillTranslateAnchor() {
        let value = FillTranslateAnchor.allCases.randomElement()!
        manager.fillTranslateAnchor = value
        XCTAssertEqual(manager.fillTranslateAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"] as! String, value.rawValue)
    }

    func testFillTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.allCases.randomElement()!
        let secondFillTranslateAnchorProperty = FillTranslateAnchor.allCases.randomElement()!

        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.fillTranslateAnchor = secondFillTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

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
        let newFillTranslateAnchorProperty = FillTranslateAnchor.allCases.randomElement()!

        manager.annotations = annotations
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"])
    }

    func testSetToNilFillTranslateAnchor() {
        let newFillTranslateAnchorProperty = FillTranslateAnchor.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .fill, property: "fill-translate-anchor").value as! String
        manager.fillTranslateAnchor = newFillTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["fill-translate-anchor"])

        manager.fillTranslateAnchor = nil
        manager.syncSourceAndLayerIfNeeded()
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
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["polygon1"])

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testHandleDragBeginNoFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: [])

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)
    }

    func testHandleDragBeginInvalidFeatureId() {
        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["not-a-feature"])

        XCTAssertTrue(style.addSourceStub.invocations.isEmpty)
        XCTAssertTrue(style.addPersistentLayerWithPropertiesStub.invocations.isEmpty)
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)
    }

    func testHandleDragBegin() throws {
        manager.annotations = [
            PolygonAnnotation(id: "polygon1", polygon: .init([[
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]]), isSelected: false, isDraggable: true)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerWithPropertiesStub.reset()

        manager.handleDragBegin(with: ["polygon1"])

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.last).parameters
        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters

        XCTAssertEqual(addLayerParameters.properties["source"] as? String, addSourceParameters.id)
        XCTAssertNotEqual(addLayerParameters.properties["id"] as? String, manager.layerId)

        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.id)
    }

    func testHandleDragChanged() throws {
        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .random()
        mapboxMap.cameraState.zoom = 1

        let annotation = PolygonAnnotation(
            id: "polygon1", 
            polygon: .init([[
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]]), 
            isSelected: false, 
            isDraggable: true)
        manager.annotations = [annotation]

        manager.handleDragChanged(with: .random())
        XCTAssertTrue(style.updateGeoJSONSourceStub.invocations.isEmpty)

        manager.handleDragBegin(with: ["polygon1"])
        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters

        manager.handleDragChanged(with: .random())
        let updateSourceParameters = try XCTUnwrap(style.updateGeoJSONSourceStub.invocations.last).parameters
        XCTAssertTrue(updateSourceParameters.id == addSourceParameters.id)
        if case .featureCollection(let collection) = updateSourceParameters.geojson {
            XCTAssertTrue(collection.features.contains(where: { $0.identifier?.rawValue as? String == annotation.id }))
        } else {
            XCTFail("GeoJSONObject should be a feature collection")
        }
    }
}

// End of generated file
