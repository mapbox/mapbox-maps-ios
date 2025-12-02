import SwiftUI
import MapboxMaps

/// Example demonstrating custom vector icons with dynamic styling and interaction.
/// This example shows how to:
/// - Dynamically colorize vector icons based on feature properties using the image expression
/// - Interactively change icon size by tapping on icons
///
/// Vector icons are parameterized SVG images that can be styled at runtime. In this example,
/// three flag icons are colored red, yellow, and purple using the 'flagColor' property.
/// Tap any flag to toggle its size between 1x and 2x.
///
/// For this example to work, the SVGs must live inside the map style. The SVG file was uploaded
/// to Mapbox Studio with the name `flag`, making it available for customization at runtime.
/// You can add vector icons to your own style in Mapbox Studio.
struct CustomVectorIconsExample: View {
    @State private var selectedFlagId: String?

    var body: some View {
        Map(initialViewport: .camera(center: CLLocationCoordinate2D(latitude: 60.185755, longitude: 24.6881), zoom: 16)) {
            // Create GeoJSON source with three flag locations
            GeoJSONSource(id: "points")
                .data(.featureCollection(flagFeatures))

            // Create symbol layer with parameterized icon
            SymbolLayer(id: "points", source: "points")
                .iconImage(
                    Exp(.image) {
                        "flag"
                        ["params": ["flag_color": Exp(.get) { "flagColor" }]]
                    }
                )
                .iconSize(
                    Exp(.switchCase) {
                        Exp(.eq) {
                            Exp(.get) { "id" }
                            selectedFlagId ?? ""
                        }
                        2.0
                        1.0
                    }
                )
                .iconAllowOverlap(true)

            // Add tap interaction for the symbol layer
            TapInteraction(.layer("points")) { feature, _ in
                if let id = feature.properties["id"]??.rawValue as? String {
                    selectedFlagId = (selectedFlagId == id) ? nil : id
                }
                return true
            }
        }
        .mapStyle(MapStyle(uri: StyleURI(rawValue: "mapbox://styles/mapbox-map-design/cm4r19bcm00ao01qvhp3jc2gi")!))
        .ignoresSafeArea()
    }

    /// GeoJSON features with flag locations and colors
    private var flagFeatures: FeatureCollection {
        FeatureCollection(features: [
            createFlagFeature(
                id: "flag-red",
                longitude: 24.68727,
                latitude: 60.185755,
                color: "red"
            ),
            createFlagFeature(
                id: "flag-yellow",
                longitude: 24.68827,
                latitude: 60.186255,
                color: "yellow"
            ),
            createFlagFeature(
                id: "flag-purple",
                longitude: 24.68927,
                latitude: 60.186055,
                color: "#800080"
            )
        ])
    }

    /// Creates a feature with a flag at the specified location and color
    private func createFlagFeature(id: String, longitude: Double, latitude: Double, color: String) -> Feature {
        var feature = Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))))
        feature.properties = [
            "id": .string(id),
            "flagColor": .string(color)
        ]
        return feature
    }
}
