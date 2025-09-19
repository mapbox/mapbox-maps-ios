import SwiftUI
import MapboxMaps

class FavoritesManager: ObservableObject {
    @Published var favoriteIds: Set<String> = []
    
    func isFavorite(_ mapboxId: String) -> Bool {
        return favoriteIds.contains(mapboxId)
    }

    func isFavorite(_ feature: FeaturesetFeature) -> Bool {
        guard case JSONValue.string(let mapboxId)?? = feature.properties["mapbox_id"] else {
            return false
        }
        return isFavorite(mapboxId)
    }

    func toggleFavorite(for feature: FeaturesetFeature) {
        guard case JSONValue.string(let mapboxId)?? = feature.properties["mapbox_id"] else {
            return
        }

        toggleFavorite(for: mapboxId)
    }
    
    func toggleFavorite(for mapboxId: String) {
        if favoriteIds.contains(mapboxId) {
            favoriteIds.remove(mapboxId)
        } else {
            favoriteIds.insert(mapboxId)
        }
    }
        
    var allFavoriteIds: [String] {
        return Array(favoriteIds)
    }
}
