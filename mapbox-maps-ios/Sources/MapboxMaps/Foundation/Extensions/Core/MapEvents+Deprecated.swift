import Foundation

public extension MapEvents {
    /// Events emitted by the SDK
    @available(*, deprecated, message: "Use 'Event' instead")
    enum EventKind: RawRepresentable, CaseIterable {
        /**
         * The style has been fully loaded, and the map has rendered all visible tiles.
         */
        case mapLoaded

        /**
         * Describes an error that has occurred while loading the Map. The `type` property defines what resource could
         * not be loaded and the `message` property will contain a descriptive error message.
         * In case of `source` or `tile` loading errors, `source-id` will contain the id of the source failing.
         * In case of `tile` loading errors, `tile-id` will contain the id of the tile
         *
         * ``` text
         * Event data format (Object):
         * .
         * ├── type - String ("style" | "sprite" | "source" | "tile" | "glyphs")
         * ├── message - String
         * ├── source-id - optional String
         * └── tile-id - optional Object
         *     ├── z Number (zoom level)
         *     ├── x Number (x coordinate)
         *     └── y Number (y coordinate)
         * ```
         */
        case mapLoadingError

        /**
         * The map has entered the idle state. The map is in the idle state when there are no ongoing transitions
         * and the map has rendered all requested non-volatile tiles. The event will not be emitted if `setUserAnimationInProgress`
         * and / or `setGestureInProgress` is set to `true`.
         */
        case mapIdle

        /**
         * The requested style data has been loaded. The `type` property defines what kind of style data has been loaded.
         * Event may be emitted synchronously, for example, when `setStyleJSON` is used to load style.
         *
         * Based on an event data `type` property value, following use-cases may be implemented:
         * - `style`: Style is parsed, style layer properties could be read and modified, style layers and sources could be
         *   added or removed before rendering is started.
         * - `sprite`: Style's sprite sheet is parsed and it is possible to add or update images.
         * - `sources`: All sources defined by the style are loaded and their properties could be read and updated if needed.
         *
         * ``` text
         * Event data format (Object):
         * .
         * └── type - String ("style" | "sprite" | "sources")
         * ```
         */
        case styleDataLoaded

        /**
         * The requested style has been fully loaded, including the style, specified sprite and sources' metadata.
         *
         * Note: The style specified sprite would be marked as loaded even with sprite loading error (An error will be emitted via `.mapLoadingError`).
         * Sprite loading error is not fatal and we don't want it to block the map rendering, thus this event will still be emitted if style and sources are fully loaded.
         */
        case styleLoaded

        /**
         * A style has a missing image. This event is emitted when the map renders visible tiles and
         * one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
         * by calling ``Style/addImage(_:id:sdf:contentInsets:)``.
         *
         * ``` text
         * Event data format (Object):
         * .
         * └── id - String
         * ```
         */
        case styleImageMissing

        /**
         * An image added to the style is no longer needed and can be removed using ``Style/removeImage(withId:)``.
         *
         * ``` text
         * Event data format (Object):
         * .
         * └── id - String
         * ```
         */
        case styleImageRemoveUnused

        /**
         * A source data has been loaded.
         * Event may be emitted synchronously in cases when source's metadata is available when source is added to the style.
         *
         * The `id` property defines the source id.
         *
         * The `type` property defines if source's metadata (e.g., TileJSON) or tile has been loaded. The property of `metadata`
         * value might be useful to identify when particular source's metadata is loaded, thus all source's properties are
         * readable and can be updated before map will start requesting data to be rendered.
         *
         * The `loaded` property will be set to `true` if all source's data required for visible viewport of the map, are loaded.
         * The `tile-id` property defines the tile id if the `type` field equals `tile`.
         * The `data-id` property will be returned if it has been set for this source.
         *
         * ``` text
         * Event data format (Object):
         * .
         * ├── id - String
         * ├── type - String ("metadata" | "tile")
         * ├── loaded - optional Boolean
         * └── tile-id - optional Object
         * │   ├── z Number (zoom level)
         * │   ├── x Number (x coordinate)
         * │   └── y Number (y coordinate)
         * └── data-id - optional String
         * ```
         */
        case sourceDataLoaded

        /**
         * The source has been added with ``Style/addSource(_:id:)`` or ``Style/addSource(withId:properties:)``.
         * The event is emitted synchronously, therefore, it is possible to immediately
         * read added source's properties.
         *
         * ``` text
         * Event data format (Object):
         * .
         * └── id - String
         * ```
         */
        case sourceAdded

