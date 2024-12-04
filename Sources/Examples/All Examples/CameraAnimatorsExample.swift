import UIKit
import MapboxMaps
import os

final class CameraAnimatorsExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    lazy var barButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(barButtonTap(_:)))

    // Coordinate in New York City
    let newYorkCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7128,
                                                                     longitude: -74.0060),
                                      zoom: 16,
                                      bearing: 12,
                                      pitch: 60.340)

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        animationState = .reset

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { _ in
            self.navigationItem.rightBarButtonItem = self.barButtonItem
            self.finish()
        }.store(in: &cancelables)
    }

    enum AnimationState {
        case reset
        case run
        case stop

        func next() -> AnimationState {
            switch self {
            case .reset: .run
            case .run:   .stop
            case .stop:  .reset
            }
        }

        var title: String {
            switch self {
            case .reset: "Reset"
            case .run:   "Run"
            case .stop:  "Stop"
            }
        }
    }

    var animationState: AnimationState = .reset {
        didSet {
            barButtonItem.title = animationState.next().title
            switch animationState {
            case .reset:
                // Center the map over New York City.
                mapView.mapboxMap.setCamera(to: newYorkCamera)
            case .run:
                startCameraAnimations()
            case .stop:
                mapView.camera.cancelAnimations()
            }
        }
    }

    @objc func barButtonTap(_ barButtonItem: UIBarButtonItem) {
        animationState = animationState.next()
    }

    // Start a chain of camera animations
    func startCameraAnimations() {
        os_log(.default, "Animating zoom from zoom to lvl 14")

        // Declare an animator that changes the map's bearing
        let bearingAnimator = mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.bearing.toValue = -45
        }

        bearingAnimator.addCompletion { position in
            os_log(.default, "All animations complete!")
            if position == .end {
                self.animationState = .stop
            }
        }
        bearingAnimator.onStarted.observe {
            os_log(.default, "Bearing animator has started")
        }.store(in: &cancelables)

        // Declare an animator that changes the map's pitch.
        let pitchAnimator = mapView.camera.makeAnimator(duration: 2, curve: .easeInOut) { (transition) in
            transition.pitch.toValue = 55
        }

        // Begin the bearing animation once the pitch animation has finished.
        pitchAnimator.addCompletion { _ in
            os_log(.default, "Animating camera bearing to 45 degrees")
            bearingAnimator.startAnimation()
        }

        // Declare an animator that changes the map's zoom level.
        let zoomAnimator = self.mapView.camera.makeAnimator(duration: 4, curve: .easeInOut) { (transition) in
            transition.zoom.toValue = 14
        }

        // Begin the pitch animation once the zoom animation has finished.
        zoomAnimator.addCompletion { _ in
            os_log(.default, "Animating camera pitch to 55 degrees")
            pitchAnimator.startAnimation()
        }

        // Begin the zoom animation.
        zoomAnimator.startAnimation()
    }
}
