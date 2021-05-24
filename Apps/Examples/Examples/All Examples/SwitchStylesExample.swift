import UIKit
import MapboxMaps

@objc(SwitchStylesExample)

public class SwitchStylesExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Initialize a map centered near El Ejido, Spain and with a zoom level of 13.
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 36.77271, longitude: -2.81361), zoom: 13)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions, styleURI: .satelliteStreets)

        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.mapboxMap.style.uri = .satelliteStreets
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)

        // Add a `UISegmentedControl` to toggle between Mapbox Streets, Mapbox Satellite Streets, and a custom style.
        addStyleToggle()
    }

    @objc func switchStyle(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Set the map's style to the default Mapbox Streets style.
            mapView.mapboxMap.style.uri = .streets
        case 1:
            // Set the map's style to Mapbox Satellite Streets.
            mapView.mapboxMap.style.uri = .satelliteStreets
        case 2:
            // Blueprint, a custom style designed by Amy Lee Walton. https://www.mapbox.com/gallery/#blueprint
            // Load the local style JSON. It conforms to the Mapbox Style Specification <https://docs.mapbox.com/mapbox-gl-js/style-spec/>
            let localStyleURL = Bundle.main.url(forResource: "blueprint_style", withExtension: "json")!

            // Set the map's style URI to a custom style URL.
            mapView.mapboxMap.style.uri = StyleURI(url: localStyleURL)

            // A Mapbox Studio style can also be loaded as a `StyleURI`.
            // let studioStyleURL = URL(string: "mapbox://styles/examples/ckox18pjy140u17pdvmpgut4i")!
        default:
            mapView.mapboxMap.style.uri = .satelliteStreets
        }
    }

    func addStyleToggle() {
        // Create a UISegmentedControl to toggle between map styles
        let styleToggle = UISegmentedControl(items: ["Streets", "Satellite Streets", "Local Style JSON"])
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
