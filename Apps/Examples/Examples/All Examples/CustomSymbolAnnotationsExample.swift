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

            mapView.visibleFeatures(at: sender.location(in: mapView), styleLayers: annotationLayers, filter: nil) { result in
                switch result {
                case .success(let features):
                    if features.count > 0 {
                        guard let featureText = features[0].feature.properties["text"] as? String else { return }
                        self.label.text = featureText
                    }
                case .failure(let error):
                    print("An error occurred: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateAnnotationSymbolImages() {
        guard let style = mapView.style, style.image(withId: "AnnotationLeftHanded") == nil, style.image(withId: "AnnotationRightHanded") == nil else { return }

        let annotationHighlightedColor = UIColor(hue: 0.831372549, saturation: 0.72, brightness: 0.59, alpha: 1.0)
        let annotationColor = UIColor.white

        // Centered pin
        if let image =  UIImage(named: "AnnotationCentered") {
            let stretchX = [ImageStretches(first: Float(10), second: Float(15)), ImageStretches(first: Float(45), second: Float(50))]
            let stretchY = [ImageStretches(first: Float(13), second: Float(16))]
            let imageContent = ImageContent(left: 10, top: 13, right: 50, bottom: 16)

            let regularAnnotationImage = image.tint(annotationColor)

            try? style.addImage(regularAnnotationImage, id: "AnnotationCentered", sdf: false, stretchX: stretchX, stretchY: stretchY, content: imageContent)

            let highlightedAnnotationImage = image.tint(annotationHighlightedColor)
            try? style.addImage(highlightedAnnotationImage, id: "AnnotationCentered-Highlighted", sdf: false, stretchX: stretchX, stretchY: stretchY, content: imageContent)
        }

        let stretchX = [ImageStretches(first: Float(16), second: Float(21))]
        let stretchY = [ImageStretches(first: Float(13), second: Float(16))]
        let imageContent = ImageContent(left: 16, top: 13, right: 23, bottom: 16)

        // Right-hand pin
        if let image =  UIImage(named: "AnnotationRightHanded") {
            let regularAnnotationImage = image.tint(annotationColor)

            try? style.addImage(regularAnnotationImage, id: "AnnotationRightHanded", sdf: false, stretchX: stretchX, stretchY: stretchY, content: imageContent)

            let highlightedAnnotationImage = image.tint(annotationHighlightedColor)

            try? style.addImage(highlightedAnnotationImage, id: "AnnotationRightHanded-Highlighted", sdf: false, stretchX: stretchX, stretchY: stretchY, content: imageContent)
        }

        // Left-hand pin
        if let image =  UIImage(named: "AnnotationLeftHanded") {
            let regularAnnotationImage = image.tint(annotationColor)

            try? style.addImage(regularAnnotationImage, id: "AnnotationLeftHanded", sdf: false, stretchX: stretchX, stretchY: stretchY, content: imageContent)

            let highlightedAnnotationImage = image.tint(annotationHighlightedColor)

            try? style.addImage(highlightedAnnotationImage, id: "AnnotationLeftHanded-Highlighted", sdf: false, stretchX: stretchX, stretchY: stretchY, content: imageContent)
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
            DebugFeature(coordinate: CLLocationCoordinate2DMake(40.7128, -74.0060), highlighted: true, sortOrder: 2, tailPosition: .center, label: "City Hall - Centered Highlighted", imageName: "AnnotationCentered-Highlighted"),
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
        if mapView.style.sourceExists(withId: CustomSymbolAnnotationsExample.annotations) {
            try? mapView.style.updateGeoJSONSource(withId: CustomSymbolAnnotationsExample.annotations, geoJSON: features)
        } else {
            var dataSource = GeoJSONSource()
            dataSource.data = .featureCollection(features)
            try? mapView.style.addSource(dataSource, id: CustomSymbolAnnotationsExample.annotations)
        }

        var shapeLayer: SymbolLayer

        if mapView.style.layerExists(withId: CustomSymbolAnnotationsExample.annotations) {
            shapeLayer = try! mapView.style.layer(withId: CustomSymbolAnnotationsExample.annotations) as SymbolLayer
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
        shapeLayer.layout?.textFont = .constant(["DIN Pro Medium"])

        try? style.addLayer(shapeLayer)

        let symbolSortKeyString =
        """
        ["get", "sortOrder"]
        """

        if let expressionData = symbolSortKeyString.data(using: .utf8), let expJSONObject = try? JSONSerialization.jsonObject(with: expressionData, options: []) {

            try! mapView.mapboxMap.style.setLayerProperties(for: CustomSymbolAnnotationsExample.annotations, properties: ["symbol-sort-key": expJSONObject])
        }

        let myExpression = Exp(.match) {
             Exp(.get) { "tailPosition" }
             [0]
             "bottom-left"
             [1]
             "bottom-right"
             "center"
            }
//        shapeLayer.layout?.iconAnchor = .expression(myExpression)

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

//        if let expressionData = offsetExpressionString.data(using: .utf8), let expJSONObject = try? JSONSerialization.jsonObject(with: expressionData, options: []) {
//
//            try! mapView.mapboxMap.style.setLayerProperties(for: CustomSymbolAnnotationsExample.annotations, properties: ["icon-offset": expJSONObject])
//
//            try! mapView.mapboxMap.style.setLayerProperties(for: CustomSymbolAnnotationsExample.annotations, properties: ["text-anchor": expJSONObject])
//        }
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
