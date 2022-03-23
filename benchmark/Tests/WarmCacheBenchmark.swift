import XCTest
import MapboxMaps

/// A performance benchmark tracking the time it takes to initialize the map with a warm cache.
final class WarmCacheBenchmark: BaseBenchmark {
    static var cameraOptions: CameraOptions = {
        CameraOptions(center: CLLocationCoordinate2D(latitude: 41.59679, longitude: -93.61406), zoom: 12)
    }()

    func test_sla_WarmCacheBenchmark() throws {

        benchmark {
            self.onMapLoaded { mapView in
                mapView.removeFromSuperview()
                self.onMapLoaded { _ in
                    self.stopBenchmark()
                }
            }
        }
    }
}
