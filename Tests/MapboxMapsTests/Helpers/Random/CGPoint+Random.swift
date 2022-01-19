import CoreGraphics

extension CGPoint {
    static func random() -> Self {
        return CGPoint(
            x: .random(in: -100...100),
            y: .random(in: -100...100))
    }
}
