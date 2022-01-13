#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import MapboxMaps

@objc(Custom2DPuckExample)
public class Custom2DPuckExample: UIViewController, ExampleProtocol {

    internal let toggleAccuracyRadiusButton: UIButton = UIButton(frame: .zero)
    internal var mapView: MapView!
    internal var showsAccuracyRing: Bool = false {
        didSet {
            syncPuckAndButton()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Setup and create button for toggling accuracy ring
        setupToggleShowAccuracyButton()

        // Granularly configure the location puck with a `Puck2DConfiguration`
        let configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        mapView.location.options.puckType = .puck2D(configuration)
        mapView.location.options.puckBearingSource = .course

        // Center map over the user's current location
        mapView.mapboxMap.onNext(.mapLoaded, handler: { [weak self] _ in
            guard let self = self else { return }

            if let currentLocation = self.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(center: currentLocation.coordinate, zoom: 20.0)
                self.mapView.camera.ease(to: cameraOptions, duration: 2.0)
            }
        })

        // Accuracy ring is only shown when zoom is greater than or equal to 18
        mapView.mapboxMap.onEvery(.cameraChanged, handler: { [weak self] _ in
            guard let self = self else { return }
            self.toggleAccuracyRadiusButton.isHidden = self.mapView.cameraState.zoom < 18.0
        })
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    @objc func showHideAccuracyRadius() {
        showsAccuracyRing.toggle()
    }

    func syncPuckAndButton() {
        // Update puck config
        var configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        configuration.showsAccuracyRing = showsAccuracyRing
        mapView.location.options.puckType = .puck2D(configuration)

        // Update button title
        let title: String = showsAccuracyRing ? "Disable Accuracy Radius" : "Enable Accuracy Radius"
        toggleAccuracyRadiusButton.setTitle(title, for: .normal)
    }

    private func setupToggleShowAccuracyButton() {
        // Styling
        toggleAccuracyRadiusButton.backgroundColor = .systemBlue
        toggleAccuracyRadiusButton.addTarget(self, action: #selector(showHideAccuracyRadius), for: .touchUpInside)
        toggleAccuracyRadiusButton.setTitleColor(.white, for: .normal)
        toggleAccuracyRadiusButton.isHidden = true
        syncPuckAndButton()
        toggleAccuracyRadiusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleAccuracyRadiusButton)

        // Constraints
        toggleAccuracyRadiusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        toggleAccuracyRadiusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        toggleAccuracyRadiusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 650.0).isActive = true
    }
}
