import UIKit

final class CameraViewportState: ViewportState {
    private var token: AnyCancelable?

    private let result: Signal<CameraOptions>
    private let mapboxMap: MapboxMapProtocol

    init(cameraOptions: Signal<CameraOptions>, mapboxMap: MapboxMapProtocol, safeAreaPadding: Signal<UIEdgeInsets?>) {
        self.mapboxMap = mapboxMap
        result = Signal.combineLatest(cameraOptions, safeAreaPadding).map { (cameraOptions, safeAreaPadding) in
            let opts = copyAssigned(cameraOptions, \.padding, cameraOptions.padding + safeAreaPadding)
            return opts
        }
    }

    func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        result.observeWithCancellingHandler(handler)
    }

    func startUpdatingCamera() {
        token = result.observe { [mapboxMap] options in
            mapboxMap.setCamera(to: options)
        }
    }

    func stopUpdatingCamera() {
        token = nil
    }
}

extension CameraViewportState {
    /// A camera viewport thats uses the camera options defined as a style root property when style root is loaded.
    static func defaultStyleViewport(
        with padding: UIEdgeInsets,
        styleManager: StyleProtocol,
        mapboxMap: MapboxMapProtocol,
        safeAreaPadding: Signal<UIEdgeInsets?>
    ) -> CameraViewportState {
        let camera = styleManager.isStyleRootLoaded
            .filter { $0 }
            .map { _ in
                styleManager.styleDefaultCamera
            }
            .map {
                // There is no padding in style spec, overriding it.
                copyAssigned($0, \.padding, padding)
            }
            .takeFirst() // use only first loaded style after viewport activation.
        return CameraViewportState(cameraOptions: camera, mapboxMap: mapboxMap, safeAreaPadding: safeAreaPadding)
    }
}
