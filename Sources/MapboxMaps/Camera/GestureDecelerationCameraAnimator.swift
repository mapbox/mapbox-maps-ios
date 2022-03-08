import UIKit

internal final class GestureDecelerationCameraAnimator: NSObject, CameraAnimatorProtocol {

    private let location: CGPoint
    private var velocity: CGPoint
    private let decelerationFactor: CGFloat
    private let locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
    private var previousDate: Date?
    private let dateProvider: DateProvider
    internal let owner: AnimationOwner
    internal weak var delegate: CameraAnimatorDelegate?
    private var completionBlocks = [AnimationCompletion]()

    internal init(location: CGPoint,
                  velocity: CGPoint,
                  decelerationFactor: CGFloat,
                  owner: AnimationOwner,
                  locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                  dateProvider: DateProvider) {
        self.location = location
        self.velocity = velocity
        self.decelerationFactor = decelerationFactor
        self.owner = owner
        self.locationChangeHandler = locationChangeHandler
        self.dateProvider = dateProvider
    }

    internal private(set) var state: UIViewAnimatingState = .inactive

    internal func cancel() {
        stopAnimation()
    }

    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        completionBlocks.append(completion)
    }

    private func invokeCompletionBlocks(with position: UIViewAnimatingPosition) {
        let blocks = completionBlocks
        for block in blocks {
            block(position)
        }
        completionBlocks.removeAll()
    }

    internal func startAnimation() {
        previousDate = dateProvider.now
        state = .active
        delegate?.cameraAnimatorDidStartRunning(self)
    }

    internal func stopAnimation() {
        state = .inactive
        delegate?.cameraAnimatorDidStopRunning(self)
        invokeCompletionBlocks(with: .current)
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

        if abs(velocity.x) < 20, abs(velocity.y) < 20 {
            state = .inactive
            delegate?.cameraAnimatorDidStopRunning(self)
            invokeCompletionBlocks(with: .end)
        }
    }
}
