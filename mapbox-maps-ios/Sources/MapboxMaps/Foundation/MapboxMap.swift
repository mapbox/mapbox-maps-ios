// swiftlint:disable file_length
import MapboxCoreMaps
import UIKit
@_implementationOnly import MapboxCommon_Private
@_implementationOnly import MapboxCoreMaps_Private
import Turf

internal protocol MapboxMapProtocol: AnyObject {
    var size: CGSize { get }
    var cameraBounds: CameraBounds { get }
    var cameraState: CameraState { get }
    var anchor: CGPoint { get }
    func setCamera(to cameraOptions: CameraOptions)
    func dragStart(for point: CGPoint)
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions
    func dragEnd()
    func beginAnimation()
    func endAnimation()
    func beginGesture()
    func endGesture()
    @discardableResult
    func onEvery<Payload>(event eventType: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable
    // View annotation management
    func setViewAnnotationPositionsUpdateListener(_ listener: ViewAnnotationPositionsUpdateListener?)
    func addViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws
    func updateViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws
    func removeViewAnnotation(withId id: String) throws
    func options(forViewAnnotationWithId id: String) throws -> ViewAnnotationOptions
    func pointIsAboveHorizon(_ point: CGPoint) -> Bool
    func camera(for geometry: Geometry, padding: UIEdgeInsets, bearing: CGFloat?, pitch: CGFloat?) -> CameraOptions
    func camera(for coordinateBounds: CoordinateBounds, padding: UIEdgeInsets, bearing: Double?, pitch: Double?) -> CameraOptions
    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint
    func performWithoutNotifying(_ block: () -> Void)
}

// swiftlint:disable type_body_length

/// MapboxMap provides access to the map model, including the camera, style, observable map events,
/// and querying rendered features. Obtain the MapboxMap instance for a `MapView` via MapView.mapboxMap.
///
/// - Important: MapboxMap should only be used from the main thread.
public final class MapboxMap: MapboxMapProtocol {
    /// The underlying renderer object responsible for rendering the map
    private let __map: Map

    /// The `style` object supports run time styling.
    public let style: Style

    private let observable: MapboxObservableProtocol

    deinit {
        __map.destroyRenderer()
    }

    internal init(mapClient: MapClient,
                  mapInitOptions: MapInitOptions,
                  mapboxObservableProvider: (ObservableProtocol) -> MapboxObservableProtocol) {
        let coreOptions = MapboxCoreMaps.ResourceOptions(mapInitOptions.resourceOptions)

        __map = Map(
            client: mapClient,
            mapOptions: mapInitOptions.mapOptions,
            resourceOptions: coreOptions)
        __map.createRenderer()

        observable = mapboxObservableProvider(__map)

        style = Style(with: __map)
    }

    // MARK: - Render loop

    /// Triggers a repaint of the map. Calling this method is typically unnecessary but
    /// may be needed if using a custom layer that needs to be redrawn independently
    /// of other map changes.
    public func triggerRepaint() {
        __map.triggerRepaint()
    }

    // MARK: - Style loading

    private func observeStyleLoad(_ completion: @escaping (Result<Style, Error>) -> Void) {
        let cancellable = CompositeCancelable()

        cancellable.add(onNext(event: .styleLoaded) { [style] _ in
            if !style.isLoaded {
                Log.warning(forMessage: "style.isLoaded == false, was this an empty style?", category: "Style")
            }
            completion(.success(style))
            cancellable.cancel()
        })

        cancellable.add(onEvery(event: .mapLoadingError) { event in
            guard case .style = event.payload.error else { return }

            completion(.failure(event.payload.error))
            cancellable.cancel()
        })
    }

    /// Loads a `style` from a StyleURI, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// - Parameters:
    ///   - styleURI: StyleURI to load
    ///   - completion: Closure called when the style has been fully loaded. The
    ///     `Result` type encapsulates the `Style` or error that occurred. See
    ///     `MapLoadingError`
    public func loadStyleURI(_ styleURI: StyleURI, completion: ((Result<Style, Error>) -> Void)? = nil) {
        if let completion = completion {
            observeStyleLoad(completion)
        }
        __map.setStyleURIForUri(styleURI.rawValue)
    }

    /// Loads a `style` from a JSON string, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// - Parameters:
    ///   - styleURI: Style JSON string
    ///   - completion: Closure called when the style has been fully loaded. The
    ///     `Result` type encapsulates the `Style` or error that occurred. See
    ///     `MapLoadingError`
    public func loadStyleJSON(_ JSON: String, completion: ((Result<Style, Error>) -> Void)? = nil) {
        if let completion = completion {
            observeStyleLoad(completion)
        }
        __map.setStyleJSONForJson(JSON)
    }

