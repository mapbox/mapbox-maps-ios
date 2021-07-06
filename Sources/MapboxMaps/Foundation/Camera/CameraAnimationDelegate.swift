import UIKit

// MARK: Typealias
public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void

// MARK: CameraAnimatorDelegate Protocol
internal protocol CameraAnimatorDelegate: AnyObject {

    /// Adds the view to the MapView's subviews
    func addViewToViewHeirarchy(_ view: CameraView)
}
