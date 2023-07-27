// swiftlint:disable file_length
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

    // View annotation management
    func setViewAnnotationPositionsUpdateListener(_ listener: ViewAnnotationPositionsUpdateListener?)
    func addViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws
    func updateViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws
    func removeViewAnnotation(withId id: String) throws
    func options(forViewAnnotationWithId id: String) throws -> ViewAnnotationOptions
    func pointIsAboveHorizon(_ point: CGPoint) -> Bool
    func camera(for geometry: Geometry, padding: UIEdgeInsets, bearing: CGFloat?, pitch: CGFloat?) -> CameraOptions
    // swiftlint:disable:next function_parameter_count
    func camera(for coordinateBounds: CoordinateBounds,
                padding: UIEdgeInsets,
                bearing: Double?,
                pitch: Double?,
                maxZoom: Double?,
                offset: CGPoint?) -> CameraOptions
    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint
    func performWithoutNotifying(_ block: () -> Void)
}

// swiftlint:disable type_body_length

/// Provides access to the map model, including the camera, style, observable map events,
/// and querying rendered features.
///
/// If you have a ``MapView`` you can access the `MapboxMap` instance via ``MapView/mapboxMap`` property.
///
/// Use ``style`` property to access runtime styling API, for example:
///   ```swift
///   mapboxMap.style.uri = .satelliteStreets
///   ```
///
/// Use `on`-prefixed properties to subscribe to map events, for example:
///    ```swift
///    // Holds resources allocated for subscriptions.
///    var cancelables = Set<AnyCancelable>()
///
///    // Observe every occurrence of CameraChanged event.
///    mapboxMap.onCameraChanged.observe { event in
///         print("Current camera state: \(event.cameraState)")
///    }.store(in: &cancelables)
///
///    // Observe only the next occurrence of MapLoaded event.
///    mapboxMap.onMapLoaded.observeNext { event in
///        print("Map is loaded at: \(event.timeInterval.end)")
///    }.store(in: &cancelables)
///    ```
///
/// The ``AnyCancelable`` object returned from ``Signal/observe(_:)`` or ``Signal/observeNext(_:)``
/// holds the resources allocated for the subscription and can be used to cancel it. If the cancelable
/// object is deallocated, the subscription will be cancelled immediately.
///
/// The simplified diagram of the events emitted by the map is displayed below.
///
/// ```
/// ┌─────────────┐               ┌─────────┐                   ┌──────────────┐
/// │ Application │               │   Map   │                   │ResourceLoader│
/// └──────┬──────┘               └────┬────┘                   └───────┬──────┘
///        │                           │                                │
///        ├───────setStyleURI────────▶│                                │
///        │                           ├───────────get style───────────▶│
///        │                           │                                │
///        │                           │◀─────────style data────────────┤
///        │                           │                                │
///        │                           ├─parse style─┐                  │
///        │                           │             │                  │
///        │      StyleDataLoaded      ◀─────────────┘                  │
///        │◀───────type: Style────────┤                                │
///        │                           ├─────────get sprite────────────▶│
///        │                           │                                │
///        │                           │◀────────sprite data────────────┤
///        │                           │                                │
///        │                           ├──────parse sprite───────┐      │
///        │                           │                         │      │
///        │      StyleDataLoaded      ◀─────────────────────────┘      │
///        │◀──────type: Sprite────────┤                                │
///        │                           ├─────get source TileJSON(s)────▶│
///        │                           │                                │
///        │     SourceDataLoaded      │◀─────parse TileJSON data───────┤
///        │◀─────type: Metadata───────┤                                │
///        │                           │                                │
///        │                           │                                │
///        │      StyleDataLoaded      │                                │
///        │◀──────type: Sources───────┤                                │
///        │                           ├──────────get tiles────────────▶│
///        │                           │                                │
///        │◀───────StyleLoaded────────┤                                │
///        │                           │                                │
///        │     SourceDataLoaded      │◀─────────tile data─────────────┤
///        │◀───────type: Tile─────────┤                                │
///        │                           │                                │
///        │                           │                                │
///        │◀────RenderFrameStarted────┤                                │
///        │                           ├─────render─────┐               │
///        │                           │                │               │
///        │                           ◀────────────────┘               │
///        │◀───RenderFrameFinished────┤                                │
///        │                           ├──render, all tiles loaded──┐   │
///        │                           │                            │   │
///        │                           ◀────────────────────────────┘   │
///        │◀────────MapLoaded─────────┤                                │
///        │                           │                                │
///        │                           │                                │
///        │◀─────────MapIdle──────────┤                                │
///        │                    ┌ ─── ─┴─ ─── ┐                         │
///        │                    │   offline   │                         │
///        │                    └ ─── ─┬─ ─── ┘                         │
///        │                           │                                │
///        ├─────────setCamera────────▶│                                │
///        │                           ├───────────get tiles───────────▶│
///        │                           │                                │
///        │                           │┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
///        │◀─────────MapIdle──────────┤   waiting for connectivity  │  │
///        │                           ││  Map renders cached data      │
///        │                           │ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
///        │                           │                                │
/// ```
///
/// - Important: MapboxMap should only be used from the main thread.
public final class MapboxMap: StyleManager, MapboxMapProtocol {
    /// The underlying renderer object responsible for rendering the map.
    private let __map: Map
    private var cancelables = Set<AnyCancelable>()

