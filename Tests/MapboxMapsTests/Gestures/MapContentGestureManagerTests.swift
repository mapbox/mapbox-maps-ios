@testable import MapboxMaps
import MapboxCommon
import UIKit
import XCTest

class MapContentGestureManagerTests: XCTestCase {
    var me: MapContentGestureManager!
    var annotations: MockAnnotationOrchestatorImpl!
    var mapboxMap: MockMapboxMap!
    var featureQueryable: MockMapFeatureQueryable!
    @TestSignal var onTap: Signal<CGPoint>
    @TestSignal var onLongPress: Signal<(CGPoint, UIGestureRecognizer.State)>
    var tokens = Set<AnyCancelable>()
    var mapTaps = [MapContentGestureContext]()
    var mapLongPresses = [MapContentGestureContext]()
    var layerTaps = [(QueriedFeature, MapContentGestureContext)]()
    var layerLongPresses = [(QueriedFeature, MapContentGestureContext)]()
    var layerHandledTap = true
    var layerHandledLongPress = true

    override func setUp() {
        annotations = MockAnnotationOrchestatorImpl()
        mapboxMap = MockMapboxMap()
        featureQueryable = MockMapFeatureQueryable()
        me = MapContentGestureManager(
            annotations: annotations,
            mapboxMap: mapboxMap,
            mapFeatureQueryable: featureQueryable,
            onTap: onTap,
            onLongPress: onLongPress)

        me.onMapTap.observe { [unowned self] in self.mapTaps.append($0) }.store(in: &tokens)
        me.onMapLongPress.observe { [unowned self] in self.mapLongPresses.append($0) }.store(in: &tokens)

        me.onLayerTap("observed-layer") { [unowned self] in
            self.layerTaps.append(($0, $1))
            return self.layerHandledTap
        }.store(in: &tokens)

        me.onLayerLongPress("observed-layer") { [unowned self] in
            self.layerLongPresses.append(($0, $1))
            return layerHandledLongPress
        }.store(in: &tokens)
    }

    override func tearDown() {
        layerHandledTap = true
        layerHandledLongPress = true
        tokens.removeAll()
        mapTaps.removeAll()
        mapLongPresses.removeAll()
        annotations = nil
        mapboxMap = nil
        featureQueryable = nil
        me = nil

    }

    func testTapOnMap() throws {
        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onTap.send(point)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.last?.parameters, point)
        XCTAssertEqual(featureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        featureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion(.success([]))

        XCTAssertEqual(mapTaps.count, 1)
        let mapTapParams = try XCTUnwrap(mapTaps.last)
        XCTAssertEqual(mapTapParams.point, point)
        XCTAssertEqual(mapTapParams.coordinate, coordinate)
    }

    func testLongPressOnMap() throws {
        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onLongPress.send((point, .began))
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.last?.parameters, point)
        XCTAssertEqual(featureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        featureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion(.success([]))

        XCTAssertEqual(mapLongPresses.count, 1)
        XCTAssertEqual(mapLongPresses.last?.point, point)
        XCTAssertEqual(mapLongPresses.last?.coordinate, coordinate)
    }

    func testTapOnLayer()  throws {
        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onTap.send(point)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.last?.parameters, point)
        XCTAssertEqual(featureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        let queryParameters = try XCTUnwrap(featureQueryable.queryRenderedFeaturesAtStub.invocations.first).parameters
        XCTAssertEqual(queryParameters.point, point)
        XCTAssertEqual(queryParameters.options?.layerIds, ["observed-layer"])

        let renderedFeature = makeRenderedFeature(coordinate: coordinate, layerId: "observed-layer")
        queryParameters.completion(.success([renderedFeature]))

        XCTAssertEqual(layerTaps.count, 1)
        let layerTapParams = try XCTUnwrap(layerTaps.last)
        XCTAssertEqual(layerTapParams.0, renderedFeature.queriedFeature)
        XCTAssertEqual(layerTapParams.1.point, point)
        XCTAssertEqual(layerTapParams.1.coordinate, coordinate)

        XCTAssertEqual(mapTaps.count, 0) // layer handled tap, not propagated to the map

        layerHandledTap = false
        $onTap.send(point)
        featureQueryable.queryRenderedFeaturesAtStub.invocations.last?.parameters.completion(.success([renderedFeature]))
        XCTAssertEqual(layerTaps.count, 2)
        XCTAssertEqual(mapTaps.count, 1) // layer didn't handle the tap, propagated to the map.
        XCTAssertEqual(mapTaps.last?.coordinate, coordinate)
        XCTAssertEqual(mapTaps.last?.point, point)
    }

