import XCTest
import MapboxMaps

/// A performance benchmark that flies the camera across the map to different locations.
///
/// It adds a delay to each step to make sure we capture the rendering in cloud test services.
final class AnimationFlyToBenchmark: BaseBenchmark {

    func test_sla_WarmCacheBenchmark1() {
        benchmark(timeout: 61) {
            onStyleLoaded { mapView, _ in
                self.visit(.tokyo, .minsk, .helsinki, .tokyo, .helsinki, .minsk) {
                    self.stopBenchmark()
                }
            }
        }
    }

    private func visit(_ cities: CameraOptions..., completion: @escaping () -> ()) {
        flyTo(cities, completion: completion)
    }


    private func flyTo(_ cities: [CameraOptions], completion: @escaping () -> ()) {
        guard let city = cities.first else {
            completion()
            return
        }
        let remainingCities = Array(cities.dropFirst())

        mapView.camera.fly(to: city, duration: 7.5) { _ in

            guard !remainingCities.isEmpty else { // return early if there are no cities to fly to
                completion()
                return
            }

            // keep flying to the remaining cities
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.flyTo(remainingCities, completion: completion)
            }
        }
    }
}

extension CameraOptions {
    static var tokyo: CameraOptions {
        CameraOptions(center: CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305),
                      zoom: 16,
                      bearing: 0,
                      pitch: 0)

    }
    static var minsk: CameraOptions {
        CameraOptions(center: CLLocationCoordinate2D(latitude: 53.902496, longitude: 27.561481),
                      zoom: 16,
                      bearing: 0,
                      pitch: 0)

    }
    static var helsinki: CameraOptions {
        CameraOptions(center: CLLocationCoordinate2D(latitude: 60.171924, longitude: 24.945749),
                      zoom: 16,
                      bearing: 0,
                      pitch: 0)

    }
}
