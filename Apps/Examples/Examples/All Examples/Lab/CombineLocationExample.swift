import UIKit
import MapboxMaps
import Combine
import Turf

/// This examples shows how to use Combine framework to drive the Puck's location and heading.
@available(iOS 13.0, *)
final class CombineLocationExample: UIViewController, ExampleProtocol {
    @Published
    private var location = Location(coordinate: CLLocationCoordinate2D(latitude: 60.17195694011002, longitude: 24.945389069265598))
    @Published
    private var heading = Heading(direction: 0, accuracy: 0)

    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Set the custom location & heading providers
        mapView.location.override(
            locationProvider: $location.map { [$0] }.eraseToSignal(),
            headingProvider: $heading.eraseToSignal())

        // Enable the location puck
        mapView.location.options = LocationOptions(
            puckType: .puck2D(.makeDefault(showBearing: true)),
            puckBearing: .heading,
            puckBearingEnabled: true
        )

        // Set up the follow-puck viewport, so camera will always be focused on the puck
        mapView.viewport.transition(
            to: mapView.viewport.makeFollowPuckViewportState(options: .init(zoom: 16, bearing: .constant(0), pitch: 0)),
            transition: mapView.viewport.makeImmediateViewportTransition())

        mapView.gestures.singleTapGestureRecognizer.addTarget(self, action: #selector(onTap))

        let guideLabel = UILabel()
        guideLabel.text = "Tap anywhere on the map to place the puck"
        guideLabel.backgroundColor = .systemBackground
        guideLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(guideLabel)
        NSLayoutConstraint.activate([
            guideLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func onTap(_ gesture: UIGestureRecognizer) {
        // Place the puck to the tap location
        let point = gesture.location(in: mapView)
        let coordinate = mapView.mapboxMap.coordinate(for: point)

        // Calculating the angle between the current coordinate, and the target coordinate
        let headingDirection = location.coordinate.direction(to: coordinate)

        location = Location(coordinate: coordinate)
        heading = Heading(direction: headingDirection, accuracy: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
