@_implementationOnly import MapboxCoreMaps_Private

extension MapboxCoreMaps.ViewAnnotationPositionDescriptor {
    convenience init(
        identifier: String,
        frame: CGRect,
        anchorCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        anchorConfig: ViewAnnotationAnchorConfig = ViewAnnotationAnchorConfig(anchor: .center)
    ) {
        self.init(__identifier: identifier,
                  width: frame.width,
                  height: frame.height,
                  leftTopCoordinate: ScreenCoordinate(x: frame.minX, y: frame.minY),
                  anchorCoordinate: anchorCoordinate,
                  anchorConfig: anchorConfig)
    }
}
