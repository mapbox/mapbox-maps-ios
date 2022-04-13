import XCTest
import MapboxMaps

///  A performance benchmark that eases the camera across the map from/to a location using different zoom levels.
final class AnimationEaseToBenchmark: BaseBenchmark {
    private var executionCount: Int = 0
    private let startPoint = CLLocationCoordinate2D(latitude: 40.0, longitude: -74.5)
    private let endPoint = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    func sla_easeTo() {
        benchmark(timeout: 141) {
            onStyleLoaded { mapView, _ in
                mapView.mapboxMap.setCamera(to: CameraOptions(center: self.startPoint))
                self.easeTo {
                    self.stopBenchmark()
                }
            }
        }
    }

    private func easeTo(_ completion: @escaping () -> ()) {
        executionCount += 1
        let center = executionCount % 2 == 0 ? startPoint : endPoint
        let zoom: CGFloat = executionCount % 2 == 0 ? 9 : 3

        mapView.camera.ease(to: CameraOptions(center: center, zoom: zoom), duration: 7) { _ in
            if self.executionCount < 20 {
                self.easeTo(completion)
            } else {
                completion()
            }
        }
    }
}
