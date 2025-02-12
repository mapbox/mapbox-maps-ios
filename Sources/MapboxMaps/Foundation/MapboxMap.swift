// swiftlint:disable file_length
import UIKit
import MapboxCoreMaps
@_implementationOnly import MapboxCommon_Private
import Turf

protocol MapboxMapProtocol: AnyObject {
    var viewAnnotationAvoidLayers: Set<String> { get set }
    var cameraBounds: CameraBounds { get }
    var cameraState: CameraState { get }
    var size: CGSize { get }
    var anchor: CGPoint { get }
    var options: MapOptions { get }
    func setCamera(to cameraOptions: CameraOptions)
    func setCameraBounds(with options: CameraBoundsOptions) throws
    func setNorthOrientation(_ northOrientation: NorthOrientation)
    func setConstrainMode(_ constrainMode: ConstrainMode)
    func setViewportMode(_ viewportMode: ViewportMode)
    func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions
    func beginAnimation()
    func endAnimation()
    func beginGesture()
    func endGesture()
    @discardableResult
    func queryRenderedFeatures(with point: CGPoint, options: RenderedQueryOptions?, completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable
    func collectPerformanceStatistics(_ options: PerformanceStatisticsOptions, callback: @escaping (PerformanceStatistics) -> Void) -> AnyCancelable

    // View annotation management
    func setViewAnnotationPositionsUpdateCallback(_ callback: ViewAnnotationPositionsUpdateCallback?)
    func addViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws
    func updateViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws
    func removeViewAnnotation(withId id: String) throws
    func options(forViewAnnotationWithId id: String) throws -> ViewAnnotationOptions
    func pointIsAboveHorizon(_ point: CGPoint) -> Bool
    // swiftlint:disable:next function_parameter_count
    func camera(for coordinateBounds: CoordinateBounds,
                padding: UIEdgeInsets?,
                bearing: Double?,
                pitch: Double?,
                maxZoom: Double?,
                offset: CGPoint?) -> CameraOptions
    func camera(for coordinates: [CLLocationCoordinate2D],
                camera: CameraOptions,
                coordinatesPadding: UIEdgeInsets?,
                maxZoom: Double?,
                offset: CGPoint?) throws -> CameraOptions
    func coordinate(for point: CGPoint) -> CLLocationCoordinate2D
    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint

    var onMapLoaded: Signal<MapLoaded> { get }
    var onMapLoadingError: Signal<MapLoadingError> { get }
    var onStyleLoaded: Signal<StyleLoaded> { get }
    var onStyleDataLoaded: Signal<StyleDataLoaded> { get }
    var onCameraChanged: Signal<CameraChanged> { get }
    var onMapIdle: Signal<MapIdle> { get }
    var onSourceAdded: Signal<SourceAdded> { get }
    var onSourceRemoved: Signal<SourceRemoved> { get }
    var onSourceDataLoaded: Signal<SourceDataLoaded> { get }
    var onStyleImageMissing: Signal<StyleImageMissing> { get }
    var onStyleImageRemoveUnused: Signal<StyleImageRemoveUnused> { get }
    var onRenderFrameStarted: Signal<RenderFrameStarted> { get }
    var onRenderFrameFinished: Signal<RenderFrameFinished> { get }
    var onResourceRequest: Signal<ResourceRequest> { get }

    func dispatch(event: CorePlatformEventInfo)
    @discardableResult func addInteraction(_ interaction: some Interaction) -> Cancelable
    @discardableResult func addInteraction(_ interaction: InteractionImpl) -> Cancelable
    @discardableResult func addInteraction(_ interaction: CoreInteraction) -> Cancelable
    @discardableResult func setFeatureState<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        featureId: FeaturesetFeatureId,
        state: T.State,
        callback: ((Error?) -> Void)?
    ) -> Cancelable
    @discardableResult func removeFeatureState<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        featureId: FeaturesetFeatureId,
        stateKey: T.StateKey?,
        callback: ((Error?) -> Void)?
    ) -> Cancelable
}

// swiftlint:disable type_body_length

/// Provides access to the map model, including the camera, style, observable map events,
/// and querying rendered features.
///
/// If you have a ``MapView`` you can access the `MapboxMap` instance via ``MapView/mapboxMap`` property.
///
/// ``MapboxMap`` inherits ``StyleManager-46yjd``, you can use it's methods to access runtime styling API:
///
///   ```swift
///   mapboxMap.styleURI = .satelliteStreets
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
public final class MapboxMap: StyleManager {
    /// The underlying renderer object responsible for rendering the map.
    private let __map: CoreMap

    /// The `style` object supports run time styling.
    @available(*, deprecated, message: "Access style APIs directly from MapboxMap instance instead")
    public var style: StyleManager { return self }

    /// Provides access to events triggered during Map lifecycle.
    private let events: MapEvents

    private let _isDefaultCameraInitialized = CurrentValueSignalProxy<Bool>()

    /// Triggered when map is loaded for the first time, and camera is initialized with default style camera options.
    var isDefaultCameraInitialized: Signal<Bool> { _isDefaultCameraInitialized.signal.skipRepeats() }

    deinit {
        __map.destroyRenderer()
    }

    init(map: CoreMap, events: MapEvents) {
        self.__map = map
        self.events = events

        super.init(with: map, sourceManager: StyleSourceManager(styleManager: map))

        __map.createRenderer()
        _isDefaultCameraInitialized.proxied = onCameraChanged.map { _ in true }
    }