    /// The `style` object supports run time styling.
    @available(*, deprecated, message: "Access style APIs directly from MapboxMap instance instead")
    public var style: StyleManager { return self }

    /// Provides access to events triggered during Map lifecycle.
    private let events: MapEvents

    deinit {
        __map.destroyRenderer()
    }

    internal init(map: Map, events: MapEvents, styleSourceManager: StyleSourceManagerProtocol) {
        self.__map = map
        self.events = events

        super.init(with: map, sourceManager: styleSourceManager)

        __map.createRenderer()
    }

    internal convenience init(mapClient: MapClient, mapInitOptions: MapInitOptions, styleSourceManager: StyleSourceManagerProtocol? = nil) {
        let map = Map(
            client: mapClient,
            mapOptions: mapInitOptions.mapOptions)
        self.init(
            map: map,
            events: MapEvents(observable: map),
            styleSourceManager: styleSourceManager ?? StyleSourceManager(styleManager: map))
    }

    // MARK: - Render loop

    /// Triggers a repaint of the map. Calling this method is typically unnecessary but
    /// may be needed if using a custom layer that needs to be redrawn independently
    /// of other map changes.
    public func triggerRepaint() {
        __map.triggerRepaint()
    }

    // MARK: - Style loading

    private func observeStyleLoad(_ completion: @escaping (MapLoadingError?) -> Void) {
        weak var weakToken: AnyCancelable?
        let styleLoadingError = onMapLoadingError.filter { $0.type == .style }
        let token = onStyleLoaded
            .join(withError: styleLoadingError)
            .observeNext { [weak self] result in
                guard let self else { return }
                if !self.isStyleLoaded {
                    Log.warning(forMessage: "style.isLoaded == false, was this an empty style?", category: "Style")
                }

                switch result {
                case .success: completion(nil)
                case .failure(let error): completion(error)
                }

                if let token = weakToken {
                    self.cancelables.remove(token)
                }
            }
        weakToken = token
        token.store(in: &cancelables)
    }

    private func observeStyleDataLoaded(_ completion: @escaping () -> Void) {
        weak var weakToken: AnyCancelable?
        let token = onStyleDataLoaded
            .filter { $0.type == .style }
            .observeNext { [weak self] _ in
                guard let self else { return }

                completion()

                if let token = weakToken {
                    self.cancelables.remove(token)
                }
            }
        weakToken = token
        token.store(in: &cancelables)
    }

