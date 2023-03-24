import CoreFoundation
import CoreLocation

internal protocol PinchBehaviorProviderProtocol: AnyObject {
    func makePinchBehavior(panEnabled: Bool,
                           zoomEnabled: Bool,
                           initialCameraState: CameraState,
                           initialPinchMidpoint: CGPoint,
                           focalPoint: CGPoint?) -> PinchBehavior
}

internal final class PinchBehaviorProvider: PinchBehaviorProviderProtocol {

    private let mapboxMap: MapboxMapProtocol

    init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    internal func makePinchBehavior(panEnabled: Bool,
                                    zoomEnabled: Bool,
                                    initialCameraState: CameraState,
                                    initialPinchMidpoint: CGPoint,
                                    focalPoint: CGPoint?) -> PinchBehavior {
        switch (panEnabled, zoomEnabled) {
        case (true, true):
            return PanZoomPinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                mapboxMap: mapboxMap)
        case (true, false):
            return PanPinchBehavior(
                initialPinchMidpoint: initialPinchMidpoint,
                mapboxMap: mapboxMap)
        case (false, true):
            return ZoomPinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                focalPoint: focalPoint,
                mapboxMap: mapboxMap)
        case (false, false):
            return EmptyPinchBehavior()
        }
    }
}
