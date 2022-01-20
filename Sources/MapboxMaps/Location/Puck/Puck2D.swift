@_implementationOnly import MapboxCommon_Private

internal final class Puck2D: NSObject, Puck {

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                locationProducer.add(self)
                updateLayer()
            } else {
                locationProducer.remove(self)
                try? style.removeLayer(withId: Self.layerID)
                try? style.removeImage(withId: Self.topImageId)
                try? style.removeImage(withId: Self.bearingImageId)
                try? style.removeImage(withId: Self.shadowImageId)
                previouslySetLayerPropertyKeys.removeAll()
            }
        }
    }

    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            updateLayer()
        }
    }

    private let configuration: Puck2DConfiguration
    private let style: StyleProtocol
    private let locationProducer: LocationProducerProtocol

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private static let layerID = "puck"
    private static let topImageId = "locationIndicatorLayerTopImage"
    private static let bearingImageId = "locationIndicatorLayerBearingImage"
    private static let shadowImageId = "locationIndicatorLayerShadowImage"

    internal init(configuration: Puck2DConfiguration,
                  style: StyleProtocol,
                  locationProducer: LocationProducerProtocol) {
        self.configuration = configuration
        self.style = style
        self.locationProducer = locationProducer
    }

    private func addImages() {
        try! style.addImage(
            configuration.resolvedTopImage,
            id: Self.topImageId,
            sdf: false,
            stretchX: [],
            stretchY: [],
            content: nil)
        if let bearingImage = configuration.bearingImage {
            try! style.addImage(
                bearingImage,
                id: Self.bearingImageId,
                sdf: false,
                stretchX: [],
                stretchY: [],
                content: nil)
        }
        try! style.addImage(
            configuration.resolvedShadowImage,
            id: Self.shadowImageId,
            sdf: false,
            stretchX: [],
            stretchY: [],
            content: nil)
    }

    private func updateLayer() {
        guard isActive, let location = locationProducer.latestLocation else {
            return
        }
        var layer = LocationIndicatorLayer(id: Self.layerID)
        layer.location = .constant([
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.location.altitude
        ])
        switch location.accuracyAuthorization {
        case .fullAccuracy:
            layer.topImage = .constant(.name(Self.topImageId))
            if configuration.bearingImage != nil {
                layer.bearingImage = .constant(.name(Self.bearingImageId))
            }
            layer.shadowImage = .constant(.name(Self.shadowImageId))
            layer.locationTransition = StyleTransition(duration: 0.5, delay: 0)
            layer.topImageSize = configuration.resolvedScale
            layer.bearingImageSize = configuration.resolvedScale
            layer.shadowImageSize = configuration.resolvedScale
            layer.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
            layer.bearingTransition = StyleTransition(duration: 0, delay: 0)
            if configuration.showsAccuracyRing {
                layer.accuracyRadius = .constant(location.horizontalAccuracy)
                layer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
                layer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
            }
            switch puckBearingSource {
            case .heading:
                layer.bearing = .constant(location.headingDirection ?? 0)
            case .course:
                layer.bearing = .constant(location.course)
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            layer.accuracyRadius = .expression(Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                400000
                4
                200000
                8
                5000
            })
            layer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
            layer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
        }

        // LocationIndicatorLayer is a struct, and by default, most of its properties are nil. When it gets
        // converted to JSON, only the non-nil key-value pairs are included in the dictionary. When an existing
        // layer is updated with setLayerProperties(for:properties:) as is done below, only the specified keys
        // are modified, so if other properties were customized previously, they will keep their existing values.
        // In this case, we actually want to reset any "unused" properties to their default values, so we keep
        // track of which ones were used in the previous update and on subsequent updates identify which keys
        // need to be reset to their default values. We look up the default values for those keys and create a
        // combined update dictionary that contains the new property values that we're setting and the default
        // values for the properties we were using before but no longer want to customize.

        // Create the properties dictionary for the updated layer
        let newLayerProperties = try! layer.jsonObject()
        // Construct the properties dictionary to reset any properties that are no longer used
        let unusedPropertyKeys = previouslySetLayerPropertyKeys.subtracting(newLayerProperties.keys)
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.map { (key) -> (String, Any) in
            (key, Style.layerPropertyDefaultValue(for: .locationIndicator, property: key).value)
        })
        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })
        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Update or add the layer
        if style.layerExists(withId: Self.layerID) {
            try! style.setLayerProperties(for: Self.layerID, properties: allLayerProperties)
        } else {
            // add the images at the same time as adding the layer. doing it earlier results
            // in the images getting removed if the style reloads in between when the images
            // were added and when the persistent layer is added. The presence of a persistent
            // layer causes MapboxCoreMaps to skip clearing images when the style reloads.
            // https://github.com/mapbox/mapbox-maps-ios/issues/860
            addImages()
            try! style.addPersistentLayer(with: allLayerProperties, layerPosition: nil)
        }
    }
}

