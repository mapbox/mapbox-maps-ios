import SwiftUI
import MapboxCoreMaps

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
    var presentationTransactionMode: PresentationTransactionMode = .automatic
    var additionalSafeArea = SwiftUI.EdgeInsets()
    var viewportOptions = ViewportOptions(transitionsToIdleUponUserInteraction: true, usesSafeAreaInsetsAsPadding: true)
    var performanceStatisticsParameters: Map.PerformanceStatisticsParameters?
    var attributionMenuFilter: ((AttributionMenuItem) -> Bool)?

    var onMapTap: ((InteractionContext) -> Void)?
    var onMapLongPress: ((InteractionContext) -> Void)?
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

extension Map {
    struct PerformanceStatisticsParameters {
        var options: PerformanceStatisticsOptions
        var callback: (PerformanceStatistics) -> Void
    }
}

extension Map {
    struct FrameRate: Equatable {
        var range: ClosedRange<Float>?
        var preferred: Float?
    }
}
