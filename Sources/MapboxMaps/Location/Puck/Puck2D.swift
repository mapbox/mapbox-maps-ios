@_implementationOnly import MapboxCommon_Private
import CoreGraphics
import UIKit

internal final class Puck2D: Puck {

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                interpolatedLocationProducer
                    .observe { [weak self] (location) in
                        self?.latestLocation = location
                        return true
                    }
                    .add(to: cancelables)
            } else {
                cancelables.cancelAll()
                try? style.removeLayer(withId: Self.layerID)
                try? style.removeImage(withId: Self.topImageId)
                try? style.removeImage(withId: Self.bearingImageId)
                try? style.removeImage(withId: Self.shadowImageId)
                previouslySetLayerPropertyKeys.removeAll()
                latestLocation = nil
            }
        }
    }

    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            updateLayer()
        }
    }

    internal var puckBearingEnabled: Bool = true

    private var latestLocation: InterpolatedLocation? {
        didSet {
            if oldValue?.accuracyAuthorization == latestLocation?.accuracyAuthorization {
                updateLayerLocationFastPath()
            } else {
                updateLayer()
            }
        }
    }

    private let configuration: Puck2DConfiguration
    private let style: StyleProtocol
    private let interpolatedLocationProducer: InterpolatedLocationProducerProtocol

    private let cancelables = CancelableContainer()

    // cache the encoded configuration.resolvedScale to avoid work at every location update
    private let encodedScale: Any

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
                  interpolatedLocationProducer: InterpolatedLocationProducerProtocol) {
        self.configuration = configuration
        self.style = style
        self.interpolatedLocationProducer = interpolatedLocationProducer
        self.encodedScale = try! configuration.resolvedScale.toJSON()
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
        guard isActive, let location = latestLocation else {
            return
        }

        var newLayerLayoutProperties = [LocationIndicatorLayer.LayoutCodingKeys: Any]()
        var newLayerPaintProperties = [LocationIndicatorLayer.PaintCodingKeys: Any]()

        newLayerPaintProperties[.location] = [
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.altitude
        ]
        switch location.accuracyAuthorization {
        case .fullAccuracy:
            let immediateTransition = [
                StyleTransition.CodingKeys.duration.rawValue: 0,
                StyleTransition.CodingKeys.delay.rawValue: 0]
            newLayerLayoutProperties[.topImage] = Self.topImageId
            if configuration.bearingImage != nil {
                newLayerLayoutProperties[.bearingImage] = Self.bearingImageId
            }
            newLayerLayoutProperties[.shadowImage] = Self.shadowImageId
            newLayerPaintProperties[.locationTransition] = immediateTransition
            newLayerPaintProperties[.topImageSize] = encodedScale
            newLayerPaintProperties[.bearingImageSize] = encodedScale
            newLayerPaintProperties[.shadowImageSize] = encodedScale
            newLayerPaintProperties[.emphasisCircleRadiusTransition] = immediateTransition
            newLayerPaintProperties[.bearingTransition] = immediateTransition
            if configuration.showsAccuracyRing {
                newLayerPaintProperties[.accuracyRadius] = location.horizontalAccuracy
                newLayerPaintProperties[.accuracyRadiusColor] = StyleColor(configuration.accuracyRingColor).rgbaString
                newLayerPaintProperties[.accuracyRadiusBorderColor] = StyleColor(configuration.accuracyRingBorderColor).rgbaString
            }

            if puckBearingEnabled {
                switch puckBearingSource {
                case .heading:
                    newLayerPaintProperties[.bearing] = location.heading ?? 0
                case .course:
                    newLayerPaintProperties[.bearing] = location.course ?? 0
                }
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            newLayerPaintProperties[.accuracyRadius] = [
                Expression.Operator.interpolate.rawValue,
                [Expression.Operator.linear.rawValue],
                [Expression.Operator.zoom.rawValue],
                0,
                400000,
                4,
                200000,
                8,
                5000]
            newLayerPaintProperties[.accuracyRadiusColor] = StyleColor(configuration.accuracyRingColor).rgbaString
            newLayerPaintProperties[.accuracyRadiusBorderColor] = StyleColor(configuration.accuracyRingBorderColor).rgbaString
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
        let newLayerProperties = newLayerLayoutProperties
            .mapKeys(\.rawValue)
            .merging(
                newLayerPaintProperties.mapKeys(\.rawValue),
                uniquingKeysWith: { $1 })
        // Construct the properties dictionary to reset any properties that are no longer used
        let unusedPropertyKeys = previouslySetLayerPropertyKeys.subtracting(newLayerProperties.keys)
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.map { (key) -> (String, Any) in
            (key, Style.layerPropertyDefaultValue(for: .locationIndicator, property: key).value)
        })
        // Merge the new and unused properties
        var allLayerProperties = newLayerProperties.merging(
            unusedProperties,
            uniquingKeysWith: { $1 })
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
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.id.rawValue] = Self.layerID
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.type.rawValue] = LayerType.locationIndicator.rawValue
            try! style.addPersistentLayer(with: allLayerProperties, layerPosition: nil)
        }
    }

    private func updateLayerLocationFastPath() {
        guard isActive, let location = latestLocation else {
            return
        }
        var layerProperties: [String: Any] = [
            LocationIndicatorLayer.PaintCodingKeys.location.rawValue: [
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.altitude
            ]
        ]
        switch location.accuracyAuthorization {
        case .fullAccuracy:
            if configuration.showsAccuracyRing {
                layerProperties[LocationIndicatorLayer.PaintCodingKeys.accuracyRadius.rawValue] = location.horizontalAccuracy
            }
            if puckBearingEnabled {
                switch puckBearingSource {
                case .heading:
                    layerProperties[LocationIndicatorLayer.PaintCodingKeys.bearing.rawValue] = location.heading ?? 0
                case .course:
                    layerProperties[LocationIndicatorLayer.PaintCodingKeys.bearing.rawValue] = location.course ?? 0
                }
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            break
        }

        try! style.setLayerProperties(for: Self.layerID, properties: layerProperties)
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