    func testLongPressOnLayer()  throws {
        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onLongPress.send((point, .began))
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.last?.parameters, point)
        XCTAssertEqual(featureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        let queryParameters = try XCTUnwrap(featureQueryable.queryRenderedFeaturesAtStub.invocations.first).parameters
        XCTAssertEqual(queryParameters.point, point)
        XCTAssertEqual(queryParameters.options?.layerIds, ["observed-layer"])

        let renderedFeature = makeRenderedFeature(coordinate: coordinate, layerId: "observed-layer")
        queryParameters.completion(.success([renderedFeature]))

        XCTAssertEqual(layerLongPresses.count, 1)
        let layerTapParams = try XCTUnwrap(layerLongPresses.last)
        XCTAssertEqual(layerTapParams.0, renderedFeature.queriedFeature)
        XCTAssertEqual(layerTapParams.1.point, point)
        XCTAssertEqual(layerTapParams.1.coordinate, coordinate)

        layerHandledLongPress = false
        $onLongPress.send((point, .began))
        featureQueryable.queryRenderedFeaturesAtStub.invocations.last?.parameters.completion(.success([renderedFeature]))
        XCTAssertEqual(layerLongPresses.count, 2)
        XCTAssertEqual(mapLongPresses.count, 1) // layer didn't handle the long press, propagated to the map.
        XCTAssertEqual(mapLongPresses.last?.coordinate, coordinate)
        XCTAssertEqual(mapLongPresses.last?.point, point)
    }

    func testAnnotationTap() throws {
        let manager = MockAnnotationManager()
        let managersByLayerId = [
            "annotation-layer": manager
        ]
        annotations.$managersByLayerId.getStub.defaultReturnValue = managersByLayerId

        manager.handleTapStub.defaultReturnValue = true // handles the tap

        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onTap.send(point)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.last?.parameters, point)
        XCTAssertEqual(featureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        let queryParameters = try XCTUnwrap(featureQueryable.queryRenderedFeaturesAtStub.invocations.first).parameters
        XCTAssertEqual(queryParameters.point, point)
        let layerIds = try XCTUnwrap(queryParameters.options?.layerIds)
        XCTAssertEqual(Set(layerIds), Set(["observed-layer", "annotation-layer"]))

        let renderedFeature = makeRenderedFeature(id: "annotation-id", coordinate: coordinate, layerId: "annotation-layer")
        queryParameters.completion(.success([renderedFeature]))

        XCTAssertEqual(manager.handleTapStub.invocations.count, 1)
        let handleTapParameters = try XCTUnwrap(manager.handleTapStub.invocations.last).parameters
        XCTAssertEqual(handleTapParameters.feature.identifier?.string, "annotation-id")
        XCTAssertEqual(handleTapParameters.context.point, point)
        XCTAssertEqual(handleTapParameters.context.coordinate, coordinate)

        XCTAssertEqual(mapTaps.count, 0)
        $onTap.send(point)
        manager.handleTapStub.defaultReturnValue = false // don't handle tap, pass to map
        featureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion(.success([renderedFeature]))
        XCTAssertEqual(mapTaps.count, 1)
        XCTAssertEqual(mapTaps.first?.point, point)
        XCTAssertEqual(mapTaps.first?.coordinate, coordinate)
    }

    func testAnnotationLongPress() throws {
        let manager = MockAnnotationManager()
        let managersByLayerId = [
            "annotation-layer": manager
        ]
        annotations.$managersByLayerId.getStub.defaultReturnValue = managersByLayerId

        manager.handleLongPressStub.defaultReturnValue = true // handles the long-press

        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onLongPress.send((point, .began))
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.coordinateForPointStub.invocations.last?.parameters, point)
        XCTAssertEqual(featureQueryable.queryRenderedFeaturesAtStub.invocations.count, 1)
        let queryParameters = try XCTUnwrap(featureQueryable.queryRenderedFeaturesAtStub.invocations.first).parameters
        XCTAssertEqual(queryParameters.point, point)
        let layerIds = try XCTUnwrap(queryParameters.options?.layerIds)
        XCTAssertEqual(Set(layerIds), Set(["observed-layer", "annotation-layer"]))

        let renderedFeature = makeRenderedFeature(id: "annotation-id", coordinate: coordinate, layerId: "annotation-layer")
        queryParameters.completion(.success([renderedFeature]))

