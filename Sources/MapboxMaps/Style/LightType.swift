import Foundation

/// Supported light types
public struct LightType: RawRepresentable, Codable, Equatable, Sendable {

    /// A global directional light.
    public static let flat = LightType(rawValue: "flat")

    /// An indirect type of light.
    public static let ambient = LightType(rawValue: "ambient")

    /// A type of light that has a direction.
    public static let directional = LightType(rawValue: "directional")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
