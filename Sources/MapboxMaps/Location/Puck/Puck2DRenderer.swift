@_implementationOnly import MapboxCommon_Private
import CoreGraphics
import UIKit
import os

final class Puck2DRenderer: PuckRenderer {
    var state: PuckRendererState<Puck2DConfiguration>? {
        didSet {
            do {
                if let state, state != oldValue {
                    try startRendering(newState: state, oldState: oldValue)
                }
                if state == nil {
                    stopRendering()
                }
            } catch { Log.error("Failed to update Puck2D Layer properties, \(error)") }
        }
    }

    private var displayLinkToken: AnyCancelable?
    private let style: StyleProtocol
    private let mapboxMap: MapboxMapProtocol
    private let timeProvider: TimeProvider
    private let pulsingAnimationDuration: CFTimeInterval = 3
    private let pulsingAnimationTimingCurve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
    private var pulsingAnimationStartTimestamp: CFTimeInterval?

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private let displayLink: Signal<Void>

    init(
        style: StyleProtocol,
        mapboxMap: MapboxMapProtocol,
        displayLink: Signal<Void>,
        timeProvider: TimeProvider
    ) {
        self.style = style
        self.mapboxMap = mapboxMap
        self.displayLink = displayLink.tracingInterval(SignpostName.mapViewDisplayLink, "Participant: Puck2D Pulsing")
        self.timeProvider = timeProvider
    }

    // MARK: State handling

    private func startRendering(newState: PuckRendererState<Puck2DConfiguration>, oldState: PuckRendererState<Puck2DConfiguration>?) throws {
        if newState.configuration != oldState?.configuration || newState.accuracyAuthorization != oldState?.accuracyAuthorization {
            try updateLayer(newState: newState, oldState: oldState)
        } else {
            try updateLayerFastPath(with: newState)
        }

        if let pulsing = newState.configuration.pulsing, pulsing.isEnabled, displayLinkToken == nil {
            displayLinkToken = displayLink.observe { [weak self] in
                do {
                    try self?.renderPulsing()
                } catch { Log.error("Failed to render pulsing animation, \(error)") }
            }
        }
    }

    private func stopRendering() {
        try? style.removeLayer(withId: Self.layerID)
        try? style.removeImage(withId: Self.topImageId)
        try? style.removeImage(withId: Self.bearingImageId)
        try? style.removeImage(withId: Self.shadowImageId)
        previouslySetLayerPropertyKeys.removeAll()
        pulsingAnimationStartTimestamp = nil
        displayLinkToken = nil
    }

    // MARK: Images

