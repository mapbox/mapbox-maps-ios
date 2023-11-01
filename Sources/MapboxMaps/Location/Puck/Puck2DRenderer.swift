@_implementationOnly import MapboxCommon_Private
import CoreGraphics
import UIKit
import os

// swiftlint:disable:next type_body_length
internal final class Puck2DRenderer: Puck2DRendererProtocol {
    private static let layerID = "puck"
    private static let topImageId = "locationIndicatorLayerTopImage"
    private static let bearingImageId = "locationIndicatorLayerBearingImage"
    private static let shadowImageId = "locationIndicatorLayerShadowImage"

    internal var isActive = false {
        didSet {
            guard isActive != oldValue else {
                return
            }
            if isActive {
                renderingData.observe { [weak self] data in
                    self?.render(with: data)
                }.store(in: &cancelables)
            } else {
                cancelables.removeAll()
                try? style.removeLayer(withId: Self.layerID)
                try? style.removeImage(withId: Self.topImageId)
                try? style.removeImage(withId: Self.bearingImageId)
                try? style.removeImage(withId: Self.shadowImageId)
                previouslySetLayerPropertyKeys.removeAll()
                currentAccuracyAuthorization = nil
                forceLongPath = true
                pulsingAnimationStartTimestamp = nil
            }
        }
    }

    // The change in this properties will be handled in the next render call (renderingData update).
    // TODO: Those properties should come as part of rendering data.
    var puckBearing: PuckBearing = .heading
    var puckBearingEnabled: Bool = false
    var configuration: Puck2DConfiguration {
        didSet {
            if configuration != oldValue {
                forceLongPath = true
                needsUpdateTopImage = configuration.topImage != oldValue.topImage
                needsUpdateBearingImage = configuration.bearingImage != oldValue.bearingImage
                needsUpdateShadowImage = configuration.shadowImage != oldValue.shadowImage
            }
        }
    }

    private var needsUpdateTopImage = true
    private var needsUpdateBearingImage = true
    private var needsUpdateShadowImage = true

    private func render(with data: PuckRenderingData) {
        self.currentAccuracyAuthorization = data.location.accuracyAuthorization

        defer {
            // Next time render will take fast path (only location update) until configuration is updated.
            forceLongPath = false
        }

        do {
            if forceLongPath {
                try updateLayer(with: data)
            } else {
                try updateLayerFastPath(with: data)
            }
            try renderPulsing(with: data)
        } catch {
            Log.error(forMessage: "Failed to update Puck2D Layer properties, \(error)")
        }
    }

    private let style: StyleProtocol
    private let mapboxMap: MapboxMapProtocol
    private var cancelables = Set<AnyCancelable>()
    private let timeProvider: TimeProvider
    private let renderingData: Signal<PuckRenderingData>
    // cache the encoded configuration.resolvedScale to avoid work at every location update
    private let encodedScale: Any?
    private let pulsingAnimationDuration: CFTimeInterval = 3
    private let pulsingAnimationTimingCurve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
    private var pulsingAnimationStartTimestamp: CFTimeInterval?
    private var currentAccuracyAuthorization: CLAccuracyAuthorization? {
        didSet {
            if oldValue != currentAccuracyAuthorization {
                forceLongPath = true
            }
        }
    }
    private var forceLongPath = true

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    internal init(configuration: Puck2DConfiguration,
                  style: StyleProtocol,
                  renderingData: Signal<PuckRenderingData>,
                  mapboxMap: MapboxMapProtocol,
                  timeProvider: TimeProvider) {
        self.configuration = configuration
        self.style = style
        self.renderingData = renderingData
        self.mapboxMap = mapboxMap
        self.timeProvider = timeProvider
        self.encodedScale = try? configuration.resolvedScale.toJSON()
    }

    // MARK: Images

    private func addImages() throws {
        defer {
            needsUpdateTopImage = false
            needsUpdateBearingImage = false
            needsUpdateShadowImage = false
        }

        if needsUpdateTopImage {
            try style.addImage(configuration.resolvedTopImage, id: Self.topImageId, sdf: false, stretchX: [], stretchY: [], content: nil)
        }
        if needsUpdateBearingImage {
            try replaceImage(id: Self.bearingImageId, with: configuration.bearingImage)
        }
        if needsUpdateShadowImage {
            try replaceImage(id: Self.shadowImageId, with: configuration.shadowImage)
        }
    }

    private func replaceImage(id: String, with newImage: UIImage?) throws {
        if style.imageExists(withId: id) {
            try style.removeImage(withId: id)
        }
        if let newImage {
            try style.addImage(newImage, id: id, sdf: false, stretchX: [], stretchY: [], content: nil)
        }
    }

