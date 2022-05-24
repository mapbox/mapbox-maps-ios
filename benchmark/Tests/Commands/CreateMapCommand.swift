import Foundation
import MapboxMaps

public struct CreateMapCommand: AsyncCommand, Decodable {
    let style: StyleURI
    let camera: CameraOptions

    enum Error: Swift.Error {
        case cannotLoadMap
    }

    @MainActor
    func execute() async throws {
        let viewController = UIViewController.rootController!
        let mapInitOptions = MapInitOptions(cameraOptions: camera, styleURI: style)
        let mapView = MapView(frame: viewController.view.frame, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        viewController.view.addSubview(mapView)

        try await withCheckedThrowingContinuation { continuation in
            mapView.mapboxMap.onNext(.mapLoaded) { [weak mapView] event in
                mapView?.removeFromSuperview()
                return continuation.resume(returning: ())
            }

            mapView.mapboxMap.onNext(.mapLoadingError) { [weak mapView] event in
                mapView?.removeFromSuperview()
                return continuation.resume(throwing: Error.cannotLoadMap)
            }
        }
        as Void // This cast is nessesary to help type checker find <T> for …Continuation func
    }
}

extension StyleURI: Decodable { }
