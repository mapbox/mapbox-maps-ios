public struct PreferredFPS: RawRepresentable, Equatable {

    public typealias RawValue = Int

    /// The preferred frames per second as an `Int` value.
    public let rawValue: Int

    /**
     Create a `PreferredFPS` value from an `Int`.
     - Parameter rawValue: The `Int` value to use as the preferred frames per second.
     */
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The default frame rate. This can be either 30 FPS or 60 FPS, depending on
    /// device capabilities.
    public static let normal = PreferredFPS(rawValue: -1)

    /// A conservative frame rate; typically 30 FPS.
    public static let lowPower = PreferredFPS(rawValue: 30)

    /// The maximum supported frame rate; typically 60 FPS.
    public static let maximum = PreferredFPS(rawValue: 0)
}
