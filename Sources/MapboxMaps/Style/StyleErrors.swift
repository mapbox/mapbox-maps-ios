import Foundation

// MARK: - Style error types

public enum StyleEncodingError: Error {
    case invalidJSONObject
}

/// All source related errors
public enum SourceError: Error {
    /// The source could not be encoded to JSON
    case sourceEncodingFailed(Error)

    /// The source could not be decoded from JSON
    case sourceDecodingFailed(Error)

    /// The source could not be added to the map
    case addSourceFailed(String)

    /// The source could not be removed from the map
    case removeSourceFailed(String)

    /// The source could not be retrieved from the map
    case getSourceFailed(String)

    /// The source property could not be set.
    case setSourceProperty(String)

    /// Temporary error for clustering.
    case getSourceClusterDetailsFailed(String)
}

/// Error enum for all layer-related errors
public enum LayerError: Error {
    /// The layer provided to the map in `addLayer()` could not be encoded
    case layerEncodingFailed(Error?)

    /// The layer retrieved from the map could not be decoded.
    case layerDecodingFailed(Error)

    /// Adding the style layer to the map failed
    case addLayerFailed(String)

    /// Remove the style layer from the map failed
    case removeLayerFailed(String)

    /// Setting layer property(s) failed
    case setLayerPropertyFailed(String)

    /// The layer properties for a layer are nil
    case getStyleLayerFailed(String)

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
    case addStyleImageFailed(String)

    /// The style image does not exist in the sprite
    case getStyleImageFailed(String)

    /// Temporary
    case imageSourceImageUpdateFailed(String)
    case removeImageFailed(String)
}

/// Error enum for all terrain-related errors
public enum TerrainError: Error {
    /// Decoding terrain failed
    case setTerrainProperty(String)

    /// Adding terrain failed
    case addTerrainFailed(String)
}

/// Enum for all light-related errors
public enum LightError: Error {
    /// Adding a new light object to style failed
    case addLightFailed(String)

    /// Retrieving a light object from style failed
    case getLightFailed(Error)
}
