import Foundation

/// A structure represeting a Model
public struct Model: Equatable, Codable {

    /// URL to a `gltf` 3D asset in the application bundle
    public var uri: URL?

    /// Coordinates of the model in `[longitude, latitude]`format
    public var position: [Double]?

    /// Orientation of the model
    public var orientation: [Double]?

    public init(uri: URL? = nil, position: [Double]? = nil, orientation: [Double]? = nil) {
        self.uri = uri
        self.position = position
        self.orientation = orientation
    }
}

/// A model data source used to power a `ModelLayer`
internal struct ModelSource: Source {

    internal let type: SourceType

    /// Dictionary of model identifiers to models
    internal var models: [String: Model]?

    internal init() {
      type = .model
    }
}
