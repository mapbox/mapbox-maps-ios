import Foundation

// MARK: - MapEvents

public extension MapEvents {

    enum EventKind: RawRepresentable, CaseIterable {
        case mapLoadingFinished
        case mapLoadingError
        case mapIdle
        case styleLoadingFinished
        case styleFullyLoaded
        case styleImageMissing
        case styleImageRemoveUnused
        case sourceChanged
        case sourceAdded
        case sourceRemoved
        case renderFrameStarted
        case renderFrameFinished
        case cameraChanged
        case resourceRequest

        // swiftlint:disable:next cyclomatic_complexity
        public init?(rawValue: String) {
            switch rawValue {
            case MapEvents.mapLoadingFinished:
                self = .mapLoadingFinished
            case MapEvents.mapLoadingError:
                self = .mapLoadingError
            case MapEvents.mapIdle:
                self = .mapIdle
            case MapEvents.styleLoadingFinished:
                self = .styleLoadingFinished
            case MapEvents.styleFullyLoaded:
                self = .styleFullyLoaded
            case MapEvents.styleImageMissing:
                self = .styleImageMissing
            case MapEvents.styleImageRemoveUnused:
                self = .styleImageRemoveUnused
            case MapEvents.sourceChanged:
                self = .sourceChanged
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
            case .mapLoadingFinished:
                return MapEvents.mapLoadingFinished
            case .mapLoadingError:
                return MapEvents.mapLoadingError
            case .mapIdle:
                return MapEvents.mapIdle
            case .styleLoadingFinished:
                return MapEvents.styleLoadingFinished
            case .styleFullyLoaded:
                return MapEvents.styleFullyLoaded
            case .styleImageMissing:
                return MapEvents.styleImageMissing
            case .styleImageRemoveUnused:
                return MapEvents.styleImageRemoveUnused
            case .sourceChanged:
                return MapEvents.sourceChanged
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