    private func updateImages(newConfiguration: Puck2DConfiguration, oldConfiguration: Puck2DConfiguration?) throws {
        if newConfiguration.resolvedTopImage != oldConfiguration?.topImage {
            try replaceImage(id: Self.topImageId, with: newConfiguration.resolvedTopImage)
        }
        if newConfiguration.bearingImage != oldConfiguration?.bearingImage {
            try replaceImage(id: Self.bearingImageId, with: newConfiguration.bearingImage)
        }
        if newConfiguration.shadowImage != oldConfiguration?.shadowImage {
            try replaceImage(id: Self.shadowImageId, with: newConfiguration.shadowImage)
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
    private func updateLayer(newState: PuckRendererState<Puck2DConfiguration>, oldState: PuckRendererState<Puck2DConfiguration>?) throws {
        let newConfiguration = newState.configuration
        var newLayerLayoutProperties = [LocationIndicatorLayer.LayoutCodingKeys: Any]()
        var newLayerPaintProperties = [LocationIndicatorLayer.PaintCodingKeys: Any]()

        newLayerPaintProperties[.location] = [
            newState.coordinate.latitude,
            newState.coordinate.longitude,
            0
        ]
        switch newState.accuracyAuthorization {
        case .fullAccuracy:
            let immediateTransition = [
                StyleTransition.CodingKeys.duration.rawValue: 0,
                StyleTransition.CodingKeys.delay.rawValue: 0]

            newLayerLayoutProperties[.topImage] = Self.topImageId
            if newConfiguration.bearingImage != nil {
                newLayerLayoutProperties[.bearingImage] = Self.bearingImageId
            }
            if newConfiguration.shadowImage != nil {
                newLayerLayoutProperties[.shadowImage] = Self.shadowImageId
            }

            newLayerPaintProperties[.locationTransition] = immediateTransition
            if let encodedScale = try? newConfiguration.resolvedScale.toJSON() {
                newLayerPaintProperties[.topImageSize] = encodedScale
                newLayerPaintProperties[.bearingImageSize] = encodedScale
                newLayerPaintProperties[.shadowImageSize] = encodedScale
            }
            newLayerPaintProperties[.emphasisCircleRadiusTransition] = immediateTransition
            newLayerPaintProperties[.bearingTransition] = immediateTransition
            newLayerPaintProperties[.locationIndicatorOpacity] = newConfiguration.opacity
            newLayerPaintProperties[.locationIndicatorOpacityTransition] = immediateTransition
            if newConfiguration.showsAccuracyRing {
                newLayerPaintProperties[.accuracyRadius] = newState.horizontalAccuracy
                newLayerPaintProperties[.accuracyRadiusColor] = StyleColor(newConfiguration.accuracyRingColor).rawValue
                newLayerPaintProperties[.accuracyRadiusBorderColor] = StyleColor(newConfiguration.accuracyRingBorderColor).rawValue
            }

            if newState.bearingEnabled {
                switch newState.bearingType {
                case .heading:
                    newLayerPaintProperties[.bearing] = newState.heading?.direction ?? 0
                case .course:
                    newLayerPaintProperties[.bearing] = newState.bearing ?? 0
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
            let horizontalAccuracy = newState.horizontalAccuracy ?? 1000
            let cutoffZoomLevel = zoomCutoffRange.upperBound - (zoomCutoffRange.magnitude * (horizontalAccuracy - accuracyRange.lowerBound) / accuracyRange.magnitude)
            let minPuckRadiusInPoints = 11.0
            let minPuckRadiusInMeters = minPuckRadiusInPoints * Projection.metersPerPoint(for: newState.coordinate.latitude, zoom: cutoffZoomLevel)
            newLayerPaintProperties[.accuracyRadius] = [
                Exp.Operator.interpolate.rawValue,
                [Exp.Operator.linear.rawValue],
                [Exp.Operator.zoom.rawValue],
                cutoffZoomLevel,
                minPuckRadiusInMeters,
                cutoffZoomLevel + 1,
                horizontalAccuracy
            ] as [Any]
            newLayerPaintProperties[.accuracyRadiusColor] = [
                Exp.Operator.step.rawValue,
                [Exp.Operator.zoom.rawValue],
                StyleColor(UIColor.clear).rawValue,
                cutoffZoomLevel,
                StyleColor(newConfiguration.accuracyRingColor).rawValue] as [Any]
            newLayerPaintProperties[.accuracyRadiusBorderColor] = [
                Exp.Operator.step.rawValue,
                [Exp.Operator.zoom.rawValue],
                StyleColor(UIColor.clear).rawValue,
                cutoffZoomLevel,
                StyleColor(newConfiguration.accuracyRingBorderColor).rawValue] as [Any]
            newLayerPaintProperties[.emphasisCircleColor] = [
                Exp.Operator.step.rawValue,
                [Exp.Operator.zoom.rawValue],
                StyleColor(newConfiguration.accuracyRingColor).rawValue,
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
        try updateImages(newConfiguration: newConfiguration, oldConfiguration: oldState?.configuration)

        if newConfiguration.slot != oldState?.configuration.slot {
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.slot.rawValue] = newConfiguration.slot?.rawValue ?? ""
        }

        // Update or add the layer
        if style.layerExists(withId: Self.layerID) {
            try style.setLayerProperties(for: Self.layerID, properties: allLayerProperties)
        } else {
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.id.rawValue] = Self.layerID
            allLayerProperties[LocationIndicatorLayer.RootCodingKeys.type.rawValue] = LayerType.locationIndicator.rawValue
            try style.addPersistentLayer(with: allLayerProperties, layerPosition: newConfiguration.layerPosition)
        }

        if newConfiguration.layerPosition != oldState?.configuration.layerPosition {
            try style.moveLayer(withId: Self.layerID, to: newConfiguration.layerPosition ?? .default)
        }
    }

    private func updateLayerFastPath(with state: PuckRendererState<Puck2DConfiguration>) throws {
        var layerProperties: [String: Any] = [
            LocationIndicatorLayer.PaintCodingKeys.location.rawValue: [
                state.coordinate.latitude,
                state.coordinate.longitude,
                0
            ]
        ]

        switch state.accuracyAuthorization {
        case .fullAccuracy:
            if state.configuration.showsAccuracyRing {
                layerProperties[LocationIndicatorLayer.PaintCodingKeys.accuracyRadius.rawValue] = state.horizontalAccuracy
            }
            if state.bearingEnabled {
                switch state.bearingType {
                case .heading:
                    layerProperties[LocationIndicatorLayer.PaintCodingKeys.bearing.rawValue] = state.heading?.direction ?? 0
                case .course:
                    layerProperties[LocationIndicatorLayer.PaintCodingKeys.bearing.rawValue] = state.bearing ?? 0
                }
            }
        case .reducedAccuracy:
            fallthrough
        @unknown default:
            break
        }

        try style.setLayerProperties(for: Self.layerID, properties: layerProperties)
    }

    private func renderPulsing() throws {
        guard let state else {
            return
        }

        guard let pulsing = state.configuration.pulsing, pulsing.isEnabled else {
            // Remove the pulsing when it became disabled.
            if pulsingAnimationStartTimestamp != nil {
                try style.setLayerProperties(for: Self.layerID, properties: [
                    LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue: 0
                ])
            }

            displayLinkToken = nil
            pulsingAnimationStartTimestamp = nil
            return
        }
        guard let startTimestamp = pulsingAnimationStartTimestamp else {
            pulsingAnimationStartTimestamp = timeProvider.current
            return
        }

        let currentTime = timeProvider.current
        let progress = min((currentTime - startTimestamp) / pulsingAnimationDuration, 1)
        let curvedProgress = pulsingAnimationTimingCurve.solve(progress, 1e-6)

        let baseRadius = pulsing.radius.value(
            horizontalAccuracy: state.horizontalAccuracy,
            coordinate: state.coordinate,
            zoom: mapboxMap.cameraState.zoom
        )
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
    var resolvedTopImage: UIImage { topImage ?? UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)! }
    var resolvedScale: Value<Double> { scale ?? .constant(1.0) }
}

private extension Puck2DConfiguration.Pulsing.Radius {
    func value(horizontalAccuracy: CLLocationAccuracy?, coordinate: CLLocationCoordinate2D, zoom: CGFloat) -> Double {
        let horizontalAccuracy = horizontalAccuracy ?? 0
        switch self {
        case .constant(let radius):
            return radius
        case .accuracy:
            return horizontalAccuracy / Projection.metersPerPoint(for: coordinate.latitude, zoom: zoom)
        }
    }
}

extension ClosedRange where Bound: AdditiveArithmetic {
    var magnitude: Bound { upperBound - lowerBound }
}

private extension Puck2DRenderer {
    static let layerID = "puck"
    static let topImageId = "locationIndicatorLayerTopImage"
    static let bearingImageId = "locationIndicatorLayerBearingImage"
    static let shadowImageId = "locationIndicatorLayerShadowImage"
}
