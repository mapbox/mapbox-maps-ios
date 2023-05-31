import Foundation

/// Supported 3D Light type.
@_spi(Experimental) public enum Light3DType: String, Codable {
    case ambient
    case directional
}

@_spi(Experimental) public protocol Light3DProtocol: Codable, StyleEncodable {
    /// Unique 3D Light name.
    var id: String { get }

    /// Rendering ``Light3DType`` of this light.
    var lightType: Light3DType { get }
}

/// Information about a ``Ligh3DProtocol``.
@_spi(Experimental) public struct Light3DInfo {
    /// Unique 3D Light name.
    public let id: String
    /// Rendering ``Light3DType`` of this light.
    public let lightType: Light3DType

    internal init(id: String, lightType: Light3DType) {
        self.id = id
        self.lightType = lightType
    }
}
