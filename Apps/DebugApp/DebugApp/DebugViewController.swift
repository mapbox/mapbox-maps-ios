import UIKit
@_spi(Experimental) import MapboxMaps
import CoreLocation

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

public struct Speed {
    public static let `default` = Speed(linear: 10, angular: .greatestFiniteMagnitude)
    public static let car = Speed(linear: 15, angular: .greatestFiniteMagnitude)
    public static let bike = Speed(linear: 5, angular: .greatestFiniteMagnitude)
    public static let electricScooter = Speed(linear: 7, angular: .greatestFiniteMagnitude)
    public static let pedestrian = Speed(linear: 2, angular: .greatestFiniteMagnitude)
    public static let light = Speed(linear: 299792458, angular: .greatestFiniteMagnitude)

    public let linear: Double
    public let angular: Double

    public init(linear: Double, angular: Double) {
        self.linear = linear
        self.angular = angular
    }

    func distanceInTime(_ time: CFTimeInterval) -> Double {
        return linear * time
    }
}

public final class Journey {
    public final class Leg {
        public var speed: Speed?
        public let destination: CLLocationCoordinate2D
        internal var travelled: Bool = false

        public init(destination: CLLocationCoordinate2D, speed: Speed? = nil) {
            self.destination = destination
            self.speed = speed
        }
    }

    public private(set) var legs: [Leg]
    private var _currentLeg: Leg?

    init(start: CLLocationCoordinate2D) {
        let startLeg = Leg(destination: start)
        startLeg.travelled = true
        legs = [startLeg]
    }

    public func add(leg: Leg) {
        legs.append(leg)
    }

    internal func currentLeg() -> Leg? {
        return legs.first(where: { !$0.travelled })
    }

    var isAtTheEnd: Bool {
        guard !legs.isEmpty else {
            return true
        }
        if currentLeg() == nil {
            return true
        }
        return false
    }

    func markCurrentLegAsTravelled() {
        currentLeg()?.travelled = true
    }

    func add(_ leg: Leg) {
        legs.append(leg)
    }

    internal var travelledLegs: [Leg] {
        return legs.filter(\.travelled)
    }

    internal var untravelledLegs: [Leg] {
        return legs.filter { !$0.travelled }
    }
}

internal protocol AssetDelegate: AnyObject {
    func asset(_ asset: Asset, locationDidUpdate newLocation: CLLocationCoordinate2D)
}

public final class Asset {
    public enum Appearance {
        case model(URL)
        case icon(UIImage, String)

        var imageId: String? {
            if case Appearance.icon(_, let id) = self {
                return id
            }

            return nil
        }

        var modelId: String? {
            if case Appearance.model(let URL) = self {
                return URL.absoluteString
            }

            return nil
        }
    }
    internal private(set) var currentLocation: CLLocationCoordinate2D

    public let journey: Journey

    public var speed: Speed?

    public let id: String
    internal weak var delegate: AssetDelegate?

    private func resolveSpeed(for leg: Journey.Leg) -> Speed {
        return leg.speed ?? speed ?? .default
    }
    internal var appearance: Appearance

    public init(coordinate: CLLocationCoordinate2D, appearance: Appearance) {
        self.currentLocation = coordinate
        self.journey = Journey(start: coordinate)
        self.appearance = appearance
        self.id = UUID().uuidString
    }

    internal func moveBy(elapsedTime: CFTimeInterval, speedOverride: Speed?) {
        guard !journey.isAtTheEnd, let currentLeg = journey.currentLeg() else {
            return
        }

        let speed = speedOverride ?? resolveSpeed(for: currentLeg)
        let current = LocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let direction = current.direction(to: currentLeg.destination)
        let projectedDistance = speed.distanceInTime(elapsedTime)
        let maxDistance = current.distance(to: currentLeg.destination)
        let incrementDistance = min(maxDistance, projectedDistance)
        let increment = current.coordinate(at: incrementDistance, facing: direction)

        if incrementDistance >= maxDistance {
            journey.markCurrentLegAsTravelled()
        }

        currentLocation = CLLocationCoordinate2D(latitude: increment.latitude, longitude: increment.longitude)
        delegate?.asset(self, locationDidUpdate: currentLocation)
    }

    internal var travelledPath: [CLLocationCoordinate2D] {
        var path = journey.travelledLegs.map(\.destination)
        path.append(currentLocation)
        return path
    }

    internal var untravelledPath: [CLLocationCoordinate2D] {
        var path = journey.untravelledLegs.map(\.destination)
        path.insert(currentLocation, at: 0)
        return path
    }

    public func setup(with style: Style) throws {
        switch appearance {
        case .model(let URL):
            if !style.modelExists(withId: URL.absoluteString) {
                try style.addModel(withId: URL.absoluteString, modelURI: URL.absoluteString)
            }
        case .icon(let image, let id):
            if !style.imageExists(withId: id) {
                try style.addImage(image, id: id)
            }
        }
    }
}

