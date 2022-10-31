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
    let offsetPolygonCalculator: OffsetPolygonCalculator

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        manager = PolygonAnnotationManager(id: id,
                                          style: style,
                                          layerPosition: nil,
                                          displayLinkCoordinator: displayLinkCoordinator,
                                          offsetPolygonCalculator: OffsetPolygonCalculator) {
)

        for _ in 0...10 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
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

        _ = PolygonAnnotationManager(id: id,
                                 style: style,
                                 layerPosition: nil,
                                 displayLinkCoordinator: displayLinkCoordinator)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        style.addSourceStub.reset()
        let initializedManager = PolygonAnnotationManager(id: id,
                                                         style: style,
                                                         layerPosition: nil,
                                                         displayLinkCoordinator: displayLinkCoordinator,
                                                         offsetPolygonCalculator: OffsetPolygonCalculator) {
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
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = PolygonAnnotationManager(id: manager.id,
                                               style: style,
                                               layerPosition: nil,
                                               displayLinkCoordinator: displayLinkCoordinator,
                                               offsetPolygonCalculator: OffsetPolygonCalculator) {
)
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = PolygonAnnotationManager(id: id,
                                               style: style,
                                               layerPosition: LayerPosition.at(4),
                                               displayLinkCoordinator: displayLinkCoordinator,
                                               offsetPolygonCalculator: OffsetPolygonCalculator) {
)
        manager3.annotations = annotations

        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroyManager() {
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.count, 1)
        XCTAssertEqual(style.removeLayerStub.invocations.last?.parameters, manager.id)
        XCTAssertEqual(style.removeSourceStub.invocations.count, 1)
        XCTAssertEqual(style.removeSourceStub.invocations.last?.parameters, manager.id)
    }

    func testDestroyManagerTwice() {
        manager.destroy()
        manager.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.count, 1)
        XCTAssertEqual(style.removeSourceStub.invocations.count, 1)
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

    func testfeatureCollectionPassedtoGeoJSON() {
        var annotations = [PolygonAnnotation]()
        for _ in 0...5 {
            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
            annotations.append(annotation)
        }
        let featureCollection = FeatureCollection(features: annotations.map(\.feature))

        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, manager.id)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.geojson, .featureCollection(featureCollection))
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
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
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
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
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
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
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
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
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
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))
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

}

// End of generated file
