@testable import TestsSupport
@_spi(Experimental) @testable import MapboxMapsSwiftUI

struct MockMapView {
    var style = MockStyle()
    var mapboxMap = MockMapboxMap()
    var gestures = MockGestureManager()
    var locationsStub = Stub<UIGestureRecognizer, CGPoint>(defaultReturnValue: .zero)

    var facade: MapViewFacade
    init() {
        facade = MapViewFacade(
            style: style,
            mapboxMap: mapboxMap,
            gestures: gestures,
            locationForGesture: locationsStub.call(with:))
    }
}