    // MARK: - Render loop

    /// Triggers a repaint of the map. Calling this method is typically unnecessary but
    /// may be needed if using a custom layer that needs to be redrawn independently
    /// of other map changes.
    public func triggerRepaint() {
        __map.triggerRepaint()
    }

    // MARK: - Style loading

    /// Loads a `style` from a StyleURI, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// If style loading started while the other style is already loading, the latter's loading `completion`
    /// will receive a ``CancelError``. If a style is failed to load, `completion` will receive a ``StyleError``.
    ///
    /// - Parameters:
    ///   - styleURI: StyleURI to load
    ///   - transition: Options for the style transition.
    ///   - completion: Closure called when the style has been fully loaded.
    ///     If style has failed to load a `MapLoadingError` is provided to the closure.
    public func loadStyle(_ styleURI: StyleURI,
                          transition: TransitionOptions? = nil,
                          completion: ((Error?) -> Void)? = nil) {
        load(mapStyle: MapStyle(uri: styleURI),
             transition: transition,
             completion: completion)
    }

    /// Loads a `style` from a StyleURI, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    ///
    /// - Parameters:
    ///   - styleURI: StyleURI to load
    ///   - completion: Closure called when the style has been fully loaded.
    @available(*, deprecated, renamed: "loadStyle")
    public func loadStyleURI(_ styleURI: StyleURI, completion: ((Error?) -> Void)? = nil) {
        loadStyle(styleURI, completion: completion)
    }

