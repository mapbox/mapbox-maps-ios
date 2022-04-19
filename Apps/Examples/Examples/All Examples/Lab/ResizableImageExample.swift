import Foundation
import UIKit
import MapboxMaps

/// An example showcasing of adding a resizable image to the style
/// and demonstrating how the image is stretched
@objc(ResizableImageExample)
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
    private var style: Style { mapView.mapboxMap.style }

    private var appendTextCounter = 1
    private var symbolLayer: SymbolLayer!
    private weak var timer: Timer? {
        didSet { oldValue?.invalidate() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.setupExample()
            self.startUpdatingIconText()
        }
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
        try? style.addImageResizable(image, id: "circle")

        // add a GeoJSON source with a single point to the style
        var source = GeoJSONSource()
        source.data = .feature(Feature(geometry: Point(Self.center)))

        try? style.addSource(source, id: geoJSONSourceId)

        // add a symbol layer with the resizable icon image
        symbolLayer = SymbolLayer(id: Self.layerId)
        symbolLayer.source = geoJSONSourceId
        symbolLayer.iconImage = .constant(.name("circle"))
        // make sure the icon image is stretched both vertically and horizontally
        symbolLayer.iconTextFit = .constant(.both)
        symbolLayer.iconTextFitPadding = .constant([10, 10, 10, 10])
        symbolLayer.textField = .constant(Self.textBase)

        try? style.addLayer(symbolLayer, layerPosition: .default)
    }

    private func startUpdatingIconText() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateIconText), userInfo: nil, repeats: true)
    }

    // Append some text to the layer's textField, stretching the icon image in both X and Y axes
    @objc private func updateIconText() {
        guard style.isLoaded else {
            return
        }

        let layer = try? style.layer(withId: Self.layerId, type: SymbolLayer.self)

        guard case .expression(let expression) = layer?.textField else {
            return
        }

        appendTextCounter += 1

        guard let textLabel = expression.arguments.first?.description
            .appending(Self.textBase)
            .appending(appendTextCounter % 3 == 0 ? "\n" : "") else {
            return
        }

        try? style.updateLayer(withId: Self.layerId, type: SymbolLayer.self) { layer in
            layer.textField = .constant(textLabel)
        }
    }
}
