/// Defines rendering behavior of model in respect to other 3D scene objects.
internal enum ModelLayerType: String, Codable {
    /// Integrated to 3D scene, using depth testing, along with terrain, fill-extrusions and custom layer.
    case common3D = "common-3d"
    /// Displayed over other 3D content, occluded by terrain.
    case locationIndicator = "location-indicator"
}
