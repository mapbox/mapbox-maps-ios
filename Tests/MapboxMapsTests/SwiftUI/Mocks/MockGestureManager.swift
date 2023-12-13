import UIKit
@testable @_spi(Experimental) import MapboxMaps

final class MockGestureManager: GestureManagerProtocol {
    let contentManager = MockMapContentGestureManager()
    var gestureHandlers = MapGestureHandlers()

    var onMapTap: MapboxMaps.Signal<MapboxMaps.MapContentGestureContext> { contentManager.onMapTap }
    var onMapLongPress: MapboxMaps.Signal<MapboxMaps.MapContentGestureContext> { contentManager.onMapLongPress }

    func onLayerTap(_ layerId: String, handler: @escaping MapboxMaps.MapLayerGestureHandler) -> MapboxMaps.AnyCancelable {
        contentManager.onLayerTap(layerId, handler: handler)
    }

    func onLayerLongPress(_ layerId: String, handler: @escaping MapboxMaps.MapLayerGestureHandler) -> MapboxMaps.AnyCancelable {
        contentManager.onLayerLongPress(layerId, handler: handler)
    }

    @Stubbed var options = GestureOptions()

    var singleTapGestureRecognizerMock = MockGestureRecognizer()
    var singleTapGestureRecognizer: UIGestureRecognizer {
        singleTapGestureRecognizerMock
    }
}