        XCTAssertEqual(manager.handleLongPressStub.invocations.count, 1)
        let handleLPParameters = try XCTUnwrap(manager.handleLongPressStub.invocations.last).parameters
        XCTAssertEqual(handleLPParameters.feature.identifier?.string, "annotation-id")
        XCTAssertEqual(handleLPParameters.context.point, point)
        XCTAssertEqual(handleLPParameters.context.coordinate, coordinate)

        XCTAssertEqual(mapLongPresses.count, 0)
        $onTap.send(point)
        manager.handleLongPressStub.defaultReturnValue = false // don't handle press, pass to map
        featureQueryable.queryRenderedFeaturesAtStub.invocations.first?.parameters.completion(.success([renderedFeature]))
        XCTAssertEqual(mapLongPresses.count, 1)
        XCTAssertEqual(mapLongPresses.first?.point, point)
        XCTAssertEqual(mapLongPresses.first?.coordinate, coordinate)
    }

    func testAnnotationDrag() throws {
        let manager = MockAnnotationManager()
        let managersByLayerId = [
            "annotation-layer": manager
        ]
        annotations.$managersByLayerId.getStub.defaultReturnValue = managersByLayerId

        manager.handleDragBeginStub.defaultReturnValue = true // handles the drag

        var point = CGPoint(x: 10, y: 20)
        var coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        $onLongPress.send((point, .began))

        let queryParameters = try XCTUnwrap(featureQueryable.queryRenderedFeaturesAtStub.invocations.first).parameters
        XCTAssertEqual(queryParameters.point, point)
        let layerIds = try XCTUnwrap(queryParameters.options?.layerIds)
        XCTAssertEqual(Set(layerIds), Set(["observed-layer", "annotation-layer"]))

        let renderedFeature = makeRenderedFeature(id: "annotation-id", coordinate: coordinate, layerId: "annotation-layer")
        queryParameters.completion(.success([renderedFeature]))

        XCTAssertEqual(manager.handleDragBeginStub.invocations.count, 1)
        let startParameters = try XCTUnwrap(manager.handleDragBeginStub.invocations.last).parameters
        XCTAssertEqual(startParameters.featureId, "annotation-id")
        XCTAssertEqual(startParameters.context.point, point)
        XCTAssertEqual(startParameters.context.coordinate, coordinate)

        var translation = CGPoint(x: 10, y: 10)
        point = point + translation
        coordinate.latitude += 10
        coordinate.latitude += 5
        mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate
        $onLongPress.send((point, .changed))
        XCTAssertEqual(manager.handleDragChangeStub.invocations.count, 1)
        var dragParams = try XCTUnwrap(manager.handleDragChangeStub.invocations.last).parameters
        XCTAssertEqual(dragParams.translation, CGPoint(x: -10, y: -10))
        XCTAssertEqual(dragParams.context.point, CGPoint(x: 20.0, y: 30.0))
        XCTAssertEqual(dragParams.context.coordinate, coordinate)

        translation = CGPoint(x: 5, y: 2)
        point = point + translation
        $onLongPress.send((point, .changed))
        XCTAssertEqual(manager.handleDragChangeStub.invocations.count, 2)
        dragParams = try XCTUnwrap(manager.handleDragChangeStub.invocations.last).parameters
        XCTAssertEqual(dragParams.translation, CGPoint(x: -5, y: -2))
        XCTAssertEqual(dragParams.context.point, CGPoint(x: 25, y: 32))
        XCTAssertEqual(dragParams.context.coordinate, coordinate)

        $onLongPress.send((point, .ended))
        XCTAssertEqual(manager.handleDragEndStub.invocations.count, 1)
        let endContext = try XCTUnwrap(manager.handleDragEndStub.invocations.first).parameters
        XCTAssertEqual(endContext.point, CGPoint(x: 25, y: 32))
        XCTAssertEqual(endContext.coordinate, coordinate)
    }
}

private func makeRenderedFeature(id: String? = nil, coordinate: CLLocationCoordinate2D, layerId: String) -> QueriedRenderedFeature {
    var feature = Feature(geometry: Point(coordinate))
    feature.identifier = id.map { .string($0) }
    let queriedFeature = QueriedFeature(
        __feature: MapboxCommon.Feature(feature),
        source: "src",
        sourceLayer: "src-layer",
        state: [String: Any]())
    return QueriedRenderedFeature(__queriedFeature: queriedFeature, layers: [layerId])
}
