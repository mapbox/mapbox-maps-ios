import Foundation

// MARK: - MapEvents

/* Simplified diagram for events emitted by the Map object.
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

/**
* List of supported event types by the MapView and Snapshotter objects,
* and event data format specification for each event.
*/
public extension MapEvents {
    /// Events emitted by the SDK
    enum EventKind: RawRepresentable, CaseIterable {
        /**
         * The Map's style has been fully loaded, and the Map has rendered all visible tiles.
         */
        case mapLoaded

        /**
         * Describes an error that has occurred while loading the Map. The 'type' property defines what resource could
         * not be loaded and the 'message' property will contain a descriptive error message.
         *
         * Event data format (Object):
         * ```
         * .
         * ├── type - String ("style" | "sprite" | "source" | "tile" | "glyphs")
         * └── message - String
         * ```
         */
        case mapLoadingError

        /**
         * The Map has entered the idle state. The Map is in the idle state when there are no ongoing transitions
         * and the Map has rendered all available tiles. The event will not be emitted if
         * Map#setUserAnimationInProgress or Map#setGestureInProgress is true.
         */
        case mapIdle

        /**
         * The requested style data has been loaded. The 'type' property defines
         * what kind of style data has been loaded.
         * Event may be emitted synchronously, for example, when StyleManager#setStyleJSON is used to load style.
         *
         * Based on an event data 'type' property value, following use-cases may be implemented:
         * - 'style': Style is parsed, style layer properties could be read and modified, style layers and sources could be
         *   added or removed before rendering is started.
         * - 'sprite': Style's sprite sheet is parsed and it is possible to add or update images.
         * - 'sources': All sources defined by the style are loaded and their properties could be read and updated if needed.
         *         *
         * Event data format (Object):
         * ```
         * .
         * └── type - String ("style" | "sprite" | "sources")
         * ```
         */
        case styleDataLoaded

        /**
         * The requested style has been fully loaded, including the style, specified sprite and sources' metadata.
         */
        case styleLoaded

        /**
         * A style has a missing image. This event is emitted when the Map renders visible tiles and
         * one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
         * by calling `Style.setStyleImage` method.
         * ```
         * Event data format (Object):
         * .
         * └── id - String
         * ```
         */
        case styleImageMissing

        /**
         * An image added to the Style is no longer needed.
         *
         * Event data format (Object):
         * ```
         * .
         * └── id - String
         * ```
         *
         * - Todo: Support removal using Style.removeImage.
         */
        case styleImageRemoveUnused

        /**
         * Source data has been loaded.
         * The 'id' property defines the source id.
         * The 'type' property defines if source's metadata (e.g., TileJSON) or tile has been loaded.
         * The 'loaded' property will be set to 'true' if all source's data required for Map's visible viewport, are loaded.
         * The 'tile-id' property defines the tile id if the 'type' field equals 'tile'.
         *
         * Event data format (Object):
         * ```
         * .
         * ├── id - String
         * ├── type - String ("metadata" | "tile")
         * ├── loaded - optional Boolean
         * └── tile-id optional Object
         *     ├── z Number (zoom level)
         *     ├── x Number (x coordinate)
         *     └── y Number (y coordinate)
         * ```
         */
        case sourceDataLoaded

        /**
         * Source has been added with `Style.addSource` runtime API.
         *
         * Event data format (Object):
         * ```
         * .
         * └── id - String
         * ```
         */
        case sourceAdded

        /**
         * Source has been removed with StyleManager#removeStyleSource runtime API.
         *
         * Event data format (Object):
         * ```
         * .
         * └── id - String
         * ```
         */
        case sourceRemoved

        /**
         * The Map started rendering a frame.
         */
        case renderFrameStarted

        /**
         * The Map finished rendering a frame.
         * The 'render-mode' property tells whether the Map has all data ("full") required to render the visible viewport.
         * The 'needs-repaint' property provides information about ongoing transitions that trigger Map repaint.
         * The 'placement-changed' property tells if the symbol placement has been changed in the visible viewport.
         *
         * Event data format (Object):
         * ```
         * .
         * ├── render-mode - String ("partial" | "full")
         * ├── needs-repaint - Boolean
         * └── placement-changed - Boolean
         * ```
         */
        case renderFrameFinished

        /**
         * Camera has changed. This event is emitted whenever the visible viewport
         * changes due to `MapView.layoutSubviews` being called or when the camera
         * is modified by calling Map camera methods.
         */
        case cameraChanged

        /**
         * ResourceRequest event allows client to observe resource requests made by a
         * MapView or Snapshotter.
         *
         * Event data format (Object):
         * ```
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
         * │   ├── offline-data - Boolean
         * │   ├── size - Number (size in bytes)
         * │   ├── modified - optional String, rfc1123 timestamp
         * │   ├── expires - optional String, rfc1123 timestamp
         * │   ├── etag - optional String
         * │   └── error - optional Object
         * │       ├── reason - String ("success" | "not-found" | "server" | "connection" | "rate-limit" | "other")
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
