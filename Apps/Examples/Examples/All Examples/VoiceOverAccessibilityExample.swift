import UIKit
import CoreLocation
import MapboxMaps

final class VoiceOverAccessibilityExample: UIViewController, ExampleProtocol {
    struct MyData {
        var id: Int
        var coordinate: CLLocationCoordinate2D
        var name: String
    }

    let data: [MyData] = [
        MyData(id: 0, coordinate: .init(latitude: 40.727405, longitude: -73.981926), name: "Tomkins Square Park"),
        MyData(id: 1, coordinate: .init(latitude: 40.7308963, longitude: -73.998694), name: "Washington Square Park"),
        MyData(id: 2, coordinate: .init(latitude: 40.715225, longitude: -74.000086), name: "Columbus Park"),
        MyData(id: 3, coordinate: .init(latitude: 40.692813, longitude: -73.976161), name: "Fort Greene Park")]

    var mapView: MapView!
    var pointAnnotationManager: PointAnnotationManager!
    var instructionsLabel: UILabel!

    var currentLocationAccessibilityElement: UIAccessibilityElement? {
        didSet {
            accessibilityElementsDidChange()
        }
    }

    var annotationAccessibilityElements = [UIAccessibilityElement]() {
        didSet {
            accessibilityElementsDidChange()
        }
    }

