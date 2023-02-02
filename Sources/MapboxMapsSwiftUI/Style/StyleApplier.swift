import MapboxMaps

protocol StyleApplier {
    func addLayer(_ layer: Layer) throws
    func removeLayer(withId id: String) throws
    func addSource(_ source: Source, id: String) throws
    func removeSource(withId id: String) throws
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject) throws


    func setTerrain(_ terrain: Terrain) throws
    func removeTerrain()
    func setProjection(_ projection: StyleProjection) throws
    func setAtmosphere(_ atmosphere: Atmosphere) throws
    func removeAtmosphere() throws
    

    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets) throws
    func removeImage(withId id: String) throws
}
