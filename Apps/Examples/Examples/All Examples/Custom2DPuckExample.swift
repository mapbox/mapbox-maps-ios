import UIKit
import MapboxMaps

final class Custom2DPuckExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()
    private var mapView: MapView!
    private var puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)

    private var showsPuck: PuckVisibility = .isVisible {
        didSet {
            updatePuckUI()
        }
    }

    private var puckImage: PuckImage = .blueDot {
        didSet {
            updatePuckUI()
        }
    }

    private var showsBearing: PuckBearingVisibility = .isVisible {
        didSet {
            updatePuckUI()
        }
    }

    private var showsAccuracyRing: PuckAccuracyRingVisibility = .isHidden {
        didSet {
            updatePuckUI()
        }
    }

    private var puckBearing: PuckBearing = .heading {
        didSet {
            mapView.location.options.puckBearing = puckBearing
        }
    }

    private var style: Style = .dark {
        didSet {
            mapView.mapboxMap.styleURI = style.styleURL
        }
    }

    private var projection: StyleProjectionName = .mercator {
        didSet {
            updateProjection()
        }
    }

    private var puckOpacity: PuckOpaticy = .opaque {
        didSet {
            updatePuckUI()
        }
    }

    private enum PuckOpaticy: Double {
        case opaque = 1
        case semiTransparent = 0.5

        mutating func toggle() {
            self = self == .opaque ? .semiTransparent : .opaque
        }
    }

    private enum PuckVisibility {
        case isVisible
        case isHidden

        var isVisible: Bool {
            switch self {
            case .isVisible:
                return true
            case .isHidden:
                return false
            }
        }

        mutating func toggle() {
            self = self == .isVisible ? .isHidden : .isVisible
        }
    }

    private enum PuckImage: CaseIterable {
        case dash
        case jpegSquare
        case blueDot

        var image: UIImage? {
            switch self {
            case .dash:
                return UIImage(named: "dash-puck")
            case .jpegSquare:
                return UIImage(named: "jpeg-image")
            case .blueDot:
                return .none
            }
        }

        var usesDefaultShadowImage: Bool {
            self == .blueDot
        }

        mutating func toggle() {
            var idx = Self.allCases.firstIndex(of: self)! + 1
            if idx == Self.allCases.count {
                idx = 0
            }
            self = Self.allCases[idx]
        }
    }

    private enum PuckBearingVisibility {
        case isVisible
        case isHidden

        var isVisible: Bool {
            switch self {
            case .isVisible:
                return true
            case .isHidden:
                return false
            }
        }

        mutating func toggle() {
            self = self == .isVisible ? .isHidden : .isVisible
        }
    }

    private enum PuckAccuracyRingVisibility {
        case isVisible
        case isHidden

        var isVisible: Bool {
            switch self {
            case .isVisible:
                return true
            case .isHidden:
                return false
            }
        }

        mutating func toggle() {
            self = self == .isVisible ? .isHidden : .isVisible
        }
    }

    private enum Style {
        case light
        case dark

        var styleURL: StyleURI {
            switch self {
            case .light:
                return StyleURI.light
            case .dark:
                return StyleURI.dark
            }
        }

        mutating func toggle() {
            self = self == .light ? .dark : .light
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.26301831966747, longitude: -121.97647612483807), zoom: 6)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        addCustomizePuckButton()

        // Granularly configure the location puck with a `Puck2DConfiguration`
        puckConfiguration.layerPosition = .default
        mapView.location.options.puckType = .puck2D(puckConfiguration)
        mapView.location.options.puckBearing = .heading
        mapView.location.options.puckBearingEnabled = true

        // Center map over the user's current location
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }

            if let currentLocation = self.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(center: currentLocation.coordinate, zoom: 16.0)
                self.mapView.camera.ease(to: cameraOptions, duration: 2.0)
            }
        }.store(in: &cancelables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    private func addCustomizePuckButton() {
        // Set up button to change the puck options
        let button = UIButton(type: .system)
        button.setTitle("Customize puck", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(changePuckOptions(sender:)), for: .touchUpInside)
        view.addSubview(button)

        // Set button location
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func changePuckOptions(sender: UIButton) {
        let alert = UIAlertController(title: "Toggle Puck Options",
                                      message: "Select an options to toggle.",
                                      preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = sender

        alert.addAction(UIAlertAction(title: "Toggle Puck visibility", style: .default) { _ in
            self.showsPuck.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle Puck opacity", style: .default) { _ in
            self.puckOpacity.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle Puck image", style: .default) { _ in
            self.puckImage.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle bearing visibility", style: .default) { _ in
            self.showsBearing.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle accuracy ring", style: .default) { _ in
            self.showsAccuracyRing.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle bearing source", style: .default) { _ in
            self.puckBearing.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle Map Style", style: .default) { _ in
            self.style.toggle()
        })

        alert.addAction(UIAlertAction(title: "Toggle Projection", style: .default) { _ in
            self.projection.toggle()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func updatePuckUI() {
        puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: showsBearing.isVisible)
        puckConfiguration.showsAccuracyRing = showsAccuracyRing.isVisible
        puckConfiguration.topImage = puckImage.image
        puckConfiguration.layerPosition = .default
        if !puckImage.usesDefaultShadowImage {
            puckConfiguration.shadowImage = nil
        }
        puckConfiguration.opacity = puckOpacity.rawValue
        switch showsPuck {
        case .isVisible:
            mapView.location.options.puckType = .puck2D(puckConfiguration)
        default:
            mapView.location.options.puckType = .none
        }
    }

    func updateProjection() {
        do {
            try mapView.mapboxMap.setProjection(StyleProjection(name: projection))
        } catch {
            print(error)
        }
    }
}

extension PuckBearing {
    mutating func toggle() {
        self = self == .heading ? .course : .heading
    }
}

extension StyleProjectionName {
    mutating func toggle() {
        self = self == .mercator ? .globe : .mercator
    }
}
