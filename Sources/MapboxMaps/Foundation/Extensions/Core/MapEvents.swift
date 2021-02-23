import Foundation

// MARK: - MapEvents

public extension MapEvents {

    enum EventKind: RawRepresentable, CaseIterable {
        case mapLoadingStarted
        case mapLoadingFinished
        case mapLoadingError
        case mapIdle
        case styleLoadingFinished
        case styleFullyLoaded
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

        // swiftlint:disable:next cyclomatic_complexity
        public init?(rawValue: String) {
            switch rawValue {
            case MapEvents.mapLoadingStarted :
                self = .mapLoadingStarted
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
            case MapEvents.renderFrameStarted:
                self = .renderFrameStarted
            case MapEvents.renderFrameFinished:
                self = .renderFrameFinished
            case MapEvents.renderMapStarted:
                self = .renderMapStarted
            case MapEvents.renderMapFinished:
                self = .renderMapFinished
            case MapEvents.cameraWillChange:
                self = .cameraWillChange
            case MapEvents.cameraIsChanging:
                self = .cameraIsChanging
            case MapEvents.cameraDidChange:
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
                return MapEvents.mapLoadingStarted
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
            case .renderFrameStarted:
                return MapEvents.renderFrameStarted
            case .renderFrameFinished:
                return MapEvents.renderFrameFinished
            case .renderMapStarted:
                return MapEvents.renderMapStarted
            case .renderMapFinished:
                return MapEvents.renderMapFinished
            case .cameraWillChange:
                return MapEvents.cameraWillChange
            case .cameraIsChanging:
                return MapEvents.cameraIsChanging
            case .cameraDidChange:
                return MapEvents.cameraDidChange
            case .resourceRequest:
                return MapEvents.resourceRequest
            }
        }
    }
}
