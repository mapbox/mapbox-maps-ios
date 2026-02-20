import UIKit

extension UIGestureRecognizer {
    // MARK: - SwiftUI Compatibility

    /// Checks if two gesture recognizers are attached to the same view.
    /// Used to distinguish between recognizers attached to the SwiftUI hosting view
    /// and recognizers added to the underlying UIKit view.
    func attachedToSameView(as other: UIGestureRecognizer) -> Bool {
       view === other.view
    }

    /// Checks if a touch is directly on the same view as the gesture recognizer.
    /// Returns true only if `touch.view === gestureRecognizer.view`.
    func attachedToSameView(as touch: UITouch) -> Bool {
        view === touch.view
    }

    // MARK: - Map Gesture Filtering

    /// Determines whether a map gesture should be allowed for the given touch.
    ///
    /// This method walks up the view hierarchy from the touch location to determine if the gesture
    /// should be recognized. Map gestures are allowed when:
    /// - The touch is directly on the map view, OR
    /// - The touch is on a view that conforms to `AllowsMapGestures` (e.g., `ViewAnnotationsContainer`)
    ///
    /// Map gestures are blocked when:
    /// - The touch is on UI controls/ornaments (compass, scale bar, indoor selector, etc.)
    /// - The touch is outside the map view hierarchy
    ///
    /// - Parameter touch: The touch to evaluate
    /// - Returns: `true` if the map gesture should be recognized, `false` otherwise
    func shouldAllowMapGesture(for touch: UITouch) -> Bool {
        guard let gestureView = view, let touchView = touch.view else {
            return false
        }

        // Allow touches directly on the map view itself
        if touchView === gestureView {
            return true
        }

        // Walk up the view hierarchy to find a view that allows map gestures
        // Stop before reaching the gesture view (to block direct children like ornaments)
        var currentView: UIView? = touchView
        while let view = currentView, view !== gestureView {
            if view is AllowsMapGestures {
                return true
            }
            currentView = view.superview
        }

        // Touch is on a direct child (ornament) or outside hierarchy - reject
        return false
    }
}
