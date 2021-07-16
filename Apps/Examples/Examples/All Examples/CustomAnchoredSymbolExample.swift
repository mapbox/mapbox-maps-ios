import UIKit
import MapboxMaps
import Turf

private enum SymbolTailPosition: Int {
    case left
    case right
    case center
}

private struct DebugFeature {
    var coordinate: CLLocationCoordinate2D
    var highlighted: Bool
    var sortOrder: Int
    var tailPosition: SymbolTailPosition
    var label: String
    var imageName: String
}

@objc(CustomAnchoredSymbolExample)
public class CustomAnchoredSymbolExample: UIViewController, ExampleProtocol {
    static let symbols = "custom_symbols"

    internal var mapView: MapView!

    // Configure a label
    public lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.systemBlue
        label.layer.cornerRadius = 12.0
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24.0)
        return label
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Center the map camera over New York City
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let options = MapInitOptions(cameraOptions: CameraOptions(center: centerCoordinate,
                                                                  zoom: 15.0))

        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector((mapSymbolTap(sender:))))
        mapView.addGestureRecognizer(tapGestureRecognizer)

        // Allows the delegate to receive information about map events.
        mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }

            self.updateSymbolImages()
            let features = self.addFeatures()
            self.addSymbolLayer(features: features)

            // The below line is used for internal testing purposes only.
            self.finish()
        }

        // Add the label on top of the map view controller.
        addLabel()
    }

    public func addLabel() {
        label.text = "Select A Marker"
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            label.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }

    @objc private func mapSymbolTap(sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            let layers: [String] = [CustomAnchoredSymbolExample.symbols]

            mapView.mapboxMap.queryRenderedFeatures(at: sender.location(in: mapView),
                                                    options: RenderedQueryOptions(layerIds: layers, filter: nil)) { result in
                switch result {
                case .success(let features):
                    if features.count > 0 {
                        guard  let featureText = features[0].feature.properties["text"] as? String else { return }
                        self.label.text = featureText
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateSymbolImages() {
        let style = mapView.mapboxMap.style

        let regularTintColor = UIColor.white
        let highlightTintColor = UIColor(hue: 0.831372549, saturation: 0.72, brightness: 0.59, alpha: 1.0)

        // Centered pin
        if let image =  UIImage(named: "ImageCalloutCentered") {
            let stretchX = [ImageStretches(first: Float(10), second: Float(15)), ImageStretches(first: Float(45), second: Float(50))]
            let stretchY = [ImageStretches(first: Float(13), second: Float(16))]
            let imageContent = ImageContent(left: 10, top: 13, right: 50, bottom: 16)

            try? style.addImage(image.tint(regularTintColor),
                                id: "imageCentered",
                                sdf: false,
                                stretchX: stretchX,
                                stretchY: stretchY,
                                content: imageContent)

            try? style.addImage(image.tint(highlightTintColor),
                                id: "imageCentered-Highlighted",
                                sdf: false,
                                stretchX: stretchX,
                                stretchY: stretchY,
                                content: imageContent)
        }

        let stretchX = [ImageStretches(first: Float(16), second: Float(21))]
        let stretchY = [ImageStretches(first: Float(13), second: Float(16))]
        let imageContent = ImageContent(left: 16, top: 13, right: 23, bottom: 16)

        // Right-hand pin
        if let image =  UIImage(named: "ImageCalloutRightHanded") {
            try? style.addImage(image.tint(regularTintColor),
                                id: "imageRightHanded",
                                sdf: false,
                                stretchX: stretchX,
                                stretchY: stretchY,
                                content: imageContent)

            try? style.addImage(image.tint(highlightTintColor),
                                id: "imageRightHanded-Highlighted",
                                sdf: false,
                                stretchX: stretchX,
                                stretchY: stretchY,
                                content: imageContent)
        }

        // Left-hand pin
        if let image =  UIImage(named: "ImageCalloutLeftHanded") {
            try? style.addImage(image.tint(regularTintColor),
                                id: "imageLeftHanded",
                                sdf: false,
                                stretchX: stretchX,
                                stretchY: stretchY,
                                content: imageContent)

            try? style.addImage(image.tint(highlightTintColor),
                                id: "imageLeftHanded-Highlighted",
                                sdf: false,
                                stretchX: stretchX,
                                stretchY: stretchY,
                                content: imageContent)
        }
    }

    private func addFeatures() -> FeatureCollection {

        var features = [Turf.Feature]()

        let featureList = [
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.714203, -74.006314), highlighted: false, sortOrder: 0, tailPosition: .left, label: "Chambers & Broadway - Lefthand Stem", imageName: "imageLeftHanded"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.707918, -74.006008), highlighted: false, sortOrder: 0, tailPosition: .right, label: "Cliff & John - Righthand Stem", imageName: "imageRightHanded"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.716281, -74.004526), highlighted: true, sortOrder: 1, tailPosition: .right, label: "Broadway & Worth - Right Highlighted", imageName: "imageRightHanded-Highlighted"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.710194, -74.004248), highlighted: true, sortOrder: 1, tailPosition: .left, label: "Spruce & Gold - Left Highlighted", imageName: "imageLeftHanded-Highlighted"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.7128, -74.0060), highlighted: true, sortOrder: 2, tailPosition: .center, label: "City Hall - Centered Highlighted", imageName: "imageCentered-Highlighted"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.711427, -74.008614), highlighted: false, sortOrder: 3, tailPosition: .center, label: "Broadway & Vesey - Centered Stem", imageName: "imageCentered")
        ]

        for (index, feature) in featureList.enumerated() {
            let point = Turf.Point(feature.coordinate)
            var pointFeature = Feature(geometry: .point(point))

            // Set the feature attributes which will be used in styling the symbol style layer.
            pointFeature.properties = ["highlighted": feature.highlighted,
                                       "tailPosition": feature.tailPosition.rawValue,
                                       "text": feature.label,
                                       "imageName": feature.imageName,
                                       "sortOrder": feature.highlighted == true ? index : -index]

            features.append(pointFeature)
        }

        return FeatureCollection(features: features)
    }

    private func addSymbolLayer(features: FeatureCollection) {
        if mapView.mapboxMap.style.sourceExists(withId: CustomAnchoredSymbolExample.symbols) {
            try? mapView.mapboxMap.style.updateGeoJSONSource(withId: CustomAnchoredSymbolExample.symbols, geoJSON: features)
        } else {
            var dataSource = GeoJSONSource()
            dataSource.data = .featureCollection(features)
            try? mapView.mapboxMap.style.addSource(dataSource, id: CustomAnchoredSymbolExample.symbols)
        }

        var shapeLayer: SymbolLayer

        if mapView.mapboxMap.style.layerExists(withId: CustomAnchoredSymbolExample.symbols) {
            shapeLayer = try! mapView.mapboxMap.style.layer(withId: CustomAnchoredSymbolExample.symbols) as SymbolLayer
        } else {
            shapeLayer = SymbolLayer(id: CustomAnchoredSymbolExample.symbols)
        }

        shapeLayer.source = CustomAnchoredSymbolExample.symbols

        shapeLayer.textField = .expression(Exp(.get) {
            "text"
        })

        shapeLayer.iconImage = .expression(Exp(.get) {
            "imageName"
        })

        shapeLayer.textColor = .expression(Exp(.switchCase) {
            Exp(.any) {
                Exp(.get) {
                    "highlighted"
                }
            }
            UIColor.white
            UIColor.black
        })

        shapeLayer.textSize = .constant(16)
        shapeLayer.iconTextFit = .constant(.both)
        shapeLayer.iconAllowOverlap = .constant(true)
        shapeLayer.textAllowOverlap = .constant(true)
        shapeLayer.textJustify = .constant(.left)
        shapeLayer.symbolZOrder = .constant(.auto)
        shapeLayer.symbolSortKey = .expression(Exp(.get) { "sortOrder" })
        shapeLayer.textFont = .constant(["DIN Pro Medium"])

        let expression = Exp(.switchCase) {
            Exp(.eq) {
                Exp(.get) { "tailPosition" }
                0
            }
            "bottom-left"
            Exp(.eq) {
                Exp(.get) { "tailPosition" }
                1
            }
            "bottom-right"
            Exp(.eq) {
                Exp(.get) { "tailPosition" }
                2
            }
            "bottom"
            ""
        }
        shapeLayer.textAnchor = .expression(expression)

        let offsetExpression = Exp(.switchCase) {
            Exp(.eq) {
                Exp(.get) { "tailPosition" }
                0
            }
            Exp(.literal) {
                [0.7, -2.0]
            }
            Exp(.eq) {
                Exp(.get) { "tailPosition" }
                1
            }
            Exp(.literal) {
                [-0.7, -2.0]
            }
            Exp(.eq) {
                Exp(.get) { "tailPosition" }
                2
            }
            Exp(.literal) {
                [-0.2, -2.0]
            }
            Exp(.literal) {
                [0.0, -2.0]
            }
        }
        shapeLayer.textOffset = .expression(offsetExpression)

        try? mapView.mapboxMap.style.addLayer(shapeLayer)
    }
}

extension UIImage {
    // Produce a copy of the image with tint color applied.
    // Useful for deployment to iOS versions prior to 13 where tinting support was added to UIImage natively.
    func tint(_ tintColor: UIColor) -> UIImage {
        let imageSize = size
        let imageScale = scale
        let contextBounds = CGRect(origin: .zero, size: imageSize)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, imageScale)

        defer { UIGraphicsEndImageContext() }

        UIColor.black.setFill()
        UIRectFill(contextBounds)
        draw(at: .zero)

        guard let imageOverBlack = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        tintColor.setFill()
        UIRectFill(contextBounds)

        imageOverBlack.draw(at: .zero, blendMode: .multiply, alpha: 1)
        draw(at: .zero, blendMode: .destinationIn, alpha: 1)

        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }

        return finalImage
    }
}
