import UIKit
import MapboxMaps

@objc(GestureDrawExample)

public class GestureDrawExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var drawMode: Bool = false
    internal let button = UIButton(type: .system)
    internal var coords: [CLLocationCoordinate2D] = []
    internal var userDrawLine = (identifier: "user-draw", source: GeoJSONSource())
    internal var userDrawFill = (identifier: "user-fill", source: GeoJSONSource())
    internal var isDrawingEnded = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.addDrawModeButton()
            self.addLayer()
            self.addFillLayer()
        }
    }

    private func addLayer() {
        userDrawLine.source.data = .feature(Feature(geometry: .lineString(LineString([]))))
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.source = userDrawLine.identifier
        lineLayer.lineColor = .constant(StyleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)))
        lineLayer.lineWidth = .constant(4.0)
        lineLayer.lineCap = .constant(.round)
        
        // Add the sources and layers to the map style.
        try! mapView.mapboxMap.style.addSource(userDrawLine.source, id: userDrawLine.identifier)
        try! mapView.mapboxMap.style.addLayer(lineLayer)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        convertTouch(touches, isLast: false)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        convertTouch(touches, isLast: false)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        convertTouch(touches, isLast: true)
    }

    private func convertTouch(_ touches: Set<UITouch>, isLast: Bool) {
        if !drawMode {
            return
        }
        // when a user draws after drawing has been completed
        if isDrawingEnded {
            isDrawingEnded = false
            coords = []
        }
        guard let first = touches.first else {
            return
        }
        let point = first.location(in: mapView)
        let coord = mapView.mapboxMap.coordinate(for: point)
        coords.append(coord)

        if isLast { // connect last and first point
            guard let first = coords.first else {
                return
            }
            coords.append(first)
            isDrawingEnded = true
        }
        updateLine()
        updateFillLayer()
    }

    private func updateLine() {
        let geoJSON = Feature(geometry: .lineString(LineString(coords)))
        // Update the airplane source layer with the new coordinate and bearing.
        try! mapView.mapboxMap.style.updateGeoJSONSource(withId: userDrawLine.identifier,
                                                         geoJSON: .feature(geoJSON))
    }

    private func addFillLayer() {
        userDrawFill.source.data = .feature(Feature(geometry: .polygon(Polygon([]))))
        var polygonLayer = FillLayer(id: userDrawFill.identifier)
        polygonLayer.source = userDrawFill.identifier
        polygonLayer.fillOpacity = .constant(0.25)
        polygonLayer.fillColor = .constant(StyleColor(.gray))

        // Add the sources and layers to the map style.
        try! mapView.mapboxMap.style.addSource(userDrawFill.source, id: userDrawFill.identifier)
        try! mapView.mapboxMap.style.addLayer(polygonLayer)
    }

    private func updateFillLayer() {
        guard self.coords.count > 1,
            let first = self.coords.first,
            let last = self.coords.last,
            first.latitude == last.latitude,
            first.longitude == last.longitude else {
                let geoJSON = Feature(geometry: .polygon(Polygon([])))
                try! mapView.mapboxMap.style.updateGeoJSONSource(withId: userDrawFill.identifier,
                                                             geoJSON: .feature(geoJSON))
            return
        }
        let geoJSON = Feature(geometry: .polygon(Polygon([self.coords])))
        try! mapView.mapboxMap.style.updateGeoJSONSource(withId: userDrawFill.identifier,
                                                         geoJSON: .feature(geoJSON))
    }

    private func addDrawModeButton() {
        // Set up layer postion change button
        button.setTitle("Enable Draw Mode", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(onChangeButtonPress(sender:)), for: .touchUpInside)
        view.addSubview(button)
        // Set button location
        let horizontalConstraint = button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                  constant: -24)
        let verticalConstraint = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    @objc private func onChangeButtonPress(sender: UIButton) {
        drawMode = !drawMode
        if !drawMode {
            self.mapView.gestures.options.panEnabled = true
            button.setTitle("Enable Draw Mode", for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        } else {
            self.mapView.gestures.options.panEnabled = false
            button.setTitle("Disable Draw Mode", for: .normal)
            button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        }
    }
}
