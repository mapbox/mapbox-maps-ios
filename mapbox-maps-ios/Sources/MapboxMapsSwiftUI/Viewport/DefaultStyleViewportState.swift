import UIKit
@_spi(Package) import MapboxMaps

// Sets the camera to the style default viewport state.
// Waits until the style is loaded to get the proper style's camera state.
final class DefaultStyleViewportState: ViewportState {
    private let mapboxMap: MapboxMapProtocol
    private let styleManager: StyleProtocol
    private let padding: UIEdgeInsets

    private let signalSubject = SignalSubject<CameraOptions>()
    private var cameraOptions: CameraOptions? {
        didSet {
            if let cameraOptions {
                signalSubject.send(cameraOptions)
            }
        }
    }
    private var token: AnyCancelable?
    private var styleDataLoadedToken: AnyCancelable?
    private var externalTokens = Set<AnyCancelable>()

    init(mapboxMap: MapboxMapProtocol,
         styleManager: StyleProtocol,
         padding: UIEdgeInsets) {
        self.mapboxMap = mapboxMap
        self.styleManager = styleManager
        self.padding = padding

        // If style is not loaded we will observe it once and update the `cameraOptions`
        if styleManager.isStyleLoaded {
            initializeCameraOptions()
        } else {
            styleDataLoadedToken = mapboxMap.onStyleLoaded
                .observeNext { [weak self] _ in
                // Style's default camera options is available when style data is loaded.
                self?.initializeCameraOptions()
            }
        }
    }

    private func initializeCameraOptions() {
        var cameraOptions = styleManager.styleDefaultCamera
        cameraOptions.padding = padding
        self.cameraOptions = cameraOptions
    }

    func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        if let cameraOptions {
            _ = handler(cameraOptions)
            return AnyCancelable {}
        }

        // If the camera options are not loaded yet, we will will fire handler in the next update
        let token = signalSubject.signal.observeNext { options in
            _ = handler(options)
        }
        // We have to keep the token alive, since the caller is not guaranteed to keep it.
        externalTokens.insert(token)
        return token
    }

    func startUpdatingCamera() {
        token = signalSubject.signal.observe { [weak self] options in
            self?.mapboxMap.setCamera(to: options)
        }
    }

    func stopUpdatingCamera() {
        token = nil
    }
}
