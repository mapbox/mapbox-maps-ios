import UIKit
import CoreLocation
import MapboxMaps

struct MyData {
    var id: Int
    var coordinate: CLLocationCoordinate2D
    var name: String
}

@objc(VoiceOverAccessibilityExample)
class VoiceOverAccessibilityExample: UIViewController, ExampleProtocol {

    let data: [MyData] = [
        MyData(id: 0, coordinate: CLLocationCoordinate2D(latitude: 40.727405, longitude: -73.981926), name: "Tomkins Square Park"),
        MyData(id: 1, coordinate: CLLocationCoordinate2D(latitude: 40.7308963, longitude: -73.998694), name: "Washington Square Park"),
        MyData(id: 2, coordinate: CLLocationCoordinate2D(latitude: 40.715225, longitude: -74.000086), name: "Columbus Park"),
        MyData(id: 3, coordinate: CLLocationCoordinate2D(latitude: 40.692813, longitude: -73.976161), name: "Fort Greene Park")
    ]

    var mapView: MapViewView!
    var markerAccessibilityElements: [Int: UIAccessibilityElement] = [:]
    var routeShields: [UIAccessibilityElement] = []
    var pointAnnotation: PointAnnotation?
    var pointAnnotationManager: PointAnnotationManager?
    var visibleAnnotationArray: [PointAnnotation] = []
    var accessibilityInfoLabel = UILabel(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7131854, longitude: -74.0165265)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 10))
        mapView = MapViewView(frame: view.frame, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isAccessibilityElement = true

        view.addSubview(mapView)

        // set custom location to New York City using CustomLocationProvider
        let customLocationProvider = CustomLocationProvider(currentLocation: CLLocation(latitude: 40.7131854, longitude: -74.0165265))
        mapView.location.overrideLocationProvider(with: customLocationProvider)
        mapView.location.options.puckType = .puck2D()

        // create point annotation manager to house point annotations
        pointAnnotationManager =  mapView.annotations.makePointAnnotationManager(id: "annotation-manager")

        // configure example instructions label
        accessibilityInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        accessibilityInfoLabel.backgroundColor = .lightGray
        accessibilityInfoLabel.textColor = .black
        accessibilityInfoLabel.text = "Turn on VoiceOver to interact with the mapview annotations."
        accessibilityInfoLabel.textAlignment = .center
        accessibilityInfoLabel.lineBreakMode = .byWordWrapping
        accessibilityInfoLabel.numberOfLines = 0
        view.addSubview(accessibilityInfoLabel)
        labelConstraints()

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.calculateVisibleAnnotations()
            self.queryRenderedHighwayShields()
        }

        mapView.mapboxMap.onEvery(.cameraChanged) { _ in
            for datum in self.data {
                let element = self.markerAccessibilityElements[datum.id]
                element?.accessibilityFrame = self.mapView.rect(for: datum.coordinate)
            }

            // query newly visible route shields and location at current map view
            self.setUserLocation()
            self.queryRenderedHighwayShields()
        }

        mapView.coordinates = data.map(\.coordinate)

        // create UIAccessibilityElements from data
        for datum in data {
            let element = UIAccessibilityElement(accessibilityContainer: view!)
            element.accessibilityIdentifier = datum.id.description
            element.accessibilityFrame = mapView.rect(for: datum.coordinate)
            element.accessibilityLabel = datum.name
            markerAccessibilityElements[datum.id] = element

            pointAnnotation = PointAnnotation(id: datum.name, coordinate: datum.coordinate)
            pointAnnotation!.image = .init(image: UIImage(named: "custom_marker")!, name: "custom_marker")
            pointAnnotationManager?.annotations.append(pointAnnotation!)
        }

        // add shield layer elements to the array
        view.accessibilityElements = [Array(self.markerAccessibilityElements.values), self.mapView]
        calculateVisibleAnnotations()
    }

    func labelConstraints() {
        let safeAreaLayoutForView = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            accessibilityInfoLabel.topAnchor.constraint(equalTo: safeAreaLayoutForView.topAnchor),
            accessibilityInfoLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutForView.leadingAnchor),
            accessibilityInfoLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutForView.trailingAnchor),
        ])
    }

    func setUserLocation() {
        mapView.location.isAccessibilityElement = true
        mapView.location.accessibilityLabel = "Current location"
        mapView.location.accessibilityFrame = self.mapView.rect(for: (self.mapView.location.latestLocation?.location.coordinate)!)
        view.accessibilityElements?.append(self.mapView.location.latestLocation!)
    }

    func queryRenderedHighwayShields() {
        routeShields = []

        // reset accessibility elements aray to only include existing point
        // annotations, location annotation and mapview
        view.accessibilityElements = [Array(self.markerAccessibilityElements.values), self.mapView.location, self.mapView]

        // query route-shields visible in current map view
        mapView.mapboxMap.queryRenderedFeatures(
            in: mapView.safeAreaLayoutGuide.layoutFrame,
            options: RenderedQueryOptions(layerIds: ["road-number-shield"], filter: nil)) { [weak self] result in
                switch result {
                case .success(let queriedfeatures):
                    for queriedFeature in queriedfeatures {

                        let shield = queriedFeature.feature.properties!["shield"]!!.rawValue as! String
                        let shieldNumber = queriedFeature.feature.properties!["ref"]!!.rawValue as! String
                        let geometry = queriedFeature.feature.geometry

                        switch geometry {
                        case .point(let point):
                            // create the UIAccessibility element for each route
                            // shield in the map view.
                            let element = UIAccessibilityElement(accessibilityContainer: self?.mapView.mapboxMap.style)
                            element.accessibilityIdentifier = queriedFeature.feature.identifier.debugDescription
                            element.accessibilityLabel = "U.S. interstate \(shieldNumber)"
                            element.accessibilityFrame = (self?.mapView.rect(for: point.coordinates))!
                            self?.routeShields.append(element)
                            self?.view.accessibilityElements?.append(self?.routeShields)

                        case .geometryCollection(_):
                            break
                        case .lineString(_):
                            break
                        case .multiLineString(_):
                            break
                        case .multiPoint(_):
                            break
                        case .polygon(_):
                            break
                        case .multiPolygon(_):
                            break
                        case .none:
                            break
                        }
                    }

                case .failure(let error):
                    print("Error:", error)
                }
            }
    }

    func calculateVisibleAnnotations() {
        visibleAnnotationArray = []
        let cameraOptions = CameraOptions(cameraState: mapView.cameraState)
        for annotation in pointAnnotationManager!.annotations {
            if mapView.mapboxMap.coordinateBounds(for: cameraOptions).contains(forPoint: annotation.point.coordinates, wrappedCoordinates: true) {
                visibleAnnotationArray.append(annotation)
            }
        }
        if visibleAnnotationArray.count > 1 {
            mapView.accessibilityLabel = "Map view selected. There are \(visibleAnnotationArray.count) visible point annotations: \(visibleAnnotationArray.map {$0.id}). There are also other accessibility elements, including a location component and interstate route shields"
        } else if visibleAnnotationArray.count == 1 {
            mapView.accessibilityLabel = "Map view selected. There is \(visibleAnnotationArray.count) visible annotation: \(visibleAnnotationArray.first?.id)."
        } else if visibleAnnotationArray.count == 0 {
            mapView.accessibilityLabel = "Map view selected. There are no visible annotations."
        }
    }
}

