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
        self.camera = try container.decode(SLACameraOptions.self, forKey: .camera).cameraOptions
        tileStoreUsageMode = .readOnly
    }

    init(style: StyleURI, camera: CameraOptions, tileStoreUsageMode: TileStoreUsageMode = .disabled) {
        self.style = style
        self.camera = camera
        self.tileStoreUsageMode = tileStoreUsageMode
    }

    @MainActor
    func execute(context: Context) async throws {
        guard let viewController = UIViewController.rootController else {
            throw ExecutionError.cannotFindRootViewController
        }

        MapboxMapsOptions.tileStoreUsageMode = tileStoreUsageMode
        let mapInitOptions = MapInitOptions(
            cameraOptions: camera,
            styleURI: style
        )
        context.mapView = MapView(frame: viewController.view.frame, mapInitOptions: mapInitOptions)
        context.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        viewController.view.addSubview(context.mapView)

        _ = try await withCheckedThrowingContinuation { continuation in
                context.mapView.mapboxMap.onMapLoaded.observeNext { event in
                    return continuation.resume(returning: event)
                }.store(in: &context.cancellables)

                context.mapView.mapboxMap.onMapLoadingError.observeNext { event in
                    guard event.type == .source else { return }
                    return continuation.resume(throwing: Error.cannotLoadMap)
                }.store(in: &context.cancellables)
        }
    }

    func cleanup(context: Context) {
        context.mapView?.removeFromSuperview()
    }
}

private struct SLACameraOptions: Decodable {
    let cameraOptions: MapboxMaps.CameraOptions
    enum CenterCodingKeys: CodingKey {
        case center
    }
    init(from decoder: Decoder) throws {
        var cameraOptions = try MapboxMaps.CameraOptions(from: decoder)
        if cameraOptions.center == nil {
            let container = try decoder.container(keyedBy: CenterCodingKeys.self)
            cameraOptions.center = try container.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .center)
        }
        self.cameraOptions = cameraOptions
    }
}