    var routeShieldAccessibilityElements = [UIAccessibilityElement]() {
        didSet {
            accessibilityElementsDidChange()
        }
    }

    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7131854, longitude: -74.0165265)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate, zoom: 10))
        mapView = MapView(frame: view.frame, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.isAccessibilityElement = false
        mapView.accessibilityElements = []

        let location = Location(coordinate: centerCoordinate)
        mapView.location.override(locationProvider: Signal(just: [location]))
        mapView.location.options.puckType = .puck2D(.makeDefault())

        // create point annotation manager to house point annotations
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        pointAnnotationManager.annotations = data.map { dataElement in
            var annotation = PointAnnotation(id: dataElement.id.description, coordinate: dataElement.coordinate)
            annotation.image = .init(image: UIImage(named: "dest-pin")!, name: "custom_marker")
            annotation.customData = ["name": .string(dataElement.name)]
            annotation.iconOffset = [0, 12]
            return annotation
        }

        // configure example instructions label
        instructionsLabel = UILabel()
        instructionsLabel.backgroundColor = .lightGray
        instructionsLabel.textColor = .black
        instructionsLabel.text = "Turn on VoiceOver to interact with the annotations."
        instructionsLabel.textAlignment = .center
        instructionsLabel.lineBreakMode = .byWordWrapping
        instructionsLabel.numberOfLines = 0
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionsLabel)
        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)])
        instructionsLabel.isHidden = UIAccessibility.isVoiceOverRunning
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverStatusDidChange),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil)

        // Observe events that require recomputing accessibility elements
        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.updateAllAccessibilityElements {
                self?.finish()
            }
        }.store(in: &cancelables)
        mapView.gestures.delegate = self
        mapView.location.onLocationChange.observe { [weak self] location in
            guard let self, let location = location.last else { return }
            self.updateLocationAccessibilityElement(location: location)
        }.store(in: &cancelables)
    }

    @objc private func voiceOverStatusDidChange() {
        instructionsLabel.isHidden = UIAccessibility.isVoiceOverRunning
    }

    func accessibilityElementsDidChange() {
        let summaryAccessibilityElement = UIAccessibilityElement(accessibilityContainer: mapView!)
        summaryAccessibilityElement.accessibilityIdentifier = "map-view-summary"
        summaryAccessibilityElement.accessibilityFrame = UIAccessibility.convertToScreenCoordinates(mapView.bounds, in: mapView)

        switch annotationAccessibilityElements.count {
        case 0:
            summaryAccessibilityElement.accessibilityLabel = "Map view selected. There are 0 visible annotations."
        case 1:
            summaryAccessibilityElement.accessibilityLabel = "Map view selected. There is 1 visible annotation: \(annotationAccessibilityElements.first!.accessibilityLabel!)."
        default:
            summaryAccessibilityElement.accessibilityLabel = "Map view selected. There are \(annotationAccessibilityElements.count) visible annotations: \(annotationAccessibilityElements.compactMap { $0.accessibilityLabel }.joined(separator: ", "))."
        }

        var allAccessibilityElements = [summaryAccessibilityElement]
        if let currentLocationAccessibilityElement = currentLocationAccessibilityElement {
            allAccessibilityElements.append(currentLocationAccessibilityElement)
        }
        allAccessibilityElements.append(contentsOf: annotationAccessibilityElements)
        allAccessibilityElements.append(contentsOf: routeShieldAccessibilityElements)

        mapView.accessibilityElements = allAccessibilityElements
    }

    func updateLocationAccessibilityElement(location: Location) {
        if let accessibilityFrame = mapView.accessibilityFrame(for: location.coordinate) {
            let element = UIAccessibilityElement(accessibilityContainer: mapView!)
            element.accessibilityIdentifier = "puck"
            element.accessibilityLabel = "Current Location"
            element.accessibilityFrame = accessibilityFrame
            currentLocationAccessibilityElement = element
        } else {
            currentLocationAccessibilityElement = nil
        }
    }

    func updateAllAccessibilityElements(completion: @escaping () -> Void = {}) {
        let group = DispatchGroup()

        // update accessibility elements for annotations
        group.enter()
        let pointAnnotationsQueryOptions = RenderedQueryOptions(
            layerIds: [pointAnnotationManager.layerId],
            filter: nil)
        mapView.mapboxMap.queryRenderedFeatures(
            with: mapView.safeAreaLayoutGuide.layoutFrame,
            options: pointAnnotationsQueryOptions) { [weak self] result in
                guard let self = self, let mapView = self.mapView else { return }
                switch result {
                case .success(let queriedFeatures):
                    self.annotationAccessibilityElements = queriedFeatures.compactMap { queriedFeature -> UIAccessibilityElement? in
                        guard case .point(let point) = queriedFeature.queriedFeature.feature.geometry,
                              let accessibilityFrame = mapView.accessibilityFrame(for: point.coordinates),
                              let properties = queriedFeature.queriedFeature.feature.properties?.rawValue as? [String: Any],
                              let customData = properties["custom_data"] as? [String: Any],
                              let name = customData["name"] as? String else {
                            return nil
                        }
                        let element = UIAccessibilityElement(accessibilityContainer: mapView)
                        element.accessibilityIdentifier = queriedFeature.queriedFeature.feature.identifier?.description
                        element.accessibilityFrame = accessibilityFrame
                        element.accessibilityLabel = name
                        return element
                    }
                case .failure(let error):
                    self.annotationAccessibilityElements = []
                    print(error)
                }
                group.leave()
            }

        // update accessibility elements for route shields
        group.enter()
        let routeShieldsQueryOptions = RenderedQueryOptions(
            layerIds: ["road-number-shield"],
            filter: Exp(.eq) {
                Exp(.get) {
                    "shield"
                }
                "us-interstate"
            })
        mapView.mapboxMap.queryRenderedFeatures(
            with: mapView.safeAreaLayoutGuide.layoutFrame,
            options: routeShieldsQueryOptions) { [weak self] result in
                guard let self = self, let mapView = self.mapView else { return }
                switch result {
                case .success(let queriedFeatures):
                    // create the UIAccessibility element for each route shield in the map view.
                    self.routeShieldAccessibilityElements = queriedFeatures.compactMap { queriedFeature -> UIAccessibilityElement? in
                        guard case .point(let point) = queriedFeature.queriedFeature.feature.geometry,
                              let accessibilityFrame = mapView.accessibilityFrame(for: point.coordinates),
                              let properties = queriedFeature.queriedFeature.feature.properties?.rawValue as? [String: Any],
                              let shieldNumber = properties["ref"] as? String else {
                            return nil
                        }
                        let element = UIAccessibilityElement(accessibilityContainer: mapView)
                        element.accessibilityIdentifier = "shield-\(shieldNumber)"
                        element.accessibilityLabel = "U.S. interstate \(shieldNumber)"
                        element.accessibilityFrame = accessibilityFrame
                        return element
                    }
                case .failure(let error):
                    self.routeShieldAccessibilityElements = []
                    print(error)
                }
                group.leave()
            }

        group.notify(queue: .main, execute: completion)
    }
}

extension VoiceOverAccessibilityExample: GestureManagerDelegate {
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
    }

    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        if !willAnimate {
            updateAllAccessibilityElements()
        }
    }

    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        updateAllAccessibilityElements()
    }
}

private extension MapView {
    func accessibilityFrame(for coordinate: CLLocationCoordinate2D) -> CGRect? {
        let pointInViewSpace = mapboxMap.point(for: coordinate)
        guard pointInViewSpace != CGPoint(x: -1, y: -1) else {
            return nil
        }
        let rectInViewSpace = CGRect(origin: pointInViewSpace, size: .zero).insetBy(dx: -20, dy: -20)
        return UIAccessibility.convertToScreenCoordinates(rectInViewSpace, in: self)
    }
}

extension FeatureIdentifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .number(let number):
            return number.description
        case .string(let string):
            return string
        #if USING_TURF_WITH_LIBRARY_EVOLUTION
        @unknown default:
            return String(describing: self)
        #endif
        }
    }
}