public final class Logistics {
    public var assets = [Asset]() {
        didSet {
            assets.forEach { $0.delegate = self }
            updateImageModelExpression()
            try! setupAssets()
        }
    }

    public var speed: Speed?
    public var trackedAsset: Asset?
    public var showDebugOverlays = false

    private weak var map: MapboxMap?
    private var displayLink: CADisplayLink? {
        didSet { oldValue?.invalidate() }
    }

    deinit {
        displayLink?.invalidate()
    }

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFromDisplayLink(displayLink:)))
    }

    public func asset(with id: String) -> Asset? {
        return assets.first { $0.id == id }
    }

    public func setup(with map: MapboxMap) throws {
        self.map = map

        try map.style.addImage(UIImage(named: "red_marker")!, id: "default_icon")

        var source = GeoJSONSource()
        source.data = .empty

        try map.style.addSource(source, id: "my-source-id")

        // Create a symbol layer
        var symbolLayer = SymbolLayer(id: "layer-id")
        symbolLayer.source = "my-source-id"
        symbolLayer.iconIgnorePlacement = .constant(true)
        symbolLayer.iconAllowOverlap = .constant(true)

        try map.style.addLayer(symbolLayer)

        var layer = ModelLayer(id: "model-layer-id")
        layer.source = "my-source-id"
        layer.modelType = .constant(.common3d)
        layer.modelScale = .constant([10, 10, 10])
        layer.modelTranslation = .constant([0, 0, 0])
        layer.modelRotation = .constant([0, 0, 90])
        layer.modelOpacity = .constant(0.7)

        try! map.style.addLayer(layer)

        // Debug lines

        try map.style.addSource(source, id: "travelled-paths-source")
        try map.style.addSource(source, id: "untravelled-paths-source")

        var lineLayer = LineLayer(id: "travelled-paths-layer")
        lineLayer.source = "travelled-paths-source"
        lineLayer.lineColor = .constant(StyleColor(.gray.withAlphaComponent(0.7)))

        let lowZoomWidth = 2
        let highZoomWidth = 10

        // Use an expression to define the line width at different zoom extents
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

        try map.style.addLayer(lineLayer, layerPosition: .below(symbolLayer.id))

        lineLayer.id = "untravelled-paths-layer"
        lineLayer.source = "untravelled-paths-source"
        lineLayer.lineColor = .constant(StyleColor(.systemBlue.withAlphaComponent(0.7)))

        try map.style.addLayer(lineLayer, layerPosition: .below(symbolLayer.id))

        updateImageModelExpression()
        try setupAssets()

        displayLink?.add(to: .current, forMode: .common)
    }

    private func setupAssets() throws {
        guard let style = map?.style else {
            return
        }

        try assets.forEach { try $0.setup(with: style)}
    }

    private func updateImageModelExpression() {
        guard !assets.isEmpty else {
            return
        }
        let arguments = Set(assets
            .compactMap(\.appearance.imageId))
            .flatMap { [$0, $0] }
            .map(Expression.Argument.string)
        let expression = Exp(operator: .get, arguments: [.string("icon")])
        let imageExpression = Exp(operator: .match, arguments: [.expression(expression)] + arguments + [.string("")])

        try! map?.style.updateLayer(withId: "layer-id", type: SymbolLayer.self, update: { layer in
            layer.iconImage = .expression(imageExpression)
        })

        try! map?.style.updateLayer(withId: "model-layer-id", type: ModelLayer.self, update: { layer in
            layer.modelId = .expression(Exp(.get) { "model-id" })
        })
    }

    @objc private func updateFromDisplayLink(displayLink: CADisplayLink) {
        guard let style = map?.style else {
            self.displayLink = nil
            return
        }

        let projectedElapsedTime = displayLink.targetTimestamp - displayLink.timestamp

        assets.forEach { $0.moveBy(elapsedTime: projectedElapsedTime, speedOverride: speed) }

        if showDebugOverlays {
            let travelledLines = assets.map(\.travelledPath).map(LineString.init).map(Feature.init)
            try! style.updateGeoJSONSource(withId: "travelled-paths-source",
                                           geoJSON: FeatureCollection(features: travelledLines).geoJSONObject)
            let untravelledLines = assets.map(\.untravelledPath).map(LineString.init).map(Feature.init)
            try! style.updateGeoJSONSource(withId: "untravelled-paths-source",
                                           geoJSON: FeatureCollection(features: untravelledLines).geoJSONObject)
        }

        let features = assets.map { asset -> Feature in
            var feature = Feature(geometry: Point(asset.currentLocation))
            feature.properties = ["asset-id": .string(asset.id)]

            if let id = asset.appearance.imageId {
                feature.properties!["icon"] = .string(id)
            }
            if let id = asset.appearance.modelId {
                feature.properties!["model-id"] = .string(id)
            }

            return feature
        }
        try! style.updateGeoJSONSource(withId: "my-source-id",
                                       geoJSON: FeatureCollection(features: features).geoJSONObject)
    }
}

