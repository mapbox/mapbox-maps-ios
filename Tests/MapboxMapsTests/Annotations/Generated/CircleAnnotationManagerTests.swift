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
    var offsetCalculator: OffsetPointCalculator!
    var mapboxMap: MockMapboxMap!

    override func setUp() {
        super.setUp()

        style = MockStyle()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        mapboxMap = MockMapboxMap()
        offsetCalculator = OffsetPointCalculator(mapboxMap: mapboxMap)
        manager = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetCalculator: offsetCalculator
        )

        for _ in 0...10 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        style = nil
        displayLinkCoordinator = nil
        expectation = nil
        delegateAnnotations = nil
        mapboxMap = nil
        offsetCalculator = nil
        manager = nil

        super.tearDown()
    }

    func testSourceSetup() {
        style.addSourceStub.reset()

        _ = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.id, manager.id)
    }

    func testAddLayer() throws {
        style.addSourceStub.reset()
        let initializedManager = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.circle)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        let addedLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.last?.parameters.layer as? CircleLayer)
        XCTAssertEqual(addedLayer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        var annotations2 = [CircleAnnotation]()
        for _ in 0...50 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = CircleAnnotationManager(
            id: manager.id,
            style: style,
            layerPosition: nil,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetCalculator: offsetCalculator
        )
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: LayerPosition.at(4),
            displayLinkCoordinator: displayLinkCoordinator,
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
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testManagerSubscribestoDisplayLinkCoordinator() {
        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 1)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 0)
    }

    func testDestroyManagerRemovesDisplayLinkParticipant() {
        manager.destroy()

        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 1)
    }

    func testFeatureCollectionPassedtoGeoJSON() throws {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let expectedFeatures = annotations.map(\.feature)

        manager.annotations = annotations
        manager.syncSourceAndLayerIfNeeded()

        var invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
        XCTAssertEqual(invocation.parameters.features, expectedFeatures)
        XCTAssertEqual(invocation.parameters.sourceId, manager.id)

        do {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)

            manager.annotations = annotations
            manager.syncSourceAndLayerIfNeeded()

            invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
            XCTAssertEqual(invocation.parameters.features, [annotation].map(\.feature))
            XCTAssertEqual(invocation.parameters.sourceId, manager.id)
        }
    }

    func testHandleQueriedFeatureIdsPassesNotificationToDelegate() throws {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let queriedFeatureIds = ["NotAnAnnotationID"]
        manager.delegate = self

        expectation?.isInverted = true
        manager.annotations = annotations
        manager.handleQueriedFeatureIds(queriedFeatureIds)

        XCTAssertNil(delegateAnnotations)
    }

    func testInitialCircleEmissiveStrength() {
        let initialValue = manager.circleEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetCircleEmissiveStrength() {
        let value = Double.random(in: 0...100000)
        manager.circleEmissiveStrength = value
        XCTAssertEqual(manager.circleEmissiveStrength, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, value)
    }

    func testCircleEmissiveStrengthAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleEmissiveStrengthProperty = Double.random(in: 0...100000)
        let secondCircleEmissiveStrengthProperty = Double.random(in: 0...100000)

        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        manager.syncSourceAndLayerIfNeeded()
        manager.circleEmissiveStrength = secondCircleEmissiveStrengthProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, secondCircleEmissiveStrengthProperty)
    }

    func testNewCircleEmissiveStrengthPropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        let newCircleEmissiveStrengthProperty = Double.random(in: 0...100000)

        manager.annotations = annotations
        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"])
    }

    func testSetToNilCircleEmissiveStrength() {
        let newCircleEmissiveStrengthProperty = Double.random(in: 0...100000)
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-emissive-strength").value as! Double
        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"])

        manager.circleEmissiveStrength = nil
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertNil(manager.circleEmissiveStrength)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, defaultValue)
    }

    func testInitialCirclePitchAlignment() {
        let initialValue = manager.circlePitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchAlignment() {
        let value = CirclePitchAlignment.random()
        manager.circlePitchAlignment = value
        XCTAssertEqual(manager.circlePitchAlignment, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, value.rawValue)
    }

    func testCirclePitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.random()
        let secondCirclePitchAlignmentProperty = CirclePitchAlignment.random()

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
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.random()

        manager.annotations = annotations
        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"])
    }

    func testSetToNilCirclePitchAlignment() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-alignment").value as! String
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
        let value = CirclePitchScale.random()
        manager.circlePitchScale = value
        XCTAssertEqual(manager.circlePitchScale, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, value.rawValue)
    }

    func testCirclePitchScaleAnnotationPropertiesAddedWithoutDuplicate() {
        let newCirclePitchScaleProperty = CirclePitchScale.random()
        let secondCirclePitchScaleProperty = CirclePitchScale.random()

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
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        let newCirclePitchScaleProperty = CirclePitchScale.random()

        manager.annotations = annotations
        manager.circlePitchScale = newCirclePitchScaleProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"])
    }

    func testSetToNilCirclePitchScale() {
        let newCirclePitchScaleProperty = CirclePitchScale.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-scale").value as! String
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
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate").value as! [Double]
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
        let value = CircleTranslateAnchor.random()
        manager.circleTranslateAnchor = value
        XCTAssertEqual(manager.circleTranslateAnchor, value)

        // test layer and source synced and properties added
        manager.syncSourceAndLayerIfNeeded()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, value.rawValue)
    }

    func testCircleTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.random()
        let secondCircleTranslateAnchorProperty = CircleTranslateAnchor.random()

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
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.random()

        manager.annotations = annotations
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        manager.syncSourceAndLayerIfNeeded()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"])
    }

    func testSetToNilCircleTranslateAnchor() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate-anchor").value as! String
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


    func testGetAnnotations() {
        let annotations = Array.random(withLength: 10) {
            CircleAnnotation(centerCoordinate: .random(), isSelected: false, isDraggable: true)
        }
        manager.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        manager.handleDragBegin(with: [annotationToDrag.id])
        XCTAssertTrue(manager.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        manager.annotations = [
            CircleAnnotation(id: "circle1", centerCoordinate: .random(), isSelected: false, isDraggable: false)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        manager.handleDragBegin(with: ["circle1"])

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
        let annotation = CircleAnnotation(id: "circle1", centerCoordinate: .random(), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        manager.handleDragBegin(with: ["circle1"])

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? CircleLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(manager.id))
        XCTAssertEqual(addedLayer.id, manager.id + "_drag")

        manager.handleDragBegin(with: ["circle1"])

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .random()
        mapboxMap.cameraState.zoom = 1

        manager.handleDragChanged(with: .random())

        manager.syncSourceAndLayerIfNeeded()

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
