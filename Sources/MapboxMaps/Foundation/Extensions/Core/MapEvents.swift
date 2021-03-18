import Foundation

// MARK: - MapEvents

/**
* Simplified diagram for events emitted by the Map object.
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
public extension MapEvents {

    enum EventKind: RawRepresentable, CaseIterable {
        case mapLoaded
        case mapLoadingError
        case mapIdle
        case styleDataLoaded
        case styleLoaded
        case styleImageMissing
        case styleImageRemoveUnused
        case sourceDataLoaded
        case sourceAdded
        case sourceRemoved
        case renderFrameStarted
        case renderFrameFinished
        case cameraChanged
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
