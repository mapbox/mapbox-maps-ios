import CoreFoundation
import CoreLocation

internal protocol PinchBehaviorProviderProtocol: AnyObject {
    // swiftlint:disable:next function_parameter_count
    func makePinchBehavior(panEnabled: Bool,
                           zoomEnabled: Bool,
                           rotateEnabled: Bool,
                           initialCameraState: CameraState,
                           initialPinchMidpoint: CGPoint,
                           initialPinchAngle: CGFloat,
                           focalPoint: CGPoint?) -> PinchBehavior
}

internal final class PinchBehaviorProvider: PinchBehaviorProviderProtocol {

    private let mapboxMap: MapboxMapProtocol

    init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    // swiftlint:disable:next function_parameter_count
    internal func makePinchBehavior(panEnabled: Bool,
                                    zoomEnabled: Bool,
                                    rotateEnabled: Bool,
                                    initialCameraState: CameraState,
                                    initialPinchMidpoint: CGPoint,
                                    initialPinchAngle: CGFloat,
                                    focalPoint: CGPoint?) -> PinchBehavior {
        switch (panEnabled, zoomEnabled, rotateEnabled) {
        case (true, true, true):
            return PanZoomRotatePinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                initialPinchAngle: initialPinchAngle,
                mapboxMap: mapboxMap)
        case (true, true, false):
            return PanZoomPinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                mapboxMap: mapboxMap)
        case (true, false, true):
            return PanRotatePinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                initialPinchAngle: initialPinchAngle,
                mapboxMap: mapboxMap)
        case (true, false, false):
            return PanPinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                mapboxMap: mapboxMap)
        case (false, true, true):
            return ZoomRotatePinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                initialPinchAngle: initialPinchAngle,
                focalPoint: focalPoint,
                mapboxMap: mapboxMap)
        case (false, true, false):
            return ZoomPinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                focalPoint: focalPoint,
                mapboxMap: mapboxMap)
        case (false, false, true):
            return RotatePinchBehavior(
                initialCameraState: initialCameraState,
                initialPinchMidpoint: initialPinchMidpoint,
                initialPinchAngle: initialPinchAngle,
                focalPoint: focalPoint,
                mapboxMap: mapboxMap)
        case (false, false, false):
            return EmptyPinchBehavior()
        }
    }
}
