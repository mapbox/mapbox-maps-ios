import UIKit
import MapboxMaps

@objc(AdvancedViewportGesturesExample)
final class AdvancedViewportGesturesExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var followingViewportState: FollowingViewportState!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        view.addSubview(mapView)

        mapView.location.options.puckType = .puck2D()

        followingViewportState = mapView.viewport.makeFollowingViewportState(
            options: FollowingViewportStateOptions(bearing: .course))

        mapView.viewport.transition(to: followingViewportState)

        mapView.gestures.options.panEnabled = false
        mapView.gestures.options.pitchEnabled = false
        mapView.gestures.options.pinchEnabled = false
        mapView.gestures.options.doubleTapToZoomInEnabled = false
        mapView.gestures.options.doubleTouchToZoomOutEnabled = false
        mapView.gestures.options.quickZoomEnabled = false
        mapView.gestures.options.animationLockoutEnabled = false

        let doubleTapGestureRecognzier = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        doubleTapGestureRecognzier.numberOfTapsRequired = 2
        doubleTapGestureRecognzier.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(doubleTapGestureRecognzier)

        let doubleTouchGestureRecognzier = UITapGestureRecognizer(target: self, action: #selector(zoomOut))
        doubleTouchGestureRecognzier.numberOfTapsRequired = 1
        doubleTouchGestureRecognzier.numberOfTouchesRequired = 2
        mapView.addGestureRecognizer(doubleTouchGestureRecognzier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // The below line is used for internal testing purposes only.
        finish()
    }

    @objc private func zoomIn() {
        followingViewportState.options.zoom += 1
    }

    @objc private func zoomOut() {
        followingViewportState.options.zoom -= 1
    }
}
