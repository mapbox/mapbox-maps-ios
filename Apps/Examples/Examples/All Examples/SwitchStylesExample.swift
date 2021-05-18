import UIKit
import MapboxMaps

@objc(SwitchStylesExample)

public class SwitchStylesExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create 
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 36.77271, longitude: -2.81361), zoom: 12)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .satelliteStreets)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.mapboxMap.style.uri = .satelliteStreets
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        addStyleToggle()
    }

    @objc func switchStyle(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapboxMap.style.uri = .streets
        case 1:
            mapView.mapboxMap.style.uri = .satelliteStreets
        case 2:
            // A custom style designed by Taya Lavrinenko. https://blog.mapbox.com/doh-making-a-simspons-inspired-map-with-expressions-86e633b61ede
            let customStyle = StyleURI(rawValue: "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j")!
            mapView.mapboxMap.style.uri = customStyle
        default:
            mapView.mapboxMap.style.uri = .satelliteStreets
        }
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        let styleToggle = UISegmentedControl(items: ["Local Style", "Satellite", "Studio Style"])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.tintColor = UIColor(red: 0.976, green: 0.843, blue: 0.831, alpha: 1)
        styleToggle.backgroundColor = UIColor(red: 0.973, green: 0.329, blue: 0.294, alpha: 1)
        styleToggle.layer.cornerRadius = 4
        styleToggle.clipsToBounds = true
        styleToggle.selectedSegmentIndex = 1
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(switchStyle(sender:)), for: .valueChanged)

        // Configure autolayout constraints for the UISegmentedControl to align
        // at the bottom of the map view.
        NSLayoutConstraint(item: styleToggle, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mapView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0).isActive = true
        styleToggle.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -60).isActive = true
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }
}
