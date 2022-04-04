import Foundation
import MapboxMaps

@objc(BuildingExtrusionsExample)
public class BuildingExtrusionsExample: UIViewController, ExampleProtocol {

    private lazy var lightPositionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
        } else {
            button.setTitle("Position", for: .normal)
        }
        button.addTarget(self, action: #selector(lightPositionButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var lightColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "paintbrush.fill"), for: .normal)
        } else {
            button.setTitle("Color", for: .normal)
        }
        button.addTarget(self, action: #selector(lightColorButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    internal var mapView: MapView!

    private var light = Light()

    override public func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.styleLoaded) { _ in
            self.setupExample()
        }

        view.addSubview(lightPositionButton)
        view.addSubview(lightColorButton)

        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: lightPositionButton.trailingAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalTo: lightPositionButton.bottomAnchor, constant: 100),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: lightColorButton.trailingAnchor, multiplier: 1),
            lightPositionButton.topAnchor.constraint(equalToSystemSpacingBelow: lightColorButton.bottomAnchor, multiplier: 1),
            lightColorButton.widthAnchor.constraint(equalTo: lightPositionButton.widthAnchor),
            lightColorButton.heightAnchor.constraint(equalTo: lightPositionButton.heightAnchor)
        ])
    }

    internal func setupExample() {
        addBuildingExtrusions()

        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.7135, longitude: -74.0066),
                                          zoom: 15.5,
                                          bearing: -17.6,
                                          pitch: 45)
        mapView.mapboxMap.setCamera(to: cameraOptions)

        // The below lines are used for internal testing purposes only.
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.finish()
        }
    }

    // See https://docs.mapbox.com/mapbox-gl-js/example/3d-buildings/ for equivalent gl-js example
    internal func addBuildingExtrusions() {
        var layer = FillExtrusionLayer(id: "3d-buildings")

        layer.source                      = "composite"
        layer.minZoom                     = 15
        layer.sourceLayer                 = "building"
        layer.fillExtrusionColor   = .constant(StyleColor(.lightGray))
        layer.fillExtrusionOpacity = .constant(0.6)

        layer.filter = Exp(.eq) {
            Exp(.get) {
                "extrude"
            }
            "true"
        }

        layer.fillExtrusionHeight = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                15
                0
                15.05
                Exp(.get) {
                    "height"
                }
            }
        )

        layer.fillExtrusionBase = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                15
                0
                15.05
                Exp(.get) { "min_height"}
            }
        )

        try! mapView.mapboxMap.style.addLayer(layer)
    }

    // MARK: - Actions

    @objc private func lightColorButtonTapped(_ sender: UIButton) {
        if light.color == StyleColor(.red) {
            light.color = StyleColor(.blue)
            sender.tintColor = .blue
        } else {
            light.color = StyleColor(.red)
            sender.tintColor = .red
        }

        try? mapView.mapboxMap.style.setLight(light)
    }

    @objc private func lightPositionButtonTapped(_ sender: UIButton) {
        let firstPosition = [1.5, 90, 80]
        let secondPosition = [1.15, 210, 30]

        if light.position == firstPosition {
            light.position = secondPosition
            sender.imageView?.transform = .identity
        } else {
            light.position = firstPosition
            sender.imageView?.transform = CGAffineTransform(rotationAngle: 2.0 * .pi / 3.0)
        }

        try? mapView.mapboxMap.style.setLight(light)
    }
}
