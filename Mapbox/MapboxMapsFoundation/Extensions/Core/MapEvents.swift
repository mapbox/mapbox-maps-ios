import Foundation


// MARK: - MapEvents

public extension MapEvents {

    enum EventKind: RawRepresentable, CaseIterable {
        case mapLoadingStarted
        case mapLoadingFinished
        case mapLoadingError
        case mapIdle
        case styleLoadingFinished
        case styleImageMissing
        case styleImageRemoveUnused
        case sourceChanged
        case renderFrameStarted
        case renderFrameFinished
        case renderMapStarted
        case renderMapFinished
        case cameraWillChange
        case cameraIsChanging
        case cameraDidChange
        case resourceRequest

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
            case MapEvents.styleImageMissing:
                self = .styleImageMissing
            case MapEvents.styleImageRemoveUnused:
                self = .styleImageRemoveUnused
            case MapEvents.sourceChanged:
                self = .sourceChanged
            case MapEvents.renderFrameStarted:
                self = .renderFrameStarted
            case MapEvents.renderFrameFinished:
                self = .renderFrameFinished
                self = .cameraDidChange
            case MapEvents.resourceRequest:
                self = .resourceRequest
            default:
                return nil
            }
        }

        public var rawValue: String {
            switch self {
            case .mapLoadingStarted:
                return MapEvents.mapLoadingFinished
            case .mapLoadingFinished:
                return MapEvents.mapLoadingFinished
            case .mapLoadingError:
                return MapEvents.mapLoadingError
            case .mapIdle:
                return MapEvents.mapIdle
            case .styleLoadingFinished:
                return MapEvents.styleLoadingFinished
            case .styleImageMissing:
                return MapEvents.styleImageMissing
            case .styleImageRemoveUnused:
                return MapEvents.styleImageRemoveUnused
            case .sourceChanged:
                return MapEvents.sourceChanged
            case .renderFrameStarted:
                return MapEvents.renderFrameStarted
            case .renderFrameFinished:
                return MapEvents.renderFrameFinished
            case .renderMapStarted:
                return MapEvents.renderFrameStarted
            case .renderMapFinished:
                return MapEvents.renderFrameFinished
            case .cameraWillChange:
                return MapEvents.cameraChanged
            case .cameraIsChanging:
                return MapEvents.cameraChanged
            case .cameraDidChange:
                return MapEvents.cameraChanged
            case .resourceRequest:
                return MapEvents.resourceRequest
            }
        }
    }
}
