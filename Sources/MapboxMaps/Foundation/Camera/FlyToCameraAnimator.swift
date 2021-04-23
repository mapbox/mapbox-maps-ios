import UIKit

public class FlyToCameraAnimator: NSObject, CameraAnimator, CameraAnimatorInterface {

    internal private(set) weak var delegate: CameraAnimatorDelegate?

    public private(set) var owner: AnimationOwner

    internal private(set) var flyToInterpolator: FlyToInterpolator?

    internal private(set) var animationDuration: TimeInterval?

    public private(set) var state: UIViewAnimatingState = .inactive

    internal private(set) var startTime: Date?

    internal private(set) var endTime: Date?

    internal private(set) var finalCameraOptions: CameraOptions?

    internal private(set) var animationCompletion: AnimationCompletion?

    internal init(delegate: CameraAnimatorDelegate,
                  owner: AnimationOwner = .custom(id: "fly-to")) {

        self.delegate = delegate
        self.owner = owner
    }

    deinit {
        scheduleCompletionIfNecessary(position: .current)
    }

    internal func makeFlyToInterpolator(from initalCamera: CameraOptions, to finalCamera: CameraOptions, duration: TimeInterval? = nil, screenFullSize: CGSize) {

        guard let flyTo = FlyToInterpolator(from: initalCamera,
                                                        to: finalCamera,
                                                        size: screenFullSize) else {
            assertionFailure("FlyToInterpolator could not be created.")
            return
        }

        var time = duration ?? -1.0

        // If there was no duration specified, or a negative argument, use a default
        if time < 0.0 {
            time = flyTo.duration()
        }

        animationDuration = time
        flyToInterpolator = flyTo
        finalCameraOptions = finalCamera
    }

    public func stopAnimation() {
        state = .stopped
        flyToInterpolator = nil
        scheduleCompletionIfNecessary(position: .current) // `current` represents an interrupted animation.
    }

    internal func startAnimation() {

        guard flyToInterpolator != nil, let animationDuration = animationDuration else {
            fatalError("FlyToInterpolator not created")
        }

        state = .active
        startTime = Date()
        endTime = startTime?.addingTimeInterval(animationDuration)
    }

    internal func addCompletion(_ completion: AnimationCompletion?) {
        animationCompletion = completion
    }

    internal func scheduleCompletionIfNecessary(position: UIViewAnimatingPosition) {
        if let delegate = delegate, let validAnimationCompletion = animationCompletion {
            delegate.schedulePendingCompletion(forAnimator: self,
                                                completion: validAnimationCompletion,
                                                animatingPosition: position)

            // Once a completion has been scheduled, `nil` it out so it can't be executed again.
            animationCompletion = nil
        }

    }

    internal func update() {

        guard state == .active,
              let startTime = startTime,
              let endTime = endTime,
              let animationDuration = animationDuration,
              let flyTo = flyToInterpolator else {
            return
        }

        let currentTime = Date()

        guard currentTime <= endTime else {
            flyToInterpolator = nil
            state = .stopped
            self.scheduleCompletionIfNecessary(position: .end)
            return
        }

        let fractionComplete = currentTime.timeIntervalSince(startTime) / animationDuration

        let cameraOptions = CameraOptions(center: flyTo.coordinate(at: fractionComplete),
                                          zoom: CGFloat(flyTo.zoom(at: fractionComplete)),
                                          bearing: flyTo.bearing(at: fractionComplete),
                                          pitch: CGFloat(flyTo.pitch(at: fractionComplete)))

        delegate?.jumpTo(camera: cameraOptions)

    }
}
