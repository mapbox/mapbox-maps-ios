import SwiftUI
import MapboxCoreMaps

@available(iOS 13.0, *)
struct MapDependencies {
    var cameraBounds = CameraBoundsOptions()
    var mapStyle: MapStyle = .standard
    var mapContent: () -> any MapContent = { EmptyMapContent() }
    var gestureOptions = GestureOptions()
    var gestureHandlers = MapGestureHandlers()
    var constrainMode = ConstrainMode.heightOnly
    var viewportMode = ViewportMode.default
    var orientation = NorthOrientation.upwards
    var eventsSubscriptions = [AnyEventSubscription]()
    var cameraChangeHandlers = [(CameraChanged) -> Void]()
    var ornamentOptions = OrnamentOptions()
    var frameRate = Map.FrameRate()
    var debugOptions = MapViewDebugOptions()
    var isOpaque = true
    var presentsWithTransaction = false
    var additionalSafeArea = SwiftUI.EdgeInsets()
    var viewportOptions = ViewportOptions(transitionsToIdleUponUserInteraction: true, usesSafeAreaInsetsAsPadding: true)
    var performanceStatisticsParameters: Map.PerformanceStatisticsParameters?

    var onMapTap: ((MapContentGestureContext) -> Void)?
    var onMapLongPress: ((MapContentGestureContext) -> Void)?
    var onLayerTap = [String: MapLayerGestureHandler]()
    var onLayerLongPress = [String: MapLayerGestureHandler]()
}

struct AnyEventSubscription {
    let observe: (MapboxMapProtocol) -> AnyCancelable

    init<Payload>(
        keyPath: KeyPath<MapboxMapProtocol, Signal<Payload>>,
        perform action: @escaping (Payload) -> Void
    ) {
        observe = { map in
            map[keyPath: keyPath].observe { payload in
                action(payload)
            }
        }
    }
}

@available(iOS 13.0, *)
extension Map {
    struct PerformanceStatisticsParameters {
        var options: PerformanceStatisticsOptions
        var callback: (PerformanceStatistics) -> Void
    }
}

@available(iOS 13.0, *)
extension Map {
    struct FrameRate: Equatable {
        var range: ClosedRange<Float>?
        var preferred: Float?
    }
}
