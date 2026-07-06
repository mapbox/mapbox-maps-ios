import MapboxCoreMaps

extension CoreScreenBox {
    internal convenience init(_ rect: CGRect) {
        self.init(
            min: CoreScreenCoordinate(x: Double(rect.minX), y: Double(rect.minY)),
            max: CoreScreenCoordinate(x: Double(rect.maxX), y: Double(rect.maxY)))
    }
}

extension CGRect {
    internal init(_ box: CoreScreenBox) {
        self.init(
            x: box.min.x,
            y: box.min.y,
            width: box.max.x - box.min.x,
            height: box.max.y - box.min.y)
    }
}
