import UIKit
@testable import MapboxMaps

final class MockGestureManager: GestureManagerProtocol {
    private typealias LayerTapGestureParams = (QueriedFeature, InteractionContext)
    private typealias LayerSubscribersStore = ClosureHandlersStore<LayerTapGestureParams, Bool>
    private var layerTapSubscribers = [String: LayerSubscribersStore]()
    private var layerLongPressSubscribers = [String: LayerSubscribersStore]()

    var gestureHandlers = MapGestureHandlers()

    @TestSignal var onMapTap: Signal<InteractionContext>
    @TestSignal var onMapLongPress: Signal<InteractionContext>

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

    func simulateLayerTap(layerId: String, queriedFeature: QueriedFeature, context: InteractionContext) {
        guard let store = layerTapSubscribers[layerId] else { return }
        for handler in store where handler((queriedFeature, context)) {
            return
        }
    }
    func simulateLayerLongPress(layerId: String, queriedFeature: QueriedFeature, context: InteractionContext) {
        guard let store = layerLongPressSubscribers[layerId] else { return }
        for handler in store where handler((queriedFeature, context)) {
            return
        }
    }

    @Stubbed var options = GestureOptions()

    var singleTapGestureRecognizerMock = MockGestureRecognizer()
    var singleTapGestureRecognizer: UIGestureRecognizer {
        singleTapGestureRecognizerMock
    }
}
