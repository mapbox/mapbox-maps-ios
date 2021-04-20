import UIKit

internal class FlyToAnimator: NSObject, CameraAnimatorProtocol {

    internal weak var delegate: CameraAnimatorDelegate?

    internal var owner: AnimationOwner

    internal var flyToInterpolator: FlyToInterpolator?

    internal var animationDuration: TimeInterval?

    internal private(set) var state: UIViewAnimatingState = .inactive

    internal var startTime: Date?

    internal var endTime: Date?

    internal var finalCameraOptions: CameraOptions?

    internal var animationCompletion: AnimationCompletion?

    internal init(delegate: CameraAnimatorDelegate,
                  owner: AnimationOwner = .custom(id: "fly-to")) {

        self.delegate = delegate
        self.owner = owner
    }

    deinit {
        flyToInterpolator = nil
        stopAnimation()
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

    func stopAnimation() {
        state = .stopped
        flyToInterpolator = nil
        scheduleCompletionIfNecessary(position: .current) // `current` represents an interrupted animation.
    }

    func startAnimation() {

        guard flyToInterpolator != nil, let animationDuration = animationDuration else {
            fatalError("FlyToInterpolator not created")
        }

        state = .active
        startTime = Date()
        endTime = startTime?.addingTimeInterval(animationDuration)
    }

    func addCompletion(_ completion: AnimationCompletion?) {
        animationCompletion = completion
    }

    func scheduleCompletionIfNecessary(position: UIViewAnimatingPosition) {
        if let delegate = delegate, let animationCompletion = animationCompletion {
            delegate.schedulePendingCompletion(forAnimator: self,
                                                completion: animationCompletion,
                                                animatingPosition: position)
        }
    }

    func update() {

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