    /// Loads a `style` from a JSON string, calling a completion closure when the
    /// style is fully loaded or there has been an error during load.
    ///
    /// If style loading started while the other style is already loading, the latter's loading `completion`
    /// will receive a ``CancelError``. If a style is failed to load, `completion` will receive a ``StyleError``.
    ///
    /// - Parameters:
    ///   - JSON: Style JSON string
    ///   - transition: Options for the style transition.
    ///   - completion: Closure called when the style has been fully loaded.
    ///     If style has failed to load a `MapLoadingError` is provided to the closure.
    public func loadStyle(_ JSON: String,
                          transition: TransitionOptions? = nil,
                          completion: ((Error?) -> Void)? = nil) {
        load(mapStyle: MapStyle(json: JSON),
             transition: transition,
             completion: completion)
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
    public func loadStyleJSON(_ JSON: String, completion: ((Error?) -> Void)? = nil) {
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

    /// Reduces memory use. This is called automatically when the application gets paused or
    /// sent to background.
    ///
    /// Calling this might have lead to temporary increased CPU load, as in-memory caches of tiles, images, textures etc.
    /// will be cleared. This will cause the map to fetch the required resources anew.
    /// For example, the map tiles will be re-created for the currently displayed portion of the map.
    public func reduceMemoryUse() {
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
    /// If null is set, the tile cache budget size in tile units will be dynamically calculated based on
    /// the current viewport size.
    /// - Parameter size: The tile cache budget size to be used by the Map.
    public func setTileCacheBudget(size: TileCacheBudgetSize?) {
        __map.__setTileCacheBudgetFor(size?.coreTileCacheBudget)
    }

    /// The MapboxCoreMaps tile cache budget hint to be used by the map.
    ///
    /// The budget can be given in tile units or in megabytes. A Map will do the best effort to keep memory
    /// allocations for a non essential resources within the budget.
    ///
    /// If tile cache budget in megabytes is set, the engine will try to use ETC1 texture compression
    /// for raster layers, therefore, raster images with alpha channel will be rendered incorrectly.
    ///
    /// If null is set, the tile cache budget in tile units will be dynamically calculated based on
    /// the current viewport size.
    /// - Parameter tileCacheBudget: The MapboxCoreMaps tile cache budget hint to be used by the Map.
    @available(*, deprecated, message: "Use .setTileCacheBudget(size: TileCacheBudgetSize?) instead.")
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

    /// The URL that points to the glyphs used by the style for rendering text labels on the map.
    ///
    /// This property allows setting a custom glyph URL at runtime, making it easier to
    /// apply custom fonts to the map without modifying the base style.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public var styleGlyphURL: String {
        get { __map.getStyleGlyphURL() }
        set { __map.setStyleGlyphURLForUrl(newValue) }
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
    /// The array of `MapDebugOptions` for the native map. Setting this property to an empty array
    /// disables previously enabled `MapDebugOptions`.
    /// The default value is an empty array.
    @available(*, deprecated, message: "Use MapView.debugOptions instead.")
    public var debugOptions: [MapDebugOptions] {
        get { _debugOptions }
        set { _debugOptions = newValue }
    }
    var _debugOptions: [MapDebugOptions] {
        get {
            return __map.getDebug().compactMap { MapDebugOptions(rawValue: $0.intValue) }
        }
        set {
            // Remove the previously visible options, then update the debug options to the new array.
            let oldOptions = _debugOptions.map { NSNumber(value: $0.rawValue) }
            __map.setDebugForDebugOptions(oldOptions, value: false)

            let options = newValue.map { NSNumber(value: $0.rawValue) }
            __map.setDebugForDebugOptions(options, value: true)
        }
    }

    /// Gets the size of the map in points
    var size: CGSize {
        get {
            CGSize(__map.getSize())
        }
        set {
            __map.setSizeFor(Size(newValue))
        }
    }

    /// Returns the map's options
    public var options: MapOptions {
        return __map.getOptions()
    }

    /// Set the map north orientation
    ///
    /// - Parameter northOrientation: The map north orientation to set
    public func setNorthOrientation(_ northOrientation: NorthOrientation) {
        __map.setNorthOrientationFor(northOrientation)
    }

    /// Set the map constrain mode
    ///
    /// - Parameter constrainMode: The map constraint mode to set
    public func setConstrainMode(_ constrainMode: ConstrainMode) {
        __map.setConstrainModeFor(constrainMode)
    }

    /// Set the map viewport mode
    ///
    /// - Parameter viewportMode: The map viewport mode to set
    public func setViewportMode(_ viewportMode: ViewportMode) {
        __map.setViewportModeFor(viewportMode)
    }

    /// Collects CPU and GPU resource usage, as well as timings of layers and rendering groups, over a user-configurable sampling duration.
    /// Use the collected information to identify layers or rendering groups that may be performing poorly.
    ///
    /// Use ``PerformanceStatisticsOptions`` to configure the following collection behaviours:
    ///     - Which types of sampling to perform, whether cumulative, per-frame, or both.
    ///     - Duration of sampling in milliseconds. A value of 0 forces the collection of performance statistics every frame.
    ///
    /// The statistics collection can be canceled using the ``AnyCancelable`` object returned by this function, note that if the token goes out of the scope it's deinitialized and thus canceled. Canceling collection will prevent the
    /// callback from being called. Collection can be restarted by calling ``MapboxMap/collectPerformanceStatistics(_:callback:)`` again to obtain a new ``AnyCancelable`` object.
    ///
    /// The callback function will be called every time the configured sampling duration ``PerformanceStatisticsOptions/samplingDurationMillis`` has elapsed.
    ///
    /// - Parameters:
    ///   - options The statistics collection options to collect.
    ///   - callback The callback to be invoked when performance statistics are available.
    /// - Returns:  The ``AnyCancelable`` object that can be used to cancel performance statistics collection.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func collectPerformanceStatistics(_ options: PerformanceStatisticsOptions, callback: @escaping (PerformanceStatistics) -> Void) -> AnyCancelable {
        __map.startPerformanceStatisticsCollection(for: options, callback: callback)
        return BlockCancelable { [weak self] in
            self?.__map.stopPerformanceStatisticsCollection()
        }.erased
    }

    /// Calculates a `CameraOptions` to fit a `CoordinateBounds`
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameters:
    ///   - coordinateBounds: The coordinate bounds that will be displayed within the viewport.
    ///   - padding: The amount of padding in screen points to add to the given `coordinates`.
    ///              This padding is not applied to the map but to the coordinates provided.
    ///              If you want to apply padding to the map use `camera` parameter on ``camera(for:camera:coordinatesPadding:maxZoom:offset:)``
    ///   - bearing: The new bearing to be used by the camera, in degrees (0°, 360°) clockwise from true north.
    ///   - pitch: The new pitch to be used by the camera, in degrees (0°, 85°) with 0° being a top-down view.
    ///   - maxZoom: The maximum zoom level to allow when the camera would transition to the specified bounds.
    ///   - offset: The center of the given bounds relative to the map's center, measured in points.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    /// - Important:
    ///  The equivalent of the following deprecated call, where `point1` and `point2` are the most southwestern and northeastern points:
    ///  ```swift
    ///     let coordinatesPadding = UIEdgeInsets(allEdges: 4)
    ///
    ///     mapView.mapboxMap.camera(
    ///         for: CoordinateBounds(southwest: point1, northeast: point2),
    ///         padding: coordinatesPadding,
    ///         bearing: 10,
    ///         pitch: 8
    ///     )
    ///  ```
    ///  Would be the following call that allows you to properly set map padding using initial camera options.
    ///  Where `point1` and `point2` are part of the polygon defined by points 1-4 and are are the most southwestern and northeastern points of this polygon.
    ///  ```swift
    ///     let coordinatesPadding = UIEdgeInsets(allEdges: 4)
    ///
    ///     let initialCameraOptions = CameraOptions(
    ///         padding: .zero,
    ///         bearing: 10,
    ///         pitch: 8
    ///     )
    ///
    ///    mapView.mapboxMap.camera(
    ///         for: [point1, point2, point3, point4],
    ///         camera: initialCameraOptions,
    ///         coordinatesPadding: coordinatesPadding,
    ///         maxZoom: nil,
    ///         offset: nil
    ///    )
    ///  ```
    @available(*, deprecated, renamed: "camera(for:camera:coordinatesPadding:maxZoom:offset:)", message: "Use camera(for:camera:coordinatesPadding:maxZoom:offset:) instead.")
    public func camera(for coordinateBounds: CoordinateBounds, // swiftlint:disable:this function_parameter_count
                       padding: UIEdgeInsets?,
                       bearing: Double?,
                       pitch: Double?,
                       maxZoom: Double?,
                       offset: CGPoint?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinateBounds(
                for: coordinateBounds,
                padding: padding?.toMBXEdgeInsetsValue(),
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
    ///   - padding: The amount of padding in screen points to add to the given `coordinates`.
    ///              This padding is not applied to the map but to the coordinates provided.
    ///              If you want to apply padding to the map use `camera` parameter on ``camera(for:camera:coordinatesPadding:maxZoom:offset:)``
    ///   - bearing: The new bearing to be used by the camera, in degrees (0°, 360°) clockwise from true north.
    ///   - pitch: The new pitch to be used by the camera, in degrees (0°, 85°) with 0° being a top-down view.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    /// - Important:
    ///  The equivalent of the following deprecated call:
    ///  ```swift
    ///     let coordinatesPadding = UIEdgeInsets(allEdges: 4)
    ///
    ///     mapView.mapboxMap.camera(
    ///         for: coordinates,
    ///         padding: coordinatesPadding,
    ///         bearing: 10,
    ///         pitch: 8
    ///     )
    ///  ```
    ///  Would be the following call that allows you to properly set map padding using initial camera options.
    ///  ```swift
    ///     let coordinatesPadding = UIEdgeInsets(allEdges: 4)
    ///
    ///     let initialCameraOptions = CameraOptions(
    ///         padding: .zero,
    ///         bearing: 10,
    ///         pitch: 8
    ///     )
    ///
    ///    mapView.mapboxMap.camera(
    ///         for: coordinates,
    ///         camera: initialCameraOptions,
    ///         coordinatesPadding: coordinatesPadding,
    ///         maxZoom: nil,
    ///         offset: nil
    ///    )
    ///  ```
    @available(*, deprecated, renamed: "camera(for:camera:coordinatesPadding:maxZoom:offset:)", message: "Use camera(for:camera:coordinatesPadding:maxZoom:offset:) instead.")
    public func camera(for coordinates: [CLLocationCoordinate2D],
                       padding: UIEdgeInsets?,
                       bearing: Double?,
                       pitch: Double?) -> CameraOptions {
        return CameraOptions(
            __map.cameraForCoordinates(
                for: coordinates.map { Coordinate2D(value: $0) },
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
                for: coordinates.map { Coordinate2D(value: $0) },
                camera: CoreCameraOptions(camera),
                box: CoreScreenBox(rect)))
    }

    /// Convenience method that returns the `camera options` object for given parameters.
    ///
    /// - Parameters:
    ///   - coordinates: The `coordinates` representing the bounds of the camera.
    ///   - camera: The `camera options` which will be applied before calculating the camera for the coordinates.
    ///   If any of the fields in camera options is not provided then the current value from the map for that field will be used.
    ///   - coordinatesPadding: The amount of padding in screen points to add to the given `coordinates`.
    ///   This padding is not applied to the map but to the coordinates provided. If you want to apply padding to the map use `camera` parameter.
    ///   - maxZoom: The maximum zoom level allowed in the returned camera options.
    ///   - offset: The center of the given bounds relative to map center in screen points.
    /// - Returns: A `CameraOptions` object representing the provided parameters.
    public func camera(for coordinates: [CLLocationCoordinate2D],
                       camera: CameraOptions,
                       coordinatesPadding: UIEdgeInsets?,
                       maxZoom: Double?,
                       offset: CGPoint?) throws -> CameraOptions {
        let expected = __map.cameraForCoordinates(
            for: coordinates.map { Coordinate2D(value: $0) },
            camera: CoreCameraOptions(camera),
            coordinatesPadding: coordinatesPadding?.toMBXEdgeInsetsValue(),
            maxZoom: maxZoom as? NSNumber,
            offset: offset?.screenCoordinate
        )

        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
        guard let options = expected.value else {
            throw MapError(coreError: "Failed to unwrap CameraOptions")
        }
        return CameraOptions(options)
    }

    /// Calculates a `CameraOptions` to fit a geometry
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameters:
    ///   - geometry: The geometry that will be displayed within the viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    ///
    /// - Important:
    ///  The equivalent of the following deprecated call:
    ///  ```swift
    ///     mapView.mapboxMap.camera(
    ///         for: .polygon(Polygon([..])),
    ///         padding: coordinatesPadding,
    ///         bearing: 10,
    ///         pitch: 8
    ///     )
    ///  ```
    ///  Would be the following call that allows you to properly set map padding using initial camera options.
    ///  ```swift
    ///     let initialCameraOptions = CameraOptions(
    ///         padding: .zero,
    ///         bearing: 10,
    ///         pitch: 8
    ///     )
    ///
    ///    mapView.mapboxMap.camera(
    ///         for: Polygon([..]).coordinates.flatMap { $0 },
    ///         camera: initialCameraOptions,
    ///         coordinatesPadding: coordinatesPadding,
    ///         maxZoom: nil,
    ///         offset: nil
    ///    )
    ///  ```
    @available(*, deprecated, renamed: "camera(for:camera:coordinatesPadding:maxZoom:offset:)", message: "Use camera(for:camera:coordinatesPadding:maxZoom:offset:) method instead.")
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
            forCamera: CoreCameraOptions(camera))
    }

    /// Returns the unwrapped coordinate bounds to a given ``CameraOptions-swift.struct``.
    ///
    /// This function is particularly useful, if the camera shows the antimeridian.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter camera: The camera for which the coordinate bounds will be returned.
    /// - Returns: `CoordinateBounds` for the given ``CameraOptions-swift.struct``.
    public func coordinateBoundsUnwrapped(for camera: CameraOptions) -> CoordinateBounds {
        return __map.coordinateBoundsForCameraUnwrapped(forCamera: CoreCameraOptions(camera))
    }

    /// Returns the coordinate bounds and zoom for a given `CameraOptions`.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter camera: The camera for which the `CoordinateBoundsZoom` will be returned.
    /// - Returns: `CoordinateBoundsZoom` for the given `CameraOptions`
    public func coordinateBoundsZoom(for camera: CameraOptions) -> CoordinateBoundsZoom {
        return __map.coordinateBoundsZoomForCamera(forCamera: CoreCameraOptions(camera))
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
        return __map.coordinateBoundsZoomForCameraUnwrapped(forCamera: CoreCameraOptions(camera))
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
        let locations = coordinates.map { Coordinate2D(value: $0) }
        let screenCoords = __map.pixelsForCoordinates(for: locations)
        return screenCoords.map { bounds.contains($0.point) ? $0.point : CGPoint(x: -1.0, y: -1.0) }
    }

    /// Converts points in the mapView's coordinate system to geographic coordinates.
    /// The points must exist in the coordinate space of the `MapView`.
    ///
    /// This API isn't supported by Globe projection.
    ///
    /// - Parameter points: The points to convert. Must exist in the coordinate space
    ///     of the `MapView`
    /// - Returns: A `CLLocationCoordinate` that represents the geographic location
    ///     of the point.
    public func coordinates(for points: [CGPoint]) -> [CLLocationCoordinate2D] {
        let screenCoords = points.map { $0.screenCoordinate }
        let locations = __map.coordinatesForPixels(forPixels: screenCoords)
        return locations.map { $0.value }
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
    public func coordinateInfo(for point: CGPoint) -> CoordinateInfo {
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
    public func coordinatesInfo(for points: [CGPoint]) -> [CoordinateInfo] {
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
        __map.setCameraFor(CoreCameraOptions(cameraOptions))
    }

    /// Returns the current camera state
    public var cameraState: CameraState {
        return CameraState(__map.getCameraState())
    }

    /// The map's current anchor, calculated after applying padding (if it exists)
    var anchor: CGPoint {
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
        let expected = __map.setBoundsFor(CoreCameraBoundsOptions(options))

        if expected.isError() {
            throw MapError(coreError: expected.error)
        }
    }

    // MARK: - Drag API

    /// Calculates target point where camera should move after drag. The method
    /// should be called after `beginGesture` and before `endGesture`.
    ///
    /// - Parameters:
    ///   - from: The point from which the map is dragged.
    ///   - to: The point to which the map is dragged.
    ///
    /// - Returns:
    ///     The camera options object showing end point.
    public func dragCameraOptions(from: CGPoint, to: CGPoint) -> CameraOptions {
        let options = __map.cameraForDrag(forStart: from.screenCoordinate, end: to.screenCoordinate)
        return CameraOptions(options)
    }

    /// :nodoc:
    func pointIsAboveHorizon(_ point: CGPoint) -> Bool {
        guard projection?.name == .mercator else {
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

    /// Returns `true` if an animation is currently in progress.
    public var isAnimationInProgress: Bool { __map.isUserAnimationInProgress() }

    private var animationCount = 0

    /// If implementing a custom animation mechanism, call this method when the animation begins.
    ///
    /// Tells the map rendering engine that the animation is currently performed by the
    /// user (e.g. with a `setCamera` calls series). It adjusts the engine for the animation use case.
    /// In particular, it brings more stability to symbol placement and rendering.
    ///
    /// - Note: Must always be paired with a corresponding call to `endAnimation()`.
    public func beginAnimation() {
        animationCount += 1
        if animationCount == 1 {
            __map.setUserAnimationInProgressForInProgress(true)
        }
    }

    /// If implementing a custom animation mechanism, call this method when the animation ends.
    ///
    /// - Note: Must always be paired with a corresponding call to `beginAnimation()`.
    public func endAnimation() {
        assert(animationCount > 0)
        animationCount -= 1
        if animationCount == 0 {
            __map.setUserAnimationInProgressForInProgress(false)
        }
    }

    /// Get/set the map centerAltitudeMode that defines how the map center point should react to terrain elevation changes.
    /// See ``MapCenterAltitudeMode`` for options.
    public var centerAltitudeMode: MapCenterAltitudeMode {
        get { __map.getCenterAltitudeMode() }
        set {
            __map.setCenterAltitudeModeFor(newValue)
            gestureState.intrinsicMode = newValue
        }
    }

    private struct GestureState {
        var count: Int
        var intrinsicMode: MapCenterAltitudeMode
    }

    private lazy var gestureState = GestureState(count: 0, intrinsicMode: centerAltitudeMode)

    /// Returns `true` if a gesture is currently in progress.
    public var isGestureInProgress: Bool { __map.isGestureInProgress() }

    /// If implementing a custom gesture, call this method when the gesture begins.
    ///
    /// Tells the map rendering engine that there is currently a gesture in progress. This
    /// affects how the map renders labels, as it will use different texture filters if a gesture
    /// is ongoing.
    ///
    /// - Note: Must always be paired with a corresponding call to `endGesture()`
    public func beginGesture() {
        gestureState.count += 1
        if gestureState.count == 1 { __map.setGestureInProgressForInProgress(true) }

        /// We should set the center altitude mode to ``MapCenterAltitudeMode.sea`` during gestures to avoid bumpiness when the terrain is enabled.
        /// It's not necessary to update ``MapCenterAltitudeMode`` if the user explicitly changed altitude to ``MapCenterAltitudeMode.sea`` before the gesture starts.
        if centerAltitudeMode != .sea { __map.setCenterAltitudeModeFor(.sea) }
    }

    /// If implementing a custom gesture, call this method when the gesture ends.
    ///
    /// - Note: Must always be paired with a corresponding call to `beginGesture()`.
    public func endGesture() {
        assert(gestureState.count > 0)
        gestureState.count -= 1
        if gestureState.count == 0 {
            __map.setGestureInProgressForInProgress(false)

            /// After the gesture end we must ensure to set the ``centerAltitudeMode`` expected be the user.
            __map.setCenterAltitudeModeFor(gestureState.intrinsicMode)
        }
    }

    func dispatch(event: CorePlatformEventInfo) {
        __map.dispatch(for: event)
    }
}

extension MapboxMap: MapboxMapProtocol {}

// swiftlint:enable type_body_length

// MARK: - MapFeatureQueryable

extension MapboxMap: MapFeatureQueryable {

    /// Queries the map for rendered features.
    ///
    /// The feature must be visible on screen to be queried. The `geometry` defines a portion of the screen that should be queried. Thus, it must be a screen coordinate.
    ///
    /// If the `geometry` parameter is CGPoint, only that point is queried. When it's a `CGRect` or an array of `CGPoint`, the shape is queried.
    ///
    /// - Important: If you need to handle basic gestures on map content, please prefer to use Interactions API (see ``MapboxMap/addInteraction(_:)``). If you need to query a featureset from an imported style, use ``queryRenderedFeatures(with:featureset:filter:completion:)`` instead.
    ///
    /// - Parameters:
    ///   - geometry: A screen geometry to query. Can be a `CGPoint`, `CGRect`, or an array of `CGPoint`.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes.
    @discardableResult
    public func queryRenderedFeatures(with geometry: some RenderedQueryGeometryConvertible, options: RenderedQueryOptions? = nil, completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: geometry.geometry.core,
                                             options: options ?? RenderedQueryOptions(layerIds: nil, filter: nil),
                                             callback: coreAPIClosureAdapter(for: completion,
                                                                             type: NSArray.self,
                                                                             concreteErrorType: MapError.self))
    }

    private func queryRenderedFeatures(with geometry: some RenderedQueryGeometryConvertible,
                                       targets: [CoreFeaturesetQueryTarget],
                                       completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable {
        return __map.__queryRenderedFeatures(for: geometry.geometry.core,
                                             targets: targets,
                                             callback: coreAPIClosureAdapter(for: completion,
                                                                             type: NSArray.self,
                                                                             concreteErrorType: MapError.self))
    }

    /// Queries the map for rendered features with one typed featureset.
    ///
    /// The results array will contain features of the type specified by this featureset.
    ///
    ///```swift
    /// mapView.mapboxMap.queryRenderedFeatures(
    ///   with: CGPoint(x: 0, y: 0),
    ///   featureset: .standardBuildings) { result in
    ///     // handle buildings in result
    /// }
    /// ```
    ///
    /// - Important: If you need to handle basic gestures on map content, please prefer to use Interactions API, see ``MapboxMap/addInteraction(_:)``.
    ///
    /// - Parameters:
    ///   - geometry: A screen geometry to query. Can be a `CGPoint`, `CGRect`, or an array of `CGPoint`.
    ///   - featureset: A typed featureset to query with.
    ///   - filter: An additional filter for features.
    ///   - completion: Callback called when the query completes.
    @_spi(Experimental)
    @_documentation(visibility: public)
    @discardableResult
    public func queryRenderedFeatures<G: RenderedQueryGeometryConvertible, T: FeaturesetFeatureType>(
        with geometry: G,
        featureset: FeaturesetDescriptor<T>,
        filter: Exp? = nil,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> Cancelable {
            queryRenderedFeatures(
                with: geometry,
                targets: [
                    CoreFeaturesetQueryTarget(featureset: featureset.core, filter: filter?.asCore, id: nil)
                ]) { result in
                    completion(result.map({ features in
                        features.compactMap {
                            T.init(from: FeaturesetFeature(
                              queriedFeature: $0.queriedFeature,
                              featureset: featureset.converted()))
                        }
                    }))
                }
    }

    /// Queries all rendered features in current viewport, using one typed featureset.
    ///
    /// This is same as ``MapboxMap/queryRenderedFeatures(with:featureset:filter:completion:)`` called with geometry matching the current viewport.
    ///
    /// - Important: If you need to handle basic gestures on map content, please prefer to use Interactions API, see ``MapboxMap/addInteraction(_:)``.
    ///
    /// - Parameters:
    ///   - featureset: A typed featureset to query with.
    ///   - filter: An additional filter for features.
    ///   - completion: Callback called when the query completes.
    @_spi(Experimental)
    @_documentation(visibility: public)
    @discardableResult
    public func queryRenderedFeatures<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        filter: Exp? = nil,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> Cancelable {
        queryRenderedFeatures(
            with: CGRect(origin: .zero, size: size),
            featureset: featureset,
            filter: filter,
            completion: completion)
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
        /// Event may be emitted synchronously, for example, when ``MapboxMap/loadStyle(_:transition:completion:)-1ilz1`` is used to load style.
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

        /// The source has been added with ``StyleManager/addSource(_:dataId:)``  or ``StyleManager/addSource(withId:properties:)``.
        /// The event is emitted synchronously, therefore, it is possible to immediately
        /// read added source's properties.
    public var onSourceAdded: Signal<SourceAdded> { events.signal(for: \.onSourceAdded) }

        /// The source has been removed with ``StyleManager/removeSource(withId:)``.
        /// The event is emitted synchronously, thus, ``StyleManager/allSourceIdentifiers`` will be
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
        /// by calling ``StyleManager/addImage(_:id:sdf:contentInsets:)``.
    public var onStyleImageMissing: Signal<StyleImageMissing> { events.signal(for: \.onStyleImageMissing) }

        /// An image added to the style is no longer needed and can be removed using ``StyleManager/removeImage(withId:)``.
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
    @_documentation(visibility: public)
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
    ///   - event: The event type to listen to.
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
    ///   - event: The event type to listen to.
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
    func loadAttributions(completion: @escaping ([Attribution]) -> Void) {
        Attribution.parse(__map.getAttributions(), completion: completion)
    }
}

// MARK: - Feature State

@_documentation(visibility: public)
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

    /// Update the state map of a feature within a featureset.
    /// Update entries in the state map of a given feature within a style source. Only entries listed in the state map
    /// will be updated. An entry in the feature state map that is not listed in `state` will retain its previous value.
    ///
    /// - Parameters:
    ///   - featureset: The featureset to look the feature in.
    ///   - featureId: Identifier of the feature whose state should be updated.
    ///   - state: Map of entries to update with their respective new values
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    ///
    /// - Returns: A `Cancelable` object  that could be used to cancel the pending operation.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func setFeatureState<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        featureId: FeaturesetFeatureId,
        state: T.State,
        callback: ((Error?) -> Void)? = nil
    ) -> Cancelable {
        guard let json = encodeState(state) else {
            callback?(MapError(coreError: "Failed to encode feature state"))
            return AnyCancelable.empty
        }
        return __map.__setFeatureStateForFeatureset(featureset.core,
                                                    featureId: featureId.core,
                                                    state: json,
                                                    callback: coreAPIClosureAdapter(for: simplifyNSNullResult(callback),
                                                                                    type: NSNull.self,
                                                                                    concreteErrorType: MapError.self))
    }

    /// Update the state map of an individual feature.
    ///
    ///  The feature should have a non-nil ``FeaturesetFeatureType/id``. Otherwise,
    ///  the operation will be no-op and callback will receive an error.
    ///
    /// - Parameters:
    ///   - feature: The feature to update.
    ///   - state: Map of entries to update with their respective new values
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    ///
    /// - Returns: A `Cancelable` object  that could be used to cancel the pending operation.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func setFeatureState<T: FeaturesetFeatureType>(
        _ feature: T,
        state: T.State,
        callback: ((Error?) -> Void)? = nil
    ) -> Cancelable {
        guard let id = feature.id else {
            callback?(MapError(coreError: "Feature id is not specified"))
            return AnyCancelable.empty
        }
        return setFeatureState(featureset: feature.featureset, featureId: id, state: state, callback: callback)
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

    /// Get the state map of a feature within a style source.
    ///
    /// - Parameters:
    ///   - featureset: A featureset the feature belongs to.
    ///   - featureId: Identifier of the feature whose state should be queried.
    ///   - callback: Feature's state map or an empty map if the feature could not be found.
    ///
    /// - Returns: A `Cancelable` object that could be used to cancel the pending query.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func getFeatureState<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        featureId: FeaturesetFeatureId,
        callback: @escaping (Result<T.State, Error>) -> Void
    ) -> Cancelable {
        __map.__getFeatureState(
            forFeatureset: featureset.core,
            featureId: featureId.core,
            callback: coreAPIClosureAdapter(for: { result in
                callback(result.mapWithError {
                    try decodeState(json: JSONObject(turfRawValue: $0) ?? [:])
                })
            },
                                            type: AnyObject.self,
                                            concreteErrorType: MapError.self))
    }

    /// Get the state map of a feature within a style source.
    ///
    /// - Parameters:
    ///   - feature: An interactive feature to query the state from.
    ///   - callback: Feature's state map or an empty map if the feature could not be found.
    ///
    /// - Returns: A `Cancelable` object that could be used to cancel the pending query.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func getFeatureState<F: FeaturesetFeatureType>(
        _ feature: F,
        callback: @escaping (Result<F.State, Error>) -> Void
    ) -> Cancelable {
        guard let id = feature.id else {
            callback(.failure(MapError(coreError: "Feature id is not specified")))
            return AnyCancelable.empty
        }
        return getFeatureState(featureset: feature.featureset, featureId: id, callback: callback)
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

    /// Removes entries from a feature state object of a feature in the specified featureset.
    /// Remove a specified property or all property from a feature's state object, depending on the value of `stateKey`.
    ///
    /// - Parameters:
    ///   - featureset: A featureset the feature belongs to.
    ///   - featureId: Identifier of the feature whose state should be queried.
    ///   - stateKey: The key of the property to remove. If `nil`, all feature's state object properties are removed. Defaults to `nil`.
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    /// - Returns: A `Cancelable` object that could be used to cancel the pending operation.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func removeFeatureState<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        featureId: FeaturesetFeatureId,
        stateKey: T.StateKey?,
        callback: ((Error?) -> Void)? = nil
    ) -> Cancelable {
        return __map.__removeFeatureState(
            forFeatureset: featureset.core,
            featureId: featureId.core,
            stateKey: stateKey?.description,
            callback: coreAPIClosureAdapter(for: simplifyNSNullResult(callback),
                                            type: NSNull.self,
                                            concreteErrorType: MapError.self))
    }

    /// Removes entries from a specified Feature.
    /// Remove a specified property or all property from a feature's state object, depending on the value of `stateKey`.
    ///
    /// - Parameters:
    ///   - feature: An interactive feature to update.
    ///   - stateKey: The key of the property to remove. If `nil`, all feature's state object properties are removed. Defaults to `nil`.
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    /// - Returns: A `Cancelable` object that could be used to cancel the pending operation.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func removeFeatureState<F: FeaturesetFeatureType>(
        _ feature: F,
        stateKey: F.StateKey?,
        callback: ((Error?) -> Void)? = nil
    ) -> Cancelable {
        guard let id = feature.id else {
            callback?(MapError(coreError: "Feature id is not specified"))
            return AnyCancelable.empty
        }
        return removeFeatureState(
            featureset: feature.featureset,
            featureId: id,
            stateKey: stateKey,
            callback: callback)
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

    /// Reset all the feature states within a featureset.
    ///
    /// Note that updates to feature state are asynchronous, so changes made by this method might not be
    /// immediately visible using ``MapboxMap/getFeatureState(_:callback:)``.
    ///
    /// - Parameters:
    ///   - featureset: A featureset descriptor
    ///   - callback: The `feature state operation callback` called when the operation completes or ends.
    ///
    /// - Returns: A `cancelable` object that could be used to cancel the pending operation.
    @_documentation(visibility: public)
    @_spi(Experimental)
    @discardableResult
    public func resetFeatureStates<T: FeaturesetFeatureType>(
        featureset: FeaturesetDescriptor<T>,
        callback: ((Error?) -> Void)?
    ) -> Cancelable {
        return __map.__resetFeatureStates(
            forFeatureset: featureset.core,
            callback: coreAPIClosureAdapter(for: simplifyNSNullResult(callback),
                                            type: NSNull.self,
                                            concreteErrorType: MapError.self))

    }
}

// MARK: - View Annotations

extension MapboxMap {
    var viewAnnotationAvoidLayers: Set<String> {
        get { __map.getViewAnnotationAvoidLayers() }
        set { __map.setViewAnnotationAvoidLayersForLayerIds(newValue) }
    }

    func setViewAnnotationPositionsUpdateCallback(_ callback: ViewAnnotationPositionsUpdateCallback?) {
        __map.setViewAnnotationPositionsUpdateListenerFor(callback.map {
            ViewAnnotationPositionsUpdateListenerImpl(callback: $0)
        })
    }

    func addViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws {
        let expected = __map.addViewAnnotation(forIdentifier: id, options: CoreViewAnnotationOptions(options))
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
    }

    func updateViewAnnotation(withId id: String, options: ViewAnnotationOptions) throws {
        let expected = __map.updateViewAnnotation(forIdentifier: id, options: CoreViewAnnotationOptions(options))
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
    }

    func removeViewAnnotation(withId id: String) throws {
        let expected = __map.removeViewAnnotation(forIdentifier: id)
        if expected.isError(), let reason = expected.error {
            throw MapError(coreError: reason)
        }
    }

    func options(forViewAnnotationWithId id: String) throws -> ViewAnnotationOptions {
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
    ///   - options: Options for the tile cover method.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func tileCover(for options: TileCoverOptions) -> [CanonicalTileID] {
        __map.__tileCover(
            for: CoreTileCoverOptions(options),
            cameraOptions: nil)
    }
}

// MARK: - Map Recorder

extension MapboxMap {

    /// Create a ``MapRecorder-4soa`` to record the current MapboxMap
    @_spi(Experimental) public final func makeRecorder() throws -> MapRecorder {
        try MapRecorder(mapView: __map)
    }
}

// MARK: - Interactions

extension MapboxMap {
    func addInteraction(_ interaction: CoreInteraction) -> Cancelable {
        __map.addInteraction(for: interaction)
    }

    /// Adds interaction to the map.
    ///
    /// Use this method to add ``TapInteraction`` or ``LongPressInteraction`` to the map.
    ///
    /// ```swift
    /// map.addInteraction(TapInteraction(.layer("my-layer") { feature, context in
    ///     // Handle tap on the feature
    ///     return true // Stops propagation to features below or the map.
    /// })
    ///
    /// map.addInteraction(TapInteraction{ context in
    ///     // Handle tap on the map itself
    ///     return true
    /// })
    /// ```
    ///
    /// - Parameters:
    ///     - interaction: An instance of interaction
    /// - Returns: A cancelable token that cancels (removes) the interaction.
    @_spi(Experimental)
    @_documentation(visibility: public)
    @discardableResult public func addInteraction(_ interaction: some Interaction) -> Cancelable {
        addInteraction(interaction.impl)
    }

    @discardableResult func addInteraction(_ interaction: InteractionImpl) -> Cancelable {
        addInteraction(CoreInteraction(impl: interaction))
    }
}

// MARK: - Testing only!

extension MapboxMap {
    internal var __testingMap: CoreMap {
        return __map
    }

    /// For internal use only
    /// Triggers a gesture of the provided type at the specified screen coordinates
    @_spi(Experimental)
    @_spi(Internal)
    public func dispatch(gesture: String, screenCoordinateX: Double, screenCoordinateY: Double) {
        var eventType = CorePlatformEventType.click
        switch gesture {
        case "click":
            eventType = .click
        case "longClick":
            eventType = .longClick
        case "drag":
            eventType = .drag
        case "dragBeing":
            eventType = .dragBegin
        case "dragEnd":
            eventType = .dragEnd
        default: break
        }
        dispatch(event: CorePlatformEventInfo(type: eventType, screenCoordinate: CoreScreenCoordinate(x: CGFloat(screenCoordinateX), y: CGFloat(screenCoordinateY))))
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

func simplifyNSNullResult(_ callback: ((Error?) -> Void)?) -> (Result<NSNull, Error>) -> Void {
    guard let callback else { return { _ in } }
    return { result in
        switch result {
        case .success:
            callback(nil)
        case .failure(let error):
            callback(error)
        }
    }
}
