import MapboxMaps
import UIKit

final class DataJoinExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up map and camera
        let centerCoordinate = CLLocationCoordinate2D(latitude: 50, longitude: 12)
        let camera = CameraOptions(center: centerCoordinate, zoom: 1.6)
        let mapInitOptions = MapInitOptions(cameraOptions: camera, styleURI: .light)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        view.addSubview(mapView)

        // Add the data layer once the map has finished loading.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.addJSONDataLayer()

            // The following line is just for testing purposes.
            self.finish()
        }.store(in: &cancelables)
    }

    func addJSONDataLayer() {
        // Create an array of countries and their HDI score
        // Data: UN Human Development Index 2017 Europe extract
        // Source: https://ourworldindata.org/human-development-index
        struct Country {
            let code: String
            let hdi: Double
        }

        let countries = [Country(code: "ROU", hdi: 0.811),
                        Country(code: "RUS", hdi: 0.816),
                        Country(code: "SRB", hdi: 0.787 ),
                        Country(code: "SVK", hdi: 0.855 ),
                        Country(code: "SVN", hdi: 0.896 ),
                        Country(code: "ESP", hdi: 0.891 ),
                        Country(code: "SWE", hdi: 0.933 ),
                        Country(code: "CHE", hdi: 0.944 ),
                        Country(code: "HRV", hdi: 0.831 ),
                        Country(code: "CZE", hdi: 0.888 ),
                        Country(code: "DNK", hdi: 0.929 ),
                        Country(code: "EST", hdi: 0.871 ),
                        Country(code: "FIN", hdi: 0.92 ),
                        Country(code: "FRA", hdi: 0.901 ),
                        Country(code: "DEU", hdi: 0.936 ),
                        Country(code: "GRC", hdi: 0.87 ),
                        Country(code: "ALB", hdi: 0.785 ),
                        Country(code: "AND", hdi: 0.858 ),
                        Country(code: "AUT", hdi: 0.908 ),
                        Country(code: "BLR", hdi: 0.808 ),
                        Country(code: "BEL", hdi: 0.916 ),
                        Country(code: "BIH", hdi: 0.768 ),
                        Country(code: "BGR", hdi: 0.813 ),
                        Country(code: "MKD", hdi: 0.757 ),
                        Country(code: "MLT", hdi: 0.878 ),
                        Country(code: "MDA", hdi: 0.7 ),
                        Country(code: "MNE", hdi: 0.814 ),
                        Country(code: "NLD", hdi: 0.931 ),
                        Country(code: "NOR", hdi: 0.953 ),
                        Country(code: "POL", hdi: 0.865 ),
                        Country(code: "PRT", hdi: 0.847 ),
                        Country(code: "HUN", hdi: 0.838 ),
                        Country(code: "ISL", hdi: 0.935 ),
                        Country(code: "IRL", hdi: 0.938 ),
                        Country(code: "ITA", hdi: 0.88 ),
                        Country(code: "LVA", hdi: 0.847 ),
                        Country(code: "LIE", hdi: 0.916 ),
                        Country(code: "LTU", hdi: 0.858 ),
                        Country(code: "LUX", hdi: 0.904 ),
                        Country(code: "UKR", hdi: 0.751 ),
                        Country(code: "GBR", hdi: 0.922 )]

        // Create the source for country polygons using the Mapbox Countries tileset
        // The polygons contain an ISO 3166 alpha-3 code which can be used to for joining the data
        // https://docs.mapbox.com/vector-tiles/reference/mapbox-countries-v1
        var source = VectorSource(id: "countries")
        source.url = "mapbox://mapbox.country-boundaries-v1"

        // Add layer from the vector tile source to create the choropleth
        var layer = FillLayer(id: "countries", source: source.id)
        layer.sourceLayer = "country_boundaries"

        // Build a GL match expression that defines the color for every vector tile feature
        // https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/#match
        // Use the ISO 3166-1 alpha 3 code as the lookup key for the country shape
        let expressionHeader =
            """
            [
            "match",
            ["get", "iso_3166_1_alpha_3"],

            """

        // Calculate color values for each country based on 'hdi' value
        var green: Double
        var expressionBody: String = ""
        for country in countries {
            // Convert the range of data values to a suitable color
            green = country.hdi*255
            expressionBody += """
            "\(country.code)",
            "rgb(0, \(green), 0)",

            """
        }

        // Last value is the default, used where there is no data
        let expressionFooter =
            """
            "rgba(0, 0, 0, 0)"
            ]
            """

        // Combine the expression strings into a single JSON expression
        // You can alternatively translate JSON expressions into Swift: https://docs.mapbox.com/ios/maps/guides/styles/use-expressions/
        let jsonExpression = expressionHeader + expressionBody + expressionFooter

        // Add the source
        // Insert the vector layer below the 'admin-1-boundary-bg' layer in the style
        // Join data to the vector layer
        do {
            try mapView.mapboxMap.addSource(source)
            try mapView.mapboxMap.addLayer(layer, layerPosition: .below("admin-1-boundary-bg"))
            if let expressionData = jsonExpression.data(using: .utf8) {
                let expJSONObject = try JSONSerialization.jsonObject(with: expressionData, options: [])
                try mapView.mapboxMap.setLayerProperty(for: "countries",
                                                           property: "fill-color",
                                                           value: expJSONObject)
            }
        } catch {
            print("Failed to add the data layer. Error: \(error.localizedDescription)")
        }
    }
}
