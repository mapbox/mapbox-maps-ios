import Foundation
import UIKit
import MapboxMaps
import CoreLocation

final class GlobeFlyToExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var isAtStart = true
    private var instuctionLabel = UILabel(frame: CGRect.zero)
    private var cancelables = Set<AnyCancelable>()

    private var cameraStart = CameraOptions(
        center: CLLocationCoordinate2D(latitude: 36, longitude: 80),
        zoom: 1.0,
        bearing: 0,
        pitch: 0)

    private var cameraEnd = CameraOptions(
        center: CLLocationCoordinate2D(latitude: 46.58842, longitude: 8.11862),
        zoom: 12.5,
        bearing: 130.0,
        pitch: 75.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .satelliteStreets))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.setCamera(to: .init(center: CLLocationCoordinate2D(latitude: 40, longitude: -78), zoom: 1.0))
        try! self.mapView.mapboxMap.setProjection(StyleProjection(name: .globe))

        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            try! self.mapView.mapboxMap.setAtmosphere(Atmosphere())
            self.addTerrain()
            self.finish()
        }.store(in: &cancelables)

        mapView.mapboxMap.addInteraction(TapInteraction { [weak self] _ in
            self?.animateCameraOnClick()
            return true
        })

        instuctionLabel.text = "Tap anywhere on the map"
        instuctionLabel.textColor = UIColor.black
        instuctionLabel.textAlignment = .center
        instuctionLabel.layer.backgroundColor = UIColor.gray.cgColor
        instuctionLabel.layer.cornerRadius = 20.0
        instuctionLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapView)
        view.addSubview(instuctionLabel)
        installConstraints()
    }

    func installConstraints() {
        let safeView = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            instuctionLabel.topAnchor.constraint(equalTo: safeView.bottomAnchor, constant: -70),
            instuctionLabel.bottomAnchor.constraint(equalTo: safeView.bottomAnchor, constant: -30),
            instuctionLabel.leadingAnchor.constraint(equalTo: safeView.leadingAnchor, constant: 70),
            instuctionLabel.trailingAnchor.constraint(equalTo: safeView.trailingAnchor, constant: -70)
        ])

    }

    func addTerrain() {
        var demSource = RasterDemSource(id: "mapbox-dem")
        demSource.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
        // Setting the `tileSize` to 514 provides better performance and adds padding around the outside
        // of the tiles.
        demSource.tileSize = 514
        demSource.maxzoom = 14.0
        try! mapView.mapboxMap.addSource(demSource)

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .constant(1.5)

        try! mapView.mapboxMap.setTerrain(terrain)
    }

    private func animateCameraOnClick() {
        instuctionLabel.isHidden = true
        var target = CameraOptions()
        if isAtStart {
            target = self.cameraEnd
        } else {
            target = self.cameraStart
        }
        isAtStart = !isAtStart
        mapView.camera.fly(to: target, duration: 12)

    }
}
