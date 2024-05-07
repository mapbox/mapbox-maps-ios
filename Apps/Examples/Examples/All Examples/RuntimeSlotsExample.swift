import UIKit
@_spi(Experimental) import MapboxMaps

/// This example shows how to use a slot from the Standard style and use another custom slot added at runtime
/// to split the former into two parts.
@available(iOS 13.0, *)
final class RuntimeSlotsExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let square = Polygon(center: .berlin, radius: 1000, vertices: 4)
        let triangle = Polygon(center: .berlin.coordinate(at: 800, facing: 320), radius: 700, vertices: 3)

        mapView.mapboxMap.setMapStyleContent {
            GeoJSONSource(id: "square-data")
                .data(.feature(Feature(geometry: square)))

            /// The MapStyleContent defines the desired layers positions.
            /// ```
            /// ... bottom layers ...
            /// "middle" slot
            ///    - "annotation-placeholder" slot
            ///    - "polygon" layer
            /// ... top layers layers ...
            /// ```
            SlotLayer(id: "annotation-placeholder")
                .slot(.middle)
            FillLayer(id: "square", source: "square-data")
                .fillColor(.systemPink)
                .fillOpacity(0.8)
                .slot(.middle)
        }

        /// The annotation uses slot `annotation-placeholder` so it will be rendered below the polygon:
        /// ```
        /// ... bottom layers ...
        /// "middle" slot
        ///    - triangle annotation
        ///    - "annotation-placeholder" slot
        ///    - "square" layer
        /// ... top layers layers ...
        /// ```
        /// If any other layers or annotations are added to the `annotation-placeholder` slot, they will appear above the triangle annotation, but below the square layer.
        let manager = mapView.annotations.makePolygonAnnotationManager()
        manager.slot = "annotation-placeholder"
        manager.annotations = [
            PolygonAnnotation(polygon: triangle).fillColor(StyleColor(.yellow))
        ]

        mapView.mapboxMap.setCamera(to: CameraOptions(center: .berlin, zoom: 12))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
