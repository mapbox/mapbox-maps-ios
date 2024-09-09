@_spi(Experimental) @testable import MapboxMaps
import XCTest

final class AnnotationManagerImplTests: XCTestCase {
    private var harness: AnnotationManagerTestingHarness!
    private var style: MockStyle { harness.style }
    private var me: AnnotationManagerImpl<PointAnnotation>!
    private var annotations = [PointAnnotation]()

    let id = "default"
    var layerIds: [String] {
        [
            "mapbox-iOS-cluster-circle-layer-manager-\(id)",
            "mapbox-iOS-cluster-text-layer-manager-\(id)",
            id
        ]
    }

    class Delegate: AnnotationManagerImplDelegate {
        var annotations: [any Annotation]?
        var syncImagesCount = 0
        var removeImagesCount = 0
        func didTap(_ annotations: [any Annotation]) {
            self.annotations = annotations
        }
        func syncImages() { syncImagesCount += 1 }
        func removeAllImages() { removeImagesCount += 1 }
    }

    override func setUp() {
        super.setUp()
        harness = AnnotationManagerTestingHarness()

        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: ClusterOptions()),
            deps: harness.makeDeps())

        annotations = (0...10).map {
            PointAnnotation(
                id: "default-\($0)",
                coordinate: .init(latitude: LocationDegrees($0), longitude: LocationDegrees($0)), isSelected: false, isDraggable: false)
        }
    }

    override func tearDown() {
        me = nil
        harness = nil
        annotations = []
        super.tearDown()
    }

    func testSetup() throws {
        style.addSourceStub.reset()

        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: "foo",
                                            layerPosition: .at(4),
                                            clusterOptions: nil),
            deps: harness.makeDeps())

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.type, LayerType.symbol)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layer.id, "foo")
        let addedLayer = try XCTUnwrap(style.addPersistentLayerStub.invocations.last?.parameters.layer as? SymbolLayer)
        XCTAssertEqual(addedLayer.source, "foo")
        XCTAssertEqual(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition, LayerPosition.at(4))
    }

    func testDestroy() {
        me.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), layerIds)
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id])

        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        me.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testDestroyManagerWithDraggedAnnotations() {
        var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
        annotation.isDraggable = true
        me.annotations = [annotation]
        // adds drag source/layer
        harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotation.feature, context: .zero)

        me.destroy()

        XCTAssertEqual(style.removeLayerStub.invocations.map(\.parameters), layerIds + [id + "_drag"])
        XCTAssertEqual(style.removeSourceStub.invocations.map(\.parameters), [id, id + "_drag"])

        style.removeLayerStub.reset()
        style.removeSourceStub.reset()

        me.destroy()
        XCTAssertTrue(style.removeLayerStub.invocations.isEmpty)
        XCTAssertTrue(style.removeSourceStub.invocations.isEmpty)
    }

    func testSyncSourceAndLayer() {
        me.annotations = annotations
        harness.triggerDisplayLink()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testDoNotSyncSourceAndLayerWhenNotNeeded() {
        harness.$displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testFeatureCollectionPassedToGeoJSON() throws {
        let expectedFeatures = annotations.map(\.feature)

        me.annotations = annotations
        harness.triggerDisplayLink()

        var invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
        XCTAssertEqual(invocation.parameters.features, expectedFeatures)
        XCTAssertEqual(invocation.parameters.sourceId, "default")

        do {
            let annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)), isSelected: false, isDraggable: false)
            annotations.append(annotation)

            me.annotations = annotations
            harness.triggerDisplayLink()

            invocation = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last)
            XCTAssertEqual(invocation.parameters.features, [annotation].map(\.feature))
            XCTAssertEqual(invocation.parameters.sourceId, "default")
        }
    }

    func testLayerSync() throws {
        func checkExpression(key: String, props: [String: Any]) throws {
            let value = try XCTUnwrap(props[key] as? [Any])
            let valueData = try XCTUnwrap(JSONSerialization.data(withJSONObject: value))
            let valueString = try XCTUnwrap(String(data: valueData, encoding: .utf8))

            let fallbackValue = me.layerProperties[key] ?? StyleManager.layerPropertyDefaultValue(for: .symbol, property: key).value
            let fallbackValueData = JSONSerialization.isValidJSONObject(fallbackValue)
                ? try XCTUnwrap(JSONSerialization.data(withJSONObject: fallbackValue))
                : Data(String(describing: fallbackValue).utf8)
            let fallbackValueString = try XCTUnwrap(String(data: fallbackValueData, encoding: .utf8))

            let expectedString = "[\"coalesce\",[\"get\",\"\(key)\",[\"get\",\"layerProperties\"]],\(fallbackValueString)]"
            XCTAssertEqual(valueString, expectedString)
        }

        me.annotations = annotations
        let delegate = Delegate()
        me.delegate = delegate
        harness.triggerDisplayLink()

        XCTAssertEqual(delegate.syncImagesCount, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, id)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.properties.count, 0)

        style.setLayerPropertiesStub.reset()

        // Add properties
        me.annotations = [
            PointAnnotation(id: "foo", coordinate: .init(latitude: 0, longitude: 0))
                .textSize(10)
        ]
        me.layerProperties["bar"] = "Bar"
        me.layerProperties["baz"] = "Baz"
        me.layerProperties["icon-allow-overlap"] = true

        harness.triggerDisplayLink()

        XCTAssertEqual(delegate.syncImagesCount, 2)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, id)

        let props = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(props["bar"] as? String, "Bar")
        XCTAssertEqual(props["baz"] as? String, "Baz")
        XCTAssertEqual(props["icon-allow-overlap"] as? Bool, true)
        try checkExpression(key: "text-size", props: props)
        XCTAssertEqual(props.count, 4)

        style.setLayerPropertiesStub.reset()

        // Update with other properties
        me.annotations = [
            PointAnnotation(id: "foo", coordinate: .init(latitude: 0, longitude: 0))
                .textSize(20)
                .textField("Bar")
        ]
        me.layerProperties["x"] = "X"
        me.layerProperties["bar"] = "qux"
        me.layerProperties.removeValue(forKey: "icon-allow-overlap") // expected to reset unused prop to default

        harness.triggerDisplayLink()

        XCTAssertEqual(delegate.syncImagesCount, 3)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.last?.parameters.layerId, id)

        let props2 = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(props2["x"] as? String, "X")
        XCTAssertEqual(props2["bar"] as? String, "qux")

        // resets to default
        let def = StyleManager.layerPropertyDefaultValue(for: .symbol, property: "icon-allow-overlap").value as? Bool
        XCTAssertEqual(props2["icon-allow-overlap"] as? Bool, def)

        try checkExpression(key: "text-field", props: props2)
        XCTAssertEqual(props2.count, 6)
    }

    @available(*, deprecated)
    func testHandleTap() throws {
        let delegate = Delegate()
        var taps = [InteractionContext]()
        annotations[0].tapHandler = { context in
            taps.append(context)
            return true
        }
        annotations[1].tapHandler = { _ in
            return false // skips handling
        }
        me.delegate = delegate
        me.annotations = annotations

        // first annotation, handles tap
        let context = InteractionContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        harness.map.simulateInteraction(.tap, .layer(id), feature: annotations[0].feature, context: context)

        var result = try XCTUnwrap(delegate.annotations)
        XCTAssertEqual(result[0].id, annotations[0].id)

        XCTAssertEqual(taps.count, 1)
        XCTAssertEqual(taps.first?.point, context.point)
        XCTAssertEqual(taps.first?.coordinate, context.coordinate)

        // second annotation, skips handling tap
        delegate.annotations = nil
        harness.map.simulateInteraction(.tap, .layer(id), feature: annotations[1].feature, context: context)

        result = try XCTUnwrap(delegate.annotations)
        XCTAssertEqual(result[0].id, annotations[1].id)

        // invalid id
        delegate.annotations = nil
        let invalidFeature = Feature(geometry: nil)
        harness.map.simulateInteraction(.tap, .layer(id), feature: invalidFeature, context: context)

        XCTAssertNil(delegate.annotations)
        XCTAssertEqual(taps.count, 1)
    }

    func testHandleLongPress() throws {
        var taps = [InteractionContext]()
        annotations[0].longPressHandler = { context in
            taps.append(context)
            return true
        }
        me.annotations = annotations

        // first annotation, handles tap
        let context = InteractionContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        harness.map.simulateInteraction(.longPress, .layer(id), feature: annotations[0].feature, context: context)

        XCTAssertEqual(taps.count, 1)
        XCTAssertEqual(taps.first?.point, context.point)
        XCTAssertEqual(taps.first?.coordinate, context.coordinate)

        // second annotation, skips handling tap
        harness.map.simulateInteraction(.longPress, .layer(id), feature: annotations[1].feature, context: context)

        // invalid id
        let invalidFeature = Feature(geometry: nil)
        harness.map.simulateInteraction(.longPress, .layer(id), feature: invalidFeature, context: context)

        XCTAssertEqual(taps.count, 1)
    }

    func testHandleClusterTap() {
        let onClusterTap = Stub<AnnotationClusterGestureContext, Void>(defaultReturnValue: ())
        let context = InteractionContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        let annotationContext = AnnotationClusterGestureContext(point: context.point, coordinate: context.coordinate, expansionZoom: 4)
        me.onClusterTap = onClusterTap.call

        harness.map.simulateInteraction(.tap, .layer("mapbox-iOS-cluster-circle-layer-manager-default"), feature: annotations[1].feature, context: context)

        harness.mapFeatureQueryable.getGeoJsonClusterExpansionZoomStub.invocations.map(\.parameters.completion).forEach { completion in
            completion(.success(FeatureExtensionValue(value: 4, features: nil)))
        }

        XCTAssertEqual(harness.mapFeatureQueryable.getGeoJsonClusterExpansionZoomStub.invocations.map(\.parameters.feature), [
            annotations[1].feature
        ])

        XCTAssertEqual(onClusterTap.invocations.map(\.parameters), [annotationContext])
    }

    func testHandleClusterLongPress() {
        let onClusterLongPress = Stub<AnnotationClusterGestureContext, Void>(defaultReturnValue: ())
        let context = InteractionContext(point: .init(x: 1, y: 2), coordinate: .init(latitude: 3, longitude: 4))
        let annotationContext = AnnotationClusterGestureContext(point: context.point, coordinate: context.coordinate, expansionZoom: 4)
        me.onClusterLongPress = onClusterLongPress.call

        harness.map.simulateInteraction(.longPress, .layer("mapbox-iOS-cluster-circle-layer-manager-default"), feature: annotations[1].feature, context: context)

        harness.mapFeatureQueryable.getGeoJsonClusterExpansionZoomStub.invocations.map(\.parameters.completion).forEach { completion in
            completion(.success(FeatureExtensionValue(value: 4, features: nil)))
        }

        XCTAssertEqual(harness.mapFeatureQueryable.getGeoJsonClusterExpansionZoomStub.invocations.map(\.parameters.feature), [
            annotations[1].feature
        ])

        XCTAssertEqual(onClusterLongPress.invocations.map(\.parameters), [annotationContext])
    }

    // MARK: - Clustering tests
    func testInitWithDefaultClusterOptions() {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: clusterOptions),
            deps: harness.makeDeps())

        me.annotations = annotations

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
        XCTAssertEqual(style.addSourceStub.invocations.last?.parameters.source.id, id)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 3) // symbol layer, one cluster layer, one text layer
        XCTAssertNil(style.addPersistentLayerStub.invocations.last?.parameters.layerPosition)
    }

    func testSourceClusterOptions() throws {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testClusterRadius = Double.testSourceValue()
        let testClusterMaxZoom = Double.testSourceValue()
        let testClusterProperties = [String: Exp].testSourceValue()
        let clusterOptions = ClusterOptions(clusterRadius: testClusterRadius,
                                            clusterMaxZoom: testClusterMaxZoom,
                                            clusterProperties: testClusterProperties)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: clusterOptions),
            deps: harness.makeDeps())

        me.annotations = annotations
        let geoJSONSource = try XCTUnwrap(style.addSourceStub.invocations.last?.parameters.source as? GeoJSONSource)

        // then
        XCTAssertTrue(geoJSONSource.cluster!)
        XCTAssertEqual(clusterOptions.clusterRadius, testClusterRadius)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(geoJSONSource.clusterRadius, testClusterRadius)
        XCTAssertEqual(geoJSONSource.clusterMaxZoom, testClusterMaxZoom)
        XCTAssertEqual(geoJSONSource.clusterProperties, testClusterProperties)
    }

    func testCircleLayer() throws {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let testCircleRadius = Value<Double>.testConstantValue()
        let testCircleColor = Value<StyleColor>.testConstantValue()
        let clusterOptions = ClusterOptions(circleRadius: testCircleRadius,
                                            circleColor: testCircleColor)
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: clusterOptions),
            deps: harness.makeDeps())
        me.annotations = annotations

        // then
        let circleLayerInvocations = style.addPersistentLayerStub.invocations.filter { circleLayer in
            return circleLayer.parameters.layer.id == "mapbox-iOS-cluster-circle-layer-manager-" + id
        }
        let circleLayer = try XCTUnwrap(circleLayerInvocations[0].parameters.layer as? CircleLayer)

        XCTAssertEqual(clusterOptions.circleRadius, testCircleRadius)
        XCTAssertEqual(circleLayer.circleRadius, testCircleRadius)
        XCTAssertEqual(clusterOptions.circleColor, testCircleColor)
        XCTAssertEqual(circleLayer.circleColor, testCircleColor)
        XCTAssertEqual(circleLayer.filter, Exp(.has) { "point_count" })
        XCTAssertEqual(circleLayer.id, "mapbox-iOS-cluster-circle-layer-manager-" + id)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testTextLayer() throws {
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
            let annotation = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: clusterOptions),
            deps: harness.makeDeps())
        me.annotations = annotations

        // then
        let textLayerInvocations = style.addPersistentLayerStub.invocations.filter { symbolLayer in
            return symbolLayer.parameters.layer.id == "mapbox-iOS-cluster-text-layer-manager-" + id
        }
        let textLayer = try XCTUnwrap(textLayerInvocations[0].parameters.layer as? SymbolLayer)

        XCTAssertEqual(textLayer.textColor, testTextColor)
        XCTAssertEqual(textLayer.textSize, testTextSize)
        XCTAssertEqual(textLayer.textField, testTextField)
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
    }

    func testSymbolLayers() throws {
        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        // given
        let clusterOptions = ClusterOptions()
        var annotations = [PointAnnotation]()
        for _ in 0...500 {
            let annotation = PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
            annotations.append(annotation)
        }

        // when
        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: clusterOptions),
            deps: harness.makeDeps())
        me.annotations = annotations

        // then
        let symbolLayerInvocations = style.addPersistentLayerStub.invocations.filter { symbolLayer in
            return symbolLayer.parameters.layer.id == id
        }
        let symbolLayer = try XCTUnwrap(symbolLayerInvocations[0].parameters.layer as? SymbolLayer)

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
            PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
        }
        let newAnnotations = (0..<100).map { _ in
            PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
        }

        // when
        me = AnnotationManagerImpl(
            params: AnnotationManagerParams(id: id, layerPosition: nil, clusterOptions: clusterOptions),
            deps: harness.makeDeps())
        me.annotations = annotations
        harness.triggerDisplayLink()

        let parameters = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last).parameters
        XCTAssertEqual(parameters.features, annotations.map(\.feature))

        // then
        me.annotations = newAnnotations
        harness.triggerDisplayLink()

        let addParameters = try XCTUnwrap(style.addGeoJSONSourceFeaturesStub.invocations.last).parameters
        XCTAssertEqual(addParameters.features, newAnnotations.map(\.feature))

        let removeParameters = try XCTUnwrap(style.removeGeoJSONSourceFeaturesStub.invocations.last).parameters
        XCTAssertEqual(removeParameters.featureIds, annotations.map(\.id))
    }

    // MARK: - Draggable

    func testGetDraggedAnnotations() {
        let annotations = Array.random(withLength: 10) {
            PointAnnotation(coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: true)
        }
        me.annotations = annotations

        // Dragged annotation will be added to internal list of dragged annotations.
        let annotationToDrag = annotations.randomElement()!
        harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotationToDrag.feature, context: .zero)

        XCTAssertTrue(me.annotations.contains(where: { $0.id == annotationToDrag.id }))
    }

    func testHandleDragBeginIsDraggableFalse() throws {
        let annotation = PointAnnotation(id: "point1", coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: false)
        me.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()

        harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotation.feature, context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
    }

    func testDrag() throws {
        let annotation = PointAnnotation(id: "point1", coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: true)
        me.annotations = [annotation]

        style.addSourceStub.reset()
        style.addPersistentLayerStub.reset()
        harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotation.feature, context: .zero)

        let addSourceParameters = try XCTUnwrap(style.addSourceStub.invocations.last).parameters
        let addLayerParameters = try XCTUnwrap(style.addPersistentLayerStub.invocations.last).parameters

        let addedLayer = try XCTUnwrap(addLayerParameters.layer as? SymbolLayer)
        XCTAssertEqual(addedLayer.source, addSourceParameters.source.id)
        XCTAssertEqual(addLayerParameters.layerPosition, .above(id))
        XCTAssertEqual(addedLayer.id, id + "_drag")

        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
        harness.triggerDisplayLink()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 1)
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.last?.parameters.id, "\(id)_drag")

        harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotation.feature, context: .zero)

        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)

        harness.map.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        harness.map.coordinateForPointStub.defaultReturnValue = .init(latitude: 0, longitude: 0)
        harness.map.cameraState.zoom = 1

        harness.map.simulateInteraction(.drag(.change), .layer(id), feature: annotation.feature, context: .zero)

        harness.triggerDisplayLink()

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
            var context: InteractionContext
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
        me.annotations = [annotation]

        harness.map.pointStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        harness.map.coordinateForPointStub.defaultReturnValue = .init(latitude: 23.5432356, longitude: -12.5326744)
        harness.map.cameraState.zoom = 1

        var context = InteractionContext(point: CGPoint(x: 0, y: 1), coordinate: .init(latitude: 2, longitude: 3))

        // test it twice to cover the case when annotation was already on drag layer.
        for _ in 0...1 {
            beginDragStub.reset()
            changeDragStub.reset()
            endDragStub.reset()

            // skipped gesture
            beginDragStub.defaultReturnValue = false
            harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotation.feature, context: context)
            XCTAssertEqual(beginDragStub.invocations.count, 1)
            var data = try XCTUnwrap(beginDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            harness.map.simulateInteraction(.drag(.change), .layer(id), feature: annotation.feature, context: context)
            harness.map.simulateInteraction(.drag(.end), .layer(id), feature: annotation.feature, context: context)
            XCTAssertEqual(changeDragStub.invocations.count, 0)
            XCTAssertEqual(endDragStub.invocations.count, 0)

            // handled gesture
            context.point.x += 1
            context.coordinate.latitude += 1
            beginDragStub.defaultReturnValue = true

            harness.map.simulateInteraction(.drag(.begin), .layer(id), feature: annotation.feature, context: context)
            XCTAssertEqual(beginDragStub.invocations.count, 2)
            data = try XCTUnwrap(beginDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            context.point.x += 1
            context.coordinate.latitude += 1
            harness.map.simulateInteraction(.drag(.change), .layer(id), feature: annotation.feature, context: context)
            XCTAssertEqual(changeDragStub.invocations.count, 1)
            data = try XCTUnwrap(changeDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)

            context.point.x += 1
            context.coordinate.latitude += 1
            harness.map.simulateInteraction(.drag(.end), .layer(id), feature: annotation.feature, context: context)
            XCTAssertEqual(endDragStub.invocations.count, 1)
            data = try XCTUnwrap(endDragStub.invocations.last).parameters
            XCTAssertEqual(data.annotation.id, annotation.id)
            XCTAssertEqual(data.context.point, context.point)
            XCTAssertEqual(data.context.coordinate, context.coordinate)
        }
    }

    func testDoesNotUpdateDragSourceWhenNoDragged() {
        let annotation = PointAnnotation(id: "point1", coordinate: .init(latitude: 0, longitude: 0), isSelected: false, isDraggable: true)
        me.annotations = [annotation]
        harness.triggerDisplayLink()
        XCTAssertEqual(style.updateGeoJSONSourceStub.invocations.count, 0)
    }

    func testRemovingDuplicatedAnnotations() {
        let annotation1 = PointAnnotation(id: "A", point: .init(.init(latitude: 1, longitude: 1)), isSelected: false, isDraggable: false)
        let annotation2 = PointAnnotation(id: "B", point: .init(.init(latitude: 2, longitude: 2)), isSelected: false, isDraggable: false)
        let annotation3 = PointAnnotation(id: "A", point: .init(.init(latitude: 3, longitude: 3)), isSelected: false, isDraggable: false)
        me.annotations = [annotation1, annotation2, annotation3]

        XCTAssertEqual(me.annotations, [
            annotation1,
            annotation2
        ])
    }

    func testSetNewAnnotations() {
        let annotation1 = PointAnnotation(id: "A", point: .init(.init(latitude: 1, longitude: 1)), isSelected: false, isDraggable: false)
        let annotation2 = PointAnnotation(id: "B", point: .init(.init(latitude: 2, longitude: 2)), isSelected: false, isDraggable: false)
        let annotation3 = PointAnnotation(id: "C", point: .init(.init(latitude: 3, longitude: 3)), isSelected: false, isDraggable: false)

        me.set(newAnnotations: [
            (1, annotation1),
            (2, annotation2)
        ])

        XCTAssertEqual(me.annotations.map(\.id), ["A", "B"])

        me.set(newAnnotations: [
            (1, annotation3),
            (2, annotation2)
        ])

        XCTAssertEqual(me.annotations.map(\.id), ["A", "B"])

        me.set(newAnnotations: [
            (3, annotation3),
            (2, annotation2)
        ])

        XCTAssertEqual(me.annotations.map(\.id), ["C", "B"])
    }
}
