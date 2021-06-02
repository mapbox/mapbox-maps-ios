import Turf

internal protocol CameraManagerProtocol {

    /// Calculates a `CameraOptions` to fit a `CoordinateBounds`
    ///
    /// - Parameters:
    ///   - coordinateBounds: The coordinate bounds that will be displayed within the viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    func camera(for coordinateBounds: CoordinateBounds,
                padding: UIEdgeInsets,
                bearing: Double?,
                pitch: Double?) -> CameraOptions

    /// Calculates a `CameraOptions` to fit a list of coordinates.
    ///
    /// - Parameters:
    ///   - coordinates: Array of coordinates that should fit within the new viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    func camera(for coordinates: [CLLocationCoordinate2D],
                padding: UIEdgeInsets,
                bearing: Double?,
                pitch: Double?) -> CameraOptions

    /// Calculates a `CameraOptions` to fit a list of coordinates into a sub-rect of the map.
    ///
    /// Adjusts the zoom of `camera` to fit `coordinates` into `rect`.
    ///
    /// Returns the provided camera with zoom adjusted to fit coordinates into
    /// `rect`, so that the coordinates on the left, top and right of the effective
    /// camera center at the principal point of the projection (defined by padding)
    /// fit into the rect.
    ///
    /// - Note:
    ///     This method may fail if the principal point of the projection is not
    ///     inside `rect` or if there is insufficient screen space, defined by
    ///     principal point and rect, to fit the geometry.
    ///
    /// - Parameters:
    ///   - coordinates: The coordinates to frame within `rect`.
    ///   - camera: The camera for which the zoom should be adjusted to fit `coordinates`. `camera.center` must be non-nil.
    ///   - rect: The rectangle inside of the map that should be used to frame `coordinates`.
    /// - Returns: A `CameraOptions` that fits the provided constraints, or `cameraOptions` if an error occurs.
    func camera(for coordinates: [CLLocationCoordinate2D],
                camera: CameraOptions,
                rect: CGRect) -> CameraOptions

    /// Calculates a `CameraOptions` to fit a geometry
    ///
    /// - Parameters:
    ///   - geometry: The geoemtry that will be displayed within the viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    func camera(for geometry: Turf.Geometry,
                padding: UIEdgeInsets,
                bearing: CGFloat?,
                pitch: CGFloat?) -> CameraOptions

    // MARK: - CameraOptions to CoordinateBounds

    /// Returns the coordinate bounds corresponding to a given `CameraOptions`
    ///
    /// - Parameter camera: The camera for which the coordinate bounds will be returned.
    /// - Returns: `CoordinateBounds` for the given `CameraOptions`
    func coordinateBounds(for camera: CameraOptions) -> CoordinateBounds

    /// Returns the coordinate bounds and zoom for a given `CameraOptions`.
    ///
    /// - Parameter camera: The camera for which the `CoordinateBoundsZoom` will be returned.
    /// - Returns: `CoordinateBoundsZoom` for the given `CameraOptions`
    func coordinateBoundsZoom(for camera: CameraOptions) -> CoordinateBoundsZoom

    /// Returns the unwrapped coordinate bounds and zoom for a given `CameraOptions`.
    ///
    /// This function is particularly useful, if the camera shows the antimeridian.
    ///
    /// - Parameter camera: The camera for which the `CoordinateBoundsZoom` will
    ///     be returned.
    /// - Returns: `CoordinateBoundsZoom` for the given `CameraOptions`
    func coordinateBoundsZoomUnwrapped(for camera: CameraOptions) -> CoordinateBoundsZoom

    // MARK: - Screen coordinate conversion

    /// Converts a map coordinate to a `CGPoint`, relative to the `MapView`.
    /// - Parameter coordinate: The coordinate to convert.
    /// - Returns: A `CGPoint` relative to the `UIView`.
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint

    /// Converts a point in the mapView's coordinate system to a geographic coordinate.
    /// The point must exist in the coordinate space of the `MapView`
    ///
    /// - Parameter point: The point to convert. Must exist in the coordinate space
    ///     of the `MapView`
    /// - Returns: A `CLLocationCoordinate` that represents the geographic location
    ///     of the point.
    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D

    /// Converts map coordinates to an array of `CGPoint`, relative to the `MapView`.
    ///
    /// - Parameter coordinates: The coordinate to convert.
    /// - Returns: An array of `CGPoint` relative to the `UIView`.
    func points(for coordinates: [CLLocationCoordinate2D]) -> [CGPoint]

    /// Converts points in the mapView's coordinate system to geographic coordinates.
    /// The points must exist in the coordinate space of the `MapView`.
    ///
    /// - Parameter point: The point to convert. Must exist in the coordinate space
    ///     of the `MapView`
    /// - Returns: A `CLLocationCoordinate` that represents the geographic location
    ///     of the point.
    func coordinates(for points: [CGPoint]) -> [CLLocationCoordinate2D]

    // MARK: - Camera getters/setters

    /// :nodoc:
    /// Changes the map view by any combination of center, zoom, bearing, and pitch,
    /// without an animated transition. The map will retain its current values
    /// for any details not passed via the camera options argument. It is not
    /// guaranteed that the provided `CameraOptions` will be set, the map may apply
    /// constraints resulting in a different `CameraState`.
    ///
    /// - Parameter cameraOptions: New camera options
    func setCamera(to cameraOptions: CameraOptions)

    /// Returns the current camera state
    var cameraState: CameraState { get }

    /// Sets/get the map view with the free camera options.
    ///
    /// FreeCameraOptions provides more direct access to the underlying camera entity.
    /// For backwards compatibility the state set using this API must be representable
    /// with `CameraOptions` as well. Parameters are clamped to a valid range or
    /// discarded as invalid if the conversion to the pitch and bearing presentation
    /// is ambiguous. For example orientation can be invalid if it leads to the
    /// camera being upside down or the quaternion has zero length.
    ///
    /// - Parameter freeCameraOptions: The free camera options to set.
    var freeCameraOptions: FreeCameraOptions { get set }

    /// Returns the bounds of the map.
    var cameraBounds: CameraBounds { get }

    /// Sets the camera bounds using a `CameraBoundsOptions`
    /// - Parameter options: `CameraBoundsOptions` - `nil` parameters take no effect.
    func setCameraBounds(for options: CameraBoundsOptions) throws

    // MARK: - Drag API

    /// Prepares the drag gesture to use the provided screen coordinate as a pivot
    /// point. This function should be called each time when user starts a
    /// dragging action (e.g. by clicking on the map). The following dragging
    /// will be relative to the pivot.
    ///
    /// - Parameter point: Screen point
    func dragStart(for point: CGPoint)

    /// Calculates target point where camera should move after drag. The method
    /// should be called after `dragStart` and before `dragEnd`.
    ///
    /// - Parameters:
    ///   - fromPoint: The point from which the map is dragged.
    ///   - toPoint: The point to which the map is dragged.
    ///
    /// - Returns:
    ///     The camera options object showing end point.
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions

    /// Ends the ongoing drag gesture. This function should be called always after
    /// the user has ended a drag gesture initiated by `dragStart`.
    func dragEnd()
}