    /// Loads a `style` from a StyleURI, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// - Parameters:
    ///   - styleURI: StyleURI to load
    ///   - transition: Options for the style transition.
    ///   - completion: Closure called when the style has been fully loaded.
    ///     If style has failed to load a `MapLoadingError` is provided to the closure.
    public func loadStyle(_ styleURI: StyleURI,
                          transition: TransitionOptions? = nil,
                          completion: ((MapLoadingError?) -> Void)? = nil) {
        if let transition {
            observeStyleDataLoaded { [weak self] in
                self?.styleTransition = transition
            }
        }
        if let completion {
            observeStyleLoad(completion)
        }
        __map.setStyleURIForUri(styleURI.rawValue)
    }

    /// Loads a `style` from a StyleURI, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// - Parameters:
    ///   - styleURI: StyleURI to load
    ///   - completion: Closure called when the style has been fully loaded.
    @available(*, deprecated, renamed: "loadStyle")
    public func loadStyleURI(_ styleURI: StyleURI, completion: ((MapLoadingError?) -> Void)? = nil) {
        loadStyle(styleURI, completion: completion)
    }

    /// Loads a `style` from a JSON string, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// - Parameters:
    ///   - JSON: Style JSON string
    ///   - transition: Options for the style transition.
    ///   - completion: Closure called when the style has been fully loaded.
    ///     If style has failed to load a `MapLoadingError` is provided to the closure.
    public func loadStyle(_ JSON: String,
                          transition: TransitionOptions? = nil,
                          completion: ((MapLoadingError?) -> Void)? = nil) {
        if let transition {
            observeStyleDataLoaded { [weak self] in self?.styleTransition = transition }
        }
        if let completion {
            observeStyleLoad(completion)
        }
        __map.setStyleJSONForJson(JSON)
    }

    /// Loads a `style` from a JSON string, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// - Parameters:
    ///   - JSON: Style JSON string
    ///   - completion: Closure called when the style has been fully loaded. The
    ///     `Result` type encapsulates the `Style` or error that occurred. See
    ///     `MapLoadingError`
    @available(*, deprecated, renamed: "loadStyle")
    public func loadStyleJSON(_ JSON: String, completion: ((MapLoadingError?) -> Void)? = nil) {
        loadStyle(JSON, completion: completion)
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

    /// The tile cache budget hint to be used by the map.
    ///
    /// The budget can be given in tile units or in megabytes. A Map will do the best effort to keep memory
    /// allocations for a non essential resources within the budget.
    ///
    /// If tile cache budget in megabytes is set, the engine will try to use ETC1 texture compression
    /// for raster layers, therefore, raster images with alpha channel will be rendered incorrectly.
    ///
    /// If null is set, the tile cache budget in tile units will be dynamically calculated based on
    /// the current viewport size.
    /// - Parameter tileCacheBudget: The tile cache budget hint to be used by the Map.
    public func setTileCacheBudget(_ tileCacheBudget: TileCacheBudget?) {
        __map.__setTileCacheBudgetFor(tileCacheBudget)
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
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)

        let coordinates = coordinates(for: [topRight, bottomLeft])

        let northeast = coordinates[0].wrap()
        let southwest = coordinates[1].wrap()

        return CoordinateBounds(southwest: southwest, northeast: northeast)
    }

