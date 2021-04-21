import Foundation
import MapboxCoreMaps

public final class MapboxMap {
    /// The underlying renderer object responsible for rendering the map
    public let __map: Map

    internal var size: CGSize {
        get {
            CGSize(__map.getSize())
        }
        set {
            __map.setSizeFor(Size(newValue))
        }
    }

    internal init(mapClient: MapClient, mapInitOptions: MapInitOptions) {
        __map = Map(
            client: mapClient,
            mapOptions: mapInitOptions.mapOptions,
            resourceOptions: mapInitOptions.resourceOptions)
        __map.createRenderer()
    }

    internal var cameraOptions: CameraOptions {
        return __map.getCameraOptions(forPadding: nil)
    }

    internal func updateCamera(with cameraOptions: CameraOptions) {
        __map.setCameraFor(cameraOptions)
    }
}
