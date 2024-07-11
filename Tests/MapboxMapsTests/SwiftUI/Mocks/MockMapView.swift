import UIKit
import SwiftUI
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
struct MockMapView {
    var style = MockStyle()
    var mapboxMap = MockMapboxMap()
    var gestures = MockGestureManager()
    var viewportManager = MockViewportManager()
    var ornaments = MockOrnamentsManager()

    var makeViewportTransitionStub = Stub<ViewportAnimation, ViewportTransition>(defaultReturnValue: MockViewportTransition())
    struct MakeViewportParameters {
        var viewport: Viewport
        var layoutDirection: SwiftUI.LayoutDirection
    }
    var makeViewportStateStub = Stub<MakeViewportParameters, ViewportState?>(defaultReturnValue: nil)

    var facade: MapViewFacade
    init() {
        facade = MapViewFacade(
            styleManager: style,
            mapboxMap: mapboxMap,
            gestureManager: gestures,
            viewportManager: viewportManager,
            ornaments: ornaments,
            debugOptions: [],
            isOpaque: false,
            presentationTransactionMode: .automatic,
            frameRate: Map.FrameRate(),
            makeViewportTransition: makeViewportTransitionStub.call(with:),
            makeViewportState: { [makeViewportStateStub] viewport, layoutDirection in
                makeViewportStateStub.call(with: MakeViewportParameters(viewport: viewport, layoutDirection: layoutDirection))
            })
    }
}

class MockViewportManager: ViewportManagerProtocol {
    var options: ViewportOptions = .init()

    private struct WeakViewportStatusObserver {
        weak var value: ViewportStatusObserver?
    }

    private var observers = [WeakViewportStatusObserver]()
    func addStatusObserver(_ observer: ViewportStatusObserver) {
        observers.append(WeakViewportStatusObserver(value: observer))
    }

    func removeStatusObserver(_ observer: MapboxMaps.ViewportStatusObserver) {
        observers.removeAll { $0.value === observer }
    }

    func simulateViewportStatusDidChange(from fromStatus: ViewportStatus,
                                         to toStatus: ViewportStatus,
                                         reason: ViewportStatusChangeReason) {
        for observer in observers {
            observer.value?.viewportStatusDidChange(from: fromStatus, to: toStatus, reason: reason)
        }
    }

    var idleStub = Stub<Void, Void>()
    func idle() {
        idleStub.call()
    }

    struct TransitionParams {
        var toState: ViewportState
        var transition: ViewportTransition?
        var completion: ((Bool) -> Void)?
    }
    let transitionStub = Stub<TransitionParams, Void>()
    func transition(to toState: ViewportState, transition: ViewportTransition?, completion: ((Bool) -> Void)?) {
        transitionStub.call(with: .init(
            toState: toState,
            transition: transition,
            completion: completion))
    }

    var makeImmediateViewportTransitionStub = Stub<Void, ViewportTransition>(defaultReturnValue: MockViewportTransition())
    func makeImmediateViewportTransition() -> MapboxMaps.ViewportTransition {
        makeImmediateViewportTransitionStub.call()
    }
}
