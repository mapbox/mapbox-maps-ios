import UIKit
import MapboxMaps

@objc(SwitchStylesExample)

public class SwitchStylesExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var styleToggle: UISegmentedControl!
    internal var style: Style = .satelliteStreets {
        didSet {
            mapView.mapboxMap.style.uri = style.uri
        }
    }

    enum Style: Int, CaseIterable {

        var name: String {
            switch self {
            case .light:
                return "light".capitalized
            case .satelliteStreets:
                return "s. streets".capitalized
            case .customUri:
                return "custom".capitalized
            }
        }

        var uri: StyleURI {
            switch self {
            case .light:
                return .light
            case .satelliteStreets:
                return .satelliteStreets
            case .customUri:
                let localStyleURL = Bundle.main.url(forResource: "blueprint_style", withExtension: "json")!
                return .init(url: localStyleURL)!
            }
        }

        case light
        case satelliteStreets
        case customUri
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a map centered near El Ejido, Spain and with a zoom level of 13.
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 36.77271, longitude: -2.81361), zoom: 13)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: style.uri)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add a `UISegmentedControl` to toggle between Mapbox Streets, Mapbox Satellite Streets, and a custom style.
        addStyleToggle()
        installConstraints()
    }

    @objc func switchStyle(sender: UISegmentedControl) {
        style = Style(rawValue: sender.selectedSegmentIndex) ?? . satelliteStreets
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        styleToggle = UISegmentedControl(items: Style.allCases.map(\.name))
        styleToggle.tintColor = UIColor(red: 0.976, green: 0.843, blue: 0.831, alpha: 1)
        styleToggle.backgroundColor = .white
        styleToggle.selectedSegmentIndex = style.rawValue
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(switchStyle(sender:)), for: .valueChanged)
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
    }

    func installConstraints() {
        // Configure autolayout constraints for the UISegmentedControl to align
        // at the bottom of the map view.
        NSLayoutConstraint.activate([
            styleToggle.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60),
            styleToggle.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
        ])
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
