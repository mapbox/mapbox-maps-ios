import Foundation
import MapboxMaps

struct CreateMapCommand: AsyncCommand, Decodable {
    let style: StyleURI
    let camera: CameraOptions
    let tileStoreUsageMode: TileStoreUsageMode

    enum Error: Swift.Error {
        case cannotLoadMap
    }

    enum CodingKeys: CodingKey {
        case style
        case camera
        case tileStoreUsage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.style = try container.decode(StyleURI.self, forKey: .style)
        self.camera = try container.decode(CameraOptions.self, forKey: .camera)
        if try container.decodeIfPresent(Bool.self, forKey: .tileStoreUsage) == true {
            self.tileStoreUsageMode = .readOnly
        } else {
            self.tileStoreUsageMode = .disabled
        }
    }

    init(style: StyleURI, camera: CameraOptions, tileStoreUsageMode: TileStoreUsageMode = .disabled) {
        self.style = style
        self.camera = camera
        self.tileStoreUsageMode = tileStoreUsageMode
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

        let mapInitOptions = MapInitOptions(
            resourceOptions: ResourceOptionsManager.default.resourceOptions.tileStoreUsageMode(tileStoreUsageMode),
            cameraOptions: camera,
            styleURI: style
        )
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
