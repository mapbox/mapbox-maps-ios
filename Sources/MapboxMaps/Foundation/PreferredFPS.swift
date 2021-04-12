public enum PreferredFPS: RawRepresentable, Equatable {

    /**
     Create a `PreferredFPS` value from an `Int`.
     - Parameter rawValue: The `Int` value to use as the preferred frames per second.
     */
    public init?(rawValue: Int) {
        switch rawValue {
        case Self.lowPower.rawValue:
            self = .lowPower
        case Self.normal.rawValue:
            self = .normal
        case Self.maximum.rawValue:
            self = .maximum
        default:
            self = .custom(fps: rawValue)
        }
    }

    public typealias RawValue = Int

    /// The default frame rate. This can be either 30 FPS or 60 FPS, depending on
    /// device capabilities.
    case normal

    /// A conservative frame rate; typically 30 FPS.
    case lowPower

    /// The maximum supported frame rate; typically 60 FPS.
    case maximum

    /// A custom frame rate. The default value is 30 FPS.
    case custom(fps: Int)

    /// The preferred frames per second as an `Int` value.
    public var rawValue: Int {
        switch self {
        case .lowPower:
            return 30
        case .normal:
            return -1
        case .maximum:
            return 0
        case .custom(let fps):
            // TODO: Check that value is a valid FPS value.
            return fps
        }
    }

}