    // MARK: - Prefetching

    /// When loading a map, if `prefetchZoomDelta` is set to any number greater
    /// than 0, the map will first request a tile for `zoom - prefetchZoomDelta`
    /// in an attempt to display a full map at lower resolution as quick as
    /// possible.
    ///
    /// It will get clamped at the tile source minimum zoom. The default delta
    /// is 4.
    public var prefetchZoomDelta: UInt8 {
        get {
            return __map.getPrefetchZoomDelta()
        }
        set {
            __map.setPrefetchZoomDeltaForDelta(newValue)
        }
    }

    /// Reduces memory use. Useful to call when the application gets paused or
    /// sent to background.
    internal func reduceMemoryUse() {
        __map.reduceMemoryUse()
    }

    /// The memory budget hint to be used by the map. The budget can be given in
    /// tile units or in megabytes. A Map will do its best to keep the memory
    /// allocations for non-essential resources within the budget.
    ///
    /// The memory budget distribution and resource
    /// eviction logic is subject to change. Current implementation sets a memory budget
    /// hint per data source.
    ///
    /// If nil is set, the memory budget in tile units will be dynamically calculated based on
    /// the current viewport size.
    /// - Parameter memoryBudget: The memory budget hint to be used by the Map.
    @_spi(Experimental) public func setMemoryBudget(_ memoryBudget: MapMemoryBudget?) {
        __map.__setMemoryBudgetFor(memoryBudget)
    }

    /// Enables or disables the experimental render cache feature.
    ///
    /// Render cache is an experimental feature aiming to reduce resource usage of map rendering
    /// by caching intermediate rendering results of tiles into specific cache textures for reuse between frames.
    /// Performance benefit of the cache depends on the style as not all layers are cacheable due to e.g. viewport aligned features.
    /// Render cache always prefers quality over performance.
    ///
    /// - Parameter cacheOptions: The cache options to be set to the Map.
    @_spi(Experimental) public func setRenderCache(_ cacheOptions: RenderCacheOptions) {
        __map.setRenderCacheOptionsFor(cacheOptions)
    }

    /// Defines whether multiple copies of the world will be rendered side by side beyond -180 and 180 degrees longitude.
    ///
    /// If disabled, when the map is zoomed out far enough that a single representation of the world does not fill the map's entire container,
    /// there will be blank space beyond 180 and -180 degrees longitude.
    /// In this case, features that cross 180 and -180 degrees longitude will be cut in two (with one portion on the right edge of the map
    /// and the other on the left edge of the map) at every zoom level.
    ///
    /// By default, `shouldRenderWorldCopies` is set to `true`.
    public var shouldRenderWorldCopies: Bool {
        get { __map.getRenderWorldCopies() }
        set { __map.setRenderWorldCopiesForRenderWorldCopies(newValue) }
    }

    /// Gets the resource options for the map.
    ///
    /// All optional fields of the returned object are initialized with the
    /// actual values.
    ///
    /// - Note: The result of this property is different from the `ResourceOptions`
    /// that were provided to the map's initializer.
    public var resourceOptions: ResourceOptions {
        return ResourceOptions(__map.getResourceOptions())
    }

    /// Clears temporary map data.
    ///
    /// Clears temporary map data from the data path defined in the given resource
    /// options. Useful to reduce the disk usage or in case the disk cache contains
    /// invalid data.
    ///
    /// - Note: Calling this API will affect all maps that use the same data path
    ///         and does not affect persistent map data like offline style packages.
    ///
    /// - Parameters:
    ///   - resourceOptions: The `resource options` that contain the map data path
    ///         to be used
    ///   - completion: Called once the request is complete
    public static func clearData(for resourceOptions: ResourceOptions, completion: @escaping (Error?) -> Void) {
        Map.clearData(for: MapboxCoreMaps.ResourceOptions(resourceOptions),
                      callback: coreAPIClosureAdapter(for: completion,
                                                      concreteErrorType: MapError.self))
    }

    /// Gets elevation for the given coordinate.
    ///
    /// - Note: Elevation is only available for the visible region on the screen.
    ///
    /// - Parameter coordinate: Coordinate for which to return the elevation.
    /// - Returns: Elevation (in meters) multiplied by current terrain
    ///     exaggeration, or empty if elevation for the coordinate is not available.
    public func elevation(at coordinate: CLLocationCoordinate2D) -> Double? {
        return __map.getElevationFor(coordinate)?.doubleValue
    }

    // MARK: - Camera Fitting

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

