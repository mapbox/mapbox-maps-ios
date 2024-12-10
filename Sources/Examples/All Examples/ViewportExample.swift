import UIKit
import MapboxMaps

// This example shows how to use the viewport API to keep the camera in sync with the puck,
// show an overview of a region, and toggle between those states with transitions.
//
// When trying this example in the simulator, choose Features > Location > Freeway Drive
// to get a good sense of the resulting user experience.
final class ViewportExample: UIViewController, ExampleProtocol {
    private enum State {
        case following
        case overview
    }

    private var state: State = .following {
        didSet {
            syncWithState()
        }
    }

    private var viewportButton = UIButton(type: .system)
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
        mapView.location.options.puckBearing = .heading
        mapView.location.options.puckBearingEnabled = true

        followPuckViewportState = mapView.viewport.makeFollowPuckViewportState(
            options: FollowPuckViewportStateOptions(
                bearing: .heading))

        overviewViewportState = mapView.viewport.makeOverviewViewportState(
            options: OverviewViewportStateOptions(
                geometry: Polygon(
                    center: cupertino,
                    radius: 20000,
                    vertices: 100)))

        viewportButton.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            viewportButton.backgroundColor = .systemBackground
        } else {
            viewportButton.backgroundColor = .white
        }
        viewportButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.addSubview(viewportButton)
        NSLayoutConstraint.activate([
            viewportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        viewportButton.addTarget(
            self,
            action: #selector(toggleViewportState),
            for: .touchUpInside)

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

    @objc private func toggleViewportState() {
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
            viewportButton.setTitle("Overview", for: .normal)
        case .overview:
            mapView.viewport.transition(to: overviewViewportState)
            viewportButton.setTitle("Follow", for: .normal)
        }
    }
}

extension ViewportExample: ViewportStatusObserver {
    func viewportStatusDidChange(
        from fromStatus: ViewportStatus,
        to toStatus: ViewportStatus,
        reason: ViewportStatusChangeReason) {
            print("Viewport.status changed\n    from: \(fromStatus)\n    to: \(toStatus)\n    with reason: \(reason)")
    }
}
