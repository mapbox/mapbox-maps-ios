import UIKit

internal final class GestureDecelerationCameraAnimator: NSObject, CameraAnimatorInterface {

    private var location: CGPoint
    private var velocity: CGPoint
    private let decelerationRate: CGFloat
    private let locationChangeHandler: (CGPoint) -> Void
    private var previousDate: Date?
    private let dateProvider: DateProvider
    internal var completion: (() -> Void)?

    internal init(location: CGPoint,
                  velocity: CGPoint,
                  decelerationRate: CGFloat,
                  locationChangeHandler: @escaping (CGPoint) -> Void,
                  dateProvider: DateProvider) {
        self.location = location
        self.velocity = velocity
        self.decelerationRate = decelerationRate
        self.locationChangeHandler = locationChangeHandler
        self.dateProvider = dateProvider
    }

    internal private(set) var state: UIViewAnimatingState = .inactive

    internal func cancel() {
        stopAnimation()
    }

    internal func startAnimation() {
        previousDate = dateProvider.now
        state = .active
    }

    internal func stopAnimation() {
        state = .inactive
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

        // calculate new location showing how far we have traveled
        location.x += velocity.x * elapsedTime
        location.y += velocity.y * elapsedTime

        locationChangeHandler(location)

        // deceleration rate is a factor that should
        // be applied to the velocity once per millisecond
        velocity.x *= pow(decelerationRate, (elapsedTime * 1000))
        velocity.y *= pow(decelerationRate, (elapsedTime * 1000))

        guard abs(velocity.x) >= 1 || abs(velocity.y) >= 1 else {
            stopAnimation()
            return
        }
    }
}
