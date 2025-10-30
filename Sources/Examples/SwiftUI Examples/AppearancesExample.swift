import SwiftUI
@_spi(Experimental) import MapboxMaps

/// Example demonstrating the experimental Appearances API for dynamic icon states.
/// Shows how to use appearances with feature-state to change icon images based on user interaction.
/// - Default: hotel icon
/// - Currently Selected: hotel-active icon
/// - Previously Clicked: hotel-clicked icon
struct AppearancesExample: View {
    private static let currentlySelectedKey = "currentlySelected"
    private static let hasBeenClickedKey = "hasBeenClicked"

    @State private var selectedFeature: FeaturesetFeature?
    @State private var clickedFeatureIds: Set<String> = []

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .camera(center: .pyrenees, zoom: 15.5)) {
                // When a hotel icon is tapped, set the currentlySelected feature state to true,
                // unselect the previous one if any, and store this feature both as the selected
                // feature and in the list of features that have been clicked
                TapInteraction(.layer("points")) { feature, _ in
                    guard let map = proxy.map else { return false }

                    // Clear the currently selected feature by resetting its feature state
                    if let previousFeature = selectedFeature {
                        map.setFeatureState(previousFeature, state: [Self.currentlySelectedKey: false])
                    }

                    // Store this feature as the currently selected feature and in the list
                    // of features that have been clicked
                    if let featureId = feature.id?.id {
                        clickedFeatureIds.insert(featureId)
                        map.setFeatureState(feature, state: [
                            Self.currentlySelectedKey: true,
                            Self.hasBeenClickedKey: true
                        ])
                        selectedFeature = feature
                        print("✅ Selected feature \(featureId)")
                    }

                    return true
                }

                // When the map is tapped outside of any feature, unselect the currently selected
                // feature if there's any, or remove all features from the list of features that
                // have been clicked to get back to the initial state
                TapInteraction { _ in
                    guard let map = proxy.map else { return false }

                    if let previousFeature = selectedFeature {
                        // Unselect the currently selected feature
                        map.setFeatureState(previousFeature, state: [Self.currentlySelectedKey: false])
                        selectedFeature = nil
                        print("✅ Cleared selection")
                    } else {
                        // Reset the state of all features to the default one
                        clickedFeatureIds.forEach { id in
                            map.setFeatureState(
                                sourceId: "points",
                                featureId: id,
                                state: [Self.hasBeenClickedKey: false]
                            ) { _ in }
                        }
                        clickedFeatureIds.removeAll()
                        print("✅ Reset all features")
                    }

                    return true
                }
            }
            .onStyleLoaded { _ in
                guard let map = proxy.map else { return }
                setupAppearances(map)
            }
            .mapStyle(.standard)
            .ignoresSafeArea()
        }
    }

    private func setupAppearances(_ map: MapboxMap) {
        // Load an image for every feature state
        let hotelIcon = UIImage(resource: .hotel)
        let hotelActiveIcon = UIImage(resource: .hotelActive)
        let hotelClickedIcon = UIImage(resource: .hotelClicked)

        do {
            try map.addImage(hotelIcon, id: "hotel", sdf: false)
            try map.addImage(hotelActiveIcon, id: "hotel-active", sdf: false)
            try map.addImage(hotelClickedIcon, id: "hotel-clicked", sdf: false)
            print("✅ Added all images (hotel, hotel-active, hotel-clicked)")
        } catch {
            print("❌ Failed to add images: \(error)")
            return
        }

        // Add a GeoJSON source with hotel locations
        let sourceJSON: [String: Any] = [
            "type": "geojson",
            "data": [
                "type": "FeatureCollection",
                "features": [
                    ["type": "Feature", "id": 1, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8452993238082342, 42.100164223399275]]],
                    ["type": "Feature", "id": 2, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8438590191857145, 42.1004178052402]]],
                    ["type": "Feature", "id": 3, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.844225198327564, 42.10130533369667]]],
                    ["type": "Feature", "id": 4, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8443594640122, 42.0990955459275]]],
                    ["type": "Feature", "id": 5, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8449697625811154, 42.09869705141318]]],
                    ["type": "Feature", "id": 6, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8471058075726603, 42.09978384873651]]],
                    ["type": "Feature", "id": 7, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8455739474818813, 42.10182152060625]]],
                    ["type": "Feature", "id": 8, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8427787800360136, 42.10039061289771]]],
                    ["type": "Feature", "id": 9, "properties": [:], "geometry": ["type": "Point", "coordinates": [1.8433280487479635, 42.0994396753579]]]
                ]
            ]
        ]

        do {
            try map.addSource(withId: "points", properties: sourceJSON)
            print("✅ Added GeoJSON source")
        } catch {
            print("❌ Failed to add source: \(error)")
            return
        }

        // Add a layer to show an icon on every point
        let layerJSON: [String: Any] = [
            "id": "points",
            "type": "symbol",
            "source": "points",
            "layout": [
                "icon-allow-overlap": true,
                "icon-image": "hotel",
                "icon-size": 0.75
            ],
            // appearances are experimental and subject to change in future versions
            "appearances": [
                [
                    "name": "clicked",
                    "condition": ["boolean", ["feature-state", Self.currentlySelectedKey], false],
                    "properties": ["icon-image": "hotel-active"]
                ],
                [
                    "name": "has-been-clicked",
                    "condition": ["boolean", ["feature-state", Self.hasBeenClickedKey], false],
                    "properties": ["icon-image": "hotel-clicked"]
                ]
            ]
        ]

        do {
            try map.addLayer(with: layerJSON, layerPosition: nil)
            print("✅ Added symbol layer with appearances")
        } catch {
            print("❌ Failed to add layer: \(error)")
        }
    }

}

private extension CLLocationCoordinate2D {
    static let pyrenees = CLLocationCoordinate2D(latitude: 42.10025506, longitude: 1.8447281852)
}

struct AppearancesExample_Previews: PreviewProvider {
    static var previews: some View {
        AppearancesExample()
    }
}
