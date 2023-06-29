import UIKit
import MapboxMaps

class MapViewController: UIViewController {
    
    // create MapViews for the main map and the inset map
    internal var mapView: MapView!
    internal var insetMapView: MapView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let myResourceOptions = ResourceOptions(
            accessToken: "pk.eyJ1IjoiY2hyaXN3aG9uZ21hcGJveCIsImEiOiJjbDl6bzJ6N3EwMGczM3BudjZmbm5yOXFnIn0.lPhc5Z5H3byF_gf_Jz48Ug"
        )
        
        // set up the main map
        mapView = MapView(
            frame: view.bounds,
            mapInitOptions: MapInitOptions(
                resourceOptions: myResourceOptions,
                styleURI: StyleURI.streets
            )
        )
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.gestures.options.rotateEnabled = false
        
        self.view.addSubview(mapView)
        
        // set up the inset map
        let myInsetMapInitOptions = MapInitOptions(
            resourceOptions: myResourceOptions,
            cameraOptions: CameraOptions(
                zoom:0
            ),
            styleURI: StyleURI.streets
        )
        
        insetMapView = MapView(
            // position the inset map in the bottom left corner
            frame: CGRectMake(8, (self.view.frame.size.height - 250), 120, 120),
            mapInitOptions: myInsetMapInitOptions
        )
        
        // hide the scaleBar, logo, and attribution on the inset map
        insetMapView.ornaments.options.scaleBar.visibility = .hidden
        insetMapView.ornaments.logoView.isHidden = true
        insetMapView.ornaments.attributionButton.isHidden = true
        
        // disable panning and zooming on the inset map
        insetMapView.gestures.options.panEnabled = false
        insetMapView.gestures.options.doubleTapToZoomInEnabled = false
        insetMapView.gestures.options.doubleTouchToZoomOutEnabled = false
        
        // add a border, radius, and shadow around the inset map
        insetMapView.layer.borderWidth = 2
        insetMapView.layer.cornerRadius = 10
        insetMapView.layer.borderColor = UIColor.gray.cgColor
        insetMapView.layer.shadowColor = UIColor.black.cgColor
        insetMapView.layer.shadowOffset = CGSize(width: 3, height: 3)
        insetMapView.layer.shadowOpacity = 0.7
        insetMapView.layer.shadowRadius = 4.0
        insetMapView.layer.masksToBounds = true
        
        self.view.addSubview(insetMapView)
        
        // when the inset map loads, add a source and layer to show the bounds rectangle for the main map
        insetMapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            
            var geoJSONSource = GeoJSONSource()
            geoJSONSource.data = .featureCollection(FeatureCollection(features:[]))
            
            let geoJSONDataSourceIdentifier = "bounds"
            
            // Create a line layer
            var lineBoundsLayer = LineLayer(id: "line-bounds")
            lineBoundsLayer.source = geoJSONDataSourceIdentifier
            lineBoundsLayer.lineColor = .constant(StyleColor(.gray))
            
            // Create a fill layer
            var fillBoundsLayer = FillLayer(id: "fill-bounds")
            fillBoundsLayer.source = geoJSONDataSourceIdentifier
            fillBoundsLayer.fillColor = .constant(StyleColor(.gray))
            fillBoundsLayer.fillOpacity = .constant(0.3)
            
            // Add the source and layers to the map style
            try! self.insetMapView.mapboxMap.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
            try! self.insetMapView.mapboxMap.style.addLayer(lineBoundsLayer, layerPosition: nil)
            try! self.insetMapView.mapboxMap.style.addLayer(fillBoundsLayer, layerPosition: nil)
            
            updateInsetMap()
        }
        
        func updateInsetMap() {
            // set the inset map's center to the main map's center
            self.insetMapView.mapboxMap.setCamera(
                to: CameraOptions(center: self.mapView.cameraState.center)
            )
            
            // get the main map's bounds
            var bounds = self.mapView.mapboxMap.coordinateBounds(for: self.mapView.bounds)
            
            // create a geojson polygon based on the main map's bounds
            // use it to update the "bounds" source in the inset map
            try! self.insetMapView.mapboxMap.style.updateGeoJSONSource(withId: "bounds", geoJSON: .geometry(
                .polygon(
                    Polygon(
                        outerRing: Ring(
                            coordinates: [
                                CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.west),
                                CLLocationCoordinate2D(latitude: bounds.north, longitude: bounds.west),
                                CLLocationCoordinate2D(latitude: bounds.north, longitude: bounds.east),
                                CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.east),
                                CLLocationCoordinate2D(latitude: bounds.south, longitude: bounds.west)
                            ]
                        )
                    )
                )
            ))
        }
        
        mapView.mapboxMap.onEvery(.cameraChanged, handler: { [weak self] _ in
            guard let self = self else { return }
            updateInsetMap()
        })
    }
}



