import UIKit
import MapboxMaps

final class CarPlayRootVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .skyBlue
    }

    private weak var currentChild: UIViewController?

    func updateCarPlayViewController(_ controller: UIViewController) {
        if let existing = currentChild {
            existing.willMove(toParent: nil)
            existing.view.removeFromSuperview()
            existing.removeFromParent()
        }
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.didMove(toParent: self)
        currentChild = controller
    }
}

final class CarPlayViewController: UIViewController {
    lazy var mapView: MapView = {
        let mapOptions = MapOptions(pixelRatio: UIScreen.screens[1].nativeScale)

        let mapInitOptions = MapInitOptions(mapOptions: mapOptions, cameraOptions: CameraOptions(
            center: .helsinki,
            zoom: 15.0
        ))

        return MapView(frame: UIScreen.screens[1].bounds, mapInitOptions: mapInitOptions)
    }()

    static let shared = CarPlayViewController()

    enum AnimationState {
        case stopped
        case running
    }

    private var animationState: AnimationState = .stopped {
        didSet {
            guard oldValue != animationState else { return }

            switch animationState {
            case .stopped:
                animationCancellable?.cancel()
            case .running:
                startAnimation()
            }
        }
    }
    var animationCancellable: Cancelable?

    func play() {
        animationState = .running
    }

    func stop() {
        animationState = .stopped
    }

    private func startAnimation() {
        let seattleСamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 47.602730,
                                                                         longitude: -122.338158),
                                          zoom: 15.0)
        let berlinCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 52.517794,
                                                                        longitude: 13.408331),
                                         zoom: 15.0)
        let animationDuration = 20.0

        func animateToBerlin(position: UIViewAnimatingPosition) {
            guard animationState == .running else { return }
            animationCancellable = mapView.camera.fly(to: berlinCamera, duration: animationDuration, completion: animateToSeattle(position:))
        }

        func animateToSeattle(position: UIViewAnimatingPosition) {
            guard animationState == .running else { return }
            animationCancellable = mapView.camera.fly(to: seattleСamera, duration: animationDuration, completion: animateToBerlin(position:))
        }

        animateToBerlin(position: .start)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.ornaments.options.attributionButton.position = .bottomRight

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

final class CarPlayNavViewController: UIViewController {
    lazy var mapView: MapView = {
        let mapOptions = MapOptions(pixelRatio: UIScreen.screens[1].nativeScale)

        let mapInitOptions = MapInitOptions(mapOptions: mapOptions, cameraOptions: CameraOptions(
            center: .helsinki,
            zoom: 17.0,
            pitch: 45
        ))

        return MapView(frame: UIScreen.screens[1].bounds, mapInitOptions: mapInitOptions)
    }()

    static let shared = CarPlayNavViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.ornaments.options.scaleBar.visibility = .hidden
        mapView.ornaments.options.attributionButton.position = .bottomRight

        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
