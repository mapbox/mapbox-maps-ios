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
    public var features: [QueriedRenderedFeature]
}

/// An action called when the map is tapped.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapTapAction = (CGPoint) -> Void

/// An action called when the specified layer is tapped.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapLayerTapAction = (MapLayerTapPayload) -> Void

/// An action called when a new location is emitted.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias LocationUpdateAction = (Location) -> Void

/// A view that displays Mapbox Map.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct Map<Content: View>: View {
    public typealias InitOptionsProvider = () -> MapInitOptions

    var camera: Binding<CameraState>?
    private var mapDependencies = MapDependencies()
    private var mapInitOptions: InitOptionsProvider?
    private var locationDependencies = LocationDependencies()
    private var annotationOptions = [AnyHashable: ViewAnnotationOptions]()
    private var annotationContents = [(AnyHashable, () -> Content)]()

    @State private var annotationsLayouts = AnnotationLayouts()

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - mapInitOptions: A closure to provide initial map parameters. It gets called only once when `Map` is created.
    ///     - locationOptions: The options to configure ``LocationManager``.
    ///     - annotationItems: The collection of data that the view uses to display annotations.
    ///     - annotationContent: A closure that produces the annotation content.
    public init<Items>(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil,
        locationOptions: LocationOptions = LocationOptions(),
        annotationItems: Items,
        annotationContent: @escaping (Items.Element) -> ViewAnnotation<Content>
    ) where Items: RandomAccessCollection, Items.Element: Identifiable {
        self.camera = camera
        self.mapInitOptions = mapInitOptions
        locationDependencies.locationOptions = locationOptions

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
                mapInitOptions: mapInitOptions,
                locationDependencies: locationDependencies) {
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
    ///     - locationOptions: The options to configure ``LocationManager``.
    public init(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil,
        locationOptions: LocationOptions = LocationOptions()
    ) {
        self.camera = camera
        self.mapInitOptions = mapInitOptions
        locationDependencies.locationOptions = locationOptions
    }
}

@available(iOS 13.0, *)
extension Map {

    func set<T>(_ keyPath: WritableKeyPath<Map, T>, _ value: T) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }

    func append<T>(_ keyPath: WritableKeyPath<Map, T>, _ newElement: T.Element) -> Self where T: RangeReplaceableCollection {
        var updated = self
        updated[keyPath: keyPath].append(newElement)
        return updated
    }
}

@available(iOS 13.0, *)
extension Map {

    /// Sets camera bounds.
    public func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        set(\.mapDependencies.cameraBounds, cameraBounds)
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
        set(\.mapDependencies.gestureOptions, options)
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

// MARK: Location

@available(iOS 13.0, *)
extension Map {

    /// Adds an action to perform when a new location is emitted.
    public func onLocationUpdated(perform action: @escaping LocationUpdateAction) -> Self {
        append(\.locationDependencies.locationUpdateHandlers, action)
    }

    /// Adds an action to perform when a new puck location (interpolated) is emitted.
    public func onPuckLocationUpdated(perform action: @escaping LocationUpdateAction) -> Self {
        append(\.locationDependencies.puckLocationUpdateHandlers, action)
    }
}

// MARK: Map Events

@available(iOS 13.0, *)
extension Map {

    /// Adds an action to perform when the map is loaded.
    public func onMapLoaded(perform action: @escaping () -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .mapLoaded, action: action))
    }

    /// Adds an action to perform when there is an error occured while loading the map.
    public func onMapLoadingError(perform action: @escaping (MapEvent<MapLoadingErrorPayload>) -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .mapLoadingError, action: action))
    }

    /// Adds an action to perform when the map has entered the idle state.
    public func onMapIdle(perform action: @escaping () -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .mapIdle, action: action))
    }

    /// Adds an action to perform when the requested style is fully loaded.
    public func onStyleLoaded(perform action: @escaping () -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .styleLoaded, action: action))
    }

    /// Adds an action to perform when the requested style data is loaded.
    public func onStyleDataLoaded(perform action: @escaping (MapEvent<StyleDataLoadedPayload>) -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .styleDataLoaded, action: action))
    }

    /// Adds an action to perform when a source has been added with ``Style/addSource(_:id:)`` or ``Style/addSource(withId:properties:)``.
    public func onSourceAdded(perform action: @escaping (MapEvent<SourceAddedPayload>) -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .sourceAdded, action: action))
    }

    /// Adds an action to perform when a source has been removed with ``Style/removeSource(withId:)``.
    public func onSourceRemoved(perform action: @escaping (MapEvent<SourceRemovedPayload>) -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .sourceRemoved, action: action))
    }

    /// Adds an action to perform when the map started rendering a frame.
    public func onRenderFrameStarted(perform action: @escaping () -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .renderFrameStarted, action: action))
    }

    /// Adds an action to perform when the map finished rendering a frame
    public func onRenderFrameFinished(perform action: @escaping (MapEvent<RenderFrameFinishedPayload>) -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .renderFrameFinished, action: action))
    }

    public func onResourceRequest(perform action: @escaping (MapEvent<ResourceRequestPayload>) -> Void) -> Self {
        append(\.mapDependencies.mapEventObservers, MapEventObserver(event: .resourceRequest, action: action))
    }
}
