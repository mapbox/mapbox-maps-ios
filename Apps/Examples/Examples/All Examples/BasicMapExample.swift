import UIKit
import MapboxMaps
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

@objc(BasicMapExample)

public class BasicMapExample: UIViewController, ExampleProtocol {

    internal var mapView: MapView!
    internal var label: UILabel!
    internal var card: UIView!
    internal var slider: UISlider!
    internal var calledOnce: Bool = false
    internal var location: AppleLocationProvider!
    internal var currentLayer: String?
    internal var initialMinutes: Int = 7
    internal var cardTitle: UILabel!
    internal var cardWalkMin: UILabel!
    internal var currentLocation: CLLocation?
    internal var selectedFeature: Feature?
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
        15,
        16,
        17,
        18,
        19,
        20
    ]
    internal var minutesToGeoJSON: [String: GeoJSONObject] = [:]
    
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
                                                                  zoom: 13.0))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        location = AppleLocationProvider()
        location.setDelegate(self)
        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
           self.mapView.location.delegate = self
           self.mapView.location.requestTemporaryFullAccuracyPermissions(withPurposeKey: "CustomKey")
           self.mapView.location.overrideLocationProvider(with: self.location)
           self.mapView.location.options.puckType = .puck2D()
           self.mapView.location.options.puckBearingSource = .course
           
           self.location.requestWhenInUseAuthorization()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onMapClick(_:)))
            self.mapView.addGestureRecognizer(tapGesture)
       }

        setupSlider()

        setupLabel()

        setupCard()
    }

    internal func setupCard() {
        card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        view.addSubview(card)

        cardTitle = UILabel()
        cardTitle.translatesAutoresizingMaskIntoConstraints = false
        cardTitle.text = ""
        cardTitle.textColor = .black
        cardTitle.backgroundColor = .white
        cardTitle.font = UIFont.systemFont(ofSize: 24)
        card.addSubview(cardTitle)
        
        NSLayoutConstraint.activate([
            cardTitle.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 16),
            cardTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
        ])

        cardWalkMin = UILabel()
        cardWalkMin.translatesAutoresizingMaskIntoConstraints = false
        cardWalkMin.text = ""
        cardWalkMin.textColor = .black
        cardWalkMin.backgroundColor = .white
        card.addSubview(cardWalkMin)
        
        NSLayoutConstraint.activate([
            cardWalkMin.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 16),
            cardWalkMin.topAnchor.constraint(equalTo: cardTitle.bottomAnchor, constant: 16),
        ])

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Navigate me!", for: .normal)
        button.tintColor = .blue
        button.addTarget(self, action: #selector(self.startNavigation(_:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)

        card.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            button.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -44),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.widthAnchor.constraint(equalToConstant: 150)
        ])

        NSLayoutConstraint.activate([
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            card.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            card.heightAnchor.constraint(equalToConstant: 150),
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    internal func setupSlider() {
        // Create Slider
        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = Float(self.minutes.first!)
        slider.maximumValue = Float(self.minutes.last!)
        slider.isContinuous = true
        slider.tintColor = UIColor.blue
        slider.value = Float(initialMinutes)
        slider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)

        view.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            slider.heightAnchor.constraint(equalToConstant: 44),
            slider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -144),
            slider.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
        ])
    }

    internal func setupLabel() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.init(red: 0, green: 170/255.0, blue: 0, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.layer.cornerRadius = 8
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            label.heightAnchor.constraint(equalToConstant: 44),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
        ])
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    @objc func startNavigation(_ sender: UIButton!) {
        // Define two waypoints to travel between
        guard let originCoordinate = currentLocation?.coordinate else {
            print("No current lcoation")
            return
        }
        guard case let .point(point) = self.selectedFeature?.geometry else {
            print("No destination")
            return
        }
        
        let origin = Waypoint(coordinate: originCoordinate, name: "Current Location")
        let destination = Waypoint(coordinate: point.coordinates, name: "White House")

        // Set options
        let routeOptions = NavigationRouteOptions(
            waypoints: [origin, destination]
        )

        // Request a route using MapboxDirections
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                let navigationService = MapboxNavigationService(
                    routeResponse: response,
                    routeIndex: 0,
                    routeOptions: routeOptions,
                    simulating: .always)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                // Pass the generated route response to the the NavigationViewController
                let viewController = NavigationViewController(
                    for: response,
                       routeIndex: 0,
                       routeOptions: routeOptions,
                       navigationOptions: navigationOptions)
                viewController.modalPresentationStyle = .fullScreen
                strongSelf.present(viewController, animated: true, completion: nil)
            }
        }
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
        switchLayer(to: layerName)
    }

    func switchLayer(to layerName: String) {
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
        label.text = layerName + " minutes"
        
        guard let geojson = self.minutesToGeoJSON[layerName] else {
            print("Geojson not found")
            return
        }
        print("Updating Layer", geojson.geoJSONObject)
        try! mapView.mapboxMap.style.updateLayer(withId: "poi-label", type: SymbolLayer.self) { layer in
            print("Setting within")
            layer.filter = Exp(.any) {
                Exp(.within) {
                    geojson
                }
            }
        }
    }

    func valueToLayerName(_ val: Int) -> String {
        return String(val)
    }

    func hideLayer(_ layer: String) {
        try? mapView.mapboxMap.style.updateLayer(withId: layer, type: LineLayer.self) { layer in
                print("hideLayer(lineLayer)", layer)
                layer.lineOpacity = .constant(0.0)
        }
    }

    func showLayer(_ layer: String) {
        try? mapView.mapboxMap.style.updateLayer(withId: layer, type: LineLayer.self) { layer in
                print("showLayer(lineLayer)", layer)
                layer.lineOpacity = .constant(1.0)
        }
    }

    func getDirection() {
        guard let originCoordinate = currentLocation?.coordinate else {
            print("No current lcoation")
            return
        }
        guard case let .point(point) = self.selectedFeature?.geometry else {
            print("No destination")
            return
        }
        print("ready")
        
        let origin = Waypoint(coordinate: originCoordinate, name: "Current Location")
        let destination = Waypoint(coordinate: point.coordinates, name: "White House")

        // Set options
        let routeOptions = NavigationRouteOptions(
            waypoints: [origin, destination],
            profileIdentifier: .walking)

        // Request a route using MapboxDirections
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                guard let route = response.routes?.first else {
                    return
                }
                let time = route.expectedTravelTime
                // Pass the generated route response to the the NavigationViewController
//                let viewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions)
//                viewController.modalPresentationStyle = .fullScreen
//                strongSelf.present(viewController, animated: true, completion: nil)
            }
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
            let opts = IsochroneOptions(
                centerCoordinate: location,
                contours:
                    IsochroneOptions.Contours.byExpectedTravelTimes([.init(value: Double(key), unit: .minutes)]),
                profileIdentifier: .walking
            )
            opts.contoursFormat = .polygon
            isochrones.calculate(opts) { session, result in
                if case .success(let response) = result {
                    print("Key", key)
                    if let first = response.features.first {
                        first.geometry
                        let encoder = JSONEncoder()
                        let data = try! encoder.encode(first)
                        let geoJSONString = String(data: data, encoding: .utf8)!
                        print("geoJSONString", geoJSONString)
                        if let geoJSON = try? JSONDecoder().decode(GeoJSONObject.self, from: data) {
                            self.minutesToGeoJSON[self.valueToLayerName(key)] = geoJSON
                        }
                    }
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
            self.switchLayer(to: self.valueToLayerName(self.initialMinutes))
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

            var lineLayer = LineLayer(id: layerName)
            lineLayer.source = layerName
            lineLayer.lineColor = .constant(StyleColor(.orange))
            lineLayer.lineOpacity = .constant(0.0)
            lineLayer.lineOpacityTransition = .init(duration: 0.2, delay: 0)
            lineLayer.lineWidth = .constant(4)
            try! mapView.mapboxMap.style.addSource(geoJSONSource, id: layerName)
            try! mapView.mapboxMap.style.addLayer(lineLayer)
            print("addLayer(lineLayer)", lineLayer)
        } catch {
            print("Error when adding sources and layers: \(error.localizedDescription)")
        }
    }
    
    @objc private func onMapClick(_ sender: UITapGestureRecognizer) {
        print("Tap")
        let screenPoint = sender.location(in: mapView)
        let queryOptions = RenderedQueryOptions(layerIds: ["poi-label"], filter: nil)
        mapView.mapboxMap.queryRenderedFeatures(at: screenPoint, options: queryOptions) { [weak self] result in
            if case let .success(queriedFeatures) = result,
               let feature = queriedFeatures.first?.feature {
                self?.selectedFeature = feature
                if let name = feature.properties?["name"],
                   case let .string(namestr) = name
                {
                    self?.cardTitle.text = namestr
                }
//                if let walkMin = feature.properties?["name"] as? String {
//                    self?.cardWalkMin.text = "3 minute walk"
//                }
            }
        }
    }
}


extension BasicMapExample: LocationProviderDelegate {
    public func locationProvider(_ provider: LocationProvider, didUpdateLocations locations: [CLLocation]) {
        print("Location", locations)
        guard let first = locations.first else {
            return
        }
        self.currentLocation = first
        
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
