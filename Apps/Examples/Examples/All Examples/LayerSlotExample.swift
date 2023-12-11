import UIKit
@_spi(Experimental) import MapboxMaps

final class LayerSlotExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private lazy var source = GeoJSONSource(id: "ploygon-geojson-source")
    private lazy var layer = FillLayer(id: "polygon-layer", source: source.id)
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Center the map over the United States.
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.58058466412761,
                                                      longitude: -97.734375)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 3))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Allows the view controller to receive information about map events.
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
        }.store(in: &cancelables)

        // Add a control to change the slot of layer
        addLayerSlotChangeControl()
    }

    private func addLayerSlotChangeControl() {
        // Set up a segemented control changing slots
        let control = UISegmentedControl(items: ["Bottom", "Middle", "Top"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = .white
        control.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 0
        view.addSubview(control)

        // Set segmented control location
        let horizontalConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: control.bottomAnchor,
                                                                  constant: 40)
        let verticalConstraint = control.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let minWidthConstraint = control.widthAnchor.constraint(greaterThanOrEqualToConstant: 300)
        let leadingConstraint = control.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.leadingAnchor, multiplier: 1)
        let trailingConstraint = control.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.trailingAnchor, multiplier: 1)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, leadingConstraint, trailingConstraint, minWidthConstraint])
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let slotName = sender.titleForSegment(at: sender.selectedSegmentIndex)?.lowercased() else { return }

        try! mapView.mapboxMap.updateLayer(withId: self.layer.id, type: FillLayer.self, update: { layer in
            layer.slot = Slot(rawValue: slotName)
        })
    }

    // Wait for the style to load before adding data to it.
    func setupExample() {
        // Apply basic styling to the fill layer.
        layer.fillColor = .constant(StyleColor(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)))
        layer.fillOutlineColor = .constant(StyleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))

        // If a slot is not supplied, the layer is added above all other layers by default.
        layer.slot = .bottom

        // Create a new GeoJSON data source which gets its data from a polygon.
        source.data = .geometry(.polygon(.init([[
            CLLocationCoordinate2DMake(32.91648534731439, -114.43359375),
            CLLocationCoordinate2DMake(32.91648534731439, -81.298828125),
            CLLocationCoordinate2DMake(48.16608541901253, -81.298828125),
            CLLocationCoordinate2DMake(48.16608541901253, -114.43359375),
            CLLocationCoordinate2DMake(32.91648534731439, -114.43359375)
        ]])))

        try! mapView.mapboxMap.addSource(source)

        try! mapView.mapboxMap.addLayer(layer)

        // The below line is used for internal testing purposes only.
        finish()
    }
}
