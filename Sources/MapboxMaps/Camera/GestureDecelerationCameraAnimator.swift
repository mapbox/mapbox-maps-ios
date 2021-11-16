import UIKit

internal final class GestureDecelerationCameraAnimator: NSObject, CameraAnimatorInterface {

    private let location: CGPoint
    private var velocity: CGPoint
    private let decelerationFactor: CGFloat
    private let locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
    private var previousDate: Date?
    private let dateProvider: DateProvider
    private weak var delegate: CameraAnimatorDelegate?
    internal var completion: (() -> Void)?

    internal init(location: CGPoint,
                  velocity: CGPoint,
                  decelerationFactor: CGFloat,
                  locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                  dateProvider: DateProvider,
                  delegate: CameraAnimatorDelegate) {
        self.location = location
        self.velocity = velocity
        self.decelerationFactor = decelerationFactor
        self.locationChangeHandler = locationChangeHandler
        self.dateProvider = dateProvider
        self.delegate = delegate
    }

    internal private(set) var state: UIViewAnimatingState = .inactive

    internal func cancel() {
        stopAnimation()
    }

    internal func startAnimation() {
        previousDate = dateProvider.now
        state = .active
        delegate?.cameraAnimatorDidStartRunning(self)
    }

    internal func stopAnimation() {
        state = .inactive
        delegate?.cameraAnimatorDidStopRunning(self)
        completion?()
        completion = nil
    }

    internal func update() {
        guard state == .active, let previousDate = previousDate else {
            return
        }

        let currentDate = dateProvider.now
        self.previousDate = currentDate

        let elapsedTime = CGFloat(currentDate.timeIntervalSince(previousDate))

        // This is part of a workaround for pan deceleration near the horizon.
        // Instead of allowing the touch location to travel farther and farther
        // away from the initial location, emit a series of increasingly smaller
        // displacements always relative to the initial location.
        var toLocation = location

        // calculate new location showing how far we have traveled
        toLocation.x += velocity.x * elapsedTime
        toLocation.y += velocity.y * elapsedTime

        locationChangeHandler(location, toLocation)

        // deceleration factor should be applied to the velocity once per millisecond
        velocity.x *= pow(decelerationFactor, (elapsedTime * 1000))
        velocity.y *= pow(decelerationFactor, (elapsedTime * 1000))

        guard abs(velocity.x) >= 1 || abs(velocity.y) >= 1 else {
            stopAnimation()
            return
        }
    }
}