    // MARK: Debug options
    /// The array of `MapDebugOptions`. Setting this property to an empty array
    /// disables previously enabled `MapDebugOptions`.
    /// The default value is an empty array.
    public var debugOptions: [MapDebugOptions] {
        get {
            return __map.getDebug().compactMap { MapDebugOptions(rawValue: $0.intValue) }
        }
        set {
            // Remove the previously visible options, then update the debug options to the new array.
            let oldOptions = debugOptions.map { NSNumber(value: $0.rawValue) }
            __map.setDebugForDebugOptions(oldOptions, value: false)

            let options = newValue.map { NSNumber(value: $0.rawValue) }
            __map.setDebugForDebugOptions(options, value: true)
        }
    }

    /// Gets the size of the map in points
    internal var size: CGSize {
        get {
            CGSize(__map.getSize())
        }
        set {
            __map.setSizeFor(Size(newValue))
        }
    }

    /// Notify map about gesture being in progress.
    internal var isGestureInProgress: Bool {
        get {
            return __map.isGestureInProgress()
        }
        set {
            __map.setGestureInProgressForInProgress(newValue)
        }
    }

    /// Tells the map rendering engine that the animation is currently performed
    /// by the user (e.g. with a `setCamera()` calls series). It adjusts the
    /// engine for the animation use case.
    /// In particular, it brings more stability to symbol placement and rendering.
    internal var isUserAnimationInProgress: Bool {
        get {
            return __map.isUserAnimationInProgress()
        }
        set {
            __map.setUserAnimationInProgressForInProgress(newValue)
        }
    }

    /// Returns the map's options
    public var options: MapOptions {
        return __map.getOptions()
    }

    /// Set the map north orientation
    ///
    /// - Parameter northOrientation: The map north orientation to set
    internal func setNorthOrientation(northOrientation: NorthOrientation) {
        __map.setNorthOrientationFor(northOrientation)
    }

    /// Set the map constrain mode
    ///
    /// - Parameter constrainMode: The map constraint mode to set
    internal func setConstrainMode(_ constrainMode: ConstrainMode) {
        __map.setConstrainModeFor(constrainMode)
    }

    /// Set the map viewport mode
    ///
    /// - Parameter viewportMode: The map viewport mode to set
    internal func setViewportMode(_ viewportMode: ViewportMode) {
        __map.setViewportModeFor(viewportMode)
    }

