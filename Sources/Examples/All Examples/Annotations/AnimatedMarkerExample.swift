import Foundation
import MapboxMaps
import UIKit

final class AnimatedMarkerExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var currentPosition = CLLocationCoordinate2D(latitude: 64.900932, longitude: -18.167040)
    private var animationStartTimestamp: CFTimeInterval = 0
    private var origin: CLLocationCoordinate2D!
    private var destination: CLLocationCoordinate2D!
    private var displayLink: CADisplayLink? {
        didSet { oldValue?.invalidate() }
    }
    private var cancelables = Set<AnyCancelable>()

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
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in

            // Set up the example
            self?.setupExample()

            // The below line is used for internal testing purposes only.
            self?.finish()
        }.store(in: &cancelables)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Tap anywhere on the map"

        mapView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        mapView.mapboxMap.loadStyle(.satelliteStreets)

        // add a tap gesture handler that will allow the marker to be animated
        mapView.mapboxMap.addInteraction(TapInteraction { [weak self] context in
            self?.updatePosition(newCoordinate: context.coordinate)
            return true
        })
    }

    private func setupExample() {
        try? mapView.mapboxMap.addImage(UIImage(named: "dest-pin")!, id: Constants.markerIconId)

        // Create a GeoJSON data source.
        var source = GeoJSONSource(id: Constants.sourceId)
        source.data = .feature(Feature(geometry: Point(currentPosition)))

        try? mapView.mapboxMap.addSource(source)

        // Create a symbol layer
        var symbolLayer = SymbolLayer(id: "layer-id", source: Constants.sourceId)
        symbolLayer.iconImage = .constant(.name(Constants.markerIconId))
        symbolLayer.iconIgnorePlacement = .constant(true)
        symbolLayer.iconAllowOverlap = .constant(true)
        symbolLayer.iconOffset = .constant([0, 12])

        try? mapView.mapboxMap.addLayer(symbolLayer)
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
        self.mapView.mapboxMap.updateGeoJSONSource(withId: Constants.sourceId,
                                                              geoJSON: .feature(Feature(geometry: Point(coordinate))))

    }

    private func updatePosition(newCoordinate: CLLocationCoordinate2D) {
        // save marker's origin and destination to interpolate between them during the animation
        destination = newCoordinate
        origin = currentPosition
        animationStartTimestamp = CACurrentMediaTime()

        // add display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateFromDisplayLink(displayLink:)))
        displayLink?.add(to: .current, forMode: .common)
    }
}

extension AnimatedMarkerExample {
    enum Constants {
        static let markerIconId = "marker_icon"
        static let sourceId = "source-id"
        static let animationDuration: CFTimeInterval = 2
    }
}
