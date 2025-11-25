import UIKit
import SwiftUI
import MapboxMaps

final class TrackingModeExample: UIViewController, ExampleProtocol {
    private var locationTrackingCancellation: AnyCancelable?

    private var mapView: MapView!
    private var style: Style = .standard {
        didSet {
            mapView.mapboxMap.styleURI = style.uri
        }
    }
    private var showsBearingImage: Bool = false {
        didSet {
            let configuration = Puck2DConfiguration.makeDefault(showBearing: showsBearingImage)
            mapView.location.options.puckType = .puck2D(configuration)
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Set initial camera settings
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 37.26301831966747, longitude: -121.97647612483807), zoom: 10)
        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: style.uri)

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        setupSettingsButton()

        // Add user position icon to the map with location indicator layer
        mapView.location.options.puckType = .puck2D()
        mapView.location.options.puckBearingEnabled = true

        mapView.gestures.delegate = self

        // Update the camera's centerCoordinate when a locationUpdate is received.
        startTracking()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    private func setupSettingsButton() {
        let buttonView = SettingsButtonView(onTap: openSettings)
        let hostingController = UIHostingController(rootView: buttonView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
        ])
    }

    private func openSettings() {
        let controlsSection = SettingsSection(
            title: "Controls",
            controls: [
                .toggle(
                    title: "Track user location",
                    isOn: Binding(
                        get: { [weak self] in self?.locationTrackingCancellation != nil },
                        set: { [weak self] in $0 ? self?.startTracking() : self?.stopTracking() }
                    )
                ),
                .toggle(
                    title: "Show bearing image",
                    isOn: Binding(
                        get: { [weak self] in self?.showsBearingImage ?? false },
                        set: { [weak self] in self?.showsBearingImage = $0 }
                    )
                ),
                .segmentedPicker(
                    title: "Map style",
                    options: Style.allCases.map(\.name),
                    selection: Binding(
                        get: { [weak self] in self?.style.rawValue ?? 0 },
                        set: { [weak self] newValue in
                            self?.style = Style(rawValue: newValue) ?? .standard
                        }
                    )
                )
            ]
        )

        let docsSection = SettingsSection(
            title: "Docs",
            controls: [
                .link(
                    title: "Tracking mode example",
                    url: URL(string: "https://docs.mapbox.com/ios/maps/examples/tracking-mode/")!
                )
            ]
        )

        let settingsView = SettingsSheet(sections: [controlsSection, docsSection])
        let hostingController = UIHostingController(rootView: settingsView)

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(hostingController, animated: true)
    }

    private func startTracking() {
        locationTrackingCancellation = mapView.location.onLocationChange.observe { [weak mapView] newLocation in
            guard let location = newLocation.last, let mapView else { return }
            mapView.camera.ease(
                to: CameraOptions(center: location.coordinate, zoom: 15),
                duration: 1.3)
        }
    }

    private func stopTracking() {
        locationTrackingCancellation = nil
    }
}

extension TrackingModeExample: GestureManagerDelegate {
    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        stopTracking()
    }

    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {}

    public func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {}
}

extension TrackingModeExample {
    private enum Style: Int, CaseIterable {
        case standard
        case light
        case satelliteStreets
        case customUri

        var name: String {
            switch self {
            case .standard:
                return "Standard"
            case .light:
                return "Light"
            case .satelliteStreets:
                return "Satellite"
            case .customUri:
                return "Custom"
            }
        }

        var uri: StyleURI {
            switch self {
            case .standard:
                return .standard
            case .light:
                return .light
            case .satelliteStreets:
                return .satelliteStreets
            case .customUri:
                let localStyleURL = Bundle.main.url(forResource: "blueprint_style", withExtension: "json")!
                return .init(url: localStyleURL)!
            }
        }
    }
}

// MARK: - SwiftUI Settings Button
private struct SettingsButtonView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "slider.horizontal.3")
        }
        .buttonStyle(MapFloatingButtonStyle())
    }
}
