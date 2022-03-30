import Foundation
import MapboxMaps
import UIKit

@objc(AnimatedMarkerExample)
final class AnimatedMarkerExample: UIViewController, ExampleProtocol {
    enum Constants {
        static let markerIconId = "marker_icon"
        static let sourceId = "source-id"
        static let animationDuration: CFTimeInterval = 2
    }
    private var mapView: MapView!

    private var currentPosition = CLLocationCoordinate2D(latitude: 64.900932, longitude: -18.167040)

    private var animationStartTimestamp: CFTimeInterval = 0
    private var origin: CLLocationCoordinate2D!
    private var destination: CLLocationCoordinate2D!
    private var displayLink: CADisplayLink? {
        didSet { oldValue?.invalidate() }
    }

    deinit {
        displayLink?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: currentPosition, zoom: 5)
        let initOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in

            // Set up the example
            self?.setupExample()

            // The below line is used for internal testing purposes only.
            self?.finish()
        }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Tap anywhere on the map"

        mapView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        mapView.mapboxMap.loadStyleURI(.satelliteStreets)

        // add a tap gesture recognizer that will allow the marker to be animated
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePosition(_:))))
    }

    private func setupExample() {
        try? mapView.mapboxMap.style.addImage(UIImage(named: "red_marker")!, id: Constants.markerIconId, stretchX: [], stretchY: [])

        // Create a GeoJSON data source.
        var source = GeoJSONSource()
        source.data = .feature(Feature(geometry: .point(Point(currentPosition))))

        try? mapView.mapboxMap.style.addSource(source, id: Constants.sourceId)

        // Create a symbol layer
        var symbolLayer = SymbolLayer(id: "layer-id")
        symbolLayer.source = Constants.sourceId
        symbolLayer.iconImage = .constant(.name(Constants.markerIconId))
        symbolLayer.iconIgnorePlacement = .constant(true)
        symbolLayer.iconAllowOverlap = .constant(true)

        try? mapView.mapboxMap.style.addLayer(symbolLayer)
    }


    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        // break reference cycle when moving away from screen
        if parent == nil {
            displayLink = nil
        }
    }

    @objc private func updateFromDisplayLink(displayLink: CADisplayLink) {
        let animationProgress = (CACurrentMediaTime() - animationStartTimestamp) / Constants.animationDuration

        guard animationProgress <= 1 else {
            displayLink.invalidate()
            self.displayLink = nil
            return
        }

        // interpolate from origin to destination according to the animation progress
        let coordinate = CLLocationCoordinate2D(
            latitude: origin.latitude + animationProgress * (destination.latitude - origin.latitude),
            longitude: origin.longitude + animationProgress * (destination.longitude - origin.longitude)
        )

        // update current position
        self.currentPosition = coordinate

        // update source with the new marker location
        try? self.mapView.mapboxMap.style.updateGeoJSONSource(withId: Constants.sourceId,
                                                              geoJSON: .feature(Feature(geometry: .point(Point(coordinate)))))

    }

    @objc private func updatePosition(_ sender: UITapGestureRecognizer) {
        let newCoordinate = mapView.mapboxMap.coordinate(for: sender.location(in: mapView))

        // save marker's origin and destination to interpolate between them during the animation
        destination = newCoordinate
        origin = currentPosition
        animationStartTimestamp = CACurrentMediaTime()

        // add display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateFromDisplayLink(displayLink:)))
        displayLink?.add(to: .current, forMode: .common)
    }
}
