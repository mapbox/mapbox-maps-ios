import Foundation
import UIKit
import MapboxMaps
import CoreLocation

class SpinningGlobeExample: UIViewController, GestureManagerDelegate, ExampleProtocol {

    var userInteracting = false
    var mapView: MapView!

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .satellite))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.setCamera(to: .init(center: CLLocationCoordinate2D(latitude: 40, longitude: -90), zoom: 1.0))
        try! self.mapView.mapboxMap.style.setProjection(StyleProjection(name: .globe))

        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            try! self.mapView.mapboxMap.style.setAtmosphere(Atmosphere())
            self.spinGlobe()
            self.finish()
        }

        mapView.gestures.delegate = self

        view.addSubview(mapView)
    }

    func spinGlobe() {
        // At low zooms, complete a revolution every two minutes.
        let secPerRevolution = 120.0
        // Above zoom level 5, do not rotate.
        let maxSpinZoom = 5.0
        // Rotate at intermediate speeds between zoom levels 3 and 5.
        let slowSpinZoom = 3.0

        let zoom = mapView.cameraState.zoom
        if !userInteracting && zoom < maxSpinZoom {
            var distancePerSecond = 360.0 / secPerRevolution
            if zoom > slowSpinZoom {
                // Slow spinning at higher zooms
                let zoomDif = (maxSpinZoom - zoom) / (maxSpinZoom - slowSpinZoom)
                distancePerSecond *= zoomDif
            }
            let center = mapView.cameraState.center
            let targetCenter = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude - distancePerSecond)

            // Smoothly animate the map over one second.
            // When this animation is complete, call it again
            mapView.camera.ease(to: .init(center: targetCenter), duration: 1.0, curve: .linear) { rotating in

                guard rotating == .end else {
                    return
                }
                self.spinGlobe()
            }
        }
    }

    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        userInteracting = true
    }

    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {

        if !willAnimate {
            userInteracting = false
            DispatchQueue.main.async {
                self.spinGlobe()
            }
        }
    }

    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        userInteracting = false
        DispatchQueue.main.async {
            self.spinGlobe()
        }
    }
}
