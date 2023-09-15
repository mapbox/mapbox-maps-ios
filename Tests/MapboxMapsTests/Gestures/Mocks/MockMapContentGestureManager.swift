@testable import MapboxMaps

class MockMapContentGestureManager: MapContentGestureManagerProtocol {
    @TestSignal var onMapTap: Signal<MapContentGestureContext>
    @TestSignal var onMapLongPress: Signal<MapContentGestureContext>

    private typealias LayerTapGestureParams = (QueriedFeature, MapContentGestureContext)
    private typealias LayerSubscribersStore = ClosureHandlersStore<LayerTapGestureParams, Bool>
    private var layerTapSubscribers = [String: LayerSubscribersStore]()
    private var layerLongPressSubscribers = [String: LayerSubscribersStore]()

    func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        if layerTapSubscribers[layerId] == nil {
            layerTapSubscribers[layerId] = LayerSubscribersStore()
        }
        return layerTapSubscribers[layerId]!.add(handler: handler)
    }

    func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        if layerLongPressSubscribers[layerId] == nil {
            layerLongPressSubscribers[layerId] = LayerSubscribersStore()
        }
        return layerLongPressSubscribers[layerId]!.add(handler: handler)
    }

    func simulateLayerTap(layerId: String, queriedFeature: QueriedFeature, context: MapContentGestureContext) {
        guard let store = layerTapSubscribers[layerId] else { return }
        for handler in store where handler((queriedFeature, context)) {
            return
        }
    }
    func simulateLayerLongPress(layerId: String, queriedFeature: QueriedFeature, context: MapContentGestureContext) {
        guard let store = layerLongPressSubscribers[layerId] else { return }
        for handler in store where handler((queriedFeature, context)) {
            return
        }
    }
}
