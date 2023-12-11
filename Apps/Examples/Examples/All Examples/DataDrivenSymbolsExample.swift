import UIKit
import MapboxMaps

final class DataDrivenSymbolsExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.761, longitude: -119.624)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 10.0),
                                     styleURI: .outdoors)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
        }.store(in: &cancelables)
    }

    func setupExample() {
        // Constant used to identify the source layer
        let sourceLayerIdentifier = "yosemite-pois"

        // Add icons from the U.S. National Parks Service to the map's style.
        // Icons are located in the asset catalog
        try! mapView.mapboxMap.addImage(UIImage(named: "nps-restrooms")!, id: "restrooms")
        try! mapView.mapboxMap.addImage(UIImage(named: "nps-trailhead")!, id: "trailhead")
        try! mapView.mapboxMap.addImage(UIImage(named: "nps-picnic-area")!, id: "picnic-area")

        // Access a vector tileset that contains places of interest at Yosemite National Park.
        // This tileset was created by uploading NPS shapefiles to Mapbox Studio.
        var source = VectorSource(id: sourceLayerIdentifier)
        source.url = "mapbox://examples.ciuz0vpc"
        try! mapView.mapboxMap.addSource(source)

        // Create a symbol layer and access the layer contained.
        // The source property refers to the identifier provided when the source was added.
        var layer = SymbolLayer(id: sourceLayerIdentifier, source: sourceLayerIdentifier)

        // Access the layer that contains the Point of Interest (POI) data.
        // The source layer property is a unique identifier for a layer within a vector tile source.
        layer.sourceLayer = "Yosemite_POI-38jhes"

        // Expression that adds conditions to the source to determine styling.
        /// `POITYPE` refers to a key in the data source. The values tell us which icon to use from the sprite sheet
        let expression = Exp(.switchCase) { // Switching on a value
            Exp(.eq) { // Evaluates if conditions are equal
                Exp(.get) { "POITYPE" } // Get the current value for `POITYPE`
                "Restroom" // returns true for the equal expression if the type is equal to "Restrooms"
            }
            "restrooms" // Use the icon named "restrooms" on the sprite sheet if the above condition is true
            Exp(.eq) {
                Exp(.get) { "POITYPE" }
                "Picnic Area"
            }
            "picnic-area"
            Exp(.eq) {
                Exp(.get) { "POITYPE" }
                "Trailhead"
            }
            "trailhead"
            "" // default case is to return an empty string so no icon will be loaded
        }

        // MARK: Explanation of expression
        // See https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/#case for expression docs
        /*
            The expression yields the following JSON
            [case,
                [==, [get, POITYPE], Restroom], restrooms,
                [==, [get, POITYPE], Picnic Area], picnic-area,
                [==, [get, POITYPE], Trailhead], trailhead
            ]

            This is a switch statement that makes decisions on the Key `POITYPE`
            It will map the value of `POITYPE` to the image name on the sprite sheet.
         */

        // MARK: Alternative expression that yields the same visual Output
        // See https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/#match for expression docs
        //        let expression = Exp(.match) {
        //            Exp(.get) { "POITYPE" }
        //            "Restroom"
        //            "restrooms"
        //            "Picnic Area"
        //            "picnic-area"
        //            "Trailhead"
        //            "trailhead"
        //            ""
        //          }

        /*
            The expression yields the following JSON
            [match,
                [get, POITYPE],
                Restroom, restrooms,
                Picnic Area, picnic-area,
                Trailhead, trailhead
            ]

            This gets the POITYPE and matches the result of it to image name on the sprite sheet.
         */

        layer.iconImage = .expression(expression)

        try! mapView.mapboxMap.addLayer(layer, layerPosition: nil)

        // The below line is used for internal testing purposes only.
        finish()
    }
}
