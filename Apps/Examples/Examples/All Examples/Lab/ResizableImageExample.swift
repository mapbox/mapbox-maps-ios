import Foundation
import UIKit
import MapboxMaps

/// An example showcasing of adding a resizable image to the style
/// and demonstrating how the image is stretched
final class ResizableImageExample: UIViewController, ExampleProtocol {
    private static let center = CLLocationCoordinate2DMake(55.70651, 12.554729)
    private static let layerId = "layer_id"
    private static let textBase = "Hi! "

    private lazy var mapView: MapView = {
        let mapInitOptions = MapInitOptions(cameraOptions: CameraOptions(center: Self.center, zoom: 9))
        let mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return mapView
    }()
    private var cancelables = Set<AnyCancelable>()

    private var appendTextCounter = 1
    private weak var timer: Timer? {
        didSet { oldValue?.invalidate() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
            self?.startUpdatingIconText()
        }.store(in: &cancelables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil {
            timer = nil
        }
    }

    // MARK: - Private

    private func setupExample() {
        let geoJSONSourceId = "source_id"

        // create an image of a circle and specify the corners that should remain unchanged
        let image = UIImage(named: "circle")!
            .resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        try? mapView.mapboxMap.addImage(image, id: "circle")

        // add a GeoJSON source with a single point to the style
        var source = GeoJSONSource(id: geoJSONSourceId)
        source.data = .feature(Feature(geometry: Point(Self.center)))

        try? mapView.mapboxMap.addSource(source)

        // add a symbol layer with the resizable icon image
        var symbolLayer = SymbolLayer(id: Self.layerId, source: geoJSONSourceId)
        symbolLayer.iconImage = .constant(.name("circle"))
        // make sure the icon image is stretched both vertically and horizontally
        symbolLayer.iconTextFit = .constant(.both)
        symbolLayer.iconTextFitPadding = .constant([10, 10, 10, 10])
        symbolLayer.textField = .constant(Self.textBase)

        try? mapView.mapboxMap.addLayer(symbolLayer, layerPosition: .default)
    }

    private func startUpdatingIconText() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.updateIconText()
        }
    }

    // Append some text to the layer's textField, stretching the icon image in both X and Y axes
    private func updateIconText() {
        guard mapView.mapboxMap.isStyleLoaded else {
            return
        }

        let layer = try? mapView.mapboxMap.layer(withId: Self.layerId, type: SymbolLayer.self)

        guard case .expression(let expression) = layer?.textField else {
            return
        }

        appendTextCounter += 1

        guard let textLabel = expression.arguments.first?.description
            .appending(Self.textBase)
            .appending(appendTextCounter % 3 == 0 ? "\n" : "") else {
            return
        }

        try? mapView.mapboxMap.updateLayer(withId: Self.layerId, type: SymbolLayer.self) { layer in
            layer.textField = .constant(textLabel)
        }
    }
}
