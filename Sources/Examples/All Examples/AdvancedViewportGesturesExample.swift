import UIKit
import MapboxMaps

// This example configures the viewport so that when it's in the follow puck state,
// zoom and pitch gestures work alongside updates coming from the state itself.
// Single tap on the map to switch to the overview state.
//
// When trying this example in the simulator, choose Features > Location > Freeway Drive
// to get a good sense of the resulting user experience.
final class AdvancedViewportGesturesExample: UIViewController, ExampleProtocol {

    private enum State {
        case following
        case overview
    }

    private var state: State = .following {
        didSet {
            syncWithState()
        }
    }

    private var mapView: MapView!
    private var followPuckViewportState: FollowPuckViewportState!
    private var overviewViewportState: OverviewViewportState!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        view.addSubview(mapView)

        let cupertino = CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322)

        mapView.mapboxMap.setCamera(to: CameraOptions(center: cupertino, zoom: 14))

        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: true))
        mapView.location.options.puckBearing = .course
        mapView.location.options.puckBearingEnabled = true

        followPuckViewportState = mapView.viewport.makeFollowPuckViewportState(
            options: FollowPuckViewportStateOptions(
                bearing: .course))

        overviewViewportState = mapView.viewport.makeOverviewViewportState(
            options: OverviewViewportStateOptions(
                geometry: Polygon(
                    center: cupertino,
                    radius: 20000,
                    vertices: 100)))

        mapView.gestures.delegate = self

        syncWithState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
        mapView.viewport.addStatusObserver(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // break strong reference cycle
        mapView.viewport.removeStatusObserver(self)
    }

    private func toggleViewportState() {
        switch state {
        case .overview:
            state = .following
        case .following:
            state = .overview
        }
    }

    private func syncWithState() {
        switch state {
        case .following:
            mapView.viewport.transition(to: followPuckViewportState)
        case .overview:
            mapView.viewport.transition(to: overviewViewportState)
        }

        mapView.viewport.options.transitionsToIdleUponUserInteraction = state == .overview
        mapView.gestures.options.panEnabled = state == .overview
        mapView.gestures.options.pinchEnabled = state == .overview
    }
}

extension AdvancedViewportGesturesExample: GestureManagerDelegate {
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        switch gestureType {
        case .pitch:
            if state == .following {
                followPuckViewportState.options.pitch = nil
            }
        case .doubleTapToZoomIn, .doubleTouchToZoomOut, .quickZoom:
            if state == .following {
                followPuckViewportState.options.zoom = nil
            }
        default:
            break
        }
    }

    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        switch gestureType {
        case .pitch:
            if state == .following {
                followPuckViewportState.options.pitch = mapView.mapboxMap.cameraState.pitch
            }
        case .quickZoom:
            if state == .following {
                followPuckViewportState.options.zoom = mapView.mapboxMap.cameraState.zoom
            }
        case .singleTap:
            toggleViewportState()
        default:
            break
        }
    }

    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        switch gestureType {
        case .doubleTapToZoomIn, .doubleTouchToZoomOut:
            if state == .following {
                followPuckViewportState.options.zoom = mapView.mapboxMap.cameraState.zoom
            }
        default:
            break
        }
    }
}

extension AdvancedViewportGesturesExample: ViewportStatusObserver {
    func viewportStatusDidChange(
        from fromStatus: ViewportStatus,
        to toStatus: ViewportStatus,
        reason: ViewportStatusChangeReason) {
            print("Viewport.status changed\n    from: \(fromStatus)\n    to: \(toStatus)\n    with reason: \(reason)")
    }
}
