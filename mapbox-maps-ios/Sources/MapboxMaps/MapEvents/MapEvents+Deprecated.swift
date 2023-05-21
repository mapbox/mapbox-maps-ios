import MapboxCoreMaps

/// A shim that makes it possible to subscribe to ``MapboxMap`` and ``Snapshotter`` events via the old `onNext` and  `onEvery` methods.
/// It is here to simplify migration from v10 to v11, but will be removed in v12.
@available(*, deprecated)
public struct MapEventType<Payload> {
    var keyPath: KeyPath<MapEvents, SignalSubject<Payload>>

    init(_ keyPath: KeyPath<MapEvents, SignalSubject<Payload>>) {
        self.keyPath = keyPath
    }

    /// The style has been fully loaded, and the map has rendered all visible tiles.
    public static var mapLoaded: MapEventType<MapLoaded> { .init(\.onMapLoaded) }
    /// An error that has occurred while loading the Map.
    public static var mapLoadingError: MapEventType<MapLoadingError> { .init(\.onMapLoadingError) }
    /// The requested style has been fully loaded.
    public static var styleLoaded: MapEventType<StyleLoaded> { .init(\.onStyleLoaded) }
    /// The requested style data has been loaded.
    public static var styleDataLoaded: MapEventType<StyleDataLoaded> { .init(\.onStyleDataLoaded) }
    /// The camera has changed.
    public static var cameraChanged: MapEventType<CameraChanged> { .init(\.onCameraChanged) }
    /// The map has entered the idle state.
    public static var mapIdle: MapEventType<MapIdle> { .init(\.onMapIdle) }
    /// The source has been added.
    public static var sourceAdded: MapEventType<SourceAdded> { .init(\.onSourceAdded) }
    /// The source has been removed.
    public static var sourceRemoved: MapEventType<SourceRemoved> { .init(\.onSourceRemoved) }
    /// A source data has been loaded.
    public static var sourceDataLoaded: MapEventType<SourceDataLoaded> { .init(\.onSourceDataLoaded) }
    /// A style has a missing image.
    public static var styleImageMissing: MapEventType<StyleImageMissing> { .init(\.onStyleImageMissing) }
    /// An image added to the style is no longer needed and can be removed.
    public static var styleImageRemoveUnused: MapEventType<StyleImageRemoveUnused> { .init(\.onStyleImageRemoveUnused) }
    /// The map started rendering a frame.
    public static var renderFrameStarted: MapEventType<RenderFrameStarted> { .init(\.onRenderFrameStarted) }
    /// The map finished rendering a frame.
    public static var renderFrameFinished: MapEventType<RenderFrameFinished> { .init(\.onRenderFrameFinished) }
    /// Resource requiest as been made.
    public static var resourceRequest: MapEventType<ResourceRequest> { .init(\.onResourceRequest) }
}

// The onEvery/onNext calls imply that the user can ignore the cancelable token, but the subscription should stay alive.
// The new API style forces to store the cancelable token, otherwise the subscription will canceled, this is aligned with Combine.
// For compatibility reasons, we store the cancelable token in `cancelables` set to keep subscription alive.
// The cancelables will be "leaked" until Map is destroyed. This is unwanted, but not a big issue:
// - AnyCancelable releases the resources it captured after cancellation, so if user cancels it, only cancellable will leak.
// - It might be an issue if user creates millions of subscriptions, but in real cases it's better
//     to use new API and manage cancelables manually.
// - If Cancelable is ignored and never cancelled by the user, then this is desired behavior.

extension MapEvents {
    @available(*, deprecated)
    @discardableResult
    func onNext<Payload>(event eventType: MapEventType<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        let token = signal(for: eventType.keyPath)
            .observeNext(handler)
        token.store(in: &cancelables)
        return token
    }

    @available(*, deprecated)
    @discardableResult
    func onEvery<Payload>(event eventType: MapEventType<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        let token = signal(for: eventType.keyPath)
            .observe(handler)
        token.store(in: &cancelables)
        return token
    }
}

// The extensions below are polyfill the old `MapEvent.payload` property to simplify the migration from v10 to v11.
// It doesn't fix the API compatibility, and not even source-level compatibility, hovewer in most cases
// it will allow to compile existing code with meaningful deprecation messages.

extension MapLoadingError {
    /// :nodoc:
    @available(*, deprecated, message: "Use MapLoadingError fields to access the event data.")
    public var payload: MapLoadingError { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "type")
    public var error: MapLoadingErrorType { type }
}

extension StyleDataLoaded {
    /// :nodoc:
    @available(*, deprecated, message: "Use StyleDataLoaded fields to access the event data.")
    public var payload: StyleDataLoaded { self }
}

extension SourceAdded {
    /// :nodoc:
    @available(*, deprecated, message: "Use SourceAdded fields to access the event data.")
    public var payload: SourceAdded { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "sourceId")
    public var id: String { sourceId }
}

extension SourceRemoved {
    /// :nodoc:
    @available(*, deprecated, message: "Use SourceRemoved fields to access the event data.")
    public var payload: SourceRemoved { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "sourceId")
    public var id: String { sourceId }
}

extension SourceDataLoaded {
    /// :nodoc:
    @available(*, deprecated, message: "Use SourceDataLoaded fields to access the event data.")
    public var payload: SourceDataLoaded { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "sourceId")
    public var id: String? { sourceId }
}

extension StyleImageMissing {
    /// :nodoc:
    @available(*, deprecated, message: "Use StyleImageMissing fields to access the event data.")
    public var payload: StyleImageMissing { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "imageId")
    public var id: String { imageId }
}

extension StyleImageRemoveUnused {
    /// :nodoc:
    @available(*, deprecated, message: "Use StyleImageRemoveUnused fields to access the event data.")
    public var payload: StyleImageRemoveUnused { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "imageId")
    public var id: String { imageId }
}

extension RenderFrameFinished {
    /// :nodoc:
    @available(*, deprecated, message: "Use RenderFrameFinished fields to access the event data.")
    public var payload: RenderFrameFinished { self }
}

extension ResourceRequest {
    /// :nodoc:
    @available(*, deprecated, message: "Use ResourceRequest fields to access the event data.")
    public var payload: ResourceRequest { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "source")
    public var dataSource: RequestDataSourceType? { source }
}
