import MapboxCoreMaps
import Foundation
import MapboxCommon
@_implementationOnly import MapboxCoreMaps_Private

/// The class that provides access to events triggered by ``MapboxMap`` or ``Snapshotter``.
///
/// Use it's properties to subscribe to every individual event.
///    ```swift
///    var cancelables = Set<AnyCancelable>()
///
///    // Observe ever occurrence of CameraChanged event
///    mapboxMap.events.onCameraChanged.observe { event in
///         print("Current camera state: \(event.cameraState)")
///    }.store(in: &cancelables)
///
///    // Observe only the next occurrence of MapLoaded event.
///    mapboxMap.events.onMapLoaded.observeNext { event in
///        print("Map is loaded at: \(event.timeInterval.end)")
///    }.store(in: &cancelables)
///    ```
///
/// The `AnyCancelable` object returned from ``Signal/observe(_:)`` or ``Signal/observeNext(_:)``
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
public final class MapEvents {
    /// The style has been fully loaded, and the map has rendered all visible tiles.
    public var onMapLoaded: Signal<MapLoaded> { signal(for: \.onMapLoaded) }

    /// An error that has occurred while loading the Map. The `type` property defines what resource could
    /// not be loaded and the `message` property will contain a descriptive error message.
    /// In case of `source` or `tile` loading errors, `sourceID` or `tileID` will contain the identifier of the source failing.
    public var onMapLoadingError: Signal<MapLoadingError> { signal(for: \.onMapLoadingError) }

    /// The requested style has been fully loaded, including the style, specified sprite and sources' metadata.
    ///
    /// The style specified sprite would be marked as loaded even with sprite loading error (an error will be emitted via ``MapEvents/onMapLoadingError``).
    /// Sprite loading error is not fatal and we don't want it to block the map rendering, thus this event will still be emitted if style and sources are fully loaded.
    public var onStyleLoaded: Signal<StyleLoaded> { signal(for: \.onStyleLoaded) }

    /// The requested style data has been loaded. The `type` property defines what kind of style data has been loaded.
    /// Event may be emitted synchronously, for example, when ``MapboxMap/loadStyleJSON(_:completion:)`` is used to load style.
    ///
    /// Based on an event data `type` property value, following use-cases may be implemented:
    /// - `style`: Style is parsed, style layer properties could be read and modified, style layers and sources could be
    /// added or removed before rendering is started.
    /// - `sprite`: Style's sprite sheet is parsed and it is possible to add or update images.
    /// - `sources`: All sources defined by the style are loaded and their properties could be read and updated if needed.
    public var onStyleDataLoaded: Signal<StyleDataLoaded> { signal(for: \.onStyleDataLoaded) }

    /// The camera has changed. This event is emitted whenever the visible viewport
    /// changes due to the MapView's size changing or when the camera
    /// is modified by calling camera methods. The event is emitted synchronously,
    /// so that an updated camera state can be fetched immediately.
    public var onCameraChanged: Signal<CameraChanged> { signal(for: \.onCameraChanged) }

    /// The map has entered the idle state. The map is in the idle state when there are no ongoing transitions
    /// and the map has rendered all requested non-volatile tiles. The event will not be emitted if animation is in progress (see ``MapboxMap/beginAnimation()``, ``MapboxMap/endAnimation()``)
    /// and / or gesture is in progress (see ``MapboxMap/beginGesture()``, ``MapboxMap/endGesture()``).
    public var onMapIdle: Signal<MapIdle> { signal(for: \.onMapIdle) }

    /// The source has been added with ``Style/addSource(_:id:dataId:)`` or ``Style/addSource(withId:properties:)``.
    /// The event is emitted synchronously, therefore, it is possible to immediately
    /// read added source's properties.
    public var onSourceAdded: Signal<SourceAdded> { signal(for: \.onSourceAdded) }

    /// The source has been removed with ``Style/removeSource(withId:)``.
    /// The event is emitted synchronously, thus, ``Style/allSourceIdentifiers`` will be
    /// in sync when the observer receives the notification.
    public var onSourceRemoved: Signal<SourceRemoved> { signal(for: \.onSourceRemoved) }

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
    public var onSourceDataLoaded: Signal<SourceDataLoaded> { signal(for: \.onSourceDataLoaded) }

    /// A style has a missing image. This event is emitted when the map renders visible tiles and
    /// one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
    /// by calling ``Style/addImage(_:id:sdf:contentInsets:)``. 
    public var onStyleImageMissing: Signal<StyleImageMissing> { signal(for: \.onStyleImageMissing) }

    /// An image added to the style is no longer needed and can be removed using ``Style/removeImage(withId:)``.
    public var onStyleImageRemoveUnused: Signal<StyleImageRemoveUnused> { signal(for: \.onStyleImageRemoveUnused) }

    /// The map started rendering a frame.
    public var onRenderFrameStarted: Signal<RenderFrameStarted> { signal(for: \.onRenderFrameStarted) }