    /// Transforms a set of map coordinate bounds to a `CGRect` relative to the `MapView`.
    /// - Parameter coordinateBounds: The `coordinateBounds` that will be converted into a rect relative to the `MapView`
    /// - Returns: A `CGRect` whose corners represent the vertices of a set of `CoordinateBounds`.
    public func rect(for coordinateBounds: CoordinateBounds) -> CGRect {
        let points = points(for: [coordinateBounds.southwest.wrap(), coordinateBounds.northeast.wrap()])
        let swPoint = points[0]
        let nePoint = points[1]

        return CGRect(origin: swPoint, size: CGSize.zero).extend(from: nePoint)
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
    ///   - padding: The amount of padding to add to the given bounds when calculating the camera, in points. This is differnt from camera padding.
    ///   - bearing: The new bearing to be used by the camera, in degrees (0°, 360°) clockwise from true north.
    ///   - pitch: The new pitch to be used by the camera, in degrees (0°, 85°) with 0° being a top-down view.
    ///   - maxZoom: The maximum zoom level to allow when the camera would transition to the specified bounds.
    ///   - offset: The center of the given bounds relative to the map's center, measured in points.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    public func camera(for coordinateBounds: CoordinateBounds, // swiftlint:disable:this function_parameter_count
                       padding: UIEdgeInsets,
                       bearing: Double?,
                       pitch: Double?,
                       maxZoom: Double?,
                       offset: CGPoint?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinateBounds(
                for: coordinateBounds,
                padding: padding.toMBXEdgeInsetsValue(),
                bearing: bearing?.NSNumber,
                pitch: pitch?.NSNumber,
                maxZoom: maxZoom?.NSNumber,
                offset: offset?.screenCoordinate))
    }

    /// Calculates a `CameraOptions` to fit a list of coordinates.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameters:
    ///   - coordinates: Array of coordinates that should fit within the new viewport.
    ///   - padding: The amount of padding to add to the given bounds when calculating the camera, in points. This is differnt from camera padding. 
    ///   - bearing: The new bearing to be used by the camera, in degrees (0°, 360°) clockwise from true north.
    ///   - pitch: The new pitch to be used by the camera, in degrees (0°, 85°) with 0° being a top-down view.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    public func camera(for coordinates: [CLLocationCoordinate2D],
                       padding: UIEdgeInsets?,
                       bearing: Double?,
                       pitch: Double?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinates(
                forCoordinates: coordinates.map(\.location),
                padding: padding?.toMBXEdgeInsetsValue(),
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
        return __map.pixelForCoordinate(for: coordinate).point.fit(to: size)
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

    /// Obtains the geographical coordinate information that corresponds to a given point.
    /// The point must exist in the coordinate space of the ``MapView``.
    ///
    /// The returned coordinate will be the closest position projected onto the map surface,
    /// in case the screen coordinate does not intersect with the map surface.
    ///
    /// - Parameter point: The point to convert. Must exist in the coordinate space
    ///     of the `MapView`.
    ///
    /// - Returns: A `CoordinateInfo` record containing information about the geographical coordinate corresponding to the given point, including whether it is on the map surface.
    func coordinateInfo(for point: CGPoint) -> CoordinateInfo {
        return __map.coordinateInfoForPixel(forPixel: point.screenCoordinate)
    }

    /// Obtains the geographical coordinate information that corresponds to given points.
    /// The points must exist in the coordinate space of the ``MapView``.
    ///
    /// The returned coordinate will be the closest position projected onto the map surface,
    /// in case the screen coordinate does not intersect with the map surface.
    ///
    /// - Parameter points: The array of points to convert. Points must exist in the coordinate space
    ///     of the `MapView`.
    ///
    /// - Returns: An array of `CoordinateInfo` records containing information about the geographical coordinates corresponding to the given points, including whether they are on the map surface.
    func coordinatesInfo(for points: [CGPoint]) -> [CoordinateInfo] {
        return __map.coordinatesInfoForPixels(forPixels: points.map(\.screenCoordinate))
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
        guard projection.name == .mercator else {
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
    ///   - completion: Callback called when the query completes.
    @discardableResult
    public func queryRenderedFeatures(with shape: [CGPoint], options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: .fromNSArray(shape.map {$0.screenCoordinate}),
                                       options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                       callback: coreAPIClosureAdapter(for: completion,
                                                                       type: NSArray.self,
                                                                       concreteErrorType: MapError.self))
    }

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - rect: Screen rect to query for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes.
    @discardableResult
    public func queryRenderedFeatures(with rect: CGRect, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: .fromScreenBox(.init(rect)),
                                       options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                       callback: coreAPIClosureAdapter(for: completion,
                                                                       type: NSArray.self,
                                                                       concreteErrorType: MapError.self))
    }

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - point: Screen point at which to query for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes.
    @discardableResult
    public func queryRenderedFeatures(with point: CGPoint, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: .fromScreenCoordinate(point.screenCoordinate),
                                             options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                             callback: coreAPIClosureAdapter(for: completion,
                                                                             type: NSArray.self,
                                                                             concreteErrorType: MapError.self))
    }

    /// Queries the map for source features.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier used to query for source features.
    ///   - options: Options for querying source features.
    ///   - completion: Callback called when the query completes.
    @discardableResult
    public func querySourceFeatures(for sourceId: String,
                                    options: SourceQueryOptions,
                                    completion: @escaping (Result<[QueriedSourceFeature], Error>) -> Void) -> Cancelable {
        return __map.__querySourceFeatures(forSourceId: sourceId,
                                  options: options,
                                  callback: coreAPIClosureAdapter(for: completion,
                                                                  type: NSArray.self,
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
    @discardableResult
    public func getGeoJsonClusterLeaves(forSourceId sourceId: String,
                                        feature: Feature,
                                        limit: UInt64 = 10,
                                        offset: UInt64 = 0,
                                        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable {
        return __map.__queryFeatureExtensions(forSourceIdentifier: sourceId,
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
    @discardableResult
    public func getGeoJsonClusterChildren(forSourceId sourceId: String,
                                          feature: Feature,
                                          completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable {
        return __map.__queryFeatureExtensions(forSourceIdentifier: sourceId,
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
    @discardableResult
    public func getGeoJsonClusterExpansionZoom(forSourceId sourceId: String,
                                               feature: Feature,
                                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable {
        __map.__queryFeatureExtensions(forSourceIdentifier: sourceId,
                                     feature: MapboxCommon.Feature(feature),
                                     extension: "supercluster",
                                     extensionField: "expansion-zoom",
                                     args: nil,
                                     callback: coreAPIClosureAdapter(for: completion,
                                                                     type: FeatureExtensionValue.self,
                                                                     concreteErrorType: MapError.self))
    }
}

// MARK: - Map Event handling

extension MapboxMap {

    /// The style has been fully loaded, and the map has rendered all visible tiles.
    public var onMapLoaded: Signal<MapLoaded> { events.signal(for: \.onMapLoaded) }

        /// An error that has occurred while loading the Map. The `type` property defines what resource could
        /// not be loaded and the `message` property will contain a descriptive error message.
        /// In case of `source` or `tile` loading errors, `sourceID` or `tileID` will contain the identifier of the source failing.
    public var onMapLoadingError: Signal<MapLoadingError> { events.signal(for: \.onMapLoadingError) }

        /// The requested style has been fully loaded, including the style, specified sprite and sources' metadata.
        ///
        /// The style specified sprite would be marked as loaded even with sprite loading error (an error will be emitted via ``MapboxMap/onMapLoadingError``).
        /// Sprite loading error is not fatal and we don't want it to block the map rendering, thus this event will still be emitted if style and sources are fully loaded.
    public var onStyleLoaded: Signal<StyleLoaded> { events.signal(for: \.onStyleLoaded) }

        /// The requested style data has been loaded. The `type` property defines what kind of style data has been loaded.
        /// Event may be emitted synchronously, for example, when ``MapboxMap/loadStyle(_:completion:)`` is used to load style.
        ///
        /// Based on an event data `type` property value, following use-cases may be implemented:
        /// - `style`: Style is parsed, style layer properties could be read and modified, style layers and sources could be
        /// added or removed before rendering is started.
        /// - `sprite`: Style's sprite sheet is parsed and it is possible to add or update images.
        /// - `sources`: All sources defined by the style are loaded and their properties could be read and updated if needed.
    public var onStyleDataLoaded: Signal<StyleDataLoaded> { events.signal(for: \.onStyleDataLoaded) }

        /// The camera has changed. This event is emitted whenever the visible viewport
        /// changes due to the MapView's size changing or when the camera
        /// is modified by calling camera methods. The event is emitted synchronously,
        /// so that an updated camera state can be fetched immediately.
    public var onCameraChanged: Signal<CameraChanged> { events.signal(for: \.onCameraChanged) }

        /// The map has entered the idle state. The map is in the idle state when there are no ongoing transitions
        /// and the map has rendered all requested non-volatile tiles. The event will not be emitted if animation is in progress (see ``MapboxMap/beginAnimation()``, ``MapboxMap/endAnimation()``)
        /// and / or gesture is in progress (see ``MapboxMap/beginGesture()``, ``MapboxMap/endGesture()``).
    public var onMapIdle: Signal<MapIdle> { events.signal(for: \.onMapIdle) }

        /// The source has been added with ``Style/addSource(_:id:dataId:)`` or ``Style/addSource(withId:properties:)``.
        /// The event is emitted synchronously, therefore, it is possible to immediately
        /// read added source's properties.
    public var onSourceAdded: Signal<SourceAdded> { events.signal(for: \.onSourceAdded) }

        /// The source has been removed with ``Style/removeSource(withId:)``.
        /// The event is emitted synchronously, thus, ``Style/allSourceIdentifiers`` will be
        /// in sync when the observer receives the notification.
    public var onSourceRemoved: Signal<SourceRemoved> { events.signal(for: \.onSourceRemoved) }

        /// A source data has been loaded.
        /// Event may be emitted synchronously in cases when source's metadata is available when source is added to the style.
        ///
        /// The `dataID` property defines the source id.
        ///
        /// The `type` property defines if source's metadata (e.g., TileJSON) or tile has been loaded. The property of `metadata`
        /// value might be useful to identify when particular source's metadata is loaded, thus all source's properties are
        /// readable and can be updated before map will start requesting data to be rendered.
        ///
        /// The `loaded` property will be set to `true` if all source's data required for visible viewport of the map, are loaded.
        /// The `tileID` property defines the tile id if the `type` field equals `tile`.
        /// The `dataID` property will be returned if it has been set for this source.
    public var onSourceDataLoaded: Signal<SourceDataLoaded> { events.signal(for: \.onSourceDataLoaded) }

        /// A style has a missing image. This event is emitted when the map renders visible tiles and
        /// one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
        /// by calling ``Style/addImage(_:id:sdf:contentInsets:)``.
    public var onStyleImageMissing: Signal<StyleImageMissing> { events.signal(for: \.onStyleImageMissing) }

        /// An image added to the style is no longer needed and can be removed using ``Style/removeImage(withId:)``.
    public var onStyleImageRemoveUnused: Signal<StyleImageRemoveUnused> { events.signal(for: \.onStyleImageRemoveUnused) }

        /// The map started rendering a frame.
    public var onRenderFrameStarted: Signal<RenderFrameStarted> { events.signal(for: \.onRenderFrameStarted) }

        /// The map finished rendering a frame.
        /// The `renderMode` property tells whether the map has all data (`full`) required to render the visible viewport.
        /// The `needsRepaint` property provides information about ongoing transitions that trigger map repaint.
        /// The `placementChanged` property tells if the symbol placement has been changed in the visible viewport.
    public var onRenderFrameFinished: Signal<RenderFrameFinished> { events.signal(for: \.onRenderFrameFinished) }

        /// The `ResourceRequest` event allows client to observe resource requests made by a
        /// map or snapshotter.
    public var  onResourceRequest: Signal<ResourceRequest> { events.signal(for: \.onResourceRequest) }

    /// Returns a ``Signal`` that allows to subscribe to the event with specified string name.
    /// This method is reserved for the future use.
    @_spi(Experimental)
    public subscript(eventName: String) -> Signal<GenericEvent> {
        events[eventName]
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
    @available(*, deprecated, message: "Use mapboxMap.on<eventType>.observeNext instead.")
    @discardableResult
    public func onNext<Payload>(event: MapEventType<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        events.onNext(event: event, handler: handler)
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
    @available(*, deprecated, message: "Use mapboxMap.on<eventType>.observe instead.")
    @discardableResult
    public func onEvery<Payload>(event: MapEventType<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        events.onEvery(event: event, handler: handler)
    }

    internal func performWithoutNotifying(_ block: () -> Void) {
        events.performWithoutNotifying(block)
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
    public static func clearData(completion: @escaping (Error?) -> Void) {
        MapboxMapsOptions.clearData(completion: completion)
    }
}

// MARK: - Attribution

extension MapboxMap: AttributionDataSource {
    internal func loadAttributions(completion: @escaping ([Attribution]) -> Void) {
        Attribution.parse(sourceAttributions(), completion: completion)
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
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    ///
    /// - Returns: A `Cancelable` object  that could be used to cancel the pending operation.
    @discardableResult
    public func setFeatureState(sourceId: String, sourceLayerId: String? = nil, featureId: String, state: [String: Any], callback: @escaping (Result<NSNull, Error>) -> Void) -> Cancelable {
        return __map.__setFeatureStateForSourceId(sourceId,
                                         sourceLayerId: sourceLayerId,
                                         featureId: featureId,
                                                  state: state,
                                                  callback: coreAPIClosureAdapter(for: callback,
                                                                                  type: NSNull.self,
                                                                                  concreteErrorType: MapError.self))
    }

    /// Get the state map of a feature within a style source.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier.
    ///   - sourceLayerId: Style source layer identifier (for multi-layer sources such as vector sources).
    ///   - featureId: Identifier of the feature whose state should be queried.
    ///   - callback: Feature's state map or an empty map if the feature could not be found.
    ///
    /// - Returns: A `Cancelable` object that could be used to cancel the pending query.
    @discardableResult
    public func getFeatureState(sourceId: String, sourceLayerId: String? = nil, featureId: String, callback: @escaping (Result<[String: Any], Error>) -> Void) -> Cancelable {
        return __map.__getFeatureState(forSourceId: sourceId,
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
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    ///
    /// - Returns: A `cancelable` object that could be used to cancel the pending operation.
    @discardableResult
    public func removeFeatureState(sourceId: String, sourceLayerId: String? = nil, featureId: String, stateKey: String? = nil, callback: @escaping (Result<NSNull, Error>) -> Void) -> Cancelable {
        return __map.__removeFeatureState(forSourceId: sourceId,
                                 sourceLayerId: sourceLayerId,
                                 featureId: featureId,
                                  stateKey: stateKey,
                                callback: coreAPIClosureAdapter(for: callback,
                                                                type: NSNull.self,
                                                                  concreteErrorType: MapError.self))
    }

    /// Reset all the feature states within a style source.
    /// Remove all feature state entries from the specified style source or source layer.
    /// Note that updates to feature state are asynchronous, so changes made by this method might not be
    /// immediately visible using `getStateFeature`.
    ///
    /// - Parameters:
    ///   - sourceId: The style source identifier
    ///   - sourceLayerId: The style source layer identifier (for multi-layer sources such as vector sources). Defaults to `nil`.
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    ///
    /// - Returns: A `cancelable` object that could be used to cancel the pending operation.
    @discardableResult
    public func resetFeatureStates(sourceId: String, sourceLayerId: String? = nil, callback: @escaping (Result<NSNull, Error>) -> Void) -> Cancelable {
        return __map.__resetFeatureStates(forSourceId: sourceId,
                                          sourceLayerId: sourceLayerId,
                                          callback: coreAPIClosureAdapter(for: callback,
                                                                          type: NSNull.self,
                                                                          concreteErrorType: MapError.self))
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

extension CGPoint {
    func fit(to boundingSize: CGSize) -> CGPoint {
        var x = self.x
        var y = self.y

        // Round only when value is out of the bounding box
        if x < 0 || x > boundingSize.width {
            x.round(.toNearestOrAwayFromZero)
        }
        if y < 0 || y > boundingSize.height {
            y.round(.toNearestOrAwayFromZero)
        }

        if (0...boundingSize.width).contains(x) && (0...boundingSize.height).contains(y) {
            return CGPoint(x: x, y: y)
        }

        return CGPoint(x: -1, y: -1)
    }
}
