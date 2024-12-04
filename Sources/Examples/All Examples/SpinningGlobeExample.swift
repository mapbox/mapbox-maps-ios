import Foundation
import UIKit
import MapboxMaps
import CoreLocation

final class SpinningGlobeExample: UIViewController, GestureManagerDelegate, ExampleProtocol {
    private var userInteracting = false
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds, mapInitOptions: .init(styleURI: .satellite))
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapboxMap.setCamera(to: .init(center: CLLocationCoordinate2D(latitude: 40, longitude: -90), zoom: 1.0))
        try! self.mapView.mapboxMap.setProjection(StyleProjection(name: .globe))

        mapView.mapboxMap.onStyleLoaded.observeNext { _ in
            try! self.mapView.mapboxMap.setAtmosphere(Atmosphere())
            self.spinGlobe()
            self.finish()
        }.store(in: &cancelables)

        addStyleLoadingDebugEvents()

        mapView.gestures.delegate = self

        // Enable the camera debug option to see camera state
        let debugOptions: MapViewDebugOptions = [.camera]
        mapView.debugOptions = debugOptions

        view.addSubview(mapView)
    }

    func addStyleLoadingDebugEvents() {
        func logEvent<T: LogableEvent>(_ signal: Signal<T>) {
            signal.observe {
                print(Date(), $0.logString)
            }.store(in: &cancelables)
        }

        logEvent(mapView.mapboxMap.onMapLoadingError)
        logEvent(mapView.mapboxMap.onStyleDataLoaded)
        logEvent(mapView.mapboxMap.onStyleImageMissing)
        logEvent(mapView.mapboxMap.onMapIdle)
        logEvent(mapView.mapboxMap.onMapLoaded)
        logEvent(mapView.mapboxMap.onStyleImageMissing)
        logEvent(mapView.mapboxMap.onStyleImageMissing)
    }

    func spinGlobe() {
        // At low zooms, complete a revolution every two minutes.
        let secPerRevolution = 120.0
        // Above zoom level 5, do not rotate.
        let maxSpinZoom = 5.0
        // Rotate at intermediate speeds between zoom levels 3 and 5.
        let slowSpinZoom = 3.0

        let zoom = mapView.mapboxMap.cameraState.zoom
        if !userInteracting && zoom < maxSpinZoom {
            var distancePerSecond = 360.0 / secPerRevolution
            if zoom > slowSpinZoom {
                // Slow spinning at higher zooms
                let zoomDif = (maxSpinZoom - zoom) / (maxSpinZoom - slowSpinZoom)
                distancePerSecond *= zoomDif
            }
            let center = mapView.mapboxMap.cameraState.center
            let targetCenter = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude - distancePerSecond)

            // Smoothly animate the map over one second.
            // When this animation is complete, call it again
            mapView.camera.ease(to: .init(center: targetCenter), duration: 1.0, curve: .linear) { [weak self] rotating in

                guard rotating == .end else {
                    return
                }
                self?.spinGlobe()
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
