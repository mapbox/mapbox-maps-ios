import MapboxCoreMaps

extension ScreenBox {
    internal convenience init(_ rect: CGRect) {
        self.init(
            min: ScreenCoordinate(x: Double(rect.minX), y: Double(rect.minY)),
            max: ScreenCoordinate(x: Double(rect.maxX), y: Double(rect.maxY)))
    }
}
