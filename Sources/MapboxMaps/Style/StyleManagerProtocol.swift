import Foundation

internal protocol StyleManagerProtocol {

    var isLoaded: Bool { get }

    var uri: StyleURI? { get set }

    var JSON: String { get set }

    var defaultCamera: CameraOptions { get }

    var transition: TransitionOptions { get set }

    func addLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws

    func addPersistentLayer(with properties: [String: Any], layerPosition: LayerPosition?) throws

    func isPersistentLayer(id: String) throws -> Bool

    func addPersistentCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws

    func addCustomLayer(withId id: String, layerHost: CustomLayerHost, layerPosition: LayerPosition?) throws

    func removeLayer(withId id: String) throws

    func layerExists(withId id: String) -> Bool

    var allLayerIdentifiers: [LayerInfo] { get }

    func layerProperty(for layerId: String, property: String) -> StylePropertyValue

    func setLayerProperty(for layerId: String, property: String, value: Any) throws

    static func layerPropertyDefaultValue(for layerType: LayerType, property: String) -> StylePropertyValue

    func layerProperties(for layerId: String) throws -> [String: Any]

    func setLayerProperties(for layerId: String, properties: [String: Any]) throws

    // MARK: Sources

    func addSource(withId sourceId: String, properties: [String: Any]) throws

    func removeSource(withId sourceId: String) throws

    func sourceExists(withId sourceId: String) -> Bool

    var allSourceIdentifiers: [SourceInfo] { get }

    // MARK: Source properties

    func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue

    func setSourceProperty(for sourceId: String, property: String, value: Any) throws

    func sourceProperties(for sourceId: String) throws -> [String: Any]

    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws

    static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue

    // MARK: Image source

    func updateImageSource(withId sourceId: String, image: UIImage) throws

    // MARK: Style images

    func addImage(_ image: UIImage,
                  id: String,
                  sdf: Bool,
                  stretchX: [ImageStretches],
                  stretchY: [ImageStretches],
                  content: ImageContent?) throws

    func removeImage(withId id: String) throws

    func image(withId id: String) -> UIImage?

    // MARK: Light

    func setLight(properties: [String: Any]) throws

    func lightProperty(_ property: String) -> StylePropertyValue

    func setLightProperty(_ property: String, value: Any) throws

    // MARK: Terrain

    func setTerrain(properties: [String: Any]) throws

    func terrainProperty(_ property: String) -> StylePropertyValue

    func setTerrainProperty(_ property: String, value: Any) throws

    // MARK: Custom geometry

    func addCustomGeometrySource(withId sourceId: String, options: CustomGeometrySourceOptions) throws

    func setCustomGeometrySourceTileData(forSourceId sourceId: String, tileId: CanonicalTileID, features: [Turf.Feature]) throws

    func invalidateCustomGeometrySourceTile(forSourceId sourceId: String, tileId: CanonicalTileID) throws

    func invalidateCustomGeometrySourceRegion(forSourceId sourceId: String, bounds: CoordinateBounds) throws
}
