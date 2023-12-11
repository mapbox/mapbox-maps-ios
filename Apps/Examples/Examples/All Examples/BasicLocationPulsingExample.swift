import Foundation
import UIKit
import MapboxMaps

/// This example shows a basic usage of sonar-like pulsing circle animation around the 2D puck.
final class BasicLocationPulsingExample: UIViewController, ExampleProtocol {
    private var cancelables = Set<AnyCancelable>()

    private lazy var mapView: MapView = {
        let view = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .streets))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        var puckConfiguration = Puck2DConfiguration.makeDefault()
        puckConfiguration.pulsing = .default
        mapView.location.options.puckType = .puck2D(puckConfiguration)

        mapView.location.onLocationChange.observeNext { [weak mapView] newLocation in
            guard let mapView, let location = newLocation.last else { return }
            mapView.mapboxMap.setCamera(to: .init(center: location.coordinate, zoom: 18))
        }.store(in: &cancelables)

        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action)
            updateMenu()
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(showOptions)
            )
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // The below line is used for internal testing purposes only.
        finish()
    }

    private func enablePulsingWithConstantRadius() {
        var puckConfiguration = Puck2DConfiguration.makeDefault()
        puckConfiguration.pulsing = .default
        mapView.location.options.puckType = .puck2D(puckConfiguration)
    }

    private func enablePulsingWithAccuracyRadius() {
        var puckConfiguration = Puck2DConfiguration.makeDefault()
        puckConfiguration.pulsing = .default
        puckConfiguration.pulsing?.radius = .accuracy
        mapView.location.options.puckType = .puck2D(puckConfiguration)
    }

    private func enableStaticAccuracyCircle() {
        var puckConfiguration = Puck2DConfiguration.makeDefault()
        puckConfiguration.showsAccuracyRing = true
        puckConfiguration.accuracyRingColor = Puck2DConfiguration.Pulsing.default.color.withAlphaComponent(0.3)
        mapView.location.options.puckType = .puck2D(puckConfiguration)
    }

    private func disablePulsing() {
        mapView.location.options.puckType = .puck2D(.makeDefault())
    }

    @objc private func showOptions() {
        let constantPulseAction = UIAlertAction(title: "Pulse with constant radius", style: .default) { _ in
            self.enablePulsingWithConstantRadius()
        }
        let accuracyPulseAction = UIAlertAction(title: "Pulse with accuracy radius", style: .default) { _ in
            self.enablePulsingWithAccuracyRadius()
        }
        let stopPulseAction = UIAlertAction(title: "None", style: .default) { _ in
            self.disablePulsing()
        }

        let staticAccuracyRingAction = UIAlertAction(title: "Static with accuracy radius", style: .default) { _ in
            self.enableStaticAccuracyCircle()
        }

        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel)

        let controller = UIAlertController(title: "Puck circle", message: nil, preferredStyle: .actionSheet)
        controller.modalPresentationStyle = .popover
        if #available(iOS 16.0, *) {
            controller.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            controller.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        [constantPulseAction, accuracyPulseAction, staticAccuracyRingAction, stopPulseAction, cancelAction]
            .forEach(controller.addAction)

        present(controller, animated: true)
    }

    @available(iOS 14.0, *)
    private func updateMenu() {
        let state = mapView.location.options.puckType.map { type -> PuckCircle? in
            if case PuckType.puck2D(let config) = type {
                return PuckCircle(config: config)
            }
            return nil
        }

        let constantPulseAction = UIAction(title: "Pulse with constant radius",
                                           state: state == .pulseConstant ? .on : .off) { [weak self] _ in
            self?.enablePulsingWithConstantRadius()
            self?.updateMenu()

        }
        let accuracyPulseAction = UIAction(title: "Pulse with accuracy radius",
                                           state: state == .pulseAccuracy ? .on : .off) { [weak self] _ in
            self?.enablePulsingWithAccuracyRadius()
            self?.updateMenu()
        }
        let disablePulseAction = UIAction(title: "None", state: state == .disabled ? .on : .off) { [weak self] _ in
            self?.disablePulsing()
            self?.updateMenu()
        }
        let staticAccuracyRingAction = UIAction(title: "Static with accuracy radius",
                                                state: state == .static ? .on : .off) { [weak self] _ in
            self?.enableStaticAccuracyCircle()
            self?.updateMenu()
        }

        let menu = UIMenu(
            title: "Puck circle",
            children: [constantPulseAction, accuracyPulseAction, staticAccuracyRingAction, disablePulseAction]
        )

        navigationItem.rightBarButtonItem?.menu = menu
    }
}

private enum PuckCircle {
    case pulseConstant
    case pulseAccuracy
    case `static`
    case disabled

    init(config: Puck2DConfiguration) {
        if case .constant = config.pulsing?.radius {
            self = .pulseConstant
        } else if config.pulsing?.radius == .accuracy {
            self = .pulseAccuracy
        } else if config.showsAccuracyRing {
            self = .static
        } else {
            self = .disabled
        }
    }
}
