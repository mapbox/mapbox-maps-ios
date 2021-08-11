import UIKit
import MapboxMaps

@objc(OrnamentsCompassExample)
public class OrnamentsCompassExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.ornaments.options.scaleBar.visibility = .visible
        mapView.ornaments.options.compass.visibility = .visible
        mapView.ornaments.options.compass.position = .topLeft
        mapView.ornaments.options.compass.image = .default

        view.addSubview(mapView)

        // Add controls to configure the compass
        addControls()
    }

    @objc func switchImage(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Set the compass image to default
            mapView.ornaments.options.compass.image = .default
        case 1:
            // Set the compass image to custom
            let image: UIImage
            if #available(iOS 13.0, *) {
                image = UIImage(systemName: "location.north.fill")!
            } else {
                image = UIImage(named: "star")!
            }
            mapView.ornaments.options.compass.image = .custom(image)
        default:
            return
        }
    }
    @objc func switchVisibility(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Set the compass to visible
            mapView.ornaments.options.compass.visibility = .visible
        case 1:
            // Set the compass to adaptive
            mapView.ornaments.options.compass.visibility = .adaptive
        case 2:
            // Set the compass to hidden
            mapView.ornaments.options.compass.visibility = .hidden
        default:
            return
        }
    }
    @objc func switchPosition(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Set the compass to topLeft
            mapView.ornaments.options.compass.position = .topLeft
        case 1:
            // Set the compass to topRight
            mapView.ornaments.options.compass.position = .topRight
        case 2:
            // Set the compass to bottomLeft
            mapView.ornaments.options.compass.position = .bottomLeft
        case 3:
            // Set the compass to bottomRight
            mapView.ornaments.options.compass.position = .bottomRight
        default:
            return
        }

        mapView.ornaments.options.scaleBar.visibility = .adaptive
    }
    func createSegmentControl(items: [Any],
                              selectedSegmentIndex: Int,
                              action: Selector) -> UISegmentedControl {
        let segment = UISegmentedControl(items: items)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.tintColor = UIColor(red: 0.976, green: 0.843, blue: 0.831, alpha: 1)
        segment.backgroundColor = UIColor(red: 0.973, green: 0.329, blue: 0.294, alpha: 1)
        segment.layer.cornerRadius = 4
        segment.clipsToBounds = true
        segment.selectedSegmentIndex = selectedSegmentIndex
        view.insertSubview(segment, aboveSubview: mapView)
        segment.addTarget(self, action: action, for: .valueChanged)
        return segment
    }
    func addControls() {
        let controls = [
            // Create a UISegmentedControl to toggle compass visibility
            createSegmentControl(items: ["Visibile", "Adaptive", "Hidden"],
                                 selectedSegmentIndex: 0,
                                 action:  #selector(switchVisibility(sender:))),
            // Create a UISegmentedControl to toggle compass position
            createSegmentControl(items: ["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
                                 selectedSegmentIndex: 0,
                                 action: #selector(switchPosition(sender:))),
            // Create a UISegmentedControl to toggle compass image
            createSegmentControl(items: ["Default", "Custom"],
                                 selectedSegmentIndex: 0,
                                 action: #selector(switchImage(sender:)))
        ]

        controls
            .enumerated()
            .forEach({ (index, control) in
                // Center
                NSLayoutConstraint(item: control,
                                   attribute: NSLayoutConstraint.Attribute.centerX,
                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: mapView,
                                   attribute: NSLayoutConstraint.Attribute.centerX,
                                   multiplier: 1.0,
                                   constant: 0.0).isActive = true
                // Stack vertically from bottom
                if index == 0 {
                    control
                        .bottomAnchor
                        .constraint(equalTo: mapView.bottomAnchor, constant: -80).isActive = true

                } else {
                    control
                        .bottomAnchor
                        .constraint(equalTo: controls[index - 1].topAnchor, constant: -10).isActive = true
                }
            })
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }
}
