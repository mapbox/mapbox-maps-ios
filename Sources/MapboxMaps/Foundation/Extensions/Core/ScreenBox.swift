import MapboxCoreMaps

extension CoreScreenBox {
    internal convenience init(_ rect: CGRect) {
        self.init(
            min: CoreScreenCoordinate(x: Double(rect.minX), y: Double(rect.minY)),
            max: CoreScreenCoordinate(x: Double(rect.maxX), y: Double(rect.maxY)))
    }
}