    /// Calculates a `CameraOptions` to fit a `CoordinateBounds`
    ///
    /// This API isn't supported by Globe projection.
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
    /// This API isn't supported by Globe projection.
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
    /// Returns the provided camera with zoom adjusted to fit coordinates into
    /// `rect`, so that the coordinates on the left, top and right of the effective
    /// camera center at the principal point of the projection (defined by padding)
    /// fit into the rect.
    ///
    /// This API isn't supported by Globe projection.
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
    /// This API isn't supported by Globe projection.
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
                for: MapboxCommon.Geometry(geometry),
                padding: padding.toMBXEdgeInsetsValue(),
                bearing: bearing?.NSNumber,
                pitch: pitch?.NSNumber))
    }

    // MARK: - CameraOptions to CoordinateBounds

    /// Returns the coordinate bounds corresponding to a given `CameraOptions`
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter camera: The camera for which the coordinate bounds will be returned.
    /// - Returns: `CoordinateBounds` for the given `CameraOptions`
    public func coordinateBounds(for camera: CameraOptions) -> CoordinateBounds {
        return __map.coordinateBoundsForCamera(
            forCamera: MapboxCoreMaps.CameraOptions(camera))
    }

    /// Returns the unwrapped coordinate bounds to a given ``CameraOptions``.
    ///
    /// This function is particularly useful, if the camera shows the antimeridian.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter camera: The camera for which the coordinate bounds will be returned.
    /// - Returns: `CoordinateBounds` for the given ``CameraOptions``.
    public func coordinateBoundsUnwrapped(for camera: CameraOptions) -> CoordinateBounds {
        return __map.coordinateBoundsForCameraUnwrapped(forCamera: MapboxCoreMaps.CameraOptions(camera))
    }

    /// Returns the coordinate bounds and zoom for a given `CameraOptions`.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter camera: The camera for which the `CoordinateBoundsZoom` will be returned.
    /// - Returns: `CoordinateBoundsZoom` for the given `CameraOptions`
    public func coordinateBoundsZoom(for camera: CameraOptions) -> CoordinateBoundsZoom {
        return __map.coordinateBoundsZoomForCamera(forCamera: MapboxCoreMaps.CameraOptions(camera))
    }

    /// Returns the unwrapped coordinate bounds and zoom for a given `CameraOptions`.
    ///
    /// This function is particularly useful, if the camera shows the antimeridian.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter camera: The camera for which the `CoordinateBoundsZoom` will
    ///     be returned.
    /// - Returns: `CoordinateBoundsZoom` for the given `CameraOptions`
    public func coordinateBoundsZoomUnwrapped(for camera: CameraOptions) -> CoordinateBoundsZoom {
        return __map.coordinateBoundsZoomForCameraUnwrapped(forCamera: MapboxCoreMaps.CameraOptions(camera))
    }

    // MARK: - Screen coordinate conversion

    /// Converts a point in the mapView's coordinate system to a geographic coordinate.
    /// The point must exist in the coordinate space of the `MapView`
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter point: The point to convert. Must exist in the coordinate space
    ///     of the `MapView`
    /// - Returns: A `CLLocationCoordinate` that represents the geographic location
    ///     of the point.
    public func coordinate(for point: CGPoint) -> CLLocationCoordinate2D {
        return __map.coordinateForPixel(forPixel: point.screenCoordinate)
    }

    /// Converts a map coordinate to a `CGPoint`, relative to the `MapView`.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter coordinate: The coordinate to convert.
    /// - Returns: A `CGPoint` relative to the `UIView`. If the point is outside of the bounds
    ///     of `MapView` the returned point contains `-1.0` for both coordinates.
    public func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        let point = __map.pixelForCoordinate(for: coordinate).point
        return CGRect(origin: .zero, size: size).contains(point) ? point : CGPoint(x: -1.0, y: -1.0)
    }

    /// Converts map coordinates to an array of `CGPoint`, relative to the `MapView`.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter coordinates: The coordinate to convert.
    /// - Returns: An array of `CGPoint` relative to the `UIView.
    /// If a coordinate's point is outside of map view's bounds, it will be `(-1, -1)`
    public func points(for coordinates: [CLLocationCoordinate2D]) -> [CGPoint] {
        let bounds = CGRect(origin: .zero, size: size)
        let locations = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let screenCoords = __map.pixelsForCoordinates(forCoordinates: locations)
        return screenCoords.map { bounds.contains($0.point) ? $0.point : CGPoint(x: -1.0, y: -1.0) }
    }

    /// Converts points in the mapView's coordinate system to geographic coordinates.
    /// The points must exist in the coordinate space of the `MapView`.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter point: The point to convert. Must exist in the coordinate space
    ///     of the `MapView`
    /// - Returns: A `CLLocationCoordinate` that represents the geographic location
    ///     of the point.
    public func coordinates(for points: [CGPoint]) -> [CLLocationCoordinate2D] {
        let screenCoords = points.map { $0.screenCoordinate }
        let locations = __map.coordinatesForPixels(forPixels: screenCoords)
        return locations.map { $0.coordinate }
    }

    // MARK: - Camera options setters/getters

    /// Changes the map view by any combination of center, zoom, bearing, and pitch,
    /// without an animated transition. The map will retain its current values
    /// for any details not passed via the camera options argument. It is not
    /// guaranteed that the provided `CameraOptions` will be set, the map may apply
    /// constraints resulting in a different `CameraState`.
    ///
    /// - Important:
    ///     This method does not cancel existing animations. Call
    ///     `CameraAnimationsManager.cancelAnimations()`to cancel existing animations.
    ///
    /// - Parameter cameraOptions: New camera options
    public func setCamera(to cameraOptions: CameraOptions) {
        __map.setCameraFor(MapboxCoreMaps.CameraOptions(cameraOptions))
    }

    /// Returns the current camera state
    public var cameraState: CameraState {
        return CameraState(__map.getCameraState())
    }

    /// The map's current anchor, calculated after applying padding (if it exists)
    internal var anchor: CGPoint {
        let rect = CGRect(origin: .zero, size: size).inset(by: cameraState.padding)
        return CGPoint(x: rect.midX, y: rect.midY)
    }

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
    public var freeCameraOptions: FreeCameraOptions {
        get {
            return __map.getFreeCameraOptions()
        }
        set {
            __map.setCameraFor(newValue)
        }
    }

    /// Returns the bounds of the map.
    public var cameraBounds: CameraBounds {
        return CameraBounds(__map.getBounds())
    }

    /// Sets the bounds of the map.
    ///
    /// - Parameter options: New camera bounds. Nil values will not take effect.
    /// - Throws: `MapError`
    public func setCameraBounds(with options: CameraBoundsOptions) throws {
        let expected = __map.setBoundsFor(MapboxCoreMaps.CameraBoundsOptions(options))

        if expected.isError() {
            throw MapError(coreError: expected.error)
        }
    }

    // MARK: - Drag API

    /// Prepares the drag gesture to use the provided screen coordinate as a pivot
    /// point. This function should be called each time when user starts a
    /// dragging action (e.g. by clicking on the map). The following dragging
    /// will be relative to the pivot.
    ///
    /// - Parameter point: Screen point
    public func dragStart(for point: CGPoint) {
        __map.dragStart(forPoint: point.screenCoordinate)
    }

    /// Calculates target point where camera should move after drag. The method
    /// should be called after `dragStart` and before `dragEnd`.
    ///
    /// - Parameters:
    ///   - fromPoint: The point from which the map is dragged.
    ///   - toPoint: The point to which the map is dragged.
    ///
    /// - Returns:
    ///     The camera options object showing end point.
    public func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions {
        let options = __map.getDragCameraOptionsFor(fromPoint: from.screenCoordinate,
                                                    toPoint: to.screenCoordinate)
        return CameraOptions(options)
    }

    /// Ends the ongoing drag gesture. This function should be called always after
    /// the user has ended a drag gesture initiated by `dragStart`.
    public func dragEnd() {
        __map.dragEnd()
    }

    internal func pointIsAboveHorizon(_ point: CGPoint) -> Bool {
        guard style.projection.name == .mercator else {
            return false
        }
        let topMargin = 0.04 * size.height
        let reprojectErrorMargin = min(10, topMargin / 2)
        var p = point
        p.y -= topMargin
        let coordinate = self.coordinate(for: p)
        let roundtripPoint = self.point(for: coordinate)
        return roundtripPoint.y >= p.y + reprojectErrorMargin
    }

    // MARK: - Gesture and Animation Flags

    private var animationCount = 0

    /// If implementing a custom animation mechanism, call this method when the animation begins.
    /// Must always be paired with a corresponding call to `endAnimation()`
    public func beginAnimation() {
        animationCount += 1
        if animationCount == 1 {
            __map.setUserAnimationInProgressForInProgress(true)
        }
    }

    /// If implementing a custom animation mechanism, call this method when the animation ends.
    /// Must always be paired with a corresponding call to `beginAnimation()`
    public func endAnimation() {
        assert(animationCount > 0)
        animationCount -= 1
        if animationCount == 0 {
            __map.setUserAnimationInProgressForInProgress(false)
        }
    }

    private var gestureCount = 0

    /// If implementing a custom gesture, call this method when the gesture begins.
    /// Must always be paired with a corresponding call to `endGesture()`
    public func beginGesture() {
        gestureCount += 1
        if gestureCount == 1 {
            __map.setGestureInProgressForInProgress(true)
        }
    }

    /// If implementing a custom gesture, call this method when the gesture ends.
    /// Must always be paired with a corresponding call to `beginGesture()`
    public func endGesture() {
        assert(gestureCount > 0)
        gestureCount -= 1
        if gestureCount == 0 {
            __map.setGestureInProgressForInProgress(false)
        }
    }
}

