import UIKit
import MapboxMaps

@objc(CustomPuckExample)
public class CustomPuckExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var puckConfiguration = Puck2DConfiguration.makeDefault(showBearing: true)

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.style.uri = .dark
        view.addSubview(mapView)

        customizePuckButton()

        // Granularly configure the location puck with a `Puck2DConfiguration`
        mapView.location.options.puckType = .puck2D(puckConfiguration)
        mapView.location.options.puckBearingSource = .course

        // Center map over the user's current location
        mapView.mapboxMap.onNext(event: .mapLoaded, handler: { [weak self] _ in
            guard let self = self else { return }

            if let currentLocation = self.mapView.location.latestLocation {
                let cameraOptions = CameraOptions(center: currentLocation.coordinate, zoom: 20.0)
                self.mapView.camera.ease(to: cameraOptions, duration: 2.0)
            }
        })
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    private func customizePuckButton() {
        // Set up button to change the puck options
        let button = UIButton(type: .system)
        button.setTitle("Customize puck", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(changePuckOptions(sender:)), for: .touchUpInside)
        view.addSubview(button)

        // Set button location
        let horizontalConstraint = button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        let verticalConstraint = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    func toggePuckVisibility() {
        if mapView.location.options.puckType == .none {
            mapView.location.options.puckType = .puck2D(puckConfiguration)
        } else {
            mapView.location.options.puckType = .none
        }
    }

    func togglePuckStyle() {
        if puckConfiguration.topImage == UIImage(named: "star") {
            puckConfiguration.topImage = .none
        } else {
            puckConfiguration.topImage = UIImage(named: "star")
        }
        mapView.location.options.puckType = .puck2D(puckConfiguration)
    }

    func toggleBearing() {
        var newPuck = Puck2DConfiguration()

        if mapView.location.options.puckBearingEnabled {
            newPuck = Puck2DConfiguration.makeDefault(showBearing: false)
            mapView.location.options.puckBearingEnabled = false
        } else {
            newPuck = Puck2DConfiguration.makeDefault(showBearing: true)
            mapView.location.options.puckBearingEnabled = true
        }

        newPuck.topImage = puckConfiguration.topImage
        newPuck.showsAccuracyRing = puckConfiguration.showsAccuracyRing
        mapView.location.options.puckType = .puck2D(newPuck)
        puckConfiguration = newPuck
    }

    func toggleAccuracyRing() {
        if puckConfiguration.showsAccuracyRing {
            puckConfiguration.showsAccuracyRing = false
        } else {
            puckConfiguration.showsAccuracyRing = true
        }
        mapView.location.options.puckType = .puck2D(puckConfiguration)
    }

    func toggleBearingSource() {
        let bearingSource = (mapView.location.options.puckBearingSource == .course) ? PuckBearingSource.heading : PuckBearingSource.course
        mapView.location.options.puckBearingSource = bearingSource
    }

    func toggleMapStyle() {
        let styleURL = (mapView.mapboxMap.style.uri == .dark) ? StyleURI.light : StyleURI.dark
        mapView.mapboxMap.style.uri = styleURL
    }

    func toggleProjection() {
        let projection = (mapView.mapboxMap.style.projection == StyleProjection(name: .mercator)) ? StyleProjection(name: .globe) : StyleProjection(name: .mercator)
        do {
            try mapView.mapboxMap.style.setProjection(projection)
        } catch {
            print(error)
        }
    }

    @objc public func changePuckOptions(sender: UIButton) {
        let alert = UIAlertController(title: "Toggle Puck Options",
                                      message: "Select an options to toggle.",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Toggle Puck visibility", style: .default, handler: { [weak self] _ in
            self!.toggePuckVisibility()
        }))

        alert.addAction(UIAlertAction(title: "Toggle Puck style", style: .default, handler: { [weak self] _ in
            self!.togglePuckStyle()
        }))

        alert.addAction(UIAlertAction(title: "Toggle bearing", style: .default, handler: { [weak self] _ in
            self!.toggleBearing()
        }))

        alert.addAction(UIAlertAction(title: "Toggle accuracy ring", style: .default, handler: { [weak self] _ in
            self!.toggleAccuracyRing()
        }))

        alert.addAction(UIAlertAction(title: "Toggle bearing source", style: .default, handler: { [weak self] _ in
            self!.toggleBearingSource()
        }))

        alert.addAction(UIAlertAction(title: "Toggle Map Style", style: .default, handler: { [weak self] _ in
            self!.toggleMapStyle()
        }))

        alert.addAction(UIAlertAction(title: "Toggle Projection", style: .default, handler: { [weak self] _ in
            self!.toggleProjection()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
}
