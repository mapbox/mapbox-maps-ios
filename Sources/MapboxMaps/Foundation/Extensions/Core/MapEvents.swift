import Foundation

// MARK: - MapEvents

/* Simplified diagram for events emitted by the map object.
*
* ┌─────────────┐               ┌─────────┐                   ┌──────────────┐
* │ Application │               │   Map   │                   │ResourceLoader│
* └──────┬──────┘               └────┬────┘                   └───────┬──────┘
*        │                           │                                │
*        ├───────setStyleURI────────▶│                                │
*        │                           ├───────────get style───────────▶│
*        │                           │                                │
*        │                           │◀─────────style data────────────┤
*        │                           │                                │
*        │                           ├─parse style─┐                  │
*        │                           │             │                  │
*        │      StyleDataLoaded      ◀─────────────┘                  │
*        │◀────{"type": "style"}─────┤                                │
*        │                           ├─────────get sprite────────────▶│
*        │                           │                                │
*        │                           │◀────────sprite data────────────┤
*        │                           │                                │
*        │                           ├──────parse sprite───────┐      │
*        │                           │                         │      │
*        │      StyleDataLoaded      ◀─────────────────────────┘      │
*        │◀───{"type": "sprite"}─────┤                                │
*        │                           ├─────get source TileJSON(s)────▶│
*        │                           │                                │
*        │     SourceDataLoaded      │◀─────parse TileJSON data───────┤
*        │◀──{"type": "metadata"}────┤                                │
*        │                           │                                │
*        │                           │                                │
*        │      StyleDataLoaded      │                                │
*        │◀───{"type": "sources"}────┤                                │
*        │                           ├──────────get tiles────────────▶│
*        │                           │                                │
*        │◀───────StyleLoaded────────┤                                │
*        │                           │                                │
*        │     SourceDataLoaded      │◀─────────tile data─────────────┤
*        │◀────{"type": "tile"}──────┤                                │
*        │                           │                                │
*        │                           │                                │
*        │◀────RenderFrameStarted────┤                                │
*        │                           ├─────render─────┐               │
*        │                           │                │               │
*        │                           ◀────────────────┘               │
*        │◀───RenderFrameFinished────┤                                │
*        │                           ├──render, all tiles loaded──┐   │
*        │                           │                            │   │
*        │                           ◀────────────────────────────┘   │
*        │◀────────MapLoaded─────────┤                                │
*        │                           │                                │
*        │                           │                                │
*        │◀─────────MapIdle──────────┤                                │
*        │                    ┌ ─── ─┴─ ─── ┐                         │
*        │                    │   offline   │                         │
*        │                    └ ─── ─┬─ ─── ┘                         │
*        │                           │                                │
*        ├─────────setCamera────────▶│                                │
*        │                           ├───────────get tiles───────────▶│
*        │                           │                                │
*        │                           │┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
*        │◀─────────MapIdle──────────┤   waiting for connectivity  │  │
*        │                           ││  Map renders cached data      │
*        │                           │ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
*        │                           │                                │
*
*/

/// List of supported event types by the MapView and Snapshotter objects,
/// and event data format specification for each event.
public extension MapEvents {
    /// Typed events emitted by the SDK
    struct Event<Payload> {
        /// The style has been fully loaded, and the map has rendered all visible tiles.
        public static var mapLoaded: Event<NoPayload> { .init(name: MapEvents.mapLoaded) }

        /// Describes an error that has occurred while loading the Map. The `type` property defines what resource could
        /// not be loaded and the `message` property will contain a descriptive error message.
        /// In case of `source` or `tile` loading errors, `source-id` will contain the id of the source failing.
        /// In case of `tile` loading errors, `tile-id` will contain the id of the tile.
        public static var mapLoadingError: Event<MapLoadingErrorPayload> { .init(name: MapEvents.mapLoadingError) }

        /// The map has entered the idle state. The map is in the idle state when there are no ongoing transitions
        /// and the map has rendered all requested non-volatile tiles. The event will not be emitted if `setUserAnimationInProgress`
        /// and / or `setGestureInProgress` is set to `true`.
        public static var mapIdle: Event<NoPayload> { .init(name: MapEvents.mapIdle) }

