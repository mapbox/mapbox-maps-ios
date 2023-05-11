import MapboxCoreMaps

extension MapEvents {
    /// A polyfill struct that makes it possible to subscribe to Map events with the ``MapboxMap/onNext(event:handler:)`` and  ``MapboxMap/onEvery(event:handler:)`` methods.
    /// It is here to simplify migration from v10 to v11, but will be removed in v12.
    @available(*, deprecated)
    public struct Event<Payload> {
        var keyPath: KeyPath<MapEvents, Signal<Payload>>

        init(_ keyPath: KeyPath<MapEvents, Signal<Payload>>) {
            self.keyPath = keyPath
        }

        /// The style has been fully loaded, and the map has rendered all visible tiles.
        public static var mapLoaded: Event<MapLoaded> { .init(\.onMapLoaded) }
        /// An error that has occurred while loading the Map.
        public static var mapLoadingError: Event<MapLoadingError> { .init(\.onMapLoadingError) }
        /// The requested style has been fully loaded.
        public static var styleLoaded: Event<StyleLoaded> { .init(\.onStyleLoaded) }
        /// The requested style data has been loaded.
        public static var styleDataLoaded: Event<StyleDataLoaded> { .init(\.onStyleDataLoaded) }
        /// The camera has changed.
        public static var cameraChanged: Event<CameraChanged> { .init(\.onCameraChanged) }
        /// The map has entered the idle state.
        public static var mapIdle: Event<MapIdle> { .init(\.onMapIdle) }
        /// The source has been added.
        public static var sourceAdded: Event<SourceAdded> { .init(\.onSourceAdded) }
        /// The source has been removed.
        public static var sourceRemoved: Event<SourceRemoved> { .init(\.onSourceRemoved) }
        /// A source data has been loaded.
        public static var sourceDataLoaded: Event<SourceDataLoaded> { .init(\.onSourceDataLoaded) }
        /// A style has a missing image.
        public static var styleImageMissing: Event<StyleImageMissing> { .init(\.onStyleImageMissing) }
        /// An image added to the style is no longer needed and can be removed.
        public static var styleImageRemoveUnused: Event<StyleImageRemoveUnused> { .init(\.onStyleImageRemoveUnused) }
        /// The map started rendering a frame.
        public static var renderFrameStarted: Event<RenderFrameStarted> { .init(\.onRenderFrameStarted) }
        /// The map finished rendering a frame.
        public static var renderFrameFinished: Event<RenderFrameFinished> { .init(\.onRenderFrameFinished) }
        /// Resource requiest as been made.
        public static var resourceRequest: Event<ResourceRequest> { .init(\.onResourceRequest) }
    }

    // The onEvery/onNext calls imply that the user can ignore the cancelable, but the subscription should stay alive.
    // The new API style forces to store the cancelable token, otherwise the subscription will canceled, this is alighed with Combine.
    // For compatibility reasons, we store the cancelable token in `cancelables` set to keep subscription alive.
    // The cancelables will be "leaked" until Map is destroyed. This is unwanted, but not a big issue:
    // - AnyCancelable releases the resources it captured after cancellation, so if user cancels it, only cancellable will leak.
    // - It might be an issue if user creates millions of subscriptions, but in real cases it's better
    //     to use new API and manage cancelables manually.
    // - If Cancelable is ignored and never cancelled by the user, then this is desired behavior.

    @available(*, deprecated)
    @discardableResult
    func onNext<Payload>(event eventType: Event<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        let token = self[keyPath: eventType.keyPath]
            .observeNext(handler)
        token.store(in: &cancelables)
        return token
    }

    @available(*, deprecated)
    @discardableResult
    func onEvery<Payload>(event eventType: Event<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        let token = self[keyPath: eventType.keyPath]
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
    @available(*, deprecated, renamed: "tileID")
    public var tileId: CanonicalTileID? { tileID }

    /// :nodoc:
    @available(*, deprecated, renamed: "sourceID")
    public var sourceId: String? { sourceID }

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
    @available(*, deprecated, renamed: "sourceID")
    public var id: String { sourceID }
}

extension SourceRemoved {
    /// :nodoc:
    @available(*, deprecated, message: "Use SourceRemoved fields to access the event data.")
    public var payload: SourceRemoved { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "sourceID")
    public var id: String { sourceID }
}

extension SourceDataLoaded {
    /// :nodoc:
    @available(*, deprecated, message: "Use SourceDataLoaded fields to access the event data.")
    public var payload: SourceDataLoaded { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "sourceID")
    public var id: String? { sourceID }

    /// :nodoc:
    @available(*, deprecated, renamed: "dataID")
    public var dataId: String? { dataID }

    /// :nodoc:
    @available(*, deprecated, renamed: "tileID")
    public var tileId: CanonicalTileID? { tileID }
}

extension StyleImageMissing {
    /// :nodoc:
    @available(*, deprecated, message: "Use StyleImageMissing fields to access the event data.")
    public var payload: StyleImageMissing { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "imageID")
    public var id: String { imageID }
}

extension StyleImageRemoveUnused {
    /// :nodoc:
    @available(*, deprecated, message: "Use StyleImageRemoveUnused fields to access the event data.")
    public var payload: StyleImageRemoveUnused { self }

    /// :nodoc:
    @available(*, deprecated, renamed: "imageID")
    public var id: String { imageID }
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
