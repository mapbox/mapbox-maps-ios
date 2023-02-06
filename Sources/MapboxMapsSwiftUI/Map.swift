@_exported import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public extension CameraState {
    /// Initializes CameraState with center and zoom.
    init(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.init(center: center, padding: .zero, zoom: zoom, bearing: 0, pitch: 0)
    }
}

/// The action that is called when the map is loaded.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapLoadedAction = (MapboxMap) -> Void

@_spi(Experimental)
@available(iOS 13.0, *)
public struct Map: View {
    public typealias InitOptionsProvider = () -> MapInitOptions
    public typealias TapAction = (CGPoint) -> Void
    public typealias TapQueryAction = (CGPoint, (Result<[QueriedFeature], Error>)) -> Void
    typealias TapActionWithQueryPair = (options: RenderedQueryOptions?, action: TapQueryAction)

    var camera: Binding<CameraState>?
    private var mapDependencies = MapDependencies()
    private let mapInitOptions: InitOptionsProvider?

    /// Creates an instance showing scpecisif region.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - resourceOptions: ``ResourceOptions``; default creates an instance using `ResourceOptionsManager.default`.
    ///     - mapOptions: ``MapOptions``; see ``GlyphsRasterizationOptions`` for the default  used for glyph rendering.
    public init(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil
    ) {
        self.camera = camera
        self.mapInitOptions = mapInitOptions
    }

    public var body: some View {
        ZStack {
            InternalMap(camera: camera, mapConfiguration: mapDependencies, mapInitOptions: mapInitOptions)
        }
    }
}

@available(iOS 14.0, *)
extension Map {
    private func set<T>(_ keyPath: WritableKeyPath<Map, T>, _ value: T) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }

    /// Sets camera bounds.
    public func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        set(\.mapDependencies.cameraBounds, cameraBounds)
    }

    /// Adds callback to map loaded event.
    public func onMapLoaded(_ callback: @escaping MapLoadedAction) -> Self {
        set(\.mapDependencies.actions.onMapLoaded, callback)
    }

    /// Sets style to the map.
    ///
    /// - Parameters:
    ///     - default: A Style URI to be used by default.
    ///     - darkMode: A Style URI which will automaticaly be used for dark mode. If not specified,
    ///         the default option will continue to be used.
    public func styleURI(_ default: StyleURI, darkMode: StyleURI? = nil) -> Self {
        set(\.mapDependencies.styleURIs, .init(default: `default`, darkMode: darkMode))
    }

    /// Configures gestures options.
    public func gestureOptions(_ options: GestureOptions) -> Self {
        set(\.mapDependencies.getstureOptions, options)
    }

    /// Adds tap handler to the map.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
    public func onMapTapGesture(action: @escaping TapAction) -> Self {
        set(\.mapDependencies.actions.onMapTapGesture, action)
    }

    /// Adds tap handler which additionally queries rendered features under the point.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    /// The queried features can be filtered by `queryOptions`.
    ///
    /// - Parameters:
    ///  - queryOptions: The options used to query features.
    ///  - action: The action to perform.
    public func onMapTapGesture(queryOptions: RenderedQueryOptions? = nil, action: @escaping TapQueryAction) -> Self {
        var updated = self
        updated.mapDependencies.actions.tapActionsWithQuery.append((options: queryOptions, action: action))
        return updated
    }

    /// Sets constraint mode to the map
    public func constrainMode(_ constrainMode: ConstrainMode) -> Self {
        set(\.mapDependencies.constrainMode, constrainMode)
    }

    /// Sets viewport mode to the map
    public func viewportMode(_ viewportMode: ViewportMode) -> Self {
        set(\.mapDependencies.viewportMode, viewportMode)
    }

    /// Sets ``NorthOrientation`` to the map.
    public func northOrientation(_ northOrientation: NorthOrientation) -> Self {
        set(\.mapDependencies.orientation, northOrientation)
    }
}