        /// The requested style data has been loaded. The `type` property defines what kind of style data has been loaded.
        /// Event may be emitted synchronously, for example, when `setStyleJSON` is used to load style.
        ///
        /// Based on an event data `type` property value, following use-cases may be implemented:
        /// - `style`: Style is parsed, style layer properties could be read and modified, style layers and sources could be
        /// added or removed before rendering is started.
        /// - `sprite`: Style's sprite sheet is parsed and it is possible to add or update images.
        /// - `sources`: All sources defined by the style are loaded and their properties could be read and updated if needed.
        public static var styleDataLoaded: Event<StyleDataLoadedPayload> { .init(name: MapEvents.styleDataLoaded) }

        /// The requested style has been fully loaded, including the style, specified sprite and sources' metadata.
        ///
        /// Note: The style specified sprite would be marked as loaded even with sprite loading error (An error will be emitted via `.mapLoadingError`).
        /// Sprite loading error is not fatal and we don't want it to block the map rendering, thus this event will still be emitted if style and sources are fully loaded.
        public static var styleLoaded: Event<NoPayload> { .init(name: MapEvents.styleLoaded) }

        /// A style has a missing image. This event is emitted when the map renders visible tiles and
        /// one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
        /// by calling ``Style/addImage(_:id:sdf:contentInsets:)``.
        public static var styleImageMissing: Event<StyleImageMissingPayload> { .init(name: MapEvents.styleImageMissing) }

        /// An image added to the style is no longer needed and can be removed using ``Style/removeImage(withId:)``.
        public static var styleImageRemoveUnused: Event<StyleImageUnusedPayload> { .init(name: MapEvents.styleImageRemoveUnused) }

        /// A source data has been loaded.
        /// Event may be emitted synchronously in cases when source's metadata is available when source is added to the style.
        ///
        /// The `id` property defines the source id.
        ///
        /// The `type` property defines if source's metadata (e.g., TileJSON) or tile has been loaded. The property of `metadata`
        /// value might be useful to identify when particular source's metadata is loaded, thus all source's properties are
        /// readable and can be updated before map will start requesting data to be rendered.
        ///
        /// The `loaded` property will be set to `true` if all source's data required for visible viewport of the map, are loaded.
        /// The `tile-id` property defines the tile id if the `type` field equals `tile`.
        /// The `data-id` property will be returned if it has been set for this source.
        public static var sourceDataLoaded: Event<SourceDataLoadedPayload> { .init(name: MapEvents.sourceDataLoaded) }

        /// The source has been added with ``Style/addSource(_:id:)`` or ``Style/addSource(withId:properties:)``.
        /// The event is emitted synchronously, therefore, it is possible to immediately
        /// read added source's properties.
        public static var sourceAdded: Event<SourceAddedPayload> { .init(name: MapEvents.sourceAdded) }

        /// The source has been removed with ``Style/removeSource(withId:)``.
        /// The event is emitted synchronously, thus, ``Style/allSourceIdentifiers`` will be
        /// in sync when the observer receives the notification.
        public static var sourceRemoved: Event<SourceRemovedPayload> { .init(name: MapEvents.sourceRemoved) }

        /// The map finished rendering a frame.
        /// The `render-mode` property tells whether the map has all data (`full`) required to render the visible viewport.
        /// The `needs-repaint` property provides information about ongoing transitions that trigger map repaint.
        /// The `placement-changed` property tells if the symbol placement has been changed in the visible viewport.
        public static var renderFrameStarted: Event<NoPayload> { .init(name: MapEvents.renderFrameStarted) }

        /// The camera has changed. This event is emitted whenever the visible viewport
        /// changes due to the MapView's size changing or when the camera
        /// is modified by calling camera methods. The event is emitted synchronously,
        /// so that an updated camera state can be fetched immediately.
        public static var renderFrameFinished: Event<RenderFrameFinishedPayload> { .init(name: MapEvents.renderFrameFinished) }

        /// The camera has changed. This event is emitted whenever the visible viewport
        /// changes due to the MapView's size changing or when the camera
        /// is modified by calling camera methods. The event is emitted synchronously,
        /// so that an updated camera state can be fetched immediately.
        public static var cameraChanged: Event<NoPayload> { .init(name: MapEvents.cameraChanged) }

        /// The `ResourceRequest` event allows client to observe resource requests made by a
        /// map or snapshotter.
        public static var resourceRequest: Event<ResourceRequestPayload> { .init(name: MapEvents.resourceRequest) }

        internal let name: String

        private init(name: String) {
            self.name = name
        }
    }
}
