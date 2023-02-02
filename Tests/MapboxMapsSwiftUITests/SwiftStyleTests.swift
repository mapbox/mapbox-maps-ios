@testable import MapboxMapsSwiftUI

class MockStyleApplier: StyleApplier {
    func updateGeoJSONSource(withId id: String, geoJSON: Turf.GeoJSONObject) throws {
    }

    func setAtmosphere(_ atmosphere: MapboxMaps.Atmosphere) throws {

    }

    func removeAtmosphere() throws {

    }

    func addImage(_ image: UIImage, id: String, sdf: Bool, contentInsets: UIEdgeInsets) throws {

    }

    func removeImage(withId id: String) throws {

    }

    func setTerrain(_ terrain: MapboxMaps.Terrain) throws {

    }

    func removeTerrain() {

    }

    func setProjection(_ projection: MapboxMaps.StyleProjection) throws {

    }

    var layerAdditions = Set<String>()
    var layerRemovals = Set<String>()
    
    var sourcesAdditions = Set<String>()
    var sourcesRemovals = Set<String>()

    func addLayer(_ layer: Layer) throws {
        layerAdditions.insert(layer.id)
    }

    func removeLayer(withId id: String) throws {
        layerRemovals.insert(id)
    }

    func addSource(_ source: Source, id: String) throws {
        sourcesAdditions.insert(id)
    }

    func removeSource(withId id: String) throws {
        sourcesRemovals.insert(id)
    }
}