extension Logistics: AssetDelegate {
    func asset(_ asset: Asset, locationDidUpdate newLocation: CLLocationCoordinate2D) {
        if asset === trackedAsset {
            map?.setCamera(to: CameraOptions(center: newLocation))
       }
    }
}

final class DebugViewController: UIViewController {

    var mapView: MapView!
    private let logistics = Logistics()
    private var selectedAsset: Asset?

    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraOptions = CameraOptions(zoom: 15)
        let initOptions = MapInitOptions(cameraOptions: cameraOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: initOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(mapView, at: 0)

        logistics.showDebugOverlays = true
        mapView.location.options.puckType = .puck2D()

        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            if let location = self.mapView.location.latestLocation?.coordinate {
                self.mapView.mapboxMap.setCamera(to: CameraOptions(center: location))
            }

            try! self.logistics.setup(with: self.mapView.mapboxMap)

            let image = UIImage(systemName: "bicycle")!
            let asset = Asset(coordinate: self.mapView.cameraState.center, appearance: .icon(image, "bicycle"))
            self.logistics.assets.append(asset)
        }

        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updatePosition(_:))))
    }

    @objc private func updatePosition(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        let newCoordinate = mapView.mapboxMap.coordinate(for: point)

        let options = RenderedQueryOptions(layerIds: ["layer-id", "model-layer-id"], filter: nil)
        let rect = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
        mapView.mapboxMap.queryRenderedFeatures(with: rect, options: options) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let features):
                if features.isEmpty {
                    self.selectedAsset?.journey.add(.init(destination: newCoordinate))
                    return
                }
                if let unwrapped = features.first?.feature.properties?["asset-id"], let doubleUnwrapped = unwrapped,
                    case JSONValue.string(let assetId) = doubleUnwrapped {
                    if let asset = self.logistics.asset(with: assetId) {
                        self.selectedAsset = asset
                    }
                }
            case .failure:
                fatalError()
            }
        }
    }

    func randomCoordinateInCurrentViewport() -> CLLocationCoordinate2D {
        let bounds = mapView.mapboxMap.coordinateBounds(for: view.bounds)
        return CLLocationCoordinate2D(latitude: .random(in: bounds.south...bounds.north),
                                                longitude: .random(in: bounds.west...bounds.east))
    }
}

extension DebugViewController {
    @IBAction func addPedestrianPressed(_ sender: UIButton) {
        let image = UIImage(systemName: "figure.walk")!
        let asset = Asset(coordinate: randomCoordinateInCurrentViewport(), appearance: .icon(image, "figure.walk"))
        asset.speed = .pedestrian
        self.logistics.assets.append(asset)
    }

    @IBAction func addBikePressed(_ sender: UIButton) {
        let image = UIImage(systemName: "bicycle")!
        let asset = Asset(coordinate: randomCoordinateInCurrentViewport(), appearance: .icon(image, "bicycle"))
        asset.speed = .bike
        self.logistics.assets.append(asset)
    }

    @IBAction func addScooterPressed(_ sender: UIButton) {
        let image = UIImage(systemName: "scooter")!
        let asset = Asset(coordinate: randomCoordinateInCurrentViewport(), appearance: .icon(image, "scooter"))
        asset.speed = .electricScooter
        self.logistics.assets.append(asset)
    }

    @IBAction func add3DCarPressed(_ sender: UIButton) {
        let modelURL = Bundle.main.url(forResource: "sportcar", withExtension: "glb")!
        let asset = Asset(coordinate: randomCoordinateInCurrentViewport(), appearance: .model(modelURL))
        asset.speed = .car
        self.logistics.assets.append(asset)
    }

    @IBAction func addCarPressed(_ sender: UIButton) {
        let image = UIImage(systemName: "car")!
        let asset = Asset(coordinate: randomCoordinateInCurrentViewport(), appearance: .icon(image, "car"))
        asset.speed = .car
        self.logistics.assets.append(asset)
    }

    @IBAction func slowPressed(_ sender: UIButton) {
        if let asset = selectedAsset {
            asset.speed = .pedestrian
        } else {
            logistics.speed = .pedestrian
        }
    }

    @IBAction func fastPressed(_ sender: UIButton) {
        if let asset = selectedAsset {
            asset.speed = .veryFastCar
        } else {
            logistics.speed = .veryFastCar
        }
    }

    @IBAction func clearSpeedOverridePressed(_ sender: UIButton) {
        if let asset = selectedAsset {
            asset.speed = nil
        } else {
            logistics.speed = nil
        }
    }

    @IBAction func clearSelectionButtonPressed(_ sender: UIButton) {
        selectedAsset = nil
    }

    @IBAction func trackButtonPressed(_ sender: UIButton) {
        logistics.trackedAsset = selectedAsset
    }

    @IBAction func clearTrackingPressed(_ sender: UIButton) {
        logistics.trackedAsset = nil
    }

}

extension Speed {
    static let veryFastCar = Speed(linear: 30, angular: .greatestFiniteMagnitude)
}