extension Puck2D: LocationConsumer {
    internal func locationUpdate(newLocation: Location) {
        updateLayer()
    }
}

private extension Puck2DConfiguration {
    var resolvedTopImage: UIImage {
        topImage ?? UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
    }

    var resolvedShadowImage: UIImage {
        shadowImage ?? UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!
    }

    var resolvedScale: Value<Double> {
        scale ?? .constant(1.0)
    }
}

public extension Puck2DConfiguration {
    // Create a Puck2DConfiguration instance with or without an arrow bearing image. Default without the arrow bearing image.
    static func makeDefault(showBearing: Bool = false) -> Puck2DConfiguration {
        return Puck2DConfiguration(topImage: UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!,
                                   bearingImage: showBearing ? makeBearingImage() : nil,
                                shadowImage: UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!)
    }
}

private func makeBearingImage(withGap gap: CGFloat = 30, arcLength: CGFloat = 0.5) -> UIImage {
    assert(arcLength <= .pi / 2)

    let lineWidth: CGFloat = 1
    let size: CGFloat = 22
    // The gap determines how much space we put between the circles and the arrow
    // strokes are centered on the path, so half of the width of the line is drawn
    // on either side.
    let radius = size / 2 + lineWidth / 2 + gap

    let rightArcPoint = CGPoint(
        x: radius * cos(.pi / 2 - arcLength / 2),
        y: -radius * sin(.pi / 2 - arcLength / 2))

    // The top point is always centered at 0. Calculate its height
    // to produce a right angle between the left and right sides of the arrow
    let topPoint = CGPoint(x: 0, y: rightArcPoint.y - rightArcPoint.x * tan(.pi / 4))

    // Create the path
    let path = UIBezierPath()
    path.move(to: topPoint)
    path.addLine(to: rightArcPoint)
    path.addArc(
        withCenter: .zero,
        radius: radius,
        startAngle: -.pi / 2 + arcLength / 2,
        endAngle: -.pi / 2 - arcLength / 2,
        clockwise: false)
    path.close()
    path.lineWidth = lineWidth
    path.lineJoinStyle = .round

    // Create a rectangle to
    // draw the circles, centering them at the origin
    let outerImageBounds = CGRect(
        origin: CGPoint(
            x: -size / 2,
            y: -size / 2),
        size: CGSize(width: size, height: size))

    // Union that rectangle with the bounds
    // of the arrow, also union it with the arrow
    // reflected over the horizontal axis to ensure
    // that the resulting image is centered on the origin.
    // finally, pad the image a little to ensure that
    // the arrow's stroke is not cut off.
    let imageBounds = outerImageBounds
        .union(path.bounds)
        .union(path.bounds.applying(.init(scaleX: 1, y: -1)))
        .insetBy(dx: -2, dy: -2)

    // render the image
    return UIGraphicsImageRenderer(bounds: imageBounds).image { _ in
        UIColor.systemBlue.setFill()
        path.fill()
        UIColor.white.setStroke()
        path.stroke()
    }
}
