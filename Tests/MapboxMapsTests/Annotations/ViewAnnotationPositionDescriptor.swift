@testable import MapboxMaps

extension MapboxCoreMaps.ViewAnnotationPositionDescriptor {
    convenience init(
        identifier: String,
        frame: CGRect,
        anchorCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0),
        anchorConfig: ViewAnnotationAnchorConfig = ViewAnnotationAnchorConfig(anchor: .center),
        additionalLeftTopCoordinates: [CoreScreenCoordinate] = []
    ) {
        self.init(__identifier: identifier,
                  width: frame.width,
                  height: frame.height,
                  leftTopCoordinate: CoreScreenCoordinate(x: frame.minX, y: frame.minY),
                  anchorCoordinate: anchorCoordinate,
                  anchorConfig: anchorConfig,
                  additionalLeftTopCoordinates: additionalLeftTopCoordinates)
    }
}
