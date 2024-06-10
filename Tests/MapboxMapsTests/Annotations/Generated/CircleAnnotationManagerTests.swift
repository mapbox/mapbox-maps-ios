// This file is generated
import XCTest
@testable import MapboxMaps

final class CircleAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: CircleAnnotationManager!
    var style: MockStyle!
    var id = UUID().uuidString
    var annotations = [CircleAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var offsetCalculator: OffsetPointCalculator!
    var mapboxMap: MockMapboxMap!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()

        style = MockStyle()
        mapboxMap = MockMapboxMap()
        offsetCalculator = OffsetPointCalculator(mapboxMap: mapboxMap)
        manager = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            offsetCalculator: offsetCalculator
        )

        for _ in 0...10 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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

        _ = CircleAnnotationManager(
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
        let initializedManager = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
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
            displayLink: displayLink,
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
        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let expectedFeatures = annotations.map(\.feature)

        manager.annotations = annotations
        $displayLink.send()

        var invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
        XCTAssertEqual(invocation.parameters.features, expectedFeatures)
        XCTAssertEqual(invocation.parameters.sourceId, manager.id)

        do {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            let annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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

    func testInitialCircleEmissiveStrength() {
        let initialValue = manager.circleEmissiveStrength
        XCTAssertNil(initialValue)
    }

    func testSetCircleEmissiveStrength() {
        let value = 50000.0
        manager.circleEmissiveStrength = value
        XCTAssertEqual(manager.circleEmissiveStrength, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, value)
    }

    func testCircleEmissiveStrengthAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleEmissiveStrengthProperty = 50000.0
        let secondCircleEmissiveStrengthProperty = 50000.0

        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        $displayLink.send()
        manager.circleEmissiveStrength = secondCircleEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, secondCircleEmissiveStrengthProperty)
    }

    func testNewCircleEmissiveStrengthPropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.circleSortKey = 0.0
            annotation.circleBlur = 0.0
            annotation.circleColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleOpacity = 0.5
            annotation.circleRadius = 50000.0
            annotation.circleStrokeColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleStrokeOpacity = 0.5
            annotation.circleStrokeWidth = 50000.0
            annotations.append(annotation)
        }
        let newCircleEmissiveStrengthProperty = 50000.0

        manager.annotations = annotations
        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"])
    }

    func testSetToNilCircleEmissiveStrength() {
        let newCircleEmissiveStrengthProperty = 50000.0
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-emissive-strength").value as! Double
        manager.circleEmissiveStrength = newCircleEmissiveStrengthProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"])

        manager.circleEmissiveStrength = nil
        $displayLink.send()
        XCTAssertNil(manager.circleEmissiveStrength)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-emissive-strength"] as! Double, defaultValue)
    }

    func testInitialCirclePitchAlignment() {
        let initialValue = manager.circlePitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchAlignment() {
        let value = CirclePitchAlignment.testConstantValue()
        manager.circlePitchAlignment = value
        XCTAssertEqual(manager.circlePitchAlignment, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, value.rawValue)
    }

    func testCirclePitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.testConstantValue()
        let secondCirclePitchAlignmentProperty = CirclePitchAlignment.testConstantValue()

        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        $displayLink.send()
        manager.circlePitchAlignment = secondCirclePitchAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, secondCirclePitchAlignmentProperty.rawValue)
    }

    func testNewCirclePitchAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.circleSortKey = 0.0
            annotation.circleBlur = 0.0
            annotation.circleColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleOpacity = 0.5
            annotation.circleRadius = 50000.0
            annotation.circleStrokeColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleStrokeOpacity = 0.5
            annotation.circleStrokeWidth = 50000.0
            annotations.append(annotation)
        }
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.testConstantValue()

        manager.annotations = annotations
        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"])
    }

    func testSetToNilCirclePitchAlignment() {
        let newCirclePitchAlignmentProperty = CirclePitchAlignment.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-alignment").value as! String
        manager.circlePitchAlignment = newCirclePitchAlignmentProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"])

        manager.circlePitchAlignment = nil
        $displayLink.send()
        XCTAssertNil(manager.circlePitchAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-alignment"] as! String, defaultValue)
    }

    func testInitialCirclePitchScale() {
        let initialValue = manager.circlePitchScale
        XCTAssertNil(initialValue)
    }

    func testSetCirclePitchScale() {
        let value = CirclePitchScale.testConstantValue()
        manager.circlePitchScale = value
        XCTAssertEqual(manager.circlePitchScale, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, value.rawValue)
    }

    func testCirclePitchScaleAnnotationPropertiesAddedWithoutDuplicate() {
        let newCirclePitchScaleProperty = CirclePitchScale.testConstantValue()
        let secondCirclePitchScaleProperty = CirclePitchScale.testConstantValue()

        manager.circlePitchScale = newCirclePitchScaleProperty
        $displayLink.send()
        manager.circlePitchScale = secondCirclePitchScaleProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, secondCirclePitchScaleProperty.rawValue)
    }

    func testNewCirclePitchScalePropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.circleSortKey = 0.0
            annotation.circleBlur = 0.0
            annotation.circleColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleOpacity = 0.5
            annotation.circleRadius = 50000.0
            annotation.circleStrokeColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleStrokeOpacity = 0.5
            annotation.circleStrokeWidth = 50000.0
            annotations.append(annotation)
        }
        let newCirclePitchScaleProperty = CirclePitchScale.testConstantValue()

        manager.annotations = annotations
        manager.circlePitchScale = newCirclePitchScaleProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"])
    }

    func testSetToNilCirclePitchScale() {
        let newCirclePitchScaleProperty = CirclePitchScale.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-pitch-scale").value as! String
        manager.circlePitchScale = newCirclePitchScaleProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"])

        manager.circlePitchScale = nil
        $displayLink.send()
        XCTAssertNil(manager.circlePitchScale)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-pitch-scale"] as! String, defaultValue)
    }

    func testInitialCircleTranslate() {
        let initialValue = manager.circleTranslate
        XCTAssertNil(initialValue)
    }

    func testSetCircleTranslate() {
        let value = [0.0, 0.0]
        manager.circleTranslate = value
        XCTAssertEqual(manager.circleTranslate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], value)
    }

    func testCircleTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleTranslateProperty = [0.0, 0.0]
        let secondCircleTranslateProperty = [0.0, 0.0]

        manager.circleTranslate = newCircleTranslateProperty
        $displayLink.send()
        manager.circleTranslate = secondCircleTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], secondCircleTranslateProperty)
    }

    func testNewCircleTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.circleSortKey = 0.0
            annotation.circleBlur = 0.0
            annotation.circleColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleOpacity = 0.5
            annotation.circleRadius = 50000.0
            annotation.circleStrokeColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleStrokeOpacity = 0.5
            annotation.circleStrokeWidth = 50000.0
            annotations.append(annotation)
        }
        let newCircleTranslateProperty = [0.0, 0.0]

        manager.annotations = annotations
        manager.circleTranslate = newCircleTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"])
    }

    func testSetToNilCircleTranslate() {
        let newCircleTranslateProperty = [0.0, 0.0]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate").value as! [Double]
        manager.circleTranslate = newCircleTranslateProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"])

        manager.circleTranslate = nil
        $displayLink.send()
        XCTAssertNil(manager.circleTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate"] as! [Double], defaultValue)
    }

    func testInitialCircleTranslateAnchor() {
        let initialValue = manager.circleTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetCircleTranslateAnchor() {
        let value = CircleTranslateAnchor.testConstantValue()
        manager.circleTranslateAnchor = value
        XCTAssertEqual(manager.circleTranslateAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, value.rawValue)
    }

    func testCircleTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.testConstantValue()
        let secondCircleTranslateAnchorProperty = CircleTranslateAnchor.testConstantValue()

        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        $displayLink.send()
        manager.circleTranslateAnchor = secondCircleTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, secondCircleTranslateAnchorProperty.rawValue)
    }

    func testNewCircleTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.circleSortKey = 0.0
            annotation.circleBlur = 0.0
            annotation.circleColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleOpacity = 0.5
            annotation.circleRadius = 50000.0
            annotation.circleStrokeColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleStrokeOpacity = 0.5
            annotation.circleStrokeWidth = 50000.0
            annotations.append(annotation)
        }
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.testConstantValue()

        manager.annotations = annotations
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"])
    }

    func testSetToNilCircleTranslateAnchor() {
        let newCircleTranslateAnchorProperty = CircleTranslateAnchor.testConstantValue()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "circle-translate-anchor").value as! String
        manager.circleTranslateAnchor = newCircleTranslateAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"])

        manager.circleTranslateAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.circleTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["circle-translate-anchor"] as! String, defaultValue)
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
        var annotations = [CircleAnnotation]()
        for _ in 0...5 {
            var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.circleSortKey = 0.0
            annotation.circleBlur = 0.0
            annotation.circleColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleOpacity = 0.5
            annotation.circleRadius = 50000.0
            annotation.circleStrokeColor = StyleColor(red: 255, green: 0, blue: 255)
            annotation.circleStrokeOpacity = 0.5
            annotation.circleStrokeWidth = 50000.0
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
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .circle, property: "slot").value as! String
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
            CircleAnnotation(centerCoordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: true)
        }
        manager.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        _ = manager.handleDragBegin(with: annotationToDrag.id, context: .zero)
        XCTAssertTrue(manager.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        manager.annotations = [
            CircleAnnotation(id: "circle1", centerCoordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        _ = manager.handleDragBegin(with: "circle1", context: .zero)

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
        let annotation = CircleAnnotation(id: "circle1", centerCoordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        _ = manager.handleDragBegin(with: "circle1", context: .zero)

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? CircleLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(manager.id))
        XCTAssertEqual(addedLayer.id, manager.id + "_drag")

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, "\(manager.id)_drag")

        _ = manager.handleDragBegin(with: "circle1", context: .zero)

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
            var annotation: CircleAnnotation
            var context: MapContentGestureContext
        }

        var annotation = CircleAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        let annotation = CircleAnnotation(id: "circle1", centerCoordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testRemovingDuplicatedAnnotations() {
      let annotation1 = CircleAnnotation(id: "A", point: .init(.init(latitude: 1, longitude: 1)), isSelected: false, isDraggable: false)
      let annotation2 = CircleAnnotation(id: "B", point: .init(.init(latitude: 2, longitude: 2)), isSelected: false, isDraggable: false)
      let annotation3 = CircleAnnotation(id: "A", point: .init(.init(latitude: 3, longitude: 3)), isSelected: false, isDraggable: false)
      manager.annotations = [annotation1, annotation2, annotation3]

      XCTAssertEqual(manager.annotations, [
          annotation1,
          annotation2
      ])
    }

    func testSetNewAnnotations() {
      let annotation1 = CircleAnnotation(id: "A", point: .init(.init(latitude: 1, longitude: 1)), isSelected: false, isDraggable: false)
      let annotation2 = CircleAnnotation(id: "B", point: .init(.init(latitude: 2, longitude: 2)), isSelected: false, isDraggable: false)
      let annotation3 = CircleAnnotation(id: "C", point: .init(.init(latitude: 3, longitude: 3)), isSelected: false, isDraggable: false)

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
