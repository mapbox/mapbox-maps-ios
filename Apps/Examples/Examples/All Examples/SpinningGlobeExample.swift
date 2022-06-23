import Foundation
import UIKit
@_spi(Experimental) import MapboxMaps
import CoreLocation

class SpinningGlobeExample: UIViewController, GestureManagerDelegate, ExampleProtocol{

    var userInteracting = false
    var spinEnabled = true
    var currentProjection = StyleProjection(name: .globe)
    var currentAtmosphere = Atmosphere()
    var mapView: MapView!
    var runningAnimation: Cancelable!


    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .satellite))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        try! mapView.mapboxMap.style.setProjection(currentProjection)
//        try! mapView.mapboxMap.style.setAtmosphere(properties: ["color": "rgb(220, 159, 159)",
//                                                                "highColor": "rgb(220, 159, 159)",
//                                                                "horizonBlend": 0.4])
        mapView.mapboxMap.setCamera(to: .init(center: CLLocationCoordinate2D(latitude: 40, longitude: -90), zoom: 1.0))

        mapView.mapboxMap.onNext(event: .styleLoaded) { _ in
            try! self.mapView.mapboxMap.style.setAtmosphere(self.currentAtmosphere)
            self.spinGlobe()
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
        if (spinEnabled && !userInteracting && zoom < maxSpinZoom) {
            var distancePerSecond = 360.0 / secPerRevolution
            if (zoom > slowSpinZoom) {
                // Slow spinning at higher zooms
                let zoomDif = (maxSpinZoom - zoom) / (maxSpinZoom - slowSpinZoom)
                distancePerSecond *= zoomDif
            }
            let center = mapView.cameraState.center
            let targetCenter = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude - distancePerSecond)

            // Smoothly animate the map over one second.
            // When this animation is complete, call it again
            mapView.camera.ease(to: .init(center: targetCenter), duration: 1.0, curve: .linear) { _ in

                self.spinGlobe()
            }
        }

    }

    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        // do nothing
    }

    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        if gestureType == .doubleTouchToZoomOut || gestureType == .pinch || gestureType == .doubleTapToZoomIn {
            if mapView.cameraState.zoom < 5 {
                if userInteracting == true {
                    self.spinGlobe()
                }
            } else {
                print("dont spin")
            }
        }
    }

    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        // do nothing
    }
}
