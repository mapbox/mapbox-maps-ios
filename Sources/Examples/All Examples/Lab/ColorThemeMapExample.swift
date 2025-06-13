import UIKit
@_spi(Experimental) import MapboxMaps

final class ColorThemeMapExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var mapUseTheme = true
    private var circleUseTheme = true
    private var cancellables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapInitOptions = MapInitOptions(styleURI: .streets)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)

        view.addSubview(mapView)
        view.backgroundColor = .skyBlue
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        try! mapView.mapboxMap.setColorTheme(ColorTheme(uiimage: UIImage(named: "monochrome_lut")!))
        addTestLayer()

        mapView.mapboxMap.addInteraction(TapInteraction { [weak self] _ in
            guard let self else { return false }

            self.mapUseTheme.toggle()
            if self.mapUseTheme {
                try! self.mapView.mapboxMap.setColorTheme(ColorTheme(uiimage: UIImage(named: "monochrome_lut")!))
            } else {
                try! self.mapView.mapboxMap.removeColorTheme()
            }
            return false
        })

        mapView.mapboxMap.addInteraction(TapInteraction(.layer("blue-layer")) { [weak self] _, _ in
            guard let self else { return true }

            self.circleUseTheme.toggle()
            self.addTestLayer(useTheme: self.circleUseTheme)
            return true
        })
    }

    private func addTestLayer(
        id: String = "blue-layer",
        radius: LocationDistance = 2,
        color: UIColor = .blue,
        coordinate: CLLocationCoordinate2D = .init(latitude: 40, longitude: -104),
        useTheme: Bool = true
    ) {
        let sourceId = "\(id)-source"
        try? mapView.mapboxMap.removeLayer(withId: id)
        try? mapView.mapboxMap.removeLayer(withId: "\(id)-border")
        try? mapView.mapboxMap.removeSource(withId: sourceId)

        mapView.mapboxMap.setMapStyleContent {
            FillLayer(id: id, source: sourceId)
                .fillColorUseTheme(useTheme ? .default : .none)
                .fillColor(color)
                .fillOpacity(0.4)
            LineLayer(id: "\(id)-border", source: sourceId)
                .lineColor(color.darker)
                .lineColorUseTheme(useTheme ? .default : .none)
                .lineOpacity(0.4)
                .lineWidth(2)
            GeoJSONSource(id: sourceId)
                .data(.geometry(.polygon(Polygon(center: coordinate, radius: radius * 1000000, vertices: 60))))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
