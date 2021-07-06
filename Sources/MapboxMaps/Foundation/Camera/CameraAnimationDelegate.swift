import UIKit

// MARK: Typealias
public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate: AnyObject {

    /// The current camera of the map
    var camera: CameraState { get }

    /// Adds the view to the MapView's subviews
    func addViewToViewHeirarchy(_ view: CameraView)

    /// Calculates the anchor after taking padding into consideration
    func anchorAfterPadding() -> CGPoint
}
