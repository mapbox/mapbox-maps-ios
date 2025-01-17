import SwiftUI
import UIKit

/// Abstraction around MapView which makes unit testing possible.
struct MapViewFacade {
    var styleManager: StyleProtocol
    var mapboxMap: MapboxMapProtocol
    var gestureManager: GestureManagerProtocol
    var viewportManager: ViewportManagerProtocol
    var ornaments: OrnamentsManaging
    @MutableRef
    var debugOptions: MapViewDebugOptions
    @MutableRef
    var isOpaque: Bool
    @MutableRef
    var presentationTransactionMode: PresentationTransactionMode
    @MutableRef
    var frameRate: Map.FrameRate
    var attributionMenu: AttributionMenu

    var makeViewportTransition: (ViewportAnimation) -> ViewportTransition
    var makeViewportState: (Viewport, LayoutDirection) -> ViewportState?
}

extension MapViewFacade {
    init(from mapView: MapView) {
        styleManager = mapView.mapboxMap
        mapboxMap = mapView.mapboxMap
        gestureManager = mapView.gestures
        viewportManager = mapView.viewport
        ornaments = mapView.ornaments
        _debugOptions = MutableRef(root: mapView, keyPath: \.debugOptions)
        _isOpaque = MutableRef(root: mapView, keyPath: \.isOpaque)
        _presentationTransactionMode = MutableRef(root: mapView, keyPath: \.presentationTransactionMode)
        _frameRate = MutableRef(get: mapView.getFrameRate, set: mapView.set(frameRate:))
        attributionMenu = mapView.attributionMenu
        makeViewportTransition = { animation in
            animation.makeViewportTransition(mapView)
        }
        makeViewportState = { viewport, LayoutDirection in
            viewport.makeState(with: mapView, layoutDirection: LayoutDirection)
        }
    }
}

private extension MapView {
    func set(frameRate: Map.FrameRate) {
        if #available(iOS 15.0, *), let initialRange = frameRate.range {
            let clampedRange = initialRange.clamped(to: 1...initialRange.upperBound)

            if clampedRange != initialRange {
                Log.warning(
                    """
                    Provided frame rate range was clamped from \(initialRange) to \(clampedRange).
                    Negative or zero values are not allowed.
                    """,
                    category: "MapView"
                )
            }

            preferredFrameRateRange = CAFrameRateRange(
                minimum: clampedRange.lowerBound,
                maximum: clampedRange.upperBound,
                preferred: frameRate.preferred?.clamped(to: clampedRange)
            )
        } else if let preferred = frameRate.preferred {
            let clampedValue = preferred.clamped(to: 1...Float(Int.max))

            if clampedValue != preferred {
                Log.warning(
                    """
                    Preferred frame rate was clamped from \(preferred) to \(clampedValue).
                    Negative value, zero values and values larger then Int.max are not allowed.
                    """,
                    category: "MapView"
                )
            }

            preferredFramesPerSecond = Int(clampedValue)
        }
    }

    func getFrameRate() -> Map.FrameRate {
        if #available(iOS 15.0, *) {
            return Map.FrameRate(
                range: preferredFrameRateRange.minimum...preferredFrameRateRange.maximum,
                preferred: preferredFrameRateRange.preferred
            )
        } else {
            return Map.FrameRate(range: nil, preferred: Float(preferredFramesPerSecond))
        }
    }
}
