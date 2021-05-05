import MapboxCoreMaps
import Turf
import UIKit

public final class MapboxMap {
    /// The underlying renderer object responsible for rendering the map
    public let __map: Map

    internal var size: CGSize {
        get {
            CGSize(__map.getSize())
        }
        set {
            __map.setSizeFor(Size(newValue))
        }
    }

    internal init(mapClient: MapClient, mapInitOptions: MapInitOptions) {
        __map = Map(
            client: mapClient,
            mapOptions: mapInitOptions.mapOptions,
            resourceOptions: mapInitOptions.resourceOptions)
        __map.createRenderer()
    }

    internal var cameraState: CameraState {
        return CameraState(__map.getCameraState())
    }

    internal func updateCamera(with cameraOptions: CameraOptions) {
        __map.setCameraFor(MapboxCoreMaps.CameraOptions(cameraOptions))
    }

    // MARK: - Camera Fitting

    /// Calculates a `CameraOptions` to fit a `CoordinateBounds`
    ///
    /// - Parameters:
    ///   - coordinateBounds: The coordinate bounds that will be displayed within the viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    public func camera(for coordinateBounds: CoordinateBounds,
                       padding: UIEdgeInsets,
                       bearing: Double?,
                       pitch: Double?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinateBounds(
                for: coordinateBounds,
                padding: padding.toMBXEdgeInsetsValue(),
                bearing: bearing?.NSNumber,
                pitch: pitch?.NSNumber))
    }

    /// Calculates a `CameraOptions` to fit a list of coordinates.
    ///
    /// - Parameters:
    ///   - coordinates: Array of coordinates that should fit within the new viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    public func camera(for coordinates: [CLLocationCoordinate2D],
                       padding: UIEdgeInsets,
                       bearing: Double?,
                       pitch: Double?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinates(
                forCoordinates: coordinates.map(\.location),
                padding: padding.toMBXEdgeInsetsValue(),
                bearing: bearing?.NSNumber,
                pitch: pitch?.NSNumber))
    }

    /// Calculates a `CameraOptions` to fit a list of coordinates into a sub-rect of the map.
    ///
    /// Adjusts the zoom of `camera` to fit `coordinates` into `rect`.
    ///
    /// - Parameters:
    ///   - coordinates: The coordinates to frame within `rect`.
    ///   - camera: The camera for which the zoom should be adjusted to fit `coordinates`. `camera.center` must be non-nil.
    ///   - rect: The rectangle inside of the map that should be used to frame `coordinates`.
    /// - Returns: A `CameraOptions` that fits the provided constraints, or `cameraOptions` if an error occurs.
    public func camera(for coordinates: [CLLocationCoordinate2D],
                       camera: CameraOptions,
                       rect: CGRect) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinates(
                forCoordinates: coordinates.map(\.location),
                camera: MapboxCoreMaps.CameraOptions(camera),
                box: ScreenBox(rect)))
    }

    /// Calculates a `CameraOptions` to fit a geometry
    ///
    /// - Parameters:
    ///   - geometry: The geoemtry that will be displayed within the viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    public func camera(for geometry: Geometry,
                       padding: UIEdgeInsets,
                       bearing: CGFloat?,
                       pitch: CGFloat?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForGeometry(
                for: MBXGeometry(geometry: geometry),
                padding: padding.toMBXEdgeInsetsValue(),
                bearing: bearing?.NSNumber,
                pitch: pitch?.NSNumber))
    }

    // MARK: - CameraOptions to CoordinateBounds

    /// Returns the coordinate bounds corresponding to a given `CameraOptions`
    ///
    /// - Parameter camera: The camera for which the coordinate bounds will be returned.
    /// - Returns: `CoordinateBounds` for the given `CameraOptions`
    public func coordinateBounds(for camera: CameraOptions) -> CoordinateBounds {
        return __map.coordinateBoundsForCamera(
            forCamera: MapboxCoreMaps.CameraOptions(camera))
    }

    /// Converts a point in the mapView's coordinate system to a geographic coordinate. The point must exist in the coordinate space of the `MapView`
    /// - Parameter point: The point to convert. Must exist in the coordinate space of the `MapView`
    /// - Returns: A `CLLocationCoordinate` that represents the geographic location of the point.
    public func coordinate(for point: CGPoint) -> CLLocationCoordinate2D {
        return __map.coordinateForPixel(forPixel: point.screenCoordinate)
    }
    
    /// Converts a map coordinate to a `CGPoint`, relative to the `MapView`.
    /// - Parameter coordinate: The coordinate to convert.
    /// - Returns: A `CGPoint` relative to the `UIView`.
    public func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        return __map.pixelForCoordinate(for: coordinate).point
    }
    
    /// Transforms a view's frame into a set of coordinate bounds
    /// - Parameter rect: The `rect` whose bounds will be transformed into a set of map coordinate bounds.
    /// - Returns: A `CoordinateBounds` object that represents the southwest and northeast corners of the view's bounds.
    public func coordinateBounds(for rect: CGRect) -> CoordinateBounds {
        let topRight = coordinate(for: CGPoint(x: rect.maxX, y: rect.minY)).wrap()
        let bottomLeft = coordinate(for: CGPoint(x: rect.minX, y: rect.maxY)).wrap()

        let southwest = CLLocationCoordinate2D(latitude: bottomLeft.latitude, longitude: bottomLeft.longitude)
        let northeast = CLLocationCoordinate2D(latitude: topRight.latitude, longitude: topRight.longitude)

        return CoordinateBounds(southwest: southwest, northeast: northeast)
    }
    
    /// Transforms a set of map coordinate bounds to a `CGRect` relative to the `MapView`.
    /// - Parameter coordinateBounds: The `coordinateBounds` that will be converted into a rect relative to the `MapView`
    /// - Returns: A `CGRect` whose corners represent the vertices of a set of `CoordinateBounds`.
    public func rect(for coordinateBounds: CoordinateBounds) -> CGRect {
        let southwest = coordinateBounds.southwest.wrap()
        let northeast = coordinateBounds.northeast.wrap()
        
        var rect = CGRect.zero
        
        let swPoint = point(for: southwest)
        let nePoint = point(for: northeast)
        
        rect = CGRect(origin: swPoint, size: CGSize.zero)
        
        rect = rect.extend(from: nePoint)
        
        return rect
    }
}
