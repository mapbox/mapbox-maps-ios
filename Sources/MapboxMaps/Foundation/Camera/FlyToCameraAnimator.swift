import UIKit

public class FlyToCameraAnimator: NSObject, CameraAnimator, CameraAnimatorInterface {

    internal private(set) weak var delegate: CameraAnimatorDelegate?

    public private(set) var owner: AnimationOwner

    private let interpolator: FlyToInterpolator

    public let duration: TimeInterval

    public private(set) var state: UIViewAnimatingState = .inactive

    private var start: Date?

    private let finalCameraOptions: CameraOptions

    private var completionBlocks = [AnimationCompletion]()

    private let dateProvider: DateProvider

    internal init?(initial: CameraState,
                   final: CameraOptions,
                   cameraBounds: CameraBounds,
                   owner: AnimationOwner,
                   duration: TimeInterval? = nil,
                   mapSize: CGSize,
                   delegate: CameraAnimatorDelegate,
                   dateProvider: DateProvider = DefaultDateProvider()) {
        guard let flyToInterpolator = FlyToInterpolator(from: initial, to: final, cameraBounds: cameraBounds, size: mapSize) else {
            return nil
        }
        if let duration = duration {
            guard duration >= 0 else {
                return nil
            }
        }
        self.interpolator = flyToInterpolator
        self.delegate = delegate
        self.owner = owner
        self.finalCameraOptions = final
        self.duration = duration ?? flyToInterpolator.duration()
        self.dateProvider = dateProvider
    }

    public func stopAnimation() {
        state = .stopped
        scheduleCompletionIfNecessary(position: .current) // `current` represents an interrupted animation.
    }

    internal func startAnimation() {
        state = .active
        start = dateProvider.now
    }

    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        completionBlocks.append(completion)
    }

    private func scheduleCompletionIfNecessary(position: UIViewAnimatingPosition) {
        for completion in completionBlocks {
            delegate?.schedulePendingCompletion(
                forAnimator: self,
                completion: completion,
                animatingPosition: position)
        }
        completionBlocks.removeAll()
    }

    internal var currentCameraOptions: CameraOptions? {
        guard state == .active, let start = start else {
            return nil
        }
        let fractionComplete = min(dateProvider.now.timeIntervalSince(start) / duration, 1)
        guard fractionComplete < 1 else {
            state = .stopped
            scheduleCompletionIfNecessary(position: .end)
            return finalCameraOptions
        }
        return CameraOptions(
            center: interpolator.coordinate(at: fractionComplete),
            zoom: CGFloat(interpolator.zoom(at: fractionComplete)),
            bearing: interpolator.bearing(at: fractionComplete),
            pitch: CGFloat(interpolator.pitch(at: fractionComplete)))
    }

    // MARK: Cancelable

    public func cancel() {
        stopAnimation()
    }
}
