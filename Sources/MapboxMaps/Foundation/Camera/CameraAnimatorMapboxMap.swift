internal protocol CameraAnimatorMapboxMap: AnyObject {
    var cameraState: CameraState { get }
    var anchor: CGPoint { get }
    func setCamera(to cameraOptions: CameraOptions)
}

extension MapboxMap: CameraAnimatorMapboxMap {
}
