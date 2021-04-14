import UIKit

// MARK: CameraAnimator Class
public class CameraAnimator: NSObject {

    // MARK: Stored Properties

    /// Instance of the property animator that will run animations.
    private var propertyAnimator: UIViewPropertyAnimator

    /// Delegate that conforms to `CameraAnimatorDelegate`.
    private weak var delegate: CameraAnimatorDelegate?

    /// The ID of the owner of this `CameraAnimator`.
    internal var owner: AnimationOwner
    
    /// The `CameraView` owned by this animator
    internal var cameraView: CameraView

    // MARK: Computed Properties

    /// The state from of the animator.
    public var state: UIViewAnimatingState { return propertyAnimator.state }

    /// Boolean that represents if the animation is running or not.
    public var isRunning: Bool { return propertyAnimator.isRunning }

    /// Boolean that represents if the animation is running normally or in reverse.
    public var isReversed: Bool { return propertyAnimator.isReversed }

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    public var pausesOnCompletion: Bool {
        get { return propertyAnimator.pausesOnCompletion}
        set { propertyAnimator.pausesOnCompletion = newValue }
    }

    /// Value that represents what percentage of the animation has been completed.
    public var fractionComplete: Double {
        get { return Double(propertyAnimator.fractionComplete) }
        set { propertyAnimator.fractionComplete = CGFloat(newValue) }
    }

    // MARK: Initializer
    internal init(delegate: CameraAnimatorDelegate,
                  propertyAnimator: UIViewPropertyAnimator,
                  owner: AnimationOwner) {
        self.delegate = delegate
        self.propertyAnimator = propertyAnimator
        self.owner = owner
        
        // Set up the short lived camera view
        cameraView = CameraView()
        delegate.addToViewHeirarchy(view: cameraView)
    }

    deinit {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
        cameraView.removeFromSuperview()
    }

    // MARK: Functions

    /// Starts the animation.
    public func startAnimation() {
        
        guard let renderedCamera = delegate?.camera else {
            fatalError("Rendered camera options cannot be nil when starting an animation")
        }
        
        cameraView.syncFromValuesWithRenderer(renderedCameraOptions: renderedCamera)
        propertyAnimator.startAnimation()
    }

    /// Pauses the animation.
    public func pauseAnimation() {
        propertyAnimator.pauseAnimation()
    }

    /// Stops the animation.
    public func stopAnimation() {
        propertyAnimator.stopAnimation(false)
        propertyAnimator.finishAnimation(at: .current)
    }

    /// Add animations block to the animator with a `delayFactor`.
    public func addAnimations(_ animations: @escaping (inout CameraOptions) -> Void, delayFactor: Double) {
        guard let delegate = delegate else {  return }
        var cameraOptions = delegate.camera
        
        propertyAnimator.addAnimations({ [weak self] in
            guard let self = self else { return }
            animations(&cameraOptions) // The animation block will provide the "to" values
            self.cameraView.animate(to: cameraOptions)
        }, delayFactor: CGFloat(delayFactor))
    }

    /// Add animations block to the animator.
    public func addAnimations(_ animations: @escaping (inout CameraOptions) -> Void) {
        guard let delegate = delegate else {  return }
        var cameraOptions = delegate.camera
        
        propertyAnimator.addAnimations { [weak self] in
            guard let self = self else { return }
            animations(&cameraOptions) // The animation block will provide the "to" values
            self.cameraView.animate(to: cameraOptions)
            
        }
    }

    /// Add a completion block to the animator. 
    public func addCompletion(_ completion: @escaping AnimationCompletion) {
        propertyAnimator.addCompletion({ [weak self] animatingPosition in
            guard let self = self else { return }
            self.delegate?.schedulePendingCompletion(forAnimator: self, completion: completion, animatingPosition: animatingPosition)
        })
    }

    /// Continue the animation with a timing parameter (`UITimingCurveProvider`) and duration factor (`CGFloat`).
    public func continueAnimation(withTimingParameters parameters: UITimingCurveProvider?, durationFactor: Double) {
        propertyAnimator.continueAnimation(withTimingParameters: parameters, durationFactor: CGFloat(durationFactor))
    }
    
    // Cache of camera options that the last `jumpTo` was called with.
    internal var cachedDiffedCamera: CameraOptions?
    
    
    internal func update() {

        // Retrieve currently rendered camera
        guard propertyAnimator.state == .active, let currentCamera = delegate?.camera else {
            return
        }

        // Get the latest interpolated values of the camera properties (if they exist)
        let targetCamera = cameraView.localCamera.wrap()

        // Apply targetCamera options only if they are different from currentCamera options
        if currentCamera != targetCamera {

            // Diff the targetCamera with the currentCamera and apply diffed camera properties to map
            let diffedCamera = CameraOptions()

            if targetCamera.zoom != currentCamera.zoom, let targetZoom = targetCamera.zoom, !targetZoom.isNaN {
                diffedCamera.zoom = targetCamera.zoom
            }

            if targetCamera.bearing != currentCamera.bearing, let targetBearing = targetCamera.bearing, !targetBearing.isNaN {
                diffedCamera.bearing = targetCamera.bearing
            }

            if targetCamera.pitch != currentCamera.pitch, let targetPitch = targetCamera.pitch, !targetPitch.isNaN {
                diffedCamera.pitch = targetCamera.pitch
            }

            if targetCamera.center != currentCamera.center, let targetCenter = targetCamera.center, !targetCenter.latitude.isNaN, !targetCenter.longitude.isNaN {
                diffedCamera.center = targetCamera.center
            }

            if targetCamera.anchor != currentCamera.anchor {
                diffedCamera.anchor = targetCamera.anchor
            }

            if targetCamera.padding != currentCamera.padding {
                diffedCamera.padding = targetCamera.padding
            }

//            if let cachedDiffedCamera = cachedDiffedCamera, diffedCamera == cachedDiffedCamera {
//                // Return early if we previously set the same value of diffed camera
//                // The camera is "idling".
//                return
//            }

            delegate?.jumpTo(camera: diffedCamera)
//            cachedDiffedCamera = diffedCamera
        }
    }
}


fileprivate extension CameraOptions {

    func wrap() -> CameraOptions {
        return CameraOptions(center: self.center?.wrap(),
                             padding: self.padding,
                             anchor: self.anchor,
                             zoom: self.zoom,
                             bearing: self.bearing,
                             pitch: self.pitch)

    }
}

