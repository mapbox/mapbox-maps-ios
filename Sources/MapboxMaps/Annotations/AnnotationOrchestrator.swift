import UIKit
@_implementationOnly import MapboxCommon_Private

internal class MoveDistancesObject {
    var distanceXSinceLast = 0.0
    var distanceYSinceLast = 0.0
    var prevX = Double()
    var prevY = Double()
}

/// A top-level interface for annotations.
public protocol Annotation {

    /// The unique identifier of the annotation.
    var id: String { get }

    /// The geometry that is backing this annotation.
    var geometry: Geometry { get }

    /// Properties associated with the annotation.
    var userInfo: [String: Any]? { get set }
}

public protocol AnnotationManager: AnyObject {

    /// The id of this annotation manager.
    var id: String { get }

    /// The id of the `GeoJSONSource` that this manager is responsible for.
    var sourceId: String { get }

    /// The id of the layer that this manager is responsible for.
    var layerId: String { get }
}

internal protocol AnnotationManagerInternal: AnnotationManager {
    var delegate: AnnotationInteractionDelegate? { get }

    func destroy()

    func handleQueriedFeatureIds(_ queriedFeatureIds: [String])

    func handleDragBegin(at position: CGPoint, querriedFeatureIdentifiers: [String])

    func handleDragChanged(to position: CGPoint)

    func handleDragEnded()
}

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
public protocol AnnotationInteractionDelegate: AnyObject {

    /// This method is invoked when a tap gesture is detected on an annotation
    /// - Parameters:
    ///   - manager: The `AnnotationManager` that detected this tap gesture
    ///   - annotations: A list of `Annotations` that were tapped
    func annotationManager(_ manager: AnnotationManager,
                           didDetectTappedAnnotations annotations: [Annotation])

}

/// `AnnotationOrchestrator` provides a way to create annotation managers of different types.
public class AnnotationOrchestrator {

    private let tapGestureRecognizer: UIGestureRecognizer

    private let longPressGestureRecognizer: UIGestureRecognizer

    private let style: Style

    private let mapFeatureQueryable: MapFeatureQueryable

    private let offsetPointCalculator: OffsetPointCalculator

    private let offsetLineStringCalculator: OffsetLineStringCalculator

