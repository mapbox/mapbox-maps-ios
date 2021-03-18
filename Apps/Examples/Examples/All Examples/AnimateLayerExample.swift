import UIKit
import MapboxMaps
import Turf

@objc(AnimateLayerExample)

public class AnimateLayerExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!

    // A tuple that associates the source with its identifier.
    public var airplaneRoute = (identifier: "airplane-route", source: GeoJSONSource())
    public var airplaneSymbol = (identifier: "airplane-symbol", source: GeoJSONSource())

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        // Set the map's center coordinate and zoom level
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.8,
                                                      longitude: -96)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 2)

        // Allows the view controller to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.setupExample()
        }
    }

    public func setupExample() {

        // San Francisco, California
        let origin = CLLocationCoordinate2DMake(37.776, -122.414)
        // Washington, D.C.
        let destination = CLLocationCoordinate2DMake(38.913, -77.032)

        let arcLine = arc(start: origin, end: destination)

        // Add the layers to be rendered on the map.
        addLayers(for: arcLine)

        // Begin animating the airplane across the route line.
        startAnimation(routeLine: arcLine)
    }

    public func arc(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> LineString {
        let line = LineString([start, end])
        let distance = Int(start.distance(to: end))

        var coordinates = [CLLocationCoordinate2D]()
        let steps = 500
        var index = 0

        while index < distance {
            index += distance / steps
            let coord = line.coordinateFromStart(distance: CLLocationDistance(index))!
            coordinates.append(coord)
        }

        return LineString(coordinates.compactMap({ $0 }))
    }

    public func addLayers(for routeLine: LineString) {

        // Define the source data and style layer for the airplane's route line.
        airplaneRoute.source.data = .feature(Feature(routeLine))
        var lineLayer = LineLayer(id: "line-layer")
        lineLayer.source = airplaneRoute.identifier
        lineLayer.paint?.lineColor = .constant(ColorRepresentable(color: UIColor.red))
        lineLayer.paint?.lineWidth = .constant(3.0)
        lineLayer.layout?.lineCap = .constant(.round)

        // Define the source data and style layer for the airplane symbol.
        let point = Point(routeLine.coordinates[0])
        airplaneSymbol.source.data = .feature(Feature(point))
        var airplaneSymbolLayer = SymbolLayer(id: "airplane")
        airplaneSymbolLayer.source = airplaneSymbol.identifier
        // "airport-15" is the name the image that belongs in the style's sprite by default.
        airplaneSymbolLayer.layout?.iconImage = .constant(.name("airport-15"))
        airplaneSymbolLayer.layout?.iconRotationAlignment = .constant(.map)
        airplaneSymbolLayer.layout?.iconAllowOverlap = .constant(true)
        airplaneSymbolLayer.layout?.iconIgnorePlacement = .constant(true)
        // Get the "bearing" property from the point's feature dictionary,
        // and use that value to determine the rotation angle of the airplane icon.
        airplaneSymbolLayer.layout?.iconRotate = .expression(Exp(.get) {
            "bearing"
        })

        // Add the sources and layers to the map style.
        _ = mapView.style.addSource(source: airplaneRoute.source, identifier: airplaneRoute.identifier)
        _ = mapView.style.addLayer(layer: lineLayer, layerPosition: nil)

        _ = mapView.style.addSource(source: airplaneSymbol.source, identifier: airplaneSymbol.identifier)
        _ = mapView.style.addLayer(layer: airplaneSymbolLayer, layerPosition: nil)
    }

    public func startAnimation(routeLine: LineString) {
        var runCount = 0

        _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in

            guard let self = self else { return }

            let coordinate = routeLine.coordinates[runCount]
            let nextCoordinate = routeLine.coordinates[runCount + 1]

            // Identify the new coordinate to animate to, and calculate
            // the bearing between the new coordinate and the following coordinate.
            var geoJSON = Feature.init(geometry: Geometry.point(Point(coordinate)))
            geoJSON.properties = ["bearing": coordinate.direction(to: nextCoordinate)]

            // Update the airplane source layer with the new coordinate and bearing.
            _ = self.mapView.style.updateGeoJSON(for: self.airplaneSymbol.identifier,
                                                 with: geoJSON)

            runCount += 1

            if runCount == 500 {
                timer.invalidate()
                // The below line is used for internal testing purposes only.
                self.finish()
            }
        }

    }
}
