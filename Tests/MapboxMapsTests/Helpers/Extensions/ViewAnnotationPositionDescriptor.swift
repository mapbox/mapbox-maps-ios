@_implementationOnly import MapboxCoreMaps_Private

extension MapboxCoreMaps.ViewAnnotationPositionDescriptor {
    convenience init(identifier: String, width: Int, height: Int, leftTopCoordinate: CGPoint) {
        self.init(__identifier: identifier,
                  width: UInt32(width),
                  height: UInt32(height),
                  leftTopCoordinate: ScreenCoordinate(x: Double(leftTopCoordinate.x), y: Double(leftTopCoordinate.y))
        )
    }
}
