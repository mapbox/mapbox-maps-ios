import UIKit
import MapboxMaps

@objc(LayerPositionExample)

public class LayerPositionExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    private var sourceIdentifier = "ploygon-geojson-source"
    private var source: GeoJSONSource!
    private var layer: FillLayer!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.58058466412761,
                                                      longitude: -97.734375)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                                  zoom: 3)

        // Allows the view controller to recieve information about map events.
        mapView.on(.mapLoadingFinished) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }

        // Add a button to change the position of layer
        self.addLayerPostionChangeButton()
    }

    private func addLayerPostionChangeButton() {
        // Set up layer postion change button
        let button = UIButton(type: .system)
        button.setTitle("Change Layer Position", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(onChangeButtonPress(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
        // Set button location
        let horizontalConstraint = button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                                                                  constant: -24)
        let verticalConstraint = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    @objc private func onChangeButtonPress(sender: UIButton) {
        let alert = UIAlertController(title: "Polygon Layer",
                                      message: "Please select the position of polygon layer.",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Above state label", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            _ = self.mapView.style.removeStyleLayer(forLayerId: self.layer.id)
            _ = self.mapView.style.addLayer(layer: self.layer,
                                                      layerPosition: LayerPosition(above: "state-label"))
        }))

        alert.addAction(UIAlertAction(title: "Below state label", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            _ = self.mapView.style.removeStyleLayer(forLayerId: self.layer.id)
            _ = self.mapView.style.addLayer(layer: self.layer,
                                                      layerPosition: LayerPosition(below: "state-label"))
        }))

        alert.addAction(UIAlertAction(title: "Above all", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            _ = self.mapView.style.removeStyleLayer(forLayerId: self.layer.id)
            _ = self.mapView.style.addLayer(layer: self.layer,
                                                      layerPosition: nil)
        }))

        alert.addAction(UIAlertAction(title: "Below all", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            _ = self.mapView.style.removeStyleLayer(forLayerId: self.layer.id)
            _ = self.mapView.style.addLayer(layer: self.layer,
                                                      layerPosition: LayerPosition(at: 0))
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alert, animated: true)
    }

    // Wait for the style to load before adding data to it.
    public func setupExample() {
        layer = FillLayer(id: "polygon-layer")
        layer.source = sourceIdentifier
        // Apply basic styling to the fill layer.
        layer.paint?.fillColor = .constant(ColorRepresentable(color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)))
        layer.paint?.fillOutlineColor = .constant(ColorRepresentable(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))

        // Create a new GeoJSON data source which gets its data from a polygon.
        source = GeoJSONSource()
        source.data = .geometry(.polygon(.init([[
            CLLocationCoordinate2DMake(32.91648534731439, -114.43359375),
            CLLocationCoordinate2DMake(32.91648534731439, -81.298828125),
            CLLocationCoordinate2DMake(48.16608541901253, -81.298828125),
            CLLocationCoordinate2DMake(48.16608541901253, -114.43359375),
            CLLocationCoordinate2DMake(32.91648534731439, -114.43359375)
        ]])))

        _ = mapView.style.addSource(source: source, identifier: sourceIdentifier)
        // If a layer position is not supplied, the layer is added above all other layers by default.
        _ = mapView.style.addLayer(layer: layer, layerPosition: nil)

        // The below line is used for internal testing purposes only.
        self.finish()
    }
}
