// This file is generated
import XCTest
@testable import MapboxMaps

final class PointAnnotationManagerTests: XCTestCase, AnnotationInteractionDelegate {
    var manager: PointAnnotationManager!
    var style: MockStyle!
    var id = UUID().uuidString
    var annotations = [PointAnnotation]()
    var expectation: XCTestExpectation?
    var delegateAnnotations: [Annotation]?
    var mapFeatureQueryable: MockMapFeatureQueryable!
    var imagesManager: MockAnnotationImagesManager!
    var offsetCalculator: OffsetPointCalculator!
    var mapboxMap: MockMapboxMap!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()

        style = MockStyle()
        mapFeatureQueryable = MockMapFeatureQueryable()
        imagesManager = MockAnnotationImagesManager()
        mapboxMap = MockMapboxMap()
        offsetCalculator = OffsetPointCalculator(mapboxMap: mapboxMap)
        manager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )

        for _ in 0...10 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
    }

    override func tearDown() {
        style = nil
        expectation = nil
        delegateAnnotations = nil
        imagesManager = nil
        mapFeatureQueryable = nil
        mapboxMap = nil
        offsetCalculator = nil
        manager = nil

        super.tearDown()
    }

    func testSourceSetup() {
        style.addSourceStub.reset()

        _ = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.id, manager.id)
    }

    func testAddLayer() throws {
        style.addSourceStub.reset()
        let initializedManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.symbol)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, initializedManager.id)
        let addedLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.last?.parameters.layer as? SymbolLayer)
        XCTAssertEqual(addedLayer.source, initializedManager.sourceId)
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testAddManagerWithDuplicateId() {
        var annotations2 = [PointAnnotation]()
        for _ in 0...50 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations2.append(annotation)
        }

        manager.annotations = annotations
        let manager2 = PointAnnotationManager(
            id: manager.id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        manager2.annotations = annotations2

        XCTAssertEqual(manager.annotations.count, 11)
        XCTAssertEqual(manager2.annotations.count, 51)
    }

    func testLayerPositionPassedCorrectly() {
        let manager3 = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: LayerPosition.at(4),
            displayLink: displayLink,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
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
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        let expectedFeatures = annotations.map(\.feature)

        manager.annotations = annotations
        $displayLink.send()

        var invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
        XCTAssertEqual(invocation.parameters.features, expectedFeatures)
        XCTAssertEqual(invocation.parameters.sourceId, manager.id)

        do {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }
        var taps = [MapContentGestureContext]()
        annotations[0].tapHandler = { context in
            taps.append(context)
            return true
        }
        annotations[1].tapHandler = { context in
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

    func testHandleClusterTap() {
        let onClusterTap = Stub<AnnotationClusterGestureContext, Void>(defaultReturnValue: ())
        let context = MapContentGestureContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        let annotationContext = AnnotationClusterGestureContext(point: context.point, coordinate: context.coordinate, expansionZoom: 4)
        manager.onClusterTap = onClusterTap.call

        let isHandled = manager.handleTap(
            layerId: "mapbox-iOS-cluster-circle-layer-manager-\(id)",
            feature: annotations[1].feature,
            context: context
        )
        mapFeatureQueryable.getGeoJsonClusterExpansionZoomStub.invocations.map(\.parameters.completion).forEach { completion in
            completion(.success(FeatureExtensionValue(value: 4, features: nil)))
        }

        XCTAssertTrue(isHandled)
        XCTAssertEqual(mapFeatureQueryable.getGeoJsonClusterExpansionZoomStub.invocations.map(\.parameters.feature), [
            annotations[1].feature
        ])

        XCTAssertEqual(onClusterTap.invocations.map(\.parameters), [annotationContext])
    }

    func testInitialIconAllowOverlap() {
        let initialValue = manager.iconAllowOverlap
        XCTAssertNil(initialValue)
    }

    func testSetIconAllowOverlap() {
        let value = Bool.random()
        manager.iconAllowOverlap = value
        XCTAssertEqual(manager.iconAllowOverlap, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, value)
    }

    func testIconAllowOverlapAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconAllowOverlapProperty = Bool.random()
        let secondIconAllowOverlapProperty = Bool.random()

        manager.iconAllowOverlap = newIconAllowOverlapProperty
        $displayLink.send()
        manager.iconAllowOverlap = secondIconAllowOverlapProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, secondIconAllowOverlapProperty)
    }

    func testNewIconAllowOverlapPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconAllowOverlapProperty = Bool.random()

        manager.annotations = annotations
        manager.iconAllowOverlap = newIconAllowOverlapProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"])
    }

    func testSetToNilIconAllowOverlap() {
        let newIconAllowOverlapProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-allow-overlap").value as! Bool
        manager.iconAllowOverlap = newIconAllowOverlapProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"])

        manager.iconAllowOverlap = nil
        $displayLink.send()
        XCTAssertNil(manager.iconAllowOverlap)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-allow-overlap"] as! Bool, defaultValue)
    }

    func testInitialIconIgnorePlacement() {
        let initialValue = manager.iconIgnorePlacement
        XCTAssertNil(initialValue)
    }

    func testSetIconIgnorePlacement() {
        let value = Bool.random()
        manager.iconIgnorePlacement = value
        XCTAssertEqual(manager.iconIgnorePlacement, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, value)
    }

    func testIconIgnorePlacementAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconIgnorePlacementProperty = Bool.random()
        let secondIconIgnorePlacementProperty = Bool.random()

        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        $displayLink.send()
        manager.iconIgnorePlacement = secondIconIgnorePlacementProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, secondIconIgnorePlacementProperty)
    }

    func testNewIconIgnorePlacementPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconIgnorePlacementProperty = Bool.random()

        manager.annotations = annotations
        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"])
    }

    func testSetToNilIconIgnorePlacement() {
        let newIconIgnorePlacementProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-ignore-placement").value as! Bool
        manager.iconIgnorePlacement = newIconIgnorePlacementProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"])

        manager.iconIgnorePlacement = nil
        $displayLink.send()
        XCTAssertNil(manager.iconIgnorePlacement)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-ignore-placement"] as! Bool, defaultValue)
    }

    func testInitialIconKeepUpright() {
        let initialValue = manager.iconKeepUpright
        XCTAssertNil(initialValue)
    }

    func testSetIconKeepUpright() {
        let value = Bool.random()
        manager.iconKeepUpright = value
        XCTAssertEqual(manager.iconKeepUpright, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, value)
    }

    func testIconKeepUprightAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconKeepUprightProperty = Bool.random()
        let secondIconKeepUprightProperty = Bool.random()

        manager.iconKeepUpright = newIconKeepUprightProperty
        $displayLink.send()
        manager.iconKeepUpright = secondIconKeepUprightProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, secondIconKeepUprightProperty)
    }

    func testNewIconKeepUprightPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconKeepUprightProperty = Bool.random()

        manager.annotations = annotations
        manager.iconKeepUpright = newIconKeepUprightProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"])
    }

    func testSetToNilIconKeepUpright() {
        let newIconKeepUprightProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-keep-upright").value as! Bool
        manager.iconKeepUpright = newIconKeepUprightProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"])

        manager.iconKeepUpright = nil
        $displayLink.send()
        XCTAssertNil(manager.iconKeepUpright)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-keep-upright"] as! Bool, defaultValue)
    }

    func testInitialIconOptional() {
        let initialValue = manager.iconOptional
        XCTAssertNil(initialValue)
    }

    func testSetIconOptional() {
        let value = Bool.random()
        manager.iconOptional = value
        XCTAssertEqual(manager.iconOptional, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, value)
    }

    func testIconOptionalAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconOptionalProperty = Bool.random()
        let secondIconOptionalProperty = Bool.random()

        manager.iconOptional = newIconOptionalProperty
        $displayLink.send()
        manager.iconOptional = secondIconOptionalProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, secondIconOptionalProperty)
    }

    func testNewIconOptionalPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconOptionalProperty = Bool.random()

        manager.annotations = annotations
        manager.iconOptional = newIconOptionalProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"])
    }

    func testSetToNilIconOptional() {
        let newIconOptionalProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-optional").value as! Bool
        manager.iconOptional = newIconOptionalProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"])

        manager.iconOptional = nil
        $displayLink.send()
        XCTAssertNil(manager.iconOptional)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-optional"] as! Bool, defaultValue)
    }

    func testInitialIconPadding() {
        let initialValue = manager.iconPadding
        XCTAssertNil(initialValue)
    }

    func testSetIconPadding() {
        let value = Double.random(in: 0...100000)
        manager.iconPadding = value
        XCTAssertEqual(manager.iconPadding, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, value)
    }

    func testIconPaddingAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconPaddingProperty = Double.random(in: 0...100000)
        let secondIconPaddingProperty = Double.random(in: 0...100000)

        manager.iconPadding = newIconPaddingProperty
        $displayLink.send()
        manager.iconPadding = secondIconPaddingProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, secondIconPaddingProperty)
    }

    func testNewIconPaddingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconPaddingProperty = Double.random(in: 0...100000)

        manager.annotations = annotations
        manager.iconPadding = newIconPaddingProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"])
    }

    func testSetToNilIconPadding() {
        let newIconPaddingProperty = Double.random(in: 0...100000)
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-padding").value as! Double
        manager.iconPadding = newIconPaddingProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"])

        manager.iconPadding = nil
        $displayLink.send()
        XCTAssertNil(manager.iconPadding)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-padding"] as! Double, defaultValue)
    }

    func testInitialIconPitchAlignment() {
        let initialValue = manager.iconPitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetIconPitchAlignment() {
        let value = IconPitchAlignment.random()
        manager.iconPitchAlignment = value
        XCTAssertEqual(manager.iconPitchAlignment, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, value.rawValue)
    }

    func testIconPitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconPitchAlignmentProperty = IconPitchAlignment.random()
        let secondIconPitchAlignmentProperty = IconPitchAlignment.random()

        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        $displayLink.send()
        manager.iconPitchAlignment = secondIconPitchAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, secondIconPitchAlignmentProperty.rawValue)
    }

    func testNewIconPitchAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconPitchAlignmentProperty = IconPitchAlignment.random()

        manager.annotations = annotations
        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"])
    }

    func testSetToNilIconPitchAlignment() {
        let newIconPitchAlignmentProperty = IconPitchAlignment.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-pitch-alignment").value as! String
        manager.iconPitchAlignment = newIconPitchAlignmentProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"])

        manager.iconPitchAlignment = nil
        $displayLink.send()
        XCTAssertNil(manager.iconPitchAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-pitch-alignment"] as! String, defaultValue)
    }

    func testInitialIconRotationAlignment() {
        let initialValue = manager.iconRotationAlignment
        XCTAssertNil(initialValue)
    }

    func testSetIconRotationAlignment() {
        let value = IconRotationAlignment.random()
        manager.iconRotationAlignment = value
        XCTAssertEqual(manager.iconRotationAlignment, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, value.rawValue)
    }

    func testIconRotationAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconRotationAlignmentProperty = IconRotationAlignment.random()
        let secondIconRotationAlignmentProperty = IconRotationAlignment.random()

        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        $displayLink.send()
        manager.iconRotationAlignment = secondIconRotationAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, secondIconRotationAlignmentProperty.rawValue)
    }

    func testNewIconRotationAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconRotationAlignmentProperty = IconRotationAlignment.random()

        manager.annotations = annotations
        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"])
    }

    func testSetToNilIconRotationAlignment() {
        let newIconRotationAlignmentProperty = IconRotationAlignment.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-rotation-alignment").value as! String
        manager.iconRotationAlignment = newIconRotationAlignmentProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"])

        manager.iconRotationAlignment = nil
        $displayLink.send()
        XCTAssertNil(manager.iconRotationAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-rotation-alignment"] as! String, defaultValue)
    }

    func testInitialSymbolAvoidEdges() {
        let initialValue = manager.symbolAvoidEdges
        XCTAssertNil(initialValue)
    }

    func testSetSymbolAvoidEdges() {
        let value = Bool.random()
        manager.symbolAvoidEdges = value
        XCTAssertEqual(manager.symbolAvoidEdges, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, value)
    }

    func testSymbolAvoidEdgesAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolAvoidEdgesProperty = Bool.random()
        let secondSymbolAvoidEdgesProperty = Bool.random()

        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        $displayLink.send()
        manager.symbolAvoidEdges = secondSymbolAvoidEdgesProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, secondSymbolAvoidEdgesProperty)
    }

    func testNewSymbolAvoidEdgesPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolAvoidEdgesProperty = Bool.random()

        manager.annotations = annotations
        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"])
    }

    func testSetToNilSymbolAvoidEdges() {
        let newSymbolAvoidEdgesProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-avoid-edges").value as! Bool
        manager.symbolAvoidEdges = newSymbolAvoidEdgesProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"])

        manager.symbolAvoidEdges = nil
        $displayLink.send()
        XCTAssertNil(manager.symbolAvoidEdges)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-avoid-edges"] as! Bool, defaultValue)
    }

    func testInitialSymbolPlacement() {
        let initialValue = manager.symbolPlacement
        XCTAssertNil(initialValue)
    }

    func testSetSymbolPlacement() {
        let value = SymbolPlacement.random()
        manager.symbolPlacement = value
        XCTAssertEqual(manager.symbolPlacement, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, value.rawValue)
    }

    func testSymbolPlacementAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolPlacementProperty = SymbolPlacement.random()
        let secondSymbolPlacementProperty = SymbolPlacement.random()

        manager.symbolPlacement = newSymbolPlacementProperty
        $displayLink.send()
        manager.symbolPlacement = secondSymbolPlacementProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, secondSymbolPlacementProperty.rawValue)
    }

    func testNewSymbolPlacementPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolPlacementProperty = SymbolPlacement.random()

        manager.annotations = annotations
        manager.symbolPlacement = newSymbolPlacementProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"])
    }

    func testSetToNilSymbolPlacement() {
        let newSymbolPlacementProperty = SymbolPlacement.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-placement").value as! String
        manager.symbolPlacement = newSymbolPlacementProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"])

        manager.symbolPlacement = nil
        $displayLink.send()
        XCTAssertNil(manager.symbolPlacement)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-placement"] as! String, defaultValue)
    }

    func testInitialSymbolSpacing() {
        let initialValue = manager.symbolSpacing
        XCTAssertNil(initialValue)
    }

    func testSetSymbolSpacing() {
        let value = Double.random(in: 1...100000)
        manager.symbolSpacing = value
        XCTAssertEqual(manager.symbolSpacing, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, value)
    }

    func testSymbolSpacingAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolSpacingProperty = Double.random(in: 1...100000)
        let secondSymbolSpacingProperty = Double.random(in: 1...100000)

        manager.symbolSpacing = newSymbolSpacingProperty
        $displayLink.send()
        manager.symbolSpacing = secondSymbolSpacingProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, secondSymbolSpacingProperty)
    }

    func testNewSymbolSpacingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolSpacingProperty = Double.random(in: 1...100000)

        manager.annotations = annotations
        manager.symbolSpacing = newSymbolSpacingProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"])
    }

    func testSetToNilSymbolSpacing() {
        let newSymbolSpacingProperty = Double.random(in: 1...100000)
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-spacing").value as! Double
        manager.symbolSpacing = newSymbolSpacingProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"])

        manager.symbolSpacing = nil
        $displayLink.send()
        XCTAssertNil(manager.symbolSpacing)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-spacing"] as! Double, defaultValue)
    }

    func testInitialSymbolZElevate() {
        let initialValue = manager.symbolZElevate
        XCTAssertNil(initialValue)
    }

    func testSetSymbolZElevate() {
        let value = Bool.random()
        manager.symbolZElevate = value
        XCTAssertEqual(manager.symbolZElevate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-elevate"] as! Bool, value)
    }

    func testSymbolZElevateAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolZElevateProperty = Bool.random()
        let secondSymbolZElevateProperty = Bool.random()

        manager.symbolZElevate = newSymbolZElevateProperty
        $displayLink.send()
        manager.symbolZElevate = secondSymbolZElevateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-elevate"] as! Bool, secondSymbolZElevateProperty)
    }

    func testNewSymbolZElevatePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolZElevateProperty = Bool.random()

        manager.annotations = annotations
        manager.symbolZElevate = newSymbolZElevateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-elevate"])
    }

    func testSetToNilSymbolZElevate() {
        let newSymbolZElevateProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-elevate").value as! Bool
        manager.symbolZElevate = newSymbolZElevateProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-elevate"])

        manager.symbolZElevate = nil
        $displayLink.send()
        XCTAssertNil(manager.symbolZElevate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-elevate"] as! Bool, defaultValue)
    }

    func testInitialSymbolZOrder() {
        let initialValue = manager.symbolZOrder
        XCTAssertNil(initialValue)
    }

    func testSetSymbolZOrder() {
        let value = SymbolZOrder.random()
        manager.symbolZOrder = value
        XCTAssertEqual(manager.symbolZOrder, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, value.rawValue)
    }

    func testSymbolZOrderAnnotationPropertiesAddedWithoutDuplicate() {
        let newSymbolZOrderProperty = SymbolZOrder.random()
        let secondSymbolZOrderProperty = SymbolZOrder.random()

        manager.symbolZOrder = newSymbolZOrderProperty
        $displayLink.send()
        manager.symbolZOrder = secondSymbolZOrderProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, secondSymbolZOrderProperty.rawValue)
    }

    func testNewSymbolZOrderPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSymbolZOrderProperty = SymbolZOrder.random()

        manager.annotations = annotations
        manager.symbolZOrder = newSymbolZOrderProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"])
    }

    func testSetToNilSymbolZOrder() {
        let newSymbolZOrderProperty = SymbolZOrder.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "symbol-z-order").value as! String
        manager.symbolZOrder = newSymbolZOrderProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"])

        manager.symbolZOrder = nil
        $displayLink.send()
        XCTAssertNil(manager.symbolZOrder)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["symbol-z-order"] as! String, defaultValue)
    }

    func testInitialTextAllowOverlap() {
        let initialValue = manager.textAllowOverlap
        XCTAssertNil(initialValue)
    }

    func testSetTextAllowOverlap() {
        let value = Bool.random()
        manager.textAllowOverlap = value
        XCTAssertEqual(manager.textAllowOverlap, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, value)
    }

    func testTextAllowOverlapAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextAllowOverlapProperty = Bool.random()
        let secondTextAllowOverlapProperty = Bool.random()

        manager.textAllowOverlap = newTextAllowOverlapProperty
        $displayLink.send()
        manager.textAllowOverlap = secondTextAllowOverlapProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, secondTextAllowOverlapProperty)
    }

    func testNewTextAllowOverlapPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextAllowOverlapProperty = Bool.random()

        manager.annotations = annotations
        manager.textAllowOverlap = newTextAllowOverlapProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"])
    }

    func testSetToNilTextAllowOverlap() {
        let newTextAllowOverlapProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-allow-overlap").value as! Bool
        manager.textAllowOverlap = newTextAllowOverlapProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"])

        manager.textAllowOverlap = nil
        $displayLink.send()
        XCTAssertNil(manager.textAllowOverlap)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-allow-overlap"] as! Bool, defaultValue)
    }

    func testInitialTextFont() {
        let initialValue = manager.textFont
        XCTAssertNil(initialValue)
    }

    func testSetTextFont() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        manager.textFont = value
        XCTAssertEqual(manager.textFont, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual((style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [Any])[1] as! [String], value)
    }

    func testTextFontAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        let secondTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })

        manager.textFont = newTextFontProperty
        $displayLink.send()
        manager.textFont = secondTextFontProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual((style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [Any])[1] as! [String], secondTextFontProperty)
    }

    func testNewTextFontPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })

        manager.annotations = annotations
        manager.textFont = newTextFontProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"])
    }

    func testSetToNilTextFont() {
        let newTextFontProperty = Array.random(withLength: .random(in: 0...10), generator: { String.randomASCII(withLength: .random(in: 0...100)) })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-font").value as! [String]
        manager.textFont = newTextFontProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"])

        manager.textFont = nil
        $displayLink.send()
        XCTAssertNil(manager.textFont)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-font"] as! [String], defaultValue)
    }

    func testInitialTextIgnorePlacement() {
        let initialValue = manager.textIgnorePlacement
        XCTAssertNil(initialValue)
    }

    func testSetTextIgnorePlacement() {
        let value = Bool.random()
        manager.textIgnorePlacement = value
        XCTAssertEqual(manager.textIgnorePlacement, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, value)
    }

    func testTextIgnorePlacementAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextIgnorePlacementProperty = Bool.random()
        let secondTextIgnorePlacementProperty = Bool.random()

        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        $displayLink.send()
        manager.textIgnorePlacement = secondTextIgnorePlacementProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, secondTextIgnorePlacementProperty)
    }

    func testNewTextIgnorePlacementPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextIgnorePlacementProperty = Bool.random()

        manager.annotations = annotations
        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"])
    }

    func testSetToNilTextIgnorePlacement() {
        let newTextIgnorePlacementProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-ignore-placement").value as! Bool
        manager.textIgnorePlacement = newTextIgnorePlacementProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"])

        manager.textIgnorePlacement = nil
        $displayLink.send()
        XCTAssertNil(manager.textIgnorePlacement)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-ignore-placement"] as! Bool, defaultValue)
    }

    func testInitialTextKeepUpright() {
        let initialValue = manager.textKeepUpright
        XCTAssertNil(initialValue)
    }

    func testSetTextKeepUpright() {
        let value = Bool.random()
        manager.textKeepUpright = value
        XCTAssertEqual(manager.textKeepUpright, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, value)
    }

    func testTextKeepUprightAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextKeepUprightProperty = Bool.random()
        let secondTextKeepUprightProperty = Bool.random()

        manager.textKeepUpright = newTextKeepUprightProperty
        $displayLink.send()
        manager.textKeepUpright = secondTextKeepUprightProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, secondTextKeepUprightProperty)
    }

    func testNewTextKeepUprightPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextKeepUprightProperty = Bool.random()

        manager.annotations = annotations
        manager.textKeepUpright = newTextKeepUprightProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"])
    }

    func testSetToNilTextKeepUpright() {
        let newTextKeepUprightProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-keep-upright").value as! Bool
        manager.textKeepUpright = newTextKeepUprightProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"])

        manager.textKeepUpright = nil
        $displayLink.send()
        XCTAssertNil(manager.textKeepUpright)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-keep-upright"] as! Bool, defaultValue)
    }

    func testInitialTextMaxAngle() {
        let initialValue = manager.textMaxAngle
        XCTAssertNil(initialValue)
    }

    func testSetTextMaxAngle() {
        let value = Double.random(in: -100000...100000)
        manager.textMaxAngle = value
        XCTAssertEqual(manager.textMaxAngle, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, value)
    }

    func testTextMaxAngleAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextMaxAngleProperty = Double.random(in: -100000...100000)
        let secondTextMaxAngleProperty = Double.random(in: -100000...100000)

        manager.textMaxAngle = newTextMaxAngleProperty
        $displayLink.send()
        manager.textMaxAngle = secondTextMaxAngleProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, secondTextMaxAngleProperty)
    }

    func testNewTextMaxAnglePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextMaxAngleProperty = Double.random(in: -100000...100000)

        manager.annotations = annotations
        manager.textMaxAngle = newTextMaxAngleProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"])
    }

    func testSetToNilTextMaxAngle() {
        let newTextMaxAngleProperty = Double.random(in: -100000...100000)
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-max-angle").value as! Double
        manager.textMaxAngle = newTextMaxAngleProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"])

        manager.textMaxAngle = nil
        $displayLink.send()
        XCTAssertNil(manager.textMaxAngle)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-max-angle"] as! Double, defaultValue)
    }

    func testInitialTextOptional() {
        let initialValue = manager.textOptional
        XCTAssertNil(initialValue)
    }

    func testSetTextOptional() {
        let value = Bool.random()
        manager.textOptional = value
        XCTAssertEqual(manager.textOptional, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, value)
    }

    func testTextOptionalAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextOptionalProperty = Bool.random()
        let secondTextOptionalProperty = Bool.random()

        manager.textOptional = newTextOptionalProperty
        $displayLink.send()
        manager.textOptional = secondTextOptionalProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, secondTextOptionalProperty)
    }

    func testNewTextOptionalPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextOptionalProperty = Bool.random()

        manager.annotations = annotations
        manager.textOptional = newTextOptionalProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"])
    }

    func testSetToNilTextOptional() {
        let newTextOptionalProperty = Bool.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-optional").value as! Bool
        manager.textOptional = newTextOptionalProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"])

        manager.textOptional = nil
        $displayLink.send()
        XCTAssertNil(manager.textOptional)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-optional"] as! Bool, defaultValue)
    }

    func testInitialTextPadding() {
        let initialValue = manager.textPadding
        XCTAssertNil(initialValue)
    }

    func testSetTextPadding() {
        let value = Double.random(in: 0...100000)
        manager.textPadding = value
        XCTAssertEqual(manager.textPadding, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, value)
    }

    func testTextPaddingAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextPaddingProperty = Double.random(in: 0...100000)
        let secondTextPaddingProperty = Double.random(in: 0...100000)

        manager.textPadding = newTextPaddingProperty
        $displayLink.send()
        manager.textPadding = secondTextPaddingProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, secondTextPaddingProperty)
    }

    func testNewTextPaddingPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextPaddingProperty = Double.random(in: 0...100000)

        manager.annotations = annotations
        manager.textPadding = newTextPaddingProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"])
    }

    func testSetToNilTextPadding() {
        let newTextPaddingProperty = Double.random(in: 0...100000)
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-padding").value as! Double
        manager.textPadding = newTextPaddingProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"])

        manager.textPadding = nil
        $displayLink.send()
        XCTAssertNil(manager.textPadding)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-padding"] as! Double, defaultValue)
    }

    func testInitialTextPitchAlignment() {
        let initialValue = manager.textPitchAlignment
        XCTAssertNil(initialValue)
    }

    func testSetTextPitchAlignment() {
        let value = TextPitchAlignment.random()
        manager.textPitchAlignment = value
        XCTAssertEqual(manager.textPitchAlignment, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, value.rawValue)
    }

    func testTextPitchAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextPitchAlignmentProperty = TextPitchAlignment.random()
        let secondTextPitchAlignmentProperty = TextPitchAlignment.random()

        manager.textPitchAlignment = newTextPitchAlignmentProperty
        $displayLink.send()
        manager.textPitchAlignment = secondTextPitchAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, secondTextPitchAlignmentProperty.rawValue)
    }

    func testNewTextPitchAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextPitchAlignmentProperty = TextPitchAlignment.random()

        manager.annotations = annotations
        manager.textPitchAlignment = newTextPitchAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"])
    }

    func testSetToNilTextPitchAlignment() {
        let newTextPitchAlignmentProperty = TextPitchAlignment.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-pitch-alignment").value as! String
        manager.textPitchAlignment = newTextPitchAlignmentProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"])

        manager.textPitchAlignment = nil
        $displayLink.send()
        XCTAssertNil(manager.textPitchAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-pitch-alignment"] as! String, defaultValue)
    }

    func testInitialTextRotationAlignment() {
        let initialValue = manager.textRotationAlignment
        XCTAssertNil(initialValue)
    }

    func testSetTextRotationAlignment() {
        let value = TextRotationAlignment.random()
        manager.textRotationAlignment = value
        XCTAssertEqual(manager.textRotationAlignment, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, value.rawValue)
    }

    func testTextRotationAlignmentAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextRotationAlignmentProperty = TextRotationAlignment.random()
        let secondTextRotationAlignmentProperty = TextRotationAlignment.random()

        manager.textRotationAlignment = newTextRotationAlignmentProperty
        $displayLink.send()
        manager.textRotationAlignment = secondTextRotationAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, secondTextRotationAlignmentProperty.rawValue)
    }

    func testNewTextRotationAlignmentPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextRotationAlignmentProperty = TextRotationAlignment.random()

        manager.annotations = annotations
        manager.textRotationAlignment = newTextRotationAlignmentProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"])
    }

    func testSetToNilTextRotationAlignment() {
        let newTextRotationAlignmentProperty = TextRotationAlignment.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-rotation-alignment").value as! String
        manager.textRotationAlignment = newTextRotationAlignmentProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"])

        manager.textRotationAlignment = nil
        $displayLink.send()
        XCTAssertNil(manager.textRotationAlignment)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-rotation-alignment"] as! String, defaultValue)
    }

    func testInitialTextVariableAnchor() {
        let initialValue = manager.textVariableAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextVariableAnchor() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.random() })
        manager.textVariableAnchor = value
        XCTAssertEqual(manager.textVariableAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [String], valueAsString)
    }

    func testTextVariableAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.random() })
        let secondTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.random() })

        manager.textVariableAnchor = newTextVariableAnchorProperty
        $displayLink.send()
        manager.textVariableAnchor = secondTextVariableAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let valueAsString = secondTextVariableAnchorProperty.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [String], valueAsString)
    }

    func testNewTextVariableAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.random() })

        manager.annotations = annotations
        manager.textVariableAnchor = newTextVariableAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"])
    }

    func testSetToNilTextVariableAnchor() {
        let newTextVariableAnchorProperty = Array.random(withLength: .random(in: 0...10), generator: { TextAnchor.random() })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-variable-anchor").value as! [TextAnchor]
        manager.textVariableAnchor = newTextVariableAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"])

        manager.textVariableAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.textVariableAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-variable-anchor"] as! [TextAnchor], defaultValue)
    }

    func testInitialTextWritingMode() {
        let initialValue = manager.textWritingMode
        XCTAssertNil(initialValue)
    }

    func testSetTextWritingMode() {
        let value = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.random() })
        manager.textWritingMode = value
        XCTAssertEqual(manager.textWritingMode, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        let valueAsString = value.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [String], valueAsString)
    }

    func testTextWritingModeAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.random() })
        let secondTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.random() })

        manager.textWritingMode = newTextWritingModeProperty
        $displayLink.send()
        manager.textWritingMode = secondTextWritingModeProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let valueAsString = secondTextWritingModeProperty.map { $0.rawValue }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [String], valueAsString)
    }

    func testNewTextWritingModePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.random() })

        manager.annotations = annotations
        manager.textWritingMode = newTextWritingModeProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"])
    }

    func testSetToNilTextWritingMode() {
        let newTextWritingModeProperty = Array.random(withLength: .random(in: 0...10), generator: { TextWritingMode.random() })
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-writing-mode").value as! [TextWritingMode]
        manager.textWritingMode = newTextWritingModeProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"])

        manager.textWritingMode = nil
        $displayLink.send()
        XCTAssertNil(manager.textWritingMode)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-writing-mode"] as! [TextWritingMode], defaultValue)
    }

    func testInitialIconColorSaturation() {
        let initialValue = manager.iconColorSaturation
        XCTAssertNil(initialValue)
    }

    func testSetIconColorSaturation() {
        let value = Double.random(in: 0...1)
        manager.iconColorSaturation = value
        XCTAssertEqual(manager.iconColorSaturation, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color-saturation"] as! Double, value)
    }

    func testIconColorSaturationAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconColorSaturationProperty = Double.random(in: 0...1)
        let secondIconColorSaturationProperty = Double.random(in: 0...1)

        manager.iconColorSaturation = newIconColorSaturationProperty
        $displayLink.send()
        manager.iconColorSaturation = secondIconColorSaturationProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color-saturation"] as! Double, secondIconColorSaturationProperty)
    }

    func testNewIconColorSaturationPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconColorSaturationProperty = Double.random(in: 0...1)

        manager.annotations = annotations
        manager.iconColorSaturation = newIconColorSaturationProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color-saturation"])
    }

    func testSetToNilIconColorSaturation() {
        let newIconColorSaturationProperty = Double.random(in: 0...1)
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-color-saturation").value as! Double
        manager.iconColorSaturation = newIconColorSaturationProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color-saturation"])

        manager.iconColorSaturation = nil
        $displayLink.send()
        XCTAssertNil(manager.iconColorSaturation)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-color-saturation"] as! Double, defaultValue)
    }

    func testInitialIconTranslate() {
        let initialValue = manager.iconTranslate
        XCTAssertNil(initialValue)
    }

    func testSetIconTranslate() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.iconTranslate = value
        XCTAssertEqual(manager.iconTranslate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], value)
    }

    func testIconTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.iconTranslate = newIconTranslateProperty
        $displayLink.send()
        manager.iconTranslate = secondIconTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], secondIconTranslateProperty)
    }

    func testNewIconTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.iconTranslate = newIconTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"])
    }

    func testSetToNilIconTranslate() {
        let newIconTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-translate").value as! [Double]
        manager.iconTranslate = newIconTranslateProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"])

        manager.iconTranslate = nil
        $displayLink.send()
        XCTAssertNil(manager.iconTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate"] as! [Double], defaultValue)
    }

    func testInitialIconTranslateAnchor() {
        let initialValue = manager.iconTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetIconTranslateAnchor() {
        let value = IconTranslateAnchor.random()
        manager.iconTranslateAnchor = value
        XCTAssertEqual(manager.iconTranslateAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, value.rawValue)
    }

    func testIconTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newIconTranslateAnchorProperty = IconTranslateAnchor.random()
        let secondIconTranslateAnchorProperty = IconTranslateAnchor.random()

        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        $displayLink.send()
        manager.iconTranslateAnchor = secondIconTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, secondIconTranslateAnchorProperty.rawValue)
    }

    func testNewIconTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newIconTranslateAnchorProperty = IconTranslateAnchor.random()

        manager.annotations = annotations
        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"])
    }

    func testSetToNilIconTranslateAnchor() {
        let newIconTranslateAnchorProperty = IconTranslateAnchor.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-translate-anchor").value as! String
        manager.iconTranslateAnchor = newIconTranslateAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"])

        manager.iconTranslateAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.iconTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["icon-translate-anchor"] as! String, defaultValue)
    }

    func testInitialTextTranslate() {
        let initialValue = manager.textTranslate
        XCTAssertNil(initialValue)
    }

    func testSetTextTranslate() {
        let value = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        manager.textTranslate = value
        XCTAssertEqual(manager.textTranslate, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], value)
    }

    func testTextTranslateAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let secondTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.textTranslate = newTextTranslateProperty
        $displayLink.send()
        manager.textTranslate = secondTextTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], secondTextTranslateProperty)
    }

    func testNewTextTranslatePropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]

        manager.annotations = annotations
        manager.textTranslate = newTextTranslateProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"])
    }

    func testSetToNilTextTranslate() {
        let newTextTranslateProperty = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-translate").value as! [Double]
        manager.textTranslate = newTextTranslateProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"])

        manager.textTranslate = nil
        $displayLink.send()
        XCTAssertNil(manager.textTranslate)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate"] as! [Double], defaultValue)
    }

    func testInitialTextTranslateAnchor() {
        let initialValue = manager.textTranslateAnchor
        XCTAssertNil(initialValue)
    }

    func testSetTextTranslateAnchor() {
        let value = TextTranslateAnchor.random()
        manager.textTranslateAnchor = value
        XCTAssertEqual(manager.textTranslateAnchor, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, value.rawValue)
    }

    func testTextTranslateAnchorAnnotationPropertiesAddedWithoutDuplicate() {
        let newTextTranslateAnchorProperty = TextTranslateAnchor.random()
        let secondTextTranslateAnchorProperty = TextTranslateAnchor.random()

        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        $displayLink.send()
        manager.textTranslateAnchor = secondTextTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, secondTextTranslateAnchorProperty.rawValue)
    }

    func testNewTextTranslateAnchorPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newTextTranslateAnchorProperty = TextTranslateAnchor.random()

        manager.annotations = annotations
        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"])
    }

    func testSetToNilTextTranslateAnchor() {
        let newTextTranslateAnchorProperty = TextTranslateAnchor.random()
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "text-translate-anchor").value as! String
        manager.textTranslateAnchor = newTextTranslateAnchorProperty
        $displayLink.send()
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"])

        manager.textTranslateAnchor = nil
        $displayLink.send()
        XCTAssertNil(manager.textTranslateAnchor)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["text-translate-anchor"] as! String, defaultValue)
    }

    func testInitialSlot() {
        let initialValue = manager.slot
        XCTAssertNil(initialValue)
    }

    func testSetSlot() {
        let value = String.randomASCII(withLength: .random(in: 0...100))
        manager.slot = value
        XCTAssertEqual(manager.slot, value)

        // test layer and source synced and properties added
        $displayLink.send()
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, value)
    }

    func testSlotAnnotationPropertiesAddedWithoutDuplicate() {
        let newSlotProperty = String.randomASCII(withLength: .random(in: 0...100))
        let secondSlotProperty = String.randomASCII(withLength: .random(in: 0...100))

        manager.slot = newSlotProperty
        $displayLink.send()
        manager.slot = secondSlotProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, manager.id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"] as! String, secondSlotProperty)
    }

    func testNewSlotPropertyMergedWithAnnotationProperties() {
        var annotations = [PointAnnotation]()
        for _ in 0...5 {
            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotation.iconAnchor = IconAnchor.random()
            annotation.iconImage = String.randomASCII(withLength: .random(in: 0...100))
            annotation.iconOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.iconRotate = Double.random(in: -100000...100000)
            annotation.iconSize = Double.random(in: 0...100000)
            annotation.iconTextFit = IconTextFit.random()
            annotation.iconTextFitPadding = [Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.symbolSortKey = Double.random(in: -100000...100000)
            annotation.textAnchor = TextAnchor.random()
            annotation.textField = String.randomASCII(withLength: .random(in: 0...100))
            annotation.textJustify = TextJustify.random()
            annotation.textLetterSpacing = Double.random(in: -100000...100000)
            annotation.textLineHeight = Double.random(in: -100000...100000)
            annotation.textMaxWidth = Double.random(in: 0...100000)
            annotation.textOffset = [Double.random(in: -100000...100000), Double.random(in: -100000...100000)]
            annotation.textRadialOffset = Double.random(in: -100000...100000)
            annotation.textRotate = Double.random(in: -100000...100000)
            annotation.textSize = Double.random(in: 0...100000)
            annotation.textTransform = TextTransform.random()
            annotation.iconColor = StyleColor.random()
            annotation.iconEmissiveStrength = Double.random(in: 0...100000)
            annotation.iconHaloBlur = Double.random(in: 0...100000)
            annotation.iconHaloColor = StyleColor.random()
            annotation.iconHaloWidth = Double.random(in: 0...100000)
            annotation.iconImageCrossFade = Double.random(in: 0...1)
            annotation.iconOpacity = Double.random(in: 0...1)
            annotation.textColor = StyleColor.random()
            annotation.textEmissiveStrength = Double.random(in: 0...100000)
            annotation.textHaloBlur = Double.random(in: 0...100000)
            annotation.textHaloColor = StyleColor.random()
            annotation.textHaloWidth = Double.random(in: 0...100000)
            annotation.textOpacity = Double.random(in: 0...1)
            annotations.append(annotation)
        }
        let newSlotProperty = String.randomASCII(withLength: .random(in: 0...100))

        manager.annotations = annotations
        manager.slot = newSlotProperty
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, annotations[0].layerProperties.count+1)
        XCTAssertNotNil(style.setLayerPropertiesStub.invocations.last?.parameters.properties["slot"])
    }

    func testSetToNilSlot() {
        let newSlotProperty = String.randomASCII(withLength: .random(in: 0...100))
        let defaultValue = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "slot").value as! String
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

    // Add tests specific to PointAnnotationManager
    func testNewImagesAddedToStyle() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)

        // when
        manager.annotations = annotations
        $displayLink.send()

        // then
        XCTAssertEqual(imagesManager.addImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(imagesManager.addImageStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(imagesManager.addImageStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(imagesManager.removeImageStub.invocations.count, 0)
        XCTAssertTrue(annotations.compactMap(\.image?.name).allSatisfy(manager.isUsingStyleImage(_:)))
    }

    func testUnusedImagesRemovedFromStyle() {
        // given
        let allAnnotations = Array.random(withLength: 10) {
            PointAnnotation(image: .init(image: UIImage(), name: UUID().uuidString))
        }
        manager.annotations = allAnnotations
        $displayLink.send()
        imagesManager.addImageStub.reset()
        XCTAssertTrue(allAnnotations.compactMap(\.image?.name).allSatisfy(manager.isUsingStyleImage(_:)))

        // when
        let (unusedAnnotations, remainingAnnotations) = (allAnnotations[0..<3], allAnnotations[3...])
        manager.annotations = Array(remainingAnnotations)
        $displayLink.send()

        // then
        XCTAssertEqual(imagesManager.addImageStub.invocations.count, remainingAnnotations.count)
        XCTAssertEqual(
            Set(imagesManager.addImageStub.invocations.map(\.parameters.id)),
            Set(remainingAnnotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(imagesManager.addImageStub.invocations.map(\.parameters.image)),
            Set(remainingAnnotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(imagesManager.removeImageStub.invocations.count, unusedAnnotations.count)
        XCTAssertEqual(
            Set(imagesManager.removeImageStub.invocations.map(\.parameters)),
            Set(unusedAnnotations.compactMap(\.image?.name))
        )
        XCTAssertTrue(remainingAnnotations.compactMap(\.image?.name).allSatisfy(manager.isUsingStyleImage(_:)))
        XCTAssertTrue(unusedAnnotations.compactMap(\.image?.name).filter(manager.isUsingStyleImage(_:)).isEmpty)
    }

    func testAllImagesRemovedFromStyleOnUpdate() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        $displayLink.send()

        // when
        manager.annotations = []
        $displayLink.send()

        // then
        XCTAssertEqual(imagesManager.addImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(imagesManager.addImageStub.invocations.map(\.parameters.id)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertEqual(
            Set(imagesManager.addImageStub.invocations.map(\.parameters.image)),
            Set(annotations.compactMap(\.image?.image))
        )
        XCTAssertEqual(imagesManager.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(imagesManager.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertTrue(annotations.compactMap(\.image?.name).filter(manager.isUsingStyleImage(_:)).isEmpty)
    }

    func testAllImagesRemovedFromStyleOnDestroy() {
        // given
        let annotations = (0..<10)
            .map { _ in PointAnnotation.Image(image: UIImage(), name: UUID().uuidString) }
            .map(PointAnnotation.init)
        manager.annotations = annotations
        $displayLink.send()

        // when
        manager.destroy()

        // then
        XCTAssertEqual(imagesManager.removeImageStub.invocations.count, annotations.count)
        XCTAssertEqual(
            Set(imagesManager.removeImageStub.invocations.map(\.parameters)),
            Set(annotations.compactMap(\.image?.name))
        )
        XCTAssertTrue(annotations.compactMap(\.image?.name).filter(manager.isUsingStyleImage(_:)).isEmpty)
    }

    // Tests for clustering
    func testInitWithDefaultClusterOptions() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        XCTAssertEqual(clusterOptions.clusterRadius, 50)
        XCTAssertEqual(clusterOptions.circleRadius, .constant(18))
        XCTAssertEqual(clusterOptions.circleColor, .constant(StyleColor(.black)))
        XCTAssertEqual(clusterOptions.textColor, .constant(StyleColor(.white)))
        XCTAssertEqual(clusterOptions.textSize, .constant(12))
        XCTAssertEqual(clusterOptions.textField, .expression(Exp(.get) { "point_count" }))
        XCTAssertEqual(clusterOptions.clusterMaxZoom, 14)
        XCTAssertNil(clusterOptions.clusterProperties)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.type, SourceType.geoJson)
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.id, manager.id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 3) // symbol layer, one cluster layer, one text layer
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testSourceClusterOptions() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testClusterRadius = Double.testSourceValue()
        let testClusterMaxZoom = Double.testSourceValue()
        let testClusterProperties = [String: Expression].testSourceValue()
        let clusterOptions = ClusterOptions(clusterRadius: testClusterRadius,
                                            clusterMaxZoom: testClusterMaxZoom,
                                            clusterProperties: testClusterProperties)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations
        let geoJSONSource = style.addSourceStub.invocations.last?.parameters.source as! GeoJSONSource

        // then
        XCTAssertTrue(geoJSONSource.cluster!)
        XCTAssertEqual(clusterOptions.clusterRadius, testClusterRadius)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(geoJSONSource.clusterRadius, testClusterRadius)
        XCTAssertEqual(geoJSONSource.clusterMaxZoom, testClusterMaxZoom)
        XCTAssertEqual(geoJSONSource.clusterProperties, testClusterProperties)
    }

    func testCircleLayer() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testCircleRadius = Value<Double>.testConstantValue()
        let testCircleColor = Value<StyleColor>.testConstantValue()
        let clusterOptions = ClusterOptions(circleRadius: testCircleRadius,
                                            circleColor: testCircleColor)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        let circleLayerInvocations = style.addPersistentLayerStub.invocations.filter { circleLayer in
            return circleLayer.parameters.layer.id == "mapbox-iOS-cluster-circle-layer-manager-" + id
        }
        let circleLayer = circleLayerInvocations[0].parameters.layer as! CircleLayer

        XCTAssertEqual(clusterOptions.circleRadius, testCircleRadius)
        XCTAssertEqual(circleLayer.circleRadius, testCircleRadius)
        XCTAssertEqual(clusterOptions.circleColor, testCircleColor)
        XCTAssertEqual(circleLayer.circleColor, testCircleColor)
        XCTAssertEqual(circleLayer.filter, Exp(.has) { "point_count" })
        XCTAssertEqual(circleLayer.id, "mapbox-iOS-cluster-circle-layer-manager-" + id)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testTextLayer() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testTextColor = Value<StyleColor>.testConstantValue()
        let testTextSize = Value<Double>.testConstantValue()
        let testTextField = Value<String>.testConstantValue()
        let clusterOptions = ClusterOptions(textColor: testTextColor,
                                            textSize: testTextSize,
                                            textField: testTextField)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        let textLayerInvocations = style.addPersistentLayerStub.invocations.filter { symbolLayer in
            return symbolLayer.parameters.layer.id == "mapbox-iOS-cluster-text-layer-manager-" + id
        }
        let textLayer = textLayerInvocations[0].parameters.layer as! SymbolLayer

        XCTAssertEqual(textLayer.textColor, testTextColor)
        XCTAssertEqual(textLayer.textSize, testTextSize)
        XCTAssertEqual(textLayer.textField, testTextField)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testSymbolLayers() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations

        // then
        let symbolLayerInvocations = style.addPersistentLayerStub.invocations.filter { symbolLayer in
            return symbolLayer.parameters.layer.id == id
        }
        let symbolLayer = symbolLayerInvocations[0].parameters.layer as! SymbolLayer

        XCTAssertTrue(symbolLayer.iconAllowOverlap == .constant(true))
        XCTAssertTrue(symbolLayer.textAllowOverlap == .constant(true))
        XCTAssertTrue(symbolLayer.iconIgnorePlacement == .constant(true))
        XCTAssertTrue(symbolLayer.textIgnorePlacement == .constant(true))
        XCTAssertEqual(symbolLayer.source, id)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testChangeAnnotations() throws {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        let annotations = (0..<500).map { _ in
            PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
        }
        let newAnnotations = (0..<100).map { _ in
            PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: false)
        }

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations
        $displayLink.send()
        let parameters = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last).parameters
        XCTAssertEqual(parameters.features, annotations.map(\.feature))

        // then
        pointAnnotationManager.annotations = newAnnotations
        $displayLink.send()
        let addParameters = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last).parameters
        XCTAssertEqual(addParameters.features, newAnnotations.map(\.feature))

        let removeParameters = try XCTUnwrap(style.removeGeoJSONSourceFeaturesStub.invocations.last).parameters
        XCTAssertEqual(removeParameters.featureIds, annotations.map(\.id))
    }

    func testDestroyAnnotationManager() {
        // given
        let clusterOptions = ClusterOptions()

        // when
        let pointAnnotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: nil,
            displayLink: displayLink,
            clusterOptions: clusterOptions,
            mapFeatureQueryable: mapFeatureQueryable,
            imagesManager: imagesManager,
            offsetCalculator: offsetCalculator
        )
        pointAnnotationManager.annotations = annotations
        pointAnnotationManager.destroy()

        let removeLayerInvocations = style.removeLayerStub.invocations

        // then
        XCTAssertEqual(removeLayerInvocations.map(\.parameters), [
            "mapbox-iOS-cluster-circle-layer-manager-" + id,
            "mapbox-iOS-cluster-text-layer-manager-" + id,
            id,
        ])
    }

    func testGetAnnotations() {
        let annotations = Array.random(withLength: 10) {
            PointAnnotation(coordinate: .random(), isSelected: false, isDraggable: true)
        }
        manager.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        _ = manager.handleDragBegin(with: annotationToDrag.id, context: .zero)
        XCTAssertTrue(manager.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        manager.annotations = [
            PointAnnotation(id: "point1", coordinate: .random(), isSelected: false, isDraggable: false)
        ]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        _ = manager.handleDragBegin(with: "point1", context: .zero)

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
        let annotation = PointAnnotation(id: "point1", coordinate: .random(), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        _ = manager.handleDragBegin(with: "point1", context: .zero)

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? SymbolLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(manager.id))
        XCTAssertEqual(addedLayer.id, manager.id + "_drag")

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, "\(manager.id)_drag")

        _ = manager.handleDragBegin(with: "point1", context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)

        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        mapboxMap.coordinateForPointStub.defaultReturnValue = .random()
        mapboxMap.cameraState.zoom = 1

        manager.handleDragChange(with: .random(), context: .zero)

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
            var annotation: PointAnnotation
            var context: MapContentGestureContext
        }

        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
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
            manager.handleDragEnd(context:context)
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
            manager.handleDragEnd(context:context)
            XCTAssertEqual(endDragStub.invocations.count, 1)
            data = try XCTUnwrap(endDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)
        }
    }

    func testDoesNotUpdateDragSourceWhenNoDragged() {
        let annotation = PointAnnotation(id: "point1", coordinate: .random(), isSelected: false, isDraggable: true)
        manager.annotations = [annotation]
        $displayLink.send()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testRemovingDuplicatedAnnotations() {
      let annotation1 = PointAnnotation(id: "A", point: .init(.init(latitude: 1, longitude: 1)), isSelected: false, isDraggable: false)
      let annotation2 = PointAnnotation(id: "B", point: .init(.init(latitude: 2, longitude: 2)), isSelected: false, isDraggable: false)
      let annotation3 = PointAnnotation(id: "A", point: .init(.init(latitude: 3, longitude: 3)), isSelected: false, isDraggable: false)
      manager.annotations = [annotation1, annotation2, annotation3]

      XCTAssertEqual(manager.annotations, [
          annotation1,
          annotation2
      ])
    }

    func testSetNewAnnotations() {
      let annotation1 = PointAnnotation(id: "A", point: .init(.init(latitude: 1, longitude: 1)), isSelected: false, isDraggable: false)
      let annotation2 = PointAnnotation(id: "B", point: .init(.init(latitude: 2, longitude: 2)), isSelected: false, isDraggable: false)
      let annotation3 = PointAnnotation(id: "C", point: .init(.init(latitude: 3, longitude: 3)), isSelected: false, isDraggable: false)

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

private extension PointAnnotation {
    init(image: Image) {
        self.init(coordinate: .random())
        self.image = image
    }
}
// End of generated file
