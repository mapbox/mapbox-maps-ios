import UIKit
import MapboxMaps

@objc(LocationComponent)
public class LocationComponent: UIViewController, ExampleProtocol {

    internal let toggleAccuracyRadiusButton: UIButton = UIButton(frame: .zero)
    internal var mapView: MapView!
    var configuration = Puck2DConfiguration(topImage: UIImage(named: "star"))

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.style.uri = .dark
        view.addSubview(mapView)

        customizeMapButton()

        // Granularly configure the location puck with a `Puck2DConfiguration`
        mapView.location.options.puckType = .puck2D(configuration)
        mapView.location.options.puckBearingSource = .course

        // Center map over the user's current location
        mapView.mapboxMap.onNext(event: .mapLoaded, handler: { [weak self] _ in
            guard let self = self else { return }

            if let currentLocation = self.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(center: currentLocation.coordinate, zoom: 20.0)
                self.mapView.camera.ease(to: cameraOptions, duration: 2.0)
            }
        })

        // Accuracy ring is only shown when zoom is greater than or equal to 18
        mapView.mapboxMap.onEvery(event: .cameraChanged, handler: { [weak self] _ in
            guard let self = self else { return }
            self.toggleAccuracyRadiusButton.isHidden = self.mapView.cameraState.zoom < 18.0
        })
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    private func customizeMapButton() {
        // Set up layer postion change button
        let button = UIButton(type: .system)
        button.setTitle("Customize map", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(changeMapOptions(sender:)), for: .touchUpInside)
        view.addSubview(button)

        // Set button location
        let horizontalConstraint = button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        let verticalConstraint = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    func toggleMapStyle() {
        let styleURL = (mapView.mapboxMap.style.uri == .dark) ? StyleURI.light : StyleURI.dark
        mapView.mapboxMap.style.uri = styleURL
    }

    func togglePuckStyle() {
        if configuration.topImage == UIImage(named: "star") {
            configuration.topImage = .none
        } else {
            configuration.topImage = UIImage(named: "star")
        }
        mapView.location.options.puckType = .puck2D(configuration)
    }

    func toggleProjection() {
        let projection = (mapView.mapboxMap.style.projection == StyleProjection(name: .mercator)) ? StyleProjection(name: .globe) : StyleProjection(name: .mercator)
        do {
            try mapView.mapboxMap.style.setProjection(projection)
        } catch {
            print(error)
        }
    }

    func toggleLocationComponent() {
        if mapView.location.options.puckType == .none {
            mapView.location.options.puckType = .puck2D(configuration)
        } else {
            mapView.location.options.puckType = .none
        }
    }

    func toggleBearing() {
        var testTrue = Puck2DConfiguration.makeDefault(showBearing: true)
        var testFalse = Puck2DConfiguration.makeDefault(showBearing: false)
//      let bearing = Puck2DConfiguration.makeDefault(showBearing: showsBearingImage)
        if mapView.location.options.puckBearingEnabled {
            mapView.location.options.puckType = .puck2D(testFalse)
            mapView.location.options.puckBearingEnabled = false
        } else {
            mapView.location.options.puckType = .puck2D(testTrue)
        }
    }

    func toggleAccuracyRing() {
        if configuration.showsAccuracyRing {
            configuration.showsAccuracyRing = false
        } else {
            configuration.showsAccuracyRing = true
            configuration.accuracyRingColor = UIColor.skyBlue
            configuration.accuracyRingBorderColor = UIColor.lightGray
        }
        mapView.location.options.puckType = .puck2D(configuration)
    }

    @objc public func changeMapOptions(sender: UIButton) {
        let alert = UIAlertController(title: "Toggle Custom Options",
                                      message: "Please select an options to toggle.",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Toggle Puck Style", style: .default, handler: { [weak self] _ in
            self!.togglePuckStyle()
        }))

        alert.addAction(UIAlertAction(title: "Toggle Map Style", style: .default, handler: { [weak self] _ in
            self!.toggleMapStyle()
        }))

        alert.addAction(UIAlertAction(title: "Toggle Projection", style: .default, handler: { [weak self] _ in
            self!.toggleProjection()
        }))

        alert.addAction(UIAlertAction(title: "Toggle location component visibility", style: .default, handler: { [weak self] _ in
            self!.toggleLocationComponent()
        }))

        alert.addAction(UIAlertAction(title: "Show bearing", style: .default, handler: { [weak self] _ in
            self!.toggleBearing()
        }))

        alert.addAction(UIAlertAction(title: "Show accuracy ring", style: .default, handler: { [weak self] _ in
            self!.toggleAccuracyRing()
        }))

        alert.addAction(UIAlertAction(title: "Bearing source", style: .default, handler: { [weak self] _ in

        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
