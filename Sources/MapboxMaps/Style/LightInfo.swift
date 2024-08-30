import Foundation

/// Information about a light
public struct LightInfo: Decodable, Sendable {
    /// The identifier of the light
    public var id: String

    /// The type of the light
    public var type: LightType

    /// Create a `LightInfo` value
    /// - Parameters:
    ///   - id: A light ID
    ///   - type: A light type
    public init(id: String, type: LightType) {
        self.id = id
        self.type = type
    }
}
