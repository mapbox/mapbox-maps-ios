import Foundation
import MapboxCoreMaps
import Turf

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
        return __map.getCameraState()
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
        return __map.coordinateBoundsForCamera(forCamera: MapboxCoreMaps.CameraOptions(camera))
    }
}
