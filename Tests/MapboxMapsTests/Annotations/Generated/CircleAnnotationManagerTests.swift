// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: CircleAnnotationManager!
    var style: MockStyle!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var id = UUID().uuidString
    var annotations = [CircleAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        manager = CircleAnnotationManager(id: id,
                                          style: style,
                                          layerPosition: nil,
                                          displayLinkCoordinator: displayLinkCoordinator)

        for _ in 0...10 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
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

        _ = CircleAnnotationManager(id: id,
                                 style: style,
                                 layerPosition: nil,
                                 displayLinkCoordinator: displayLinkCoordinator)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.id, manager.id)
    }

    func testAddLayer() {
        style.addSourceStub.reset()
        let initializedManager = CircleAnnotationManager(id: id,
                                                         style: style,
                                                         layerPosition: nil,
                                                         displayLinkCoordinator: displayLinkCoordinator)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.circle)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        var annotations2 = [CircleAnnotation]()
        for _ in 0...50 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = CircleAnnotationManager(id: manager.id,
                                               style: style,
                                               layerPosition: nil,
                                               displayLinkCoordinator: displayLinkCoordinator)
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = CircleAnnotationManager(id: id,
                                               style: style,
                                               layerPosition: LayerPosition.at(4),
                                               displayLinkCoordinator: displayLinkCoordinator)
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
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
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
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
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
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotations.append(annotation)
        }
        let queriedFeatureIds = ["NotAnAnnotationID"]
        manager.delegate = self

        expectation?.isInverted = true
        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        XCTAssertNil(delegateAnnotations)
    }

    func testInitialCirclePitchAlignment() {
        let initialValue = manager.circlePitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchAlignment() {
        let value = CirclePitchAlignment.allCases.randomElement()!
        manager.circlePitchAlignment = value
        XCTAssertEqual(manager.circlePitchAlignment, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, value.rawValue)
    }

    func testCirclePitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.allCases.randomElement()!
        let secondCirclePitchAlignmentProperty = CirclePitchAlignment.allCases.randomElement()!

        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circlePitchAlignment = secondCirclePitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, secondCirclePitchAlignmentProperty.rawValue)
    }

    func testNewCirclePitchAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.circleSortKey = Double.random(in: -100000...100000)
            annotation.circleBlur = Double.random(in: -100000...100000)
            annotation.circleColor = StyleColor.random()
            annotation.circleOpacity = Double.random(in: 0...1)
            annotation.circleRadius = Double.random(in: 0...100000)
            annotation.circleStrokeColor = StyleColor.random()
            annotation.circleStrokeOpacity = Double.random(in: 0...1)
            annotation.circleStrokeWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.allCases.randomElement()!

        manager.annotations = annotations
        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"])
    }

    func testSetToNilCirclePitchAlignment() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-alignment").value as! String
        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"])

        manager.circlePitchAlignment = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.circlePitchAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, defaultValue)
    }

    func testInitialCirclePitchScale() {
        let initialValue = manager.circlePitchScale
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchScale() {
        let value = CirclePitchScale.allCases.randomElement()!
        manager.circlePitchScale = value
        XCTAssertEqual(manager.circlePitchScale, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, value.rawValue)
    }

    func testCirclePitchScaleAnnotationPropertiesAddedWithoutDuplicate() {
        let newCirclePitchScaleProperty = CirclePitchScale.allCases.randomElement()!
        let secondCirclePitchScaleProperty = CirclePitchScale.allCases.randomElement()!

        manager.circlePitchScale = newCirclePitchScaleProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circlePitchScale = secondCirclePitchScaleProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, secondCirclePitchScaleProperty.rawValue)
    }

    func testNewCirclePitchScalePropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.circleSortKey = Double.random(in: -100000...100000)
            annotation.circleBlur = Double.random(in: -100000...100000)
            annotation.circleColor = StyleColor.random()
            annotation.circleOpacity = Double.random(in: 0...1)
            annotation.circleRadius = Double.random(in: 0...100000)
            annotation.circleStrokeColor = StyleColor.random()
            annotation.circleStrokeOpacity = Double.random(in: 0...1)
            annotation.circleStrokeWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newCirclePitchScaleProperty = CirclePitchScale.allCases.randomElement()!

        manager.annotations = annotations
        manager.circlePitchScale = newCirclePitchScaleProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"])
    }

    func testSetToNilCirclePitchScale() {
        let newCirclePitchScaleProperty = CirclePitchScale.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-scale").value as! String
        manager.circlePitchScale = newCirclePitchScaleProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"])

        manager.circlePitchScale = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.circlePitchScale)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, defaultValue)
    }

    func testInitialCircleTranslate() {
        let initialValue = manager.circleTranslate
        XCTAssertNil(initialValue)
    }

    func testSetCircleTranslate() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.circleTranslate = value
        XCTAssertEqual(manager.circleTranslate, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], value)
    }

    func testCircleTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondCircleTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circleTranslate = secondCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], secondCircleTranslateProperty)
    }

    func testNewCircleTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.circleSortKey = Double.random(in: -100000...100000)
            annotation.circleBlur = Double.random(in: -100000...100000)
            annotation.circleColor = StyleColor.random()
            annotation.circleOpacity = Double.random(in: 0...1)
            annotation.circleRadius = Double.random(in: 0...100000)
            annotation.circleStrokeColor = StyleColor.random()
            annotation.circleStrokeOpacity = Double.random(in: 0...1)
            annotation.circleStrokeWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newCircleTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"])
    }

    func testSetToNilCircleTranslate() {
        let newCircleTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = Style.layerPropertyDefaultValue(for: .circle, property: "circle-translate").value as! [Double]
        manager.circleTranslate = newCircleTranslateProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"])

        manager.circleTranslate = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.circleTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], defaultValue)
    }

    func testInitialCircleTranslateAnchor() {
        let initialValue = manager.circleTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetCircleTranslateAnchor() {
        let value = CircleTranslateAnchor.allCases.randomElement()!
        manager.circleTranslateAnchor = value
        XCTAssertEqual(manager.circleTranslateAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, value.rawValue)
    }

    func testCircleTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.allCases.randomElement()!
        let secondCircleTranslateAnchorProperty = CircleTranslateAnchor.allCases.randomElement()!

        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circleTranslateAnchor = secondCircleTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, secondCircleTranslateAnchorProperty.rawValue)
    }

    func testNewCircleTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            annotation.circleSortKey = Double.random(in: -100000...100000)
            annotation.circleBlur = Double.random(in: -100000...100000)
            annotation.circleColor = StyleColor.random()
            annotation.circleOpacity = Double.random(in: 0...1)
            annotation.circleRadius = Double.random(in: 0...100000)
            annotation.circleStrokeColor = StyleColor.random()
            annotation.circleStrokeOpacity = Double.random(in: 0...1)
            annotation.circleStrokeWidth = Double.random(in: 0...100000)
            annotations.append(annotation)
        }
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.allCases.randomElement()!

        manager.annotations = annotations
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"])
    }

    func testSetToNilCircleTranslateAnchor() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.allCases.randomElement()!
        let defaultValue = Style.layerPropertyDefaultValue(for: .circle, property: "circle-translate-anchor").value as! String
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"])

        manager.circleTranslateAnchor = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.circleTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, defaultValue)
    }

    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        self.delegateAnnotations = annotations
        expectation?.fulfill()
        expectation = nil
    }

}

// End of generated file
