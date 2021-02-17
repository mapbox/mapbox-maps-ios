import Foundation

// MARK: - Style error types

/// All source related errors
public enum SourceError: Error {
    /// The source could not be encoded to JSON
    case sourceEncodingFailed(Error)

    /// The source could not be decoded from JSON
    case sourceDecodingFailed(Error)

    /// The source could not be added to the map
    case addSourceFailed(String?)

    /// The source could not be retrieved from the map
    case getSourceFailed(String?)

    /// The source property could not be set.
    case setSourceProperty(String?)

    /// The source could not be removed from the map
    case removeSourceFailed(String?)
}

/// Error enum for all layer-related errors
public enum LayerError: Error {
    /// The layer provided to the map in `addLayer()` could not be encoded
    case layerEncodingFailed(Error)

    /// The layer retrieved from the map could not be decoded.
    case layerDecodingFailed(Error)

    /// Addding the style layer to the map failed
    case addStyleLayerFailed(String?)

    /// The layer properties for a layer are nil
    case getStyleLayerFailed(String?)

    /// Remove the style layer from the map failed
    case removeStyleLayerFailed(String?)

    /// The retrieved layer is nil
    case retrievedLayerIsNil

    /// Updating the layer failed with error
    case updateStyleLayerFailed(Error)
}

/// Error enum for all image-related errors
public enum ImageError: Error {
    /// Converting the input image to internal `Image` format failed.
    case convertingImageFailed(String?)

    /// Adding the image to the style's sprite failed.
    case addStyleImageFailed(String?)

    /// The style image does not exist in the sprite
    case getStyleImageFailed(String?)
}

/// Error enum for all terrain-related errors
public enum TerrainError: Error {
    /// Decoding terrain failed
    case decodingTerrainFailed(Error)
    /// Adding terrain failed
    case addTerrainFailed(String?)
}

/// Enum for all light-related errors
public enum LightError: Error {
    /// Adding a new light object to style failed
    case addLightFailed(String?)

    /// Retrieving a light object from style failed
    case getLightFailed(Error)
}
