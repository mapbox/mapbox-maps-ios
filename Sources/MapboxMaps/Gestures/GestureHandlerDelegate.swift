import UIKit

/// The `GestureHandlerDelegate` protocol supports communication
/// from the Gestures module to the `MapView`.
internal protocol GestureHandlerDelegate: AnyObject {
    // Notifies conformer that a gesture has begun
    func gestureBegan(for gestureType: GestureType)
}