    /// The map finished rendering a frame.
    /// The `renderMode` property tells whether the map has all data (`full`) required to render the visible viewport.
    /// The `needsRepaint` property provides information about ongoing transitions that trigger map repaint.
    /// The `placementChanged` property tells if the symbol placement has been changed in the visible viewport.
    public var onRenderFrameFinished: Signal<RenderFrameFinished> { signal(for: \.onRenderFrameFinished) }

    /// The `ResourceRequest` event allows client to observe resource requests made by a
    /// map or snapshotter.
    public var  onResourceRequest: Signal<ResourceRequest> { signal(for: \.onResourceRequest) }

    @MutableRef private var isMuted = false
    private var mutedCount = 0 {
        didSet {
            isMuted = mutedCount > 0
        }
    }

    private let source: MapEventsSource
    private var genericSubjects = [String: SignalSubject<GenericEvent>]()
    var cancelables = Set<AnyCancelable>()

    init(source: MapEventsSource) {
        self.source = source
    }

    convenience init(observable: Observable) {
        self.init(source: MapEventsSource(observable: observable))
    }

    /// Subscribes to a generic event by a string name.
    /// This method is reserved for the future use.
    @_spi(Experimental)
    public subscript(eventName: String) -> Signal<GenericEvent> {
        let subject: SignalSubject<GenericEvent>
        if let subj = genericSubjects[eventName] {
            subject = subj
        } else {
            subject = source.makeGenericSubject(eventName)
            genericSubjects[eventName] = subject
        }
        return subject.signal.conditional($isMuted.map(!))
    }

    func performWithoutNotifying(_ action: () throws -> Void) rethrows {
        mutedCount += 1
        defer { mutedCount -= 1 }
        try action()
    }

    private func signal<T>(for keyPath: KeyPath<MapEventsSource, SignalSubject<T>>) -> Signal<T> {
        return source[keyPath: keyPath].signal.conditional($isMuted.map(!))
    }
}

internal struct MapEventsSource {
    internal typealias GenericSubjectFactory = (String) -> SignalSubject<GenericEvent>

    let onMapLoaded: SignalSubject<MapLoaded>
    let onMapLoadingError: SignalSubject<MapLoadingError>
    let onStyleLoaded: SignalSubject<StyleLoaded>
    let onStyleDataLoaded: SignalSubject<StyleDataLoaded>
    let onCameraChanged: SignalSubject<CameraChanged>
    let onMapIdle: SignalSubject<MapIdle>
    let onSourceAdded: SignalSubject<SourceAdded>
    let onSourceRemoved: SignalSubject<SourceRemoved>
    let onSourceDataLoaded: SignalSubject<SourceDataLoaded>
    let onStyleImageMissing: SignalSubject<StyleImageMissing>
    let onStyleImageRemoveUnused: SignalSubject<StyleImageRemoveUnused>
    let onRenderFrameStarted: SignalSubject<RenderFrameStarted>
    let onRenderFrameFinished: SignalSubject<RenderFrameFinished>
    let onResourceRequest: SignalSubject<ResourceRequest>
    let makeGenericSubject: (String) -> SignalSubject<GenericEvent>

    init(observable: Observable) {
        onMapLoaded = .from(method: observable.subscribe(forMapLoaded:))
        onMapLoadingError = .from(method: observable.subscribe(forMapLoadingError:))
        onStyleLoaded = .from(method: observable.subscribe(forStyleLoaded:))
        onStyleDataLoaded = .from(method: observable.subscribe(forStyleDataLoaded:))
        onCameraChanged = .from(method: observable.subscribe(forCameraChanged:))
        onMapIdle = .from(method: observable.subscribe(forMapIdle:))
        onSourceAdded = .from(method: observable.subscribe(forSourceAdded:))
        onSourceRemoved = .from(method: observable.subscribe(forSourceRemoved:))
        onSourceDataLoaded = .from(method: observable.subscribe(forSourceDataLoaded:))
        onStyleImageMissing = .from(method: observable.subscribe(forStyleImageMissing:))
        onStyleImageRemoveUnused = .from(method: observable.subscribe(forStyleImageRemoveUnused:))
        onRenderFrameStarted = .from(method: observable.subscribe(forRenderFrameStarted:))
        onRenderFrameFinished = .from(method: observable.subscribe(forRenderFrameFinished:))
        onResourceRequest = .from(method: observable.subscribe(forResourceRequest:))
        makeGenericSubject = { eventName in
            .from(parameter: eventName, method: observable.subscribe(forEventName:callback:))
        }
    }

    // For use in tests only
    internal init(makeGenericSubject: @escaping GenericSubjectFactory) {
        onMapLoaded = SignalSubject()
        onMapLoadingError = SignalSubject()
        onStyleLoaded = SignalSubject()
        onStyleDataLoaded = SignalSubject()
        onCameraChanged = SignalSubject()
        onMapIdle = SignalSubject()
        onSourceAdded = SignalSubject()
        onSourceRemoved = SignalSubject()
        onSourceDataLoaded = SignalSubject()
        onStyleImageMissing = SignalSubject()
        onStyleImageRemoveUnused = SignalSubject()
        onRenderFrameStarted = SignalSubject()
        onRenderFrameFinished = SignalSubject()
        onResourceRequest = SignalSubject()
        self.makeGenericSubject = makeGenericSubject
    }
}
