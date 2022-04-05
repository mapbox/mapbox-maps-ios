internal protocol DefaultViewportTransitionAnimationSpecProviderProtocol: AnyObject {
    func makeAnimationSpecs(cameraOptions: CameraOptions) -> [DefaultViewportTransitionAnimationSpec]
}

internal final class DefaultViewportTransitionAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol {

    private let mapboxMap: MapboxMapProtocol
    private let lowZoomToHighZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol
    private let highZoomToLowZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol

    internal init(mapboxMap: MapboxMapProtocol,
                  lowZoomToHighZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol,
                  highZoomToLowZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol) {
        self.mapboxMap = mapboxMap
        self.lowZoomToHighZoomAnimationSpecProvider = lowZoomToHighZoomAnimationSpecProvider
        self.highZoomToLowZoomAnimationSpecProvider = highZoomToLowZoomAnimationSpecProvider
    }

    func makeAnimationSpecs(cameraOptions: CameraOptions) -> [DefaultViewportTransitionAnimationSpec] {
        let provider: DefaultViewportTransitionAnimationSpecProviderProtocol
        let currentZoom = mapboxMap.cameraState.zoom
        if let targetZoom = cameraOptions.zoom, currentZoom < targetZoom {
            provider = lowZoomToHighZoomAnimationSpecProvider
        } else {
            provider = highZoomToLowZoomAnimationSpecProvider
        }
        return provider.makeAnimationSpecs(cameraOptions: cameraOptions)
    }
}
