import MapboxMaps

enum InteractiveDraggablePinConstants {
    /// Zugspitze summit, where the pin starts and the distance is measured from.
    static let startCoordinate = CLLocationCoordinate2D(latitude: 47.42121509431908, longitude: 10.986297279596329)

    /// Initial camera centered on the start coordinate.
    static let cameraOptions = CameraOptions(center: startCoordinate, zoom: 12.283)
}
