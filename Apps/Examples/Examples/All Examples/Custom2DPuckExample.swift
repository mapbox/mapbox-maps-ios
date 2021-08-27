import UIKit
import MapboxMaps

@objc(Custom2DPuckExample)
public class Custom2DPuckExample: UIViewController, ExampleProtocol {

    internal var toggleAccuracyRadiusButton: UIButton?
    internal var mapView: MapView!
    internal var shouldToggleAccuracyRadius: Bool = true

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Granularly configure the location puck with a `Puck2DConfiguration`
        let configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        mapView.location.options.puckType = .puck2D(configuration)
        mapView.location.options.puckBearingSource = .course

        // Center map over the user's current location
        mapView.mapboxMap.onNext(.mapLoaded, handler: { [weak self] _ in
            guard let self = self else { return }

            if let currentLocation = self.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(center: currentLocation.coordinate, zoom: 17.0)
                self.mapView.camera.ease(to: cameraOptions, duration: 2.0)
            }
        })

        // Setup a toggle button to show how to toggle the accuracy radius
        mapView.mapboxMap.onEvery(.cameraChanged, handler: { [weak self] _ in
            guard let self = self else { return }

            if self.mapView.cameraState.zoom >= 17.0 {
                if let button = self.toggleAccuracyRadiusButton {
                    button.isHidden = false
                } else {
                    self.setupToggleShowAccuracyButton()
                }
            } else {
                if let button = self.toggleAccuracyRadiusButton {
                    button.isHidden = true
                }
            }
        })
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    @objc func showHideAccuracyRadius() {
        var configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))
        if shouldToggleAccuracyRadius {
            configuration.showAccuracyRadius = true
            shouldToggleAccuracyRadius = false
            self.toggleAccuracyRadiusButton!.setTitle("Disable Accuracy Radius", for: .normal)
        } else {
            configuration.showAccuracyRadius = false
            shouldToggleAccuracyRadius = true
            self.toggleAccuracyRadiusButton!.setTitle("Enable Accuracy Radius", for: .normal)
        }

        mapView.location.options.puckType = .puck2D(configuration)
    }

    private func setupToggleShowAccuracyButton() {
        // Button setup
        let button = UIButton(frame: CGRect.zero)
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(self.showHideAccuracyRadius), for: .touchUpInside)
        button.setTitle("Enable Accuracy Radius", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)

        // Constraints
        button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 650.0).isActive = true

        self.toggleAccuracyRadiusButton = button
    }
}
