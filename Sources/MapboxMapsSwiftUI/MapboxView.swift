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
    public typealias InitialOptionsProvider = () -> MapInitOptions
    public typealias TapAction = (CGPoint) -> Void
    public typealias TapQueryAction = (CGPoint, (Result<[QueriedFeature], Error>)) -> Void
    typealias TapActionWithQueryPair = (options: RenderedQueryOptions?, action: TapQueryAction)

    var camera: Binding<CameraState>?
    private var mapConfiguration = MapConfiguration()
    private let mapInitOptions: (CameraState?) -> MapInitOptions

    public init(
        camera: Binding<CameraState>? = nil,
        resourceOptions: ResourceOptions? = nil,
        mapOptions: MapOptions? = nil
    ) {
        self.camera = camera
        mapInitOptions = { camera in
            MapInitOptions(
                resourceOptions: resourceOptions ?? ResourceOptionsManager.default.resourceOptions,
                mapOptions: mapOptions ?? MapOptions(),
                cameraOptions: camera.map { CameraOptions(cameraState: $0) }
            )
        }
    }

    public var body: some View {
        ZStack {
            InternalMap(camera: camera, mapConfiguration: mapConfiguration, mapInitOptions: mapInitOptions)
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
        set(\.mapConfiguration.cameraBounds, cameraBounds)
    }

    /// Adds callback to map loaded event.
    public func onMapLoaded(_ callback: @escaping MapLoadedAction) -> Self {
        set(\.mapConfiguration.actions.onMapLoaded, callback)
    }

    /// Sets style to the map.
    ///
    /// - Parameters:
    ///     - default: A Style URI to be used by default.
    ///     - darkMode: A Style URI which will automaticaly be used for dark mode. If not specified,
    ///         the default option will continue to be used.
    public func styleURI(_ light: StyleURI, dark: StyleURI? = nil) -> Self {
        set(\.mapConfiguration.styleURIs, .init(light: light, dark: dark))
    }

    /// Configures gestures options.
    public func gestureOptions(_ options: GestureOptions) -> Self {
        set(\.mapConfiguration.getstureOptions, options)
    }

    /// Adds point annotations to the map.
    public func annotations(_ annotations: [PointAnnotation]) -> Self {
        set(\.mapConfiguration.annotations, annotations)
    }

    /// Adds tap handler to the map.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
    public func onMapTapGesture(action: @escaping TapAction) -> Self {
        set(\.mapConfiguration.actions.onMapTapGesture, action)
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
        updated.mapConfiguration.actions.tapActionsWithQuery.append((options: queryOptions, action: action))
        return updated
    }
}
