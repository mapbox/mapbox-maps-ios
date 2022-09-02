import Foundation
import MapboxMaps

public struct CreateMapCommand: AsyncCommand, Decodable {
    let style: StyleURI
    let camera: CameraOptions

    enum Error: Swift.Error {
        case cannotLoadMap
    }

    var mapView: MapView? {
        let rootView = UIViewController.rootController?.view
        let mapViews = rootView?.subviews.compactMap({ $0 as? MapView })
        assert(mapViews?.count == 1)
        return mapViews?.first
    }

    @MainActor
    func execute() async throws {
        let viewController = UIViewController.rootController!
        let mapInitOptions = MapInitOptions(cameraOptions: camera, styleURI: style)
        let mapView = MapView(frame: viewController.view.frame, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        viewController.view.addSubview(mapView)

        try await withCheckedThrowingContinuation { continuation in
            mapView.mapboxMap.onNext(event: .mapLoaded) { event in
                return continuation.resume(returning: ())
            }

            mapView.mapboxMap.onNext(event: .mapLoadingError) { event in
                if case .source = event.payload.error {
                    return continuation.resume(throwing: Error.cannotLoadMap)
                }
            }
        }
        as Void // This cast is nessesary to help type checker find <T> for …Continuation func
    }

    func cleanup() {
        UIViewController.rootController?.view.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
