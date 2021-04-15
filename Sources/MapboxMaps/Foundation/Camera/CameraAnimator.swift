import UIKit
import CoreLocation

// Represents a change in a camera property due to an animation
internal enum AnimatingCameraChanges: Hashable {
    
    case center(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)
    
    case bearing(start: Double, end: Double)
    
    case pitch(start: CGFloat, end: CGFloat)
    
    case anchor(end: CGPoint)
    
    case padding(start: UIEdgeInsets, end: UIEdgeInsets)
    
    case zoom(start: CGFloat, end: CGFloat)
    
    internal static func diffChangesToCameraOptions(from renderedCameraOptions: CameraOptions,
                                             to animatedCameraOptions: CameraOptions) -> Set<AnimatingCameraChanges> {
        
        var changes = Set<AnimatingCameraChanges>()
        
        if let startCenter = renderedCameraOptions.center,
           let endCenter = animatedCameraOptions.center,
           startCenter != endCenter {
            changes.insert(.center(start: startCenter, end: endCenter))
        }
        
        if let startBearing = renderedCameraOptions.bearing,
           let endBearing = animatedCameraOptions.bearing,
           startBearing != endBearing {
            changes.insert(.bearing(start: startBearing, end: endBearing))
        }
        
        if let startPitch = renderedCameraOptions.pitch,
           let endPitch = animatedCameraOptions.pitch,
           startPitch != endPitch {
            changes.insert(.pitch(start: startPitch, end: endPitch))
        }
        
        if let endAnchor = animatedCameraOptions.anchor { // Special case for anchor???
            changes.insert(.anchor(end: endAnchor))
        }
        
        if let startPadding = renderedCameraOptions.padding,
           let endPadding = animatedCameraOptions.padding,
           startPadding != endPadding {
            changes.insert(.padding(start: startPadding, end: endPadding))
        }
        
        if let startZoom = renderedCameraOptions.zoom,
           let endZoom = animatedCameraOptions.zoom,
           startZoom != endZoom {
            changes.insert(.zoom(start: startZoom, end: endZoom))
        }
        
        return changes
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .center(start: let start, end: let end):
            hasher.combine("center")
            hasher.combine(start)
            hasher.combine(end)
        case .anchor(end: let endAnchor):
            hasher.combine("anchor")
            hasher.combine(endAnchor)
        case .bearing(start: let start, end: let end):
            hasher.combine("bearing")
            hasher.combine(start)
            hasher.combine(end)
        case .zoom(start: let start, end: let end):
            hasher.combine("zoom")
            hasher.combine(start)
            hasher.combine(end)
        case .pitch(start: let start, end: let end):
            hasher.combine("pitch")
            hasher.combine(start)
            hasher.combine(end)
        case .padding(start: let start, end: let end):
            hasher.combine("padding")
            hasher.combine(start)
            hasher.combine(end)
        }
    }
    
    
}

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
    
    /// The set of properties being animated by this renderer
    internal var animatingChanges: Set<AnimatingCameraChanges>?

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
    
    public func startAnimation(afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.startAnimation()
        }
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
        let wrappedAnimations = wrapAnimationsBlock(animations)
        propertyAnimator.addAnimations(wrappedAnimations,
                                       delayFactor: CGFloat(delayFactor))
    }

    /// Add animations block to the animator.
    public func addAnimations(_ animations: @escaping (inout CameraOptions) -> Void) {
        let wrappedAnimations = wrapAnimationsBlock(animations)
        propertyAnimator.addAnimations(wrappedAnimations)
    }
    
    internal func wrapAnimationsBlock(_ userProvidedAnimation: @escaping (inout CameraOptions) -> Void) -> () -> Void {
        
        guard let delegate = delegate else {
            fatalError("Delegate MUST not be nil when adding animations")
        }
        
        let renderedCameraOptions = delegate.camera
        
        return { [weak self] in
            guard let self = self else { return }
            
            var cameraOptions = renderedCameraOptions
            userProvidedAnimation(&cameraOptions) // The `userProvidedAnimation` block will mutate the "rendered" camera options and provide the "to" values of the animation
            
            self.animatingChanges = AnimatingCameraChanges.diffChangesToCameraOptions(from: renderedCameraOptions,
                                                                    to: cameraOptions)
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
    
    internal func update() {

        // Only call jumpTo if this animator is currently "active"
        guard propertyAnimator.state == .active else { return }

        // Get the latest interpolated values of the camera properties and set them on the map
        delegate?.jumpTo(camera: cameraView.localCamera.clampCenter())
    }
}


fileprivate extension CameraOptions {

    func clampCenter() -> CameraOptions {
        return CameraOptions(center: self.center?.wrap(),
                             padding: self.padding,
                             anchor: self.anchor,
                             zoom: self.zoom,
                             bearing: self.bearing,
                             pitch: self.pitch)

    }
}