// swiftlint:enable type_body_length

// MARK: - MapFeatureQueryable

extension MapboxMap: MapFeatureQueryable {

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - shape: Screen point coordinates (point, line string or box) to query
    ///         for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes
    @available(*, deprecated, renamed: "queryRenderedFeatures(with:options:completion:)")
    public func queryRenderedFeatures(for shape: [CGPoint], options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.queryRenderedFeatures(forShape: shape.map { $0.screenCoordinate },
                                    options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                    callback: coreAPIClosureAdapter(for: completion,
                                                                    type: NSArray.self,
                                                                    concreteErrorType: MapError.self))
    }

    @discardableResult
    public func queryRenderedFeatures(with shape: [CGPoint], options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: .fromNSArray(shape.map {$0.screenCoordinate}),
                                       options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                       callback: coreAPIClosureAdapter(for: completion,
                                                                       type: NSArray.self,
                                                                       concreteErrorType: MapError.self)).asCancelable()
    }

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - rect: Screen rect to query for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes
    @available(*, deprecated, renamed: "queryRenderedFeatures(with:options:completion:)")
    public func queryRenderedFeatures(in rect: CGRect, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.queryRenderedFeatures(for: ScreenBox(rect),
                                    options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                    callback: coreAPIClosureAdapter(for: completion,
                                                                    type: NSArray.self,
                                                                    concreteErrorType: MapError.self))
    }

    @discardableResult
    public func queryRenderedFeatures(with rect: CGRect, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: .fromScreenBox(.init(rect)),
                                       options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                       callback: coreAPIClosureAdapter(for: completion,
                                                                       type: NSArray.self,
                                                                       concreteErrorType: MapError.self)).asCancelable()
    }

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - point: Screen point at which to query for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes
    @available(*, deprecated, renamed: "queryRenderedFeatures(with:options:completion:)")
    public func queryRenderedFeatures(at point: CGPoint, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.queryRenderedFeatures(forPixel: point.screenCoordinate,
                                    options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                    callback: coreAPIClosureAdapter(for: completion,
                                                                    type: NSArray.self,
                                                                    concreteErrorType: MapError.self))
    }

    @discardableResult
    public func queryRenderedFeatures(with point: CGPoint, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: .fromScreenCoordinate(point.screenCoordinate),
                                             options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                             callback: coreAPIClosureAdapter(for: completion,
                                                                             type: NSArray.self,
                                                                             concreteErrorType: MapError.self)).asCancelable()
    }

    /// Queries the map for source features.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier used to query for source features.
    ///   - options: Options for querying source features.
    ///   - completion: Callback called when the query completes
    public func querySourceFeatures(for sourceId: String,
                                    options: SourceQueryOptions,
                                    completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        __map.querySourceFeatures(forSourceId: sourceId,
                                  options: options,
                                  callback: coreAPIClosureAdapter(for: completion,
                                                                  type: NSArray.self,
                                                                  concreteErrorType: MapError.self))
    }

    /// Queries for feature extension values in a GeoJSON source.
    ///
    /// - Parameters:
    ///   - sourceId: The identifier of the source to query.
    ///   - feature: Feature to look for in the query.
    ///   - extension: Currently supports keyword `supercluster`.
    ///   - extensionField: Currently supports following three extensions:
    ///
    ///       1. `children`: returns the children of a cluster (on the next zoom
    ///         level).
    ///       2. `leaves`: returns all the leaves of a cluster (given its cluster_id)
    ///       3. `expansion-zoom`: returns the zoom on which the cluster expands
    ///         into several children (useful for "click to zoom" feature).
    ///
    ///   - args: Used for further query specification when using 'leaves'
    ///         extensionField. Now only support following two args:
    ///
    ///       1. `limit`: the number of points to return from the query (must
    ///             use type 'UInt64', set to maximum for all points)
    ///       2. `offset`: the amount of points to skip (for pagination, must
    ///             use type 'UInt64')
    ///
    ///   - completion: The result could be a feature extension value containing
    ///         either a value (expansion-zoom) or a feature collection (children
    ///         or leaves). An error is passed if the operation was not successful.
    /// Deprecated. Use getGeoJsonClusterLeaves/getGeoJsonClusterChildren/getGeoJsonClusterExpansionZoom to instead.
    public func queryFeatureExtension(for sourceId: String,
                                      feature: Feature,
                                      extension: String,
                                      extensionField: String,
                                      args: [String: Any]? = nil,
                                      completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {

        __map.queryFeatureExtensions(forSourceIdentifier: sourceId,
                                     feature: MapboxCommon.Feature(feature),
                                     extension: `extension`,
                                     extensionField: extensionField,
                                     args: args,
                                     callback: coreAPIClosureAdapter(for: completion,
                                                                     type: FeatureExtensionValue.self,
                                                                     concreteErrorType: MapError.self))
    }

    /// Returns all the leaves (original points) of a cluster (given its cluster_id) from a GeoJSON source, with pagination support: limit is the number of leaves
    /// to return (set to Infinity for all points), and offset is the amount of points to skip (for pagination).
    ///
    /// - Parameters:
    ///   - sourceId: The identifier of the source to query.
    ///   - feature: Feature to look for in the query.
    ///   - limit: the number of points to return from the query, default to 10
    ///   - offset: the amount of points to skip, default to 0
    ///   - completion: The result could be a feature extension value containing
    ///         either a value (expansion-zoom) or a feature collection (children
    ///         or leaves). An error is passed if the operation was not successful.
    public func getGeoJsonClusterLeaves(forSourceId sourceId: String,
                                        feature: Feature,
                                        limit: UInt64 = 10,
                                        offset: UInt64 = 0,
                                        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {
        __map.queryFeatureExtensions(forSourceIdentifier: sourceId,
                                     feature: MapboxCommon.Feature(feature),
                                     extension: "supercluster",
                                     extensionField: "leaves",
                                     args: ["limit": limit, "offset": offset],
                                     callback: coreAPIClosureAdapter(for: completion,
                                                                     type: FeatureExtensionValue.self,
                                                                     concreteErrorType: MapError.self))
    }

    /// Returns the children (original points or clusters) of a cluster (on the next zoom level)
    /// given its id (cluster_id value from feature properties) from a GeoJSON source.
    ///
    /// - Parameters:
    ///   - sourceId: The identifier of the source to query.
    ///   - feature: Feature to look for in the query.
    ///   - completion: The result could be a feature extension value containing
    ///         either a value (expansion-zoom) or a feature collection (children
    ///         or leaves). An error is passed if the operation was not successful.
    public func getGeoJsonClusterChildren(forSourceId sourceId: String,
                                          feature: Feature,
                                          completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {
        __map.queryFeatureExtensions(forSourceIdentifier: sourceId,
                                     feature: MapboxCommon.Feature(feature),
                                     extension: "supercluster",
                                     extensionField: "children",
                                     args: nil,
                                     callback: coreAPIClosureAdapter(for: completion,
                                                                     type: FeatureExtensionValue.self,
                                                                     concreteErrorType: MapError.self))
    }

    /// Returns the zoom on which the cluster expands into several children (useful for "click to zoom" feature)
    /// given the cluster's cluster_id (cluster_id value from feature properties) from a GeoJSON source.
    ///
    /// - Parameters:
    ///   - sourceId: The identifier of the source to query.
    ///   - feature: Feature to look for in the query.
    ///   - completion: The result could be a feature extension value containing
    ///         either a value (expansion-zoom) or a feature collection (children
    ///         or leaves). An error is passed if the operation was not successful.
    public func getGeoJsonClusterExpansionZoom(forSourceId sourceId: String,
                                               feature: Feature,
                                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {
        __map.queryFeatureExtensions(forSourceIdentifier: sourceId,
                                     feature: MapboxCommon.Feature(feature),
                                     extension: "supercluster",
                                     extensionField: "expansion-zoom",
                                     args: nil,
                                     callback: coreAPIClosureAdapter(for: completion,
                                                                     type: FeatureExtensionValue.self,
                                                                     concreteErrorType: MapError.self))
    }
}

extension MapboxMap {
    /// Subscribes an observer to a list of events.
    ///
    /// `MapboxMap` holds a strong reference to `observer` while it is subscribed. To stop receiving
    /// notifications, pass the same `observer` to `unsubscribe(_:events:)`.
    ///
    /// - Parameters:
    ///   - observer: An object that will receive events of the types specified by `events`
    ///   - events: Array of event types to deliver to `observer`
    ///
    /// - Note:
    ///     Prefer `onNext(eventTypes:handler:)`, `onNext(_:handler:)`, and
    ///     `onEvery(_:handler:)` to using this lower-level APIs
    public func subscribe(_ observer: Observer, events: [String]) {
        observable.subscribe(observer, events: events)
    }

    /// Unsubscribes an observer from a provided list of event types.
    ///
    /// `MapboxMap` holds a strong reference to `observer` while it is subscribed. To stop receiving
    /// notifications, pass the same `observer` to this method as was passed to
    /// `subscribe(_:events:)`.
    ///
    /// - Parameters:
    ///   - observer: The object to unsubscribe
    ///   - events: Array of event types to unsubscribe from. Pass an
    ///     empty array (the default) to unsubscribe from all events.
    public func unsubscribe(_ observer: Observer, events: [String] = []) {
        observable.unsubscribe(observer, events: events)
    }
}

// MARK: - Map Event handling

extension MapboxMap: MapEventsObservable {

    /// Listen to a single occurrence of a Map event.
    ///
    /// This will observe the next (and only the next) event of the specified
    /// type. After observation, the underlying subscriber will unsubscribe from
    /// the map or snapshotter.
    ///
    /// If you need to unsubscribe before the event fires, call `cancel()` on
    /// the returned `Cancelable` object.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     the event. This is especially important if you have a retain cycle in
    ///     the handler.
    @discardableResult
    public func onNext<Payload>(event eventType: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable {
        return observable.onNext(event: eventType, handler: handler)
    }

    /// Listen to a single occurrence of a Map event.
    ///
    /// This will observe the next (and only the next) event of the specified
    /// type. After observation, the underlying subscriber will unsubscribe from
    /// the map or snapshotter.
    ///
    /// If you need to unsubscribe before the event fires, call `cancel()` on
    /// the returned `Cancelable` object.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     the event. This is especially important if you have a retain cycle in
    ///     the handler.
    @available(*, deprecated, renamed: "onNext(event:handler:)")
    @discardableResult
    public func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        return observable.onNext([eventType], handler: handler)
    }

    /// Listen to multiple occurrences of a Map event.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     events. This is especially important if you have a retain cycle in
    ///     the handler.
    @available(*, deprecated, renamed: "onEvery(event:handler:)")
    @discardableResult
    public func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        return observable.onEvery([eventType], handler: handler)
    }

    /// Listen to multiple occurrences of a Map event.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     events. This is especially important if you have a retain cycle in
    ///     the handler.
    @discardableResult
    public func onEvery<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable {
        return observable.onEvery(event: event, handler: handler)
    }

    internal func performWithoutNotifying(_ block: () -> Void) {
        observable.performWithoutNotifying(block)
    }
}

// MARK: - Map data clearing

extension MapboxMap {
    /// Clears temporary map data.
    ///
    /// Clears temporary map data from the data path defined in the given resource
    /// options. Useful to reduce the disk usage or in case the disk cache contains
    /// invalid data.
    ///
    /// - Note: Calling this API will affect all maps that use the same data path
    ///         and does not affect persistent map data like offline style packages.
    ///
    /// - Parameter completion: Called once the request is complete
    public func clearData(completion: @escaping (Error?) -> Void) {
        MapboxMap.clearData(for: resourceOptions, completion: completion)
    }
}

// MARK: - Attribution

extension MapboxMap: AttributionDataSource {
    internal func loadAttributions(completion: @escaping ([Attribution]) -> Void) {
        Attribution.parse(style.sourceAttributions(), completion: completion)
    }
}

// MARK: - Feature State

extension MapboxMap {

    /// Update the state map of a feature within a style source.
    /// Update entries in the state map of a given feature within a style source. Only entries listed in the state map
    /// will be updated. An entry in the feature state map that is not listed in `state` will retain its previous value.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier
    ///   - sourceLayerId: Style source layer identifier (for multi-layer sources such as vector sources). Defaults to `nil`.
    ///   - featureId: Identifier of the feature whose state should be updated
    ///   - state: Map of entries to update with their respective new values
    public func setFeatureState(sourceId: String, sourceLayerId: String? = nil, featureId: String, state: [String: Any]) {
        __map.setFeatureStateForSourceId(sourceId,
                                         sourceLayerId: sourceLayerId,
                                         featureId: featureId,
                                         state: state)
    }

    /// Get the state map of a feature within a style source.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - sourceLayerId: Style source layer identifier (for multi-layer sources such as vector sources).
    ///   - featureId: Identifier of the feature whose state should be queried.
    ///   - callback: Feature's state map or an empty map if the feature could not be found.
    public func getFeatureState(sourceId: String, sourceLayerId: String? = nil, featureId: String, callback: @escaping (Result<[String: Any], Error>) -> Void) {
        __map.getFeatureState(forSourceId: sourceId,
                              sourceLayerId: sourceLayerId,
                              featureId: featureId,
                              callback: coreAPIClosureAdapter(for: callback,
                                                              type: AnyObject.self,
                                                              concreteErrorType: MapError.self))
    }

    /// Removes entries from a feature state object.
    /// Remove a specified property or all property from a feature's state object, depending on the value of `stateKey`.
    ///
    /// - Parameters:
    ///   - sourceId: The style source identifier
    ///   - sourceLayerId: The style source layer identifier (for multi-layer sources such as vector sources). Defaults to `nil`.
    ///   - featureId: The feature identifier of the feature whose state should be removed.
    ///   - stateKey: The key of the property to remove. If `nil`, all feature's state object properties are removed. Defaults to `nil`.
    public func removeFeatureState(sourceId: String, sourceLayerId: String? = nil, featureId: String, stateKey: String? = nil) {
        __map.removeFeatureState(forSourceId: sourceId,
                                 sourceLayerId: sourceLayerId,
                                 featureId: featureId,
                                 stateKey: stateKey)
    }

}

// MARK: - View Annotations

extension MapboxMap {

    internal func setViewAnnotationPositionsUpdateListener(_ listener: ViewAnnotationPositionsUpdateListener?) {
        __map.setViewAnnotationPositionsUpdateListenerFor(listener)
    }

    internal func addViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws {
        let expected = __map.addViewAnnotation(forIdentifier: id, options: MapboxCoreMaps.ViewAnnotationOptions(options))
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
    }

    internal func updateViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws {
        let expected = __map.updateViewAnnotation(forIdentifier: id, options: MapboxCoreMaps.ViewAnnotationOptions(options))
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
    }

    internal func removeViewAnnotation(withId id: String) throws {
        let expected = __map.removeViewAnnotation(forIdentifier: id)
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
    }

    internal func options(forViewAnnotationWithId id: String) throws -> ViewAnnotationOptions {
        let expected = __map.getViewAnnotationOptions(forIdentifier: id)
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
        guard let options = expected.value else {
            fatalError("Failed to unwrap ViewAnnotationOptions")
        }
        return ViewAnnotationOptions(options)
    }

}

// MARK: - TileCover

extension MapboxMap {

    /// Returns array of tile identifiers that cover current map camera.
    ///
    /// - Parameters:
    ///  - options: Options for the tile cover method.
    @_spi(Experimental)
    public func tileCover(for options: TileCoverOptions) -> [CanonicalTileID] {
        __map.__tileCover(
            for: MapboxCoreMaps.TileCoverOptions(options),
            cameraOptions: nil)
    }
}

// MARK: - Map Recorder

extension MapboxMap {

    // swiftlint:disable:next missing_docs
    @_spi(Internal) public final func makeRecorder() -> MapRecorder {
        MapRecorder(mapView: __map)
    }
}

// MARK: - Testing only!

extension MapboxMap {
    internal var __testingMap: Map {
        return __map
    }
}
