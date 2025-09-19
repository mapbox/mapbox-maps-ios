import SwiftUI
import CoreLocation
import MapboxMaps

class NetworkService: ObservableObject {
    static let token = Bundle.main.infoDictionary?["MBXAccessToken"] as? String ?? ""
    static func fetchDetails(mapboxId: String) async throws -> FeatureDetails? {
        guard let url = URL(string: "https://api.mapbox.com/search/searchbox/v1/retrieve/\(mapboxId)?attribute_sets=basic,visit,venue,photos&access_token=\(token)&session_token=\(UUID().uuidString)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FeatureCollectionWrapper.self, from: data)
        return response.features.first!
    }

    static func fetchSearchResults(_ query: String, location: CLLocationCoordinate2D, categories: [POICategory]) async throws -> FeatureCollection {
        let proximity = "\(location.longitude),\(location.latitude)"
        var components = URLComponents(string: "https://api.mapbox.com/search/searchbox/v1/forward")
        components!.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "proximity", value: proximity),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "access_token", value: token),
        ]
        if !categories.isEmpty {
            components!.queryItems?.append(URLQueryItem(name: "poi_category", value: categories.map(\.id).joined(separator: ",")))
        }

        let (data, _) = try await URLSession.shared.data(from: components!.url!)
        let response = try JSONDecoder().decode(FeatureCollection.self, from: data)
        return response

    }
}