class MapViewView: MapView {
    var coordinates: [CLLocationCoordinate2D] = []

    func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        let point = mapboxMap.point(for: coordinate)
        return point
    }

    func rect(for coordinate: CLLocationCoordinate2D) -> CGRect {
        CGRect(origin: point(for: coordinate), size: .zero).insetBy(dx: -20, dy: -20)
    }
}

class CustomLocationProvider: LocationProvider {
    var locationProviderOptions: LocationOptions

    let authorizationStatus: CLAuthorizationStatus

    let accuracyAuthorization: CLAccuracyAuthorization

    let heading: CLHeading?

    private let currentLocation: CLLocation

    private weak var delegate: LocationProviderDelegate?

    func setDelegate(_ delegate: LocationProviderDelegate) {
        self.delegate = delegate
        delegate.locationProvider(self, didUpdateLocations: [currentLocation])
        delegate.locationProviderDidChangeAuthorization(self)
    }

    func requestAlwaysAuthorization() {
        // not required for this example
    }

    func requestWhenInUseAuthorization() {
        // not required for this example
    }

    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String) {
        // not required for this example
    }

    func startUpdatingLocation() {
        // not required for this example
    }

    func stopUpdatingLocation() {
        // not required for this example
    }

    var headingOrientation: CLDeviceOrientation

    func startUpdatingHeading() {
        // not required for this example
    }

    func stopUpdatingHeading() {
        // not required for this example
    }

    func dismissHeadingCalibrationDisplay() {
        // not required for this example
    }

    init(currentLocation: CLLocation) {
        self.locationProviderOptions = .init()
        self.authorizationStatus = .notDetermined
        self.accuracyAuthorization = .fullAccuracy
        self.headingOrientation = .portrait
        self.heading = nil
        self.currentLocation = currentLocation
    }
}
