import UIKit

/// The `GestureHandlerDelegate` protocol supports communication
/// from the Gestures module to the `MapView`.
internal protocol GestureHandlerDelegate: AnyObject {
    // Notifies conformer that a gesture has begun
    func gestureBegan(for gestureType: GestureType)

    // Bearing should change with `changedAngle` at a given `anchor`
    func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat)
}