    private let offsetPolygonCalculator: OffsetPolygonCalculator

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    internal init(tapGestureRecognizer: UIGestureRecognizer,
                  longPressGestureRecognizer: UIGestureRecognizer,
                  mapFeatureQueryable: MapFeatureQueryable,
                  style: Style,
                  displayLinkCoordinator: DisplayLinkCoordinator,
                  offsetPointCalculator: OffsetPointCalculator,
                  offsetLineStringCalculator: OffsetLineStringCalculator,
                  offsetPolygonCalculator: OffsetPolygonCalculator) {
        self.tapGestureRecognizer = tapGestureRecognizer
        self.longPressGestureRecognizer = longPressGestureRecognizer
        self.mapFeatureQueryable = mapFeatureQueryable
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.offsetPointCalculator = offsetPointCalculator
        self.offsetLineStringCalculator = offsetLineStringCalculator
        self.offsetPolygonCalculator = offsetPolygonCalculator

        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        longPressGestureRecognizer.addTarget(self, action: #selector(handleDrag(_:)))
    }

    /// Dictionary of annotation managers keyed by their identifiers.
    public var annotationManagersById: [String: AnnotationManager] {
        annotationManagersByIdInternal
    }

    private var annotationManagersByIdInternal = [String: AnnotationManagerInternal]()

    /// Creates a `PointAnnotationManager` which is used to manage a collection of
    /// `PointAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PointAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    ///   - clusterOptions: Optionally set the `ClusterOptions` to cluster the Point Annotations
    /// - Returns: An instance of `PointAnnotationManager`
    public func makePointAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                           layerPosition: LayerPosition? = nil,
                                           clusterOptions: ClusterOptions? = nil) -> PointAnnotationManager {
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = PointAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `PolygonAnnotationManager` which is used to manage a collection of
    /// `PolygonAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PolygonAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager..
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolygonAnnotationManager`
    public func makePolygonAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                             layerPosition: LayerPosition? = nil) -> PolygonAnnotationManager {
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = PolygonAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPolygonCalculator: offsetPolygonCalculator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `PolylineAnnotationManager` which is used to manage a collection of
    /// `PolylineAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `PolylineAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `PolylineAnnotationManager`
    public func makePolylineAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                              layerPosition: LayerPosition? = nil) -> PolylineAnnotationManager {
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = PolylineAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetLineStringCalculator: offsetLineStringCalculator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Creates a `CircleAnnotationManager` which is used to manage a collection of
    /// `CircleAnnotation`s. Annotations persist across style changes. If an annotation manager with
    /// the same `id` has already been created, the old one will be removed as if
    /// `removeAnnotationManager(withId:)` had been called. `AnnotationOrchestrator`
    ///  keeps a strong reference to any `CircleAnnotationManager` until it is removed.
    /// - Parameters:
    ///   - id: Optional string identifier for this manager.
    ///   - layerPosition: Optionally set the `LayerPosition` of the layer managed.
    /// - Returns: An instance of `CircleAnnotationManager`
    public func makeCircleAnnotationManager(id: String = String(UUID().uuidString.prefix(5)),
                                            layerPosition: LayerPosition? = nil) -> CircleAnnotationManager {
        guard let displayLinkCoordinator = displayLinkCoordinator else {
            fatalError("DisplayLinkCoordinator must be present when creating an annotation manager")
        }
        removeAnnotationManager(withId: id, warnIfRemoved: true, function: #function)
        let annotationManager = CircleAnnotationManager(
            id: id,
            style: style,
            layerPosition: layerPosition,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator)
        annotationManagersByIdInternal[id] = annotationManager
        return annotationManager
    }

    /// Removes an annotation manager, this will remove the underlying layer and source from the style.
    /// A removed annotation manager will not be able to reuse anymore, you will need to create new annotation manger to add annotations.
    /// - Parameter id: Identifer of annotation manager to remove
    public func removeAnnotationManager(withId id: String) {
        removeAnnotationManager(withId: id, warnIfRemoved: false, function: #function)
    }

    private func removeAnnotationManager(withId id: String, warnIfRemoved: Bool, function: StaticString) {
        guard let annotationManager = annotationManagersByIdInternal.removeValue(forKey: id) else {
            return
        }
        annotationManager.destroy()
        if warnIfRemoved {
            Log.warning(
                forMessage: "\(type(of: annotationManager)) with id \(id) was removed implicitly when invoking \(function) with the same id.",
                category: "Annotations")
        }
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let managers = annotationManagersByIdInternal.values.filter { $0.delegate != nil }
        guard !managers.isEmpty else { return }

        let layerIds = managers.map { $0.layerId }
        let options = RenderedQueryOptions(layerIds: layerIds, filter: nil)
        mapFeatureQueryable.queryRenderedFeatures(
            at: tap.location(in: tap.view),
            options: options) { (result) in

                switch result {

                case .success(let queriedFeatures):

                    // Get the identifiers of all the queried features
                    let queriedFeatureIds: [String] = queriedFeatures.compactMap {
                        guard case let .string(featureId) = $0.feature.identifier else {
                            return nil
                        }
                        return featureId
                    }

                    for manager in managers {
                        manager.handleQueriedFeatureIds(queriedFeatureIds)
                    }
                case .failure(let error):
                    Log.warning(forMessage: "Failed to query map for annotations due to error: \(error)",
                                category: "Annotations")
                }
            }
    }

    @objc private func handleDrag(_ drag: UILongPressGestureRecognizer) {
        let managers = annotationManagersByIdInternal.values.filter { $0.delegate != nil }
        guard !managers.isEmpty else { return }

        let layerIdentifiers = managers.map(\.layerId)
        let options = RenderedQueryOptions(layerIds: layerIdentifiers, filter: nil)
        let gestureLocation = drag.location(in: drag.view)

        switch drag.state {
        case .began:
            mapFeatureQueryable.queryRenderedFeatures(at: gestureLocation, options: options) { result in

                switch result {
                case .success(let queriedFeatures):
                    let queriedFeatureIds: [String] = queriedFeatures.compactMap {
                        guard case let .string(featureId) = $0.feature.identifier else {
                            return nil
                        }
                        return featureId
                    }

                    for manager in managers {
                        manager.handleDragBegin(at: gestureLocation, querriedFeatureIdentifiers: queriedFeatureIds)
                    }

                case .failure(let error):
                    Log.error(forMessage: error.localizedDescription, category: "Gestures")
                }
            }

        case .changed:
            for manager in managers {
                manager.handleDragChanged(to: gestureLocation)
            }

        case .ended, .cancelled:
            for manager in managers {
                manager.handleDragEnded()
            }

        case .possible: fallthrough
        case .failed: fallthrough
        @unknown default: break
        }
    }
}

internal protocol OffsetGeometryCalculator {
    associatedtype GeometryType: GeometryConvertible
    func geometry(at distance: MoveDistancesObject, from geometry: GeometryType) -> GeometryType?
}

internal struct OffsetPointCalculator: OffsetGeometryCalculator {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    func geometry(at distance: MoveDistancesObject, from geometry: Point) -> Point? {
        let validMercatorLatitude = (-85.05112877980659...85.05112877980659)
        let point = geometry.coordinates

        let centerScreenCoordinate = mapboxMap.point(for: point)

        let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(
            x: centerScreenCoordinate.x - distance.distanceXSinceLast,
            y: centerScreenCoordinate.y - distance.distanceYSinceLast))

        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(startPoint: Point(point), endPoint: targetPoint, zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoints = Projection.shiftPointWithMercatorCoordinate(point: Point(point), shiftMercatorCoordinate: shiftMercatorCoordinate, zoomLevel: mapboxMap.cameraState.zoom)

        if targetPoints.coordinates.latitude > Projection.latitudeMax || targetPoints.coordinates.latitude < Projection.latitudeMin {
            return nil
        }
        return Point(targetPoints.coordinates)
    }
}

internal struct OffsetLineStringCalculator: OffsetGeometryCalculator {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    func geometry(at distance: MoveDistancesObject, from geometry: LineString) -> LineString? {
        let validMercatorLatitude = (-85.05112877980659...85.05112877980659)
        let startPoints = geometry.coordinates

        if startPoints.isEmpty {
            return nil
        }
        let latitudeSum = startPoints.map { $0.latitude }.reduce(0, +)
        let longitudeSum = startPoints.map { $0.longitude }.reduce(0, +)
        let latitudeAverage = latitudeSum / CGFloat(startPoints.count)
        let longitudeAverage = longitudeSum / CGFloat(startPoints.count)

        let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

        let centerPoint = Point(averageCoordinates)

        let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

        let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(
            x: centerScreenCoordinate.x - distance.distanceXSinceLast,
            y: centerScreenCoordinate.y - distance.distanceYSinceLast))

        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(startPoint: centerPoint, endPoint: targetPoint, zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoints = startPoints.map {Projection.shiftPointWithMercatorCoordinate(point: Point($0), shiftMercatorCoordinate: shiftMercatorCoordinate, zoomLevel: mapboxMap.cameraState.zoom)}

        guard let targetPointLatitude = targetPoints.first?.coordinates.latitude else {
            return nil
        }

        guard validMercatorLatitude.contains(targetPointLatitude) else {
            return nil
        }
        return LineString(.init(coordinates: targetPoints.map {$0.coordinates}))
    }
}

internal struct OffsetPolygonCalculator: OffsetGeometryCalculator {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    func geometry(at distance: MoveDistancesObject, from geometry: Polygon) -> Polygon? {
        let validMercatorLatitude = (-85.05112877980659...85.05112877980659)
        var outerRing = [CLLocationCoordinate2D]()
        var innerRing: [CLLocationCoordinate2D]?
        let startPoints = geometry.outerRing.coordinates
        if startPoints.isEmpty {
            return nil
        }

        let latitudeSum = startPoints.map { $0.latitude }.reduce(0, +)
        let longitudeSum = startPoints.map { $0.longitude }.reduce(0, +)
        let latitudeAverage = latitudeSum / CGFloat(startPoints.count)
        let longitudeAverage = longitudeSum / CGFloat(startPoints.count)

        let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

        let centerPoint = Point(averageCoordinates)

        let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

        let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(x: centerScreenCoordinate.x - distance.distanceXSinceLast, y: centerScreenCoordinate.y - distance.distanceYSinceLast))

        let targetPoint = Point(targetCoordinates)

        let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(
            startPoint: centerPoint,
            endPoint: targetPoint,
            zoomLevel: mapboxMap.cameraState.zoom)

        let targetPoints = startPoints.map {Projection.shiftPointWithMercatorCoordinate(
            point: Point($0),
            shiftMercatorCoordinate: shiftMercatorCoordinate,
            zoomLevel: mapboxMap.cameraState.zoom)}

        guard let targetPointLatitude = targetPoints.first?.coordinates.latitude else {
            return nil
        }

        guard validMercatorLatitude.contains(targetPointLatitude) else {
            return nil
        }

        outerRing = targetPoints.map {$0.coordinates}

        if !geometry.innerRings.isEmpty {

            var innerRings = [Ring]()
            for ring in geometry.innerRings {
                let startPoints = ring.coordinates
                if startPoints.isEmpty {
                    return nil
                }

                let latitudeSum = startPoints.map { $0.latitude }.reduce(0, +)
                let longitudeSum = startPoints.map { $0.longitude }.reduce(0, +)
                let latitudeAverage = latitudeSum / CGFloat(startPoints.count)
                let longitudeAverage = longitudeSum / CGFloat(startPoints.count)

                let averageCoordinates = CLLocationCoordinate2D(latitude: latitudeAverage, longitude: longitudeAverage)

                let centerPoint = Point(averageCoordinates)

                let centerScreenCoordinate = mapboxMap.point(for: centerPoint.coordinates)

                let targetCoordinates =  mapboxMap.coordinate(for: CGPoint(x: centerScreenCoordinate.x - distance.distanceXSinceLast, y: centerScreenCoordinate.y - distance.distanceYSinceLast))

                let targetPoint = Point(targetCoordinates)

                let shiftMercatorCoordinate = Projection.calculateMercatorCoordinateShift(
                    startPoint: centerPoint,
                    endPoint: targetPoint,
                    zoomLevel: mapboxMap.cameraState.zoom)

                let targetPoints = startPoints.map {Projection.shiftPointWithMercatorCoordinate(
                    point: Point($0),
                    shiftMercatorCoordinate: shiftMercatorCoordinate,
                    zoomLevel: mapboxMap.cameraState.zoom)}

                guard let targetPointLatitude = targetPoints.first?.coordinates.latitude else {
                    return nil
                }

                guard validMercatorLatitude.contains(targetPointLatitude) else {
                    return nil
                }

                innerRing = targetPoints.map {$0.coordinates}
                guard let innerRing = innerRing else { return nil }
                innerRings.append(.init(coordinates: innerRing))

            }
            return Polygon(outerRing: .init(coordinates: outerRing), innerRings: innerRings)
        }
        return Polygon(outerRing: .init(coordinates: outerRing))
    }
}
