import UIKit
import MapboxMaps
import Turf

private enum AnnotationTailPosition: Int {
    case left
    case right
    case center
}

private struct DebugFeature {
    var coordinate: CLLocationCoordinate2D
    var highlighted: Bool
    var sortOrder: Int
    var tailPosition: AnnotationTailPosition
    var label: String
    var imageName: String
}

@objc(CustomSymbolAnnotationsExample)

public class CustomSymbolAnnotationsExample: UIViewController, ExampleProtocol {

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

        mapView = MapView(with: view.bounds, resourceOptions: resourceOptions())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector((mapSymbolTap(sender:))))
        mapView.addGestureRecognizer(tapGestureRecognizer)

        // Center the map camera over New York City
        let centerCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

        mapView.cameraManager.setCamera(centerCoordinate: centerCoordinate,
                                        zoom: 15.0)

        // Allows the delegate to receive information about map events.
        mapView.on(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }

            self.updateAnnotationSymbolImages()
            let features = self.addDebugFeatures()
            self.addAnnotationSymbolLayer(features: features)

            // The below line is used for internal testing purposes only.
            self.finish()
        }

        // Add the label on top of the map view controller.
        addLabel()
    }

    public func addLabel() {
        label.text = "Select an annotation"
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
            let annotationLayers: Set<String> = [CustomSymbolAnnotationsExample.annotations]
            mapView.visibleFeatures(at: sender.location(in: mapView),
                                    styleLayers: annotationLayers,
                                    filter: nil,
                                    completion: { result in
                                        if case .success(let features) = result {
                                            if features.count == 0 { return }
                                            guard let featureText = features[0].properties?["text"] as? String else { return }
                                            self.label.text = featureText
                                        }
                                    })
        }
    }

    private func updateAnnotationSymbolImages() {
        guard let style = mapView.style, style.getStyleImage(with: "AnnotationLeftHanded") == nil, style.getStyleImage(with: "AnnotationRightHanded") == nil else { return }

        let annotationHighlightedColor = UIColor(hue: 0.831372549, saturation: 0.72, brightness: 0.59, alpha: 1.0)
        let annotationColor = UIColor.white

        // Centered pin
        if let image =  UIImage(named: "AnnotationCentered") {
            let stretchX = [ImageStretches(first: Float(20), second: Float(30)), ImageStretches(first: Float(90), second: Float(100))]
            let stretchY = [ImageStretches(first: Float(26), second: Float(32))]
            let imageContent = ImageContent(left: 20, top: 26, right: 100, bottom: 33)

            let regularAnnotationImage = image.tint(annotationColor)

            style.setStyleImage(image: regularAnnotationImage,
                                with: "AnnotationCentered",
                                stretchX: stretchX,
                                stretchY: stretchY,
                                scale: 2.0,
                                imageContent: imageContent)

            let highlightedAnnotationImage = image.tint(annotationHighlightedColor)
            style.setStyleImage(image: highlightedAnnotationImage,
                                with: "AnnotationCentered-Highlighted",
                                stretchX: stretchX,
                                stretchY: stretchY,
                                scale: 2.0,
                                imageContent: imageContent)
        }

        let stretchX = [ImageStretches(first: Float(32), second: Float(42))]
        let stretchY = [ImageStretches(first: Float(26), second: Float(32))]
        let imageContent = ImageContent(left: 32, top: 26, right: 47, bottom: 33)

        // Right-hand pin
        if let image =  UIImage(named: "AnnotationRightHanded") {
            let regularAnnotationImage = image.tint(annotationColor)

            style.setStyleImage(image: regularAnnotationImage,
                                with: "AnnotationRightHanded",
                                stretchX: stretchX,
                                stretchY: stretchY,
                                scale: 2.0,
                                imageContent: imageContent)

            let highlightedAnnotationImage = image.tint(annotationHighlightedColor)
            style.setStyleImage(image: highlightedAnnotationImage,
                                with: "AnnotationRightHanded-Highlighted",
                                stretchX: stretchX,
                                stretchY: stretchY,
                                scale: 2.0,
                                imageContent: imageContent)
        }

        // Left-hand pin
        if let image =  UIImage(named: "AnnotationLeftHanded") {
            let regularAnnotationImage = image.tint(annotationColor)

            style.setStyleImage(image: regularAnnotationImage,
                                with: "AnnotationLeftHanded",
                                stretchX: stretchX,
                                stretchY: stretchY,
                                scale: 2.0,
                                imageContent: imageContent)

            let highlightedAnnotationImage = image.tint(annotationHighlightedColor)
            style.setStyleImage(image: highlightedAnnotationImage,
                                with: "AnnotationLeftHanded-Highlighted",
                                stretchX: stretchX,
                                stretchY: stretchY,
                                scale: 2.0,
                                imageContent: imageContent)
        }
    }

    static let annotations = "annotations"

    private func addDebugFeatures() -> FeatureCollection {
        var features = [Feature]()
        let featureList = [
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.714203, -74.006314), highlighted: false, sortOrder: 0, tailPosition: .left, label: "Chambers & Broadway - Lefthand Stem", imageName: "AnnotationLeftHanded"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.707918, -74.006008), highlighted: false, sortOrder: 0, tailPosition: .right, label: "Cliff & John - Righthand Stem", imageName: "AnnotationRightHanded"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.716281, -74.004526), highlighted: true, sortOrder: 1, tailPosition: .right, label: "Broadway & Worth - Right Highlighted", imageName: "AnnotationRightHanded-Highlighted"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.710194, -74.004248), highlighted: true, sortOrder: 1, tailPosition: .left, label: "Spruce & Gold - Left Highlighted", imageName: "AnnotationLeftHanded-Highlighted"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.7128, -74.0060), highlighted: true, sortOrder: 2, tailPosition: .center, label: "الرياض", imageName: "AnnotationCentered-Highlighted"),
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.711427, -74.008614), highlighted: false, sortOrder: 3, tailPosition: .center, label: "Broadway & Vesey - Centered Stem", imageName: "AnnotationCentered")
        ]

        for (index, feature) in featureList.enumerated() {
            var featurePoint = Feature(Point(feature.coordinate))

            // set the feature attributes which will be used in styling the symbol style layer
            featurePoint.properties = ["highlighted": feature.highlighted, "tailPosition": feature.tailPosition.rawValue, "text": feature.label, "imageName": feature.imageName, "sortOrder": feature.highlighted == true ? index : -index]

            features.append(featurePoint)
        }

        return FeatureCollection(features: features)
    }

    private func addAnnotationSymbolLayer(features: FeatureCollection) {
        guard let style = mapView.style else { return }
        let existingDataSource = try? mapView.style.getSource(identifier: CustomSymbolAnnotationsExample.annotations, type: GeoJSONSource.self).get()
        if existingDataSource != nil {
            _ = mapView.style.updateGeoJSON(for: CustomSymbolAnnotationsExample.annotations, with: features)
        } else {
            var dataSource = GeoJSONSource()
            dataSource.data = .featureCollection(features)
            mapView.style.addSource(source: dataSource, identifier: CustomSymbolAnnotationsExample.annotations)
        }

        var shapeLayer: SymbolLayer

        if let layer = try? mapView.style.getLayer(with: CustomSymbolAnnotationsExample.annotations, type: SymbolLayer.self).get() {
            shapeLayer = layer
        } else {
            shapeLayer = SymbolLayer(id: CustomSymbolAnnotationsExample.annotations)
        }

        shapeLayer.source = CustomSymbolAnnotationsExample.annotations

        shapeLayer.layout?.textField = .expression(Exp(.get) {
            "text"
        })

        shapeLayer.layout?.iconImage = .expression(Exp(.get) {
            "imageName"
        })

        shapeLayer.paint?.textColor = .expression(Exp(.switchCase) {
            Exp(.any) {
                Exp(.get) {
                    "highlighted"
                }
            }
            UIColor.white
            UIColor.black
        })

        shapeLayer.layout?.textSize = .constant(16)
        shapeLayer.layout?.iconTextFit = .constant(.both)
        shapeLayer.layout?.iconAllowOverlap = .constant(true)
        shapeLayer.layout?.textAllowOverlap = .constant(true)
        shapeLayer.layout?.textJustify = .constant(.left)
        shapeLayer.layout?.symbolZOrder = .constant(.auto)
        shapeLayer.layout?.textFont = .constant(["DIN Pro Medium", "Noto Sans CJK JP Medium", "Open Sans Regular"])

        style.addLayer(layer: shapeLayer, layerPosition: nil)

        let symbolSortKeyString =
        """
        ["get", "sortOrder"]
        """

        if let expressionData = symbolSortKeyString.data(using: .utf8), let expJSONObject = try? JSONSerialization.jsonObject(with: expressionData, options: []) {

            try! mapView.__map.setStyleLayerPropertyForLayerId(CustomSymbolAnnotationsExample.annotations,
                                                          property: "symbol-sort-key",
                                                          value: expJSONObject)
        }

        let expressionString =
        """
        [
          "match",
          ["get", "tailPosition"],
          [0],
          "bottom-left",
          [1],
          "bottom-right",
          [2],
          "bottom",
          "center"
        ]
        """

        if let expressionData = expressionString.data(using: .utf8), let expJSONObject = try? JSONSerialization.jsonObject(with: expressionData, options: []) {

            try! mapView.__map.setStyleLayerPropertyForLayerId(CustomSymbolAnnotationsExample.annotations,
                                                          property: "icon-anchor",
                                                          value: expJSONObject)
            try! mapView.__map.setStyleLayerPropertyForLayerId(CustomSymbolAnnotationsExample.annotations,
                                                          property: "text-anchor",
                                                          value: expJSONObject)
        }

        let offsetExpressionString =
        """
        [
          "match",
          ["get", "tailPosition"],
          [0],
          ["literal", [0.5, -1]],
          [1],
          ["literal", [-0.5, -1]],
          [2],
          ["literal", [0.0, -1]],
          ["literal", [0.0, 0.0]]
        ]
        """

        if let expressionData = offsetExpressionString.data(using: .utf8), let expJSONObject = try? JSONSerialization.jsonObject(with: expressionData, options: []) {

            try! mapView.__map.setStyleLayerPropertyForLayerId(CustomSymbolAnnotationsExample.annotations,
                                                          property: "icon-offset",
                                                          value: expJSONObject)

            try! mapView.__map.setStyleLayerPropertyForLayerId(CustomSymbolAnnotationsExample.annotations,
                                                          property: "text-offset",
                                                          value: expJSONObject)
        }
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
