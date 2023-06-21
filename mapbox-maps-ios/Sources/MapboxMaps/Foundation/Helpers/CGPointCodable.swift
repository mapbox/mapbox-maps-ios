import CoreFoundation.CFCGTypes

/// `CGPoint` with Codable & Hashable support
internal struct CGPointCodable: Codable, Hashable {
    var x: CGFloat
    var y: CGFloat
}

extension CGPointCodable {
    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    var point: CGPoint {
        get { CGPoint(x: x, y: y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }
}
