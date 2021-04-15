import Foundation

internal protocol CoreErrorRepresentable {
    associatedtype CoreErrorType
    init(coreError: CoreErrorType)
    init(unspecifiedError: String)
}

/// Describes the reason for a tile region download request failure.
public enum TileRegionError: Error, CoreErrorRepresentable {
    typealias CoreErrorType = MapboxCommon.TileRegionError

    /// The operation was canceled.
    case canceled(String)

    /// The tile region does not exist.
    case doesNotExist(String)

    /// Resolving the tileset descriptors failed.
    case tilesetDescriptor(String)

    /// There is no available space to store the resources.
    case diskFull(String)

    /// Some other failure reason.
    case other(String)

    internal init(coreError: MapboxCommon.TileRegionError) {
        let message = coreError.message
        switch coreError.type {
        case .canceled:
            self = .canceled(message)
        case .doesNotExist:
            self = .doesNotExist(message)
        case .tilesetDescriptor:
            self = .tilesetDescriptor(message)
        case .diskFull:
            self = .diskFull(message)
        case .other:
            self = .other(message)
        }
    }

    internal init(unspecifiedError: String) {
        self = .other(unspecifiedError)
    }
}

/// Describes the reason for a style package download request failure.
public enum StylePackError: Error, CoreErrorRepresentable {
    typealias CoreErrorType = MapboxCoreMaps.StylePackError

    /// The operation was canceled.
    case canceled(String)

    /// Style package does not exist.
    case doesNotExist(String)

    /// There is no available space to store the resources.
    case diskFull(String)

    /// Some other failure reason.
    case other(String)

    internal init(unspecifiedError: String) {
        self = .other(unspecifiedError)
    }

    internal init(coreError: MapboxCoreMaps.StylePackError) {
        let message = coreError.message
        switch coreError.type {
        case .canceled:
            self = .canceled(message)
        case .doesNotExist:
            self = .doesNotExist(message)
        case .diskFull:
            self = .diskFull(message)
        case .other:
            self = .other(message)
        }
    }
}
