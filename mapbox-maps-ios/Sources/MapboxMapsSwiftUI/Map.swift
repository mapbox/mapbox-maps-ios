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

/// Represents location and rendered feaures of the tap.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapLayerTapPayload {
    public var point: CGPoint
    public var coordinate: CLLocationCoordinate2D
    public var features: [QueriedFeature]
}

/// An action called when the map is loaded.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapLoadedAction = (MapboxMap) -> Void

/// An action called when the map is tapped.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapTapAction = (CGPoint) -> Void

/// An action called when the specified layer is tapped.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapLayerTapAction = (MapLayerTapPayload) -> Void

/// A view that displays Mapbox Map.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct Map<Content: View>: View {
    public typealias InitOptionsProvider = () -> MapInitOptions

    var camera: Binding<CameraState>?
    private var mapDependencies = MapDependencies()
    private var mapInitOptions: InitOptionsProvider?
    private var annotationOptions = [AnyHashable: ViewAnnotationOptions]()
    private var annotationContents = [(AnyHashable, () -> Content)]()

    @State private var annotationsLayouts = AnnotationLayouts()

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - mapInitOptions: A closure to provide initial map parameters. It gets called only once when `Map` is created.
    ///     - annotationItems: The collection of data that the view uses to display annotations.
    ///     - annotationContent: A closure that produces the annotation content.
    public init<Items>(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil,
        annotationItems: Items,
        annotationContent: @escaping (Items.Element) -> ViewAnnotation<Content>
    ) where Items: RandomAccessCollection, Items.Element: Identifiable {
        self.camera = camera
        self.mapInitOptions = mapInitOptions

        for item in annotationItems {
            let result = annotationContent(item)
            annotationOptions[item.id] = result.options
            annotationContents.append((item.id, result.content))
        }
    }

    var annotations: some View {
        ForEach(annotationContents, id: \.0) { (id: AnyHashable, content: () -> Content) in
            if let frame = annotationsLayouts[id] {
                content()
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: frame.minX, y: frame.minY)
            }
        }
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            InternalMap(
                camera: camera,
                mapDependencies: mapDependencies,
                annotationsOptions: annotationOptions,
                mapInitOptions: mapInitOptions) {
                    annotationsLayouts = $0
                }
            annotations
        }
    }
}

@available(iOS 13.0, *)
extension Map where Content == Never {
    /// Creates a map.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - mapInitOptions: A closure to provide initial map parameters. It gets called only once when `Map` is created.
    public init(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil
    ) {
        self.camera = camera
        self.mapInitOptions = mapInitOptions
    }
}

@available(iOS 13.0, *)
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
    public func onMapTapGesture(perform action: @escaping MapTapAction) -> Self {
        set(\.mapDependencies.actions.onMapTapGesture, action)
    }

    /// Adds tap action to layers with specified `layerIds`.
    ///
    /// The action will only be called when at least one of specified layers are at the tap position.
    ///
    /// - Parameters:
    ///  - layerIds: The identifiers of layers where to perform features lookup.
    ///  - action: The action to perform.
    public func onLayerTapGesture(_ layerIds: String..., perform action: @escaping MapLayerTapAction) -> Self {
        var updated = self
        updated.mapDependencies.actions.layerTapActions.append((layerIds, action))
        return updated
    }

    /// Sets constraint mode to the map. If not set, `heightOnly` wil be in use.
    public func constrainMode(_ constrainMode: ConstrainMode) -> Self {
        set(\.mapDependencies.constrainMode, constrainMode)
    }

    /// Sets viewport mode to the map
    public func viewportMode(_ viewportMode: ViewportMode) -> Self {
        set(\.mapDependencies.viewportMode, viewportMode)
    }

    /// Sets ``NorthOrientation`` to the map. If not set, `upwards` will be in use.
    public func northOrientation(_ northOrientation: NorthOrientation) -> Self {
        set(\.mapDependencies.orientation, northOrientation)
    }
}
