//
//  File.swift
//  Examples
//
//  Created by James Carpino on 9/21/22.
//

import Foundation
import MapboxMaps

@objc(LineBorderExample)
public class LineBorderExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var lastBorderWidth = 15.0
    let increaseButton = UIButton(type: .system)
    let decreaseButton = UIButton(type: .system)

    override public func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(styleURI: .light)
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in

            self.setupExample()

            // Set the center coordinate and zoom level.
            let centerCoordinate = CLLocationCoordinate2D(latitude: 38.875, longitude: -77.035)
            let camera = CameraOptions(center: centerCoordinate, zoom: 12.0)
            self.mapView.mapboxMap.setCamera(to: camera)
        }
        increaseButton.setTitle("Increase border width", for: .normal)
        increaseButton.backgroundColor = .black
        increaseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        increaseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(increaseButton)
        increaseButton.addTarget(self, action: #selector(increaseBorder), for: .touchUpInside)
        
        decreaseButton.setTitle("Decrease border width", for: .normal)
        decreaseButton.backgroundColor = .black
        decreaseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 16)
        decreaseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(decreaseButton)
        decreaseButton.addTarget(self, action: #selector(decreaseBorder), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: decreaseButton.trailingAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalTo: decreaseButton.bottomAnchor, constant: 100),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: increaseButton.trailingAnchor, multiplier: 1),
            decreaseButton.topAnchor.constraint(equalToSystemSpacingBelow: increaseButton.bottomAnchor, multiplier: 1)
        ])
    }

    @objc
    func increaseBorder() {
            lastBorderWidth += 10.0
            let borderWidth = Double.maximum(lastBorderWidth, 1.0)
            try? mapView.mapboxMap.style.setLayerProperty(for: "line-border", property: "line-width", value: borderWidth)
    }
    @objc
    func decreaseBorder() {
            lastBorderWidth -= 10.0
            let borderWidth = Double.maximum(lastBorderWidth, 1.0)
            try? mapView.mapboxMap.style.setLayerProperty(for: "line-border", property: "line-width", value: borderWidth)
        
        }
    // Load GeoJSON file from local bundle and decode into a `FeatureCollection`.
    internal func decodeGeoJSON(from fileName: String) throws -> FeatureCollection? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
            preconditionFailure("File '\(fileName)' not found.")
        }
        let filePath = URL(fileURLWithPath: path)
        var featureCollection: FeatureCollection?
        do {
            let data = try Data(contentsOf: filePath)
            featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            print("Error parsing data: \(error)")
        }
        return featureCollection
    }

    internal func setupExample() {
        // The below lines are used for internal testing purposes only.
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.finish()
        }

        // Attempt to decode GeoJSON from file bundled with application.
        guard let featureCollection = try? decodeGeoJSON(from: "GradientLine") else { return }
        let geoJSONDataSourceIdentifier = "geoJSON-data-source"

        // Create a GeoJSON data source.
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featureCollection)
        geoJSONSource.lineMetrics = true // MUST be `true` in order to use `lineGradient` expression

        // Create a line layer
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }
        //Create the line layer border exactly as the line layer
        var lineLayerBorder = LineLayer(id: "line-border")
        lineLayer.filter = Exp(.eq){
            "$type"
            "LineString"
        }
        let lowZoomWidth = 10
        let highZoomWidth = 20
        //add the second line
        lineLayerBorder.source = geoJSONDataSourceIdentifier
        //style this line to be a larger width:
        lineLayerBorder.lineWidth = .constant(lastBorderWidth)

        //color the border by coloring the line
        lineLayerBorder.lineColor = .constant(StyleColor(.black))
       

        // Setting the source
        lineLayer.source = geoJSONDataSourceIdentifier

        // Styling the line
        lineLayer.lineColor = .constant(StyleColor(.red))
        lineLayer.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0
                UIColor.blue
                0.1
                UIColor.purple
                0.3
                UIColor.cyan
                0.5
                UIColor.green
                0.7
                UIColor.yellow
                1
                UIColor.red
            }
        )

        
        lineLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                14
                lowZoomWidth
                18
                highZoomWidth
            }
        )
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)
        
        //round the cap and join to match the line above
        lineLayerBorder.lineCap = .constant(.round)
        lineLayerBorder.lineJoin = .constant(.round)

        // Add the source and style layer to the map style.
        try! mapView.mapboxMap.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
        try! mapView.mapboxMap.style.addLayer(lineLayer, layerPosition: nil )
        
        //add the layer below the line-layer
        try! mapView.mapboxMap.style.addLayer(lineLayerBorder, layerPosition: LayerPosition.below("line-layer"))
            }
}
