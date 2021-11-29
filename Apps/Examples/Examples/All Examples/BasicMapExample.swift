import UIKit
import MapboxMaps
import MapboxDirections
import MapboxStatic

@objc(BasicMapExample)

public class BasicMapExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var slider: UISlider!
    internal var calledOnce: Bool = false
    internal var location: AppleLocationProvider!
    internal var currentLayer: String?
    internal var initialMinutes: Int = 7
    internal var minutes: [Int] = [
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15
    ]
    
    public typealias ApiCompletionHandler = (_ result: FeatureCollection) -> Void

    // MapboxDirections Isochrone class doesn't read from Info.plist automatically in the v2.1.0rc-1 version
    var accessToken: String? {
        return Bundle.main.object(
            forInfoDictionaryKey: "MBXAccessToken") as? String
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let centerCoordinate = CLLocationCoordinate2D(
            latitude: 35.640614,
            longitude: 139.745361)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 16.0))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        location = AppleLocationProvider()
        location.setDelegate(self)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.mapView.location.delegate = self
            self.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
            self.mapView.location.overrideLocationProvider(with: self.location)
            self.mapView.location.options.puckType = .puck2D()
            self.mapView.location.options.puckBearingSource = .course
            
            self.location.requestWhenInUseAuthorization()
        }
        
        view.addSubview(mapView)

        setupSlider()
    }

    internal func setupSlider() {
        // Create Slider
        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 15
        slider.isContinuous = true
        slider.tintColor = UIColor.blue
        slider.value = Float(initialMinutes)
        slider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)

        view.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            slider.heightAnchor.constraint(equalToConstant: 44),
            slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44),
            slider.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
        ])
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    @objc func sliderValueDidChange(_ sender:UISlider!) {
        let opts = minutes
        var optsMap: [Int: Bool] = [:]
        for v in opts {
            optsMap[v] = true
        }

        let value = Int(round(sender.value))
        guard let exists = optsMap[Int(value)] else {
            return
        }
        let layerName = valueToLayerName(value)
        if let layer = currentLayer {
            if layer == layerName {
                return
            }
            hideLayer(layer)
            currentLayer = layerName
            showLayer(layerName)
        } else {
            currentLayer = layerName
            showLayer(layerName)
        }
    }

    func valueToLayerName(_ val: Int) -> String {
        return "minute-" + String(val)
    }

    func hideLayer(_ layer: String) {
        try? mapView.mapboxMap.style.updateLayer(withId: layer, type: FillLayer.self) { layer in
                print("hideLayer(lineLayer)", layer)
                layer.fillOpacity = .constant(0.0)
        }
    }

    func showLayer(_ layer: String) {
        try? mapView.mapboxMap.style.updateLayer(withId: layer, type: FillLayer.self) { layer in
                print("showLayer(lineLayer)", layer)
                layer.fillOpacity = .constant(1.0)
        }
    }

    // Request Isochrone contour to draw on a map
    func getIsochroneSet(location: CLLocationCoordinate2D) {
        
        // Create a dispatch group
        let group = DispatchGroup()

        let opts = minutes

        var results: [Int: GeoJSONSourceData] = [:]
        // Make multiple simultaneous requests
        for key in opts {
            group.enter()
            let isochrones = Isochrones(credentials: Credentials(accessToken: self.accessToken))
            isochrones.calculate(IsochroneOptions(
                centerCoordinate: location,
                contours:
                    IsochroneOptions.Contours.byExpectedTravelTimes([.init(value: Double(key), unit: .minutes)]),
                profileIdentifier: .walking
            )) { session, result in
                if case .success(let response) = result {
                    print("Key", key)
                    results[key] = GeoJSONSourceData.featureCollection(response)
                    group.leave()
                }
                
            }
        }
        // Configure a completion callback
        group.notify(queue: .main) {
            for (key, result) in results {
                self.addContourLayer(
                    shape: result,
                    layerName: self.valueToLayerName(key))
            }
            self.showLayer(self.valueToLayerName(self.initialMinutes))
        }
    }

    func fetchIsochrone(
        location: CLLocationCoordinate2D,
        contourOpts: IsochroneOptions.Contours,
        completionHandler: @escaping Isochrones.IsochroneCompletionHandler
    ) {
        let isochrones = Isochrones(credentials: Credentials(accessToken: accessToken))
        isochrones.calculate(IsochroneOptions(centerCoordinate: location,
                                              contours: contourOpts),
                             completionHandler: completionHandler)
    }

    func addContourLayer(
        shape: GeoJSONSourceData,
        layerName: String) {
        // Add the sources and layers to the map's style.
        do {
            // Create a GeoJSON data source.
            var geoJSONSource = GeoJSONSource()
            geoJSONSource.data = shape
            
            var lineLayer = FillLayer(id: layerName)
            lineLayer.source = layerName
            lineLayer.fillColor = .constant(StyleColor(.orange))
            lineLayer.fillOpacity = .constant(0.0)
            lineLayer.fillOpacityTransition = .init(duration: 0.2, delay: 0)
//            lineLayer. = .constant(4)
            
//            var lineLayer = LineLayer(id: layerName)
//            lineLayer.source = layerName
//            lineLayer.lineColor = .constant(StyleColor(.orange))
//            lineLayer.lineOpacity = .constant(0.0)
//            lineLayer.lineOpacityTransition = .init(duration: 0.2, delay: 0)
//            lineLayer.lineWidth = .constant(4)
            try! mapView.mapboxMap.style.addSource(geoJSONSource, id: layerName)
            try! mapView.mapboxMap.style.addLayer(lineLayer)
            print("addLayer(lineLayer)", lineLayer)
        } catch {
            print("Error when adding sources and layers: \(error.localizedDescription)")
        }
    }
}


extension BasicMapExample: LocationProviderDelegate {
    public func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        print("Location", locations)
        guard let first = locations.first else {
            return
        }
        
        var state = self.mapView.mapboxMap.cameraState
        state.center = first.coordinate
        let camera = CameraOptions(cameraState: state)
        mapView.mapboxMap.setCamera(to: camera)
        
        if calledOnce {
            return
        }
        calledOnce = true
        self.getIsochroneSet(location: first.coordinate)
    }

    public func locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading) {
        print("locationProvider(_ provider: LocationProvider, didUpdateHeading newHeading: CLHeading)")
    }
    
    public func locationProvider(_ provider: LocationProvider, didFailWithError error: Error) {
        print("locationProvider(_ provider: LocationProvider, didFailWithError error: Error)")
    }
    
    public func locationProviderDidChangeAuthorization(_ provider: LocationProvider) {
        print("locationProviderDidChangeAuthorization(_ provider: LocationProvider)")
        if provider.authorizationStatus == .authorizedWhenInUse {
            location.startUpdatingLocation()
        }
    }
}

extension BasicMapExample: LocationPermissionsDelegate {
    public func locationManager(_ locationManager: LocationManager,
                                didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        print("locationManager(_ locationManager: LocationManager,didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization)")
    }
    public func locationManager(_ locationManager: LocationManager, didFailToLocateUserWithError error: Error) {
        print("locationManager(_ locationManager: LocationManager, didFailToLocateUserWithError error: Error)", error)
    }
}
