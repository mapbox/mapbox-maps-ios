import UIKit
import MapboxMaps

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!
    var animator = UIViewPropertyAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(mapView, at: 0)

        let config = Puck2DConfiguration(pulsing: .default)
        mapView.location.options.puckType = .puck2D(config)
        mapView.viewport.transition(to: mapView.viewport.makeFollowPuckViewportState())

//        animator.duration = 0.3
//        animator.addAnimations {
//            view.alpha = 0
//            print("aaa animation invoked")
//        }
//        animator.addCompletion { _ in
//            print("aaa animation completed")
//        }
//        animator.startAnimation()
//        animator.pauseAnimation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
}