    // MARK: Layer

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func updateLayer(with data: PuckRenderingData) throws {
        guard isActive else { return }

        var newLayerLayoutProperties = [LocationIndicatorLayer.LayoutCodingKeys: Any]()
        var newLayerPaintProperties = [LocationIndicatorLayer.PaintCodingKeys: Any]()

        newLayerPaintProperties[.location] = [
            data.location.coordinate.latitude,
            data.location.coordinate.longitude,
            0
        ]
        switch data.location.accuracyAuthorization {
        case .fullAccuracy:
            let immediateTransition = [
                StyleTransition.CodingKeys.duration.rawValue: 0,
                StyleTransition.CodingKeys.delay.rawValue: 0]
            newLayerLayoutProperties[.topImage] = Self.topImageId
            if configuration.bearingImage != nil {
                newLayerLayoutProperties[.bearingImage] = Self.bearingImageId
            }
            if configuration.shadowImage != nil {
                newLayerLayoutProperties[.shadowImage] = Self.shadowImageId
            }

            newLayerPaintProperties[.locationTransition] = immediateTransition
            if let encodedScale {
                newLayerPaintProperties[.topImageSize] = encodedScale
                newLayerPaintProperties[.bearingImageSize] = encodedScale
                newLayerPaintProperties[.shadowImageSize] = encodedScale
            }
            newLayerPaintProperties[.emphasisCircleRadiusTransition] = immediateTransition
            newLayerPaintProperties[.bearingTransition] = immediateTransition
            newLayerPaintProperties[.locationIndicatorOpacity] = configuration.opacity
            newLayerPaintProperties[.locationIndicatorOpacityTransition] = immediateTransition
            if configuration.showsAccuracyRing {
                newLayerPaintProperties[.accuracyRadius] = data.location.horizontalAccuracy
                newLayerPaintProperties[.accuracyRadiusColor] = StyleColor(configuration.accuracyRingColor).rawValue
                newLayerPaintProperties[.accuracyRadiusBorderColor] = StyleColor(configuration.accuracyRingBorderColor).rawValue
            }

            if puckBearingEnabled {
                switch puckBearing {
                case .heading:
                    newLayerPaintProperties[.bearing] = data.heading?.direction ?? 0
                case .course:
                    newLayerPaintProperties[.bearing] = data.location.bearing ?? 0
                }
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            // in order to:
            // 1) ensure that user location indicator is always(at any zoom level) is shown even for reduced accuracy authorization
            // 2) ensure that there are no unexpected sudden changes in location indicator radius when zoomin in/out
            // here we calculate a suitable zoom level to transition from `accuracyRadius` to `emphasisCircle`
            // and setup the transition using expressions.
            // The zoom level is not hardcoded to enable a seamless and smooth transition between two circles.
            //
            // When the current zoom level is below the "cutoff" point - user location indicator is shown as a circle
            // covering the area of possible user location.
            // When the current zoom level is from "cutoff" point to "cutoff" point + 1 - user location indicator radius
            // transitions from the actual accuracy radius to the minimum circle raduis, while crossfading with the emphasis
            // circle with set radius.
            // When the current zoom level is above the "cutoff" point - user location indicator is shown as a circle
            // with static radius.
            let zoomCutoffRange: ClosedRange<Double> = 4.0...7.5
            let accuracyRange: ClosedRange<CLLocationDistance> = 1000...20_000
            let horizontalAccuracy = data.location.horizontalAccuracy ?? 1000
            let cutoffZoomLevel = zoomCutoffRange.upperBound - (zoomCutoffRange.magnitude * (horizontalAccuracy - accuracyRange.lowerBound) / accuracyRange.magnitude)
            let minPuckRadiusInPoints = 11.0
            let minPuckRadiusInMeters = minPuckRadiusInPoints * Projection.metersPerPoint(for: data.location.coordinate.latitude, zoom: cutoffZoomLevel)
            newLayerPaintProperties[.accuracyRadius] = [
                Expression.Operator.interpolate.rawValue,
                [Expression.Operator.linear.rawValue],
                [Expression.Operator.zoom.rawValue],
                cutoffZoomLevel,
                minPuckRadiusInMeters,
                cutoffZoomLevel + 1,
                horizontalAccuracy
            ] as [Any]
            newLayerPaintProperties[.accuracyRadiusColor] = [
                Expression.Operator.step.rawValue,
                [Expression.Operator.zoom.rawValue],
                StyleColor(UIColor.clear).rawValue,
                cutoffZoomLevel,
                StyleColor(configuration.accuracyRingColor).rawValue] as [Any]
            newLayerPaintProperties[.accuracyRadiusBorderColor] = [
                Expression.Operator.step.rawValue,
                [Expression.Operator.zoom.rawValue],
                StyleColor(UIColor.clear).rawValue,
                cutoffZoomLevel,
                StyleColor(configuration.accuracyRingBorderColor).rawValue] as [Any]
            newLayerPaintProperties[.emphasisCircleColor] = [
                Expression.Operator.step.rawValue,
                [Expression.Operator.zoom.rawValue],
                StyleColor(configuration.accuracyRingColor).rawValue,
                cutoffZoomLevel,
                StyleColor(UIColor.clear).rawValue] as [Any]
            newLayerPaintProperties[.emphasisCircleRadius] = minPuckRadiusInPoints
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
            (key, StyleManager.layerPropertyDefaultValue(for: .locationIndicator, property: key).value)
        })
        // Merge the new and unused properties
        var allLayerProperties = newLayerProperties.merging(
            unusedProperties,
            uniquingKeysWith: { $1 })
        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // add the images at the same time as adding the layer. doing it earlier results
        // in the images getting removed if the style reloads in between when the images
        // were added and when the persistent layer is added. The presence of a persistent
        // layer causes MapboxCoreMaps to skip clearing images when the style reloads.
        // https://github.com/mapbox/mapbox-maps-ios/issues/860
        try addImages()

        // Update or add the layer
        if style.layerExists(withId: Self.layerID) {
            try style.setLayerProperties(for: Self.layerID, properties: allLayerProperties)
        } else {
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.id.rawValue] = Self.layerID
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.type.rawValue] = LayerType.locationIndicator.rawValue
            try style.addPersistentLayer(with: allLayerProperties, layerPosition: nil)
        }
    }

    private func updateLayerFastPath(with data: PuckRenderingData) throws {
        guard isActive else { return }
        var layerProperties: [String: Any] = [
            LocationIndicatorLayer.PaintCodingKeys.location.rawValue: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0
            ]
        ]

        switch data.location.accuracyAuthorization {
        case .fullAccuracy:
            if configuration.showsAccuracyRing {
                layerProperties[LocationIndicatorLayer.PaintCodingKeys.accuracyRadius.rawValue] = data.location.horizontalAccuracy
            }
            if puckBearingEnabled {
                switch puckBearing {
                case .heading:
                    layerProperties[LocationIndicatorLayer.PaintCodingKeys.bearing.rawValue] = data.heading?.direction ?? 0
                case .course:
                    layerProperties[LocationIndicatorLayer.PaintCodingKeys.bearing.rawValue] = data.location.bearing ?? 0
                }
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            break
        }

        try style.setLayerProperties(for: Self.layerID, properties: layerProperties)
    }

    private func renderPulsing(with data: PuckRenderingData) throws {
        let participantTrace = OSLog.platform.beginInterval(SignpostName.mapViewDisplayLink,
                                                            beginMessage: "Participant: Puck2D Pulsing")
        defer { participantTrace?.end() }

        guard let pulsing = configuration.pulsing,
              pulsing.isEnabled else {
            // Remove the pulsing when it became disabled.
            if pulsingAnimationStartTimestamp != nil {
                try style.setLayerProperties(for: Self.layerID, properties: [
                  LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue: 0
                ])
                pulsingAnimationStartTimestamp = nil
            }
            return
        }
        guard let startTimestamp = pulsingAnimationStartTimestamp else {
            pulsingAnimationStartTimestamp = timeProvider.current
            return
        }

        let currentTime = timeProvider.current
        let progress = min((currentTime - startTimestamp) / pulsingAnimationDuration, 1)
        let curvedProgress = pulsingAnimationTimingCurve.solve(progress, 1e-6)

        let baseRadius = pulsing.radius.value(for: data.location, zoom: mapboxMap.cameraState.zoom)
        let radius = baseRadius * curvedProgress
        let alpha = 1.0 - curvedProgress
        let color = pulsing.color.withAlphaComponent(curvedProgress <= 0.1 ? 0 : alpha)
        let properties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .emphasisCircleRadius: radius,
            .emphasisCircleColor: StyleColor(color).rawValue,
        ]

        if progress >= 1 {
            pulsingAnimationStartTimestamp = currentTime
        }
        try style.setLayerProperties(for: Self.layerID, properties: properties.mapKeys(\.rawValue))
    }
}

private extension Puck2DConfiguration {
    var resolvedTopImage: UIImage {
        topImage ?? UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
    }

    var resolvedScale: Value<Double> {
        scale ?? .constant(1.0)
    }
}

private extension Puck2DConfiguration.Pulsing.Radius {
    func value(for location: Location, zoom: CGFloat) -> Double {
        let horizontalAccuracy = location.horizontalAccuracy ?? 0
        switch self {
        case .constant(let radius):
            return radius
        case .accuracy:
            return horizontalAccuracy / Projection.metersPerPoint(for: location.coordinate.latitude, zoom: zoom)
        }
    }
}

internal extension ClosedRange where Bound: AdditiveArithmetic {
    var magnitude: Bound {
        return upperBound - lowerBound
    }
}