        /**
         * The source has been removed with ``Style/removeSource(withId:)``.
         * The event is emitted synchronously, thus, ``Style/allSourceIdentifiers`` will be
         * in sync when the observer receives the notification.
         *
         * ``` text
         * Event data format (Object):
         * .
         * └── id - String
         * ```
         */
        case sourceRemoved

        /**
         * The map started rendering a frame.
         */
        case renderFrameStarted

        /**
         * The map finished rendering a frame.
         * The `render-mode` property tells whether the map has all data (`full`) required to render the visible viewport.
         * The `needs-repaint` property provides information about ongoing transitions that trigger map repaint.
         * The `placement-changed` property tells if the symbol placement has been changed in the visible viewport.
         *
         * ``` text
         * Event data format (Object):
         * .
         * ├── render-mode - String ("partial" | "full")
         * ├── needs-repaint - Boolean
         * └── placement-changed - Boolean
         * ```
         */
        case renderFrameFinished

        /**
         * The camera has changed. This event is emitted whenever the visible viewport
         * changes due to the MapView's size changing or when the camera
         * is modified by calling camera methods. The event is emitted synchronously,
         * so that an updated camera state can be fetched immediately.
         */
        case cameraChanged

        /**
         * The `ResourceRequest` event allows client to observe resource requests made by a
         * map or snapshotter.
         *
         * ``` text
         * Event data format (Object):
         * .
         * ├── data-source - String ("resource-loader" | "network" | "database" | "asset" | "file-system")
         * ├── request - Object
         * │   ├── url - String
         * │   ├── kind - String ("unknown" | "style" | "source" | "tile" | "glyphs" | "sprite-image" | "sprite-json" | "image")
         * │   ├── priority - String ("regular" | "low")
         * │   └── loading-method - Array ["cache" | "network"]
         * ├── response - optional Object
         * │   ├── no-content - Boolean
         * │   ├── not-modified - Boolean
         * │   ├── must-revalidate - Boolean
         * │   ├── source - String ("network" | "cache" | "tile-store" | "local-file")
         * │   ├── size - Number (size in bytes)
         * │   ├── modified - optional String, rfc1123 timestamp
         * │   ├── expires - optional String, rfc1123 timestamp
         * │   ├── etag - optional String
         * │   └── error - optional Object
         * │       ├── reason - String ("success" | "not-found" | "server" | "connection" | "rate-limit" | "in-offline-mode" | "other")
         * │       └── message - String
         * └── cancelled - Boolean
         * ```
         */
        case resourceRequest

        // swiftlint:disable:next cyclomatic_complexity
        public init?(rawValue: String) {
            switch rawValue {
            case MapEvents.mapLoaded:
                self = .mapLoaded
            case MapEvents.mapLoadingError:
                self = .mapLoadingError
            case MapEvents.mapIdle:
                self = .mapIdle
            case MapEvents.styleDataLoaded:
                self = .styleDataLoaded
            case MapEvents.styleLoaded:
                self = .styleLoaded
            case MapEvents.styleImageMissing:
                self = .styleImageMissing
            case MapEvents.styleImageRemoveUnused:
                self = .styleImageRemoveUnused
            case MapEvents.sourceDataLoaded:
                self = .sourceDataLoaded
            case MapEvents.sourceAdded:
                self = .sourceAdded
            case MapEvents.sourceRemoved:
                self = .sourceRemoved
            case MapEvents.renderFrameStarted:
                self = .renderFrameStarted
            case MapEvents.renderFrameFinished:
                self = .renderFrameFinished
            case MapEvents.cameraChanged:
                self = .cameraChanged
            case MapEvents.resourceRequest:
                self = .resourceRequest
            default:
                return nil
            }
        }

        public var rawValue: String {
            switch self {
            case .mapLoaded:
                return MapEvents.mapLoaded
            case .mapLoadingError:
                return MapEvents.mapLoadingError
            case .mapIdle:
                return MapEvents.mapIdle
            case .styleDataLoaded:
                return MapEvents.styleDataLoaded
            case .styleLoaded:
                return MapEvents.styleLoaded
            case .styleImageMissing:
                return MapEvents.styleImageMissing
            case .styleImageRemoveUnused:
                return MapEvents.styleImageRemoveUnused
            case .sourceDataLoaded:
                return MapEvents.sourceDataLoaded
            case .sourceAdded:
                return MapEvents.sourceAdded
            case .sourceRemoved:
                return MapEvents.sourceRemoved
            case .renderFrameStarted:
                return MapEvents.renderFrameStarted
            case .renderFrameFinished:
                return MapEvents.renderFrameFinished
            case .cameraChanged:
                return MapEvents.cameraChanged
            case .resourceRequest:
                return MapEvents.resourceRequest
            }
        }
    }
}
