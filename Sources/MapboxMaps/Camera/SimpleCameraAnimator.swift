@_implementationOnly import MapboxCommon_Private
import UIKit

internal protocol SimpleCameraAnimatorProtocol: CameraAnimatorProtocol {
    var to: CameraOptions { get set }
    func startAnimation(afterDelay delay: TimeInterval)
}

/// A camera animator that offers cubic bezier easing, delayed start, and a dynamically-updatable target
/// camera.
///
/// This animator has some overlap in functionality with ``BasicCameraAnimator``; however, since it
/// uses direct interpolation rather than interpolation via ``CameraView``, it has a simpler implementation
/// and enables more advanced use cases like dynamically updating ``SimpleCameraAnimator/to``.
internal final class SimpleCameraAnimator: SimpleCameraAnimatorProtocol {
    private enum InternalState: Equatable {
        case initial
        case running(startDate: Date)
        case final(UIViewAnimatingPosition)
    }

    /// The animator's owner
    internal let owner: AnimationOwner

    /// Type of the embeded animation
    internal let animationType: AnimationType

    private let from: CameraOptions

    /// The target camera.
    ///
    /// This property can be updated dynamically while the animation is running, but it should
    /// generally maintain the same set of non-nil fields since nil fields will not be updated during the
    /// animation. For best results, the difference between old and new `to` should be small relative
    /// to the difference between `from` and `to`.
    internal var to: CameraOptions {
        didSet {
            func hasNilMismatch<T>(for keyPath: KeyPath<CameraOptions, T?>) -> Bool {
                return (oldValue[keyPath: keyPath] == nil) != (to[keyPath: keyPath] == nil)
            }
            if hasNilMismatch(for: \.center) ||
                hasNilMismatch(for: \.zoom) ||
                hasNilMismatch(for: \.padding) ||
                hasNilMismatch(for: \.anchor) ||
                hasNilMismatch(for: \.bearing) ||
                hasNilMismatch(for: \.pitch) {
                Log.warning("Animator updated with differing non-nil to-value properties.", category: "maps-ios")
            }
        }
    }

    private let duration: TimeInterval
    private let unitBezier: UnitBezier
    private let mapboxMap: MapboxMapProtocol
    private let mainQueue: MainQueueProtocol
    private let cameraOptionsInterpolator: CameraOptionsInterpolatorProtocol
    private let dateProvider: DateProvider

    private var completionHandlers = [AnimationCompletion]()

    private let cameraAnimatorStatusSignal = SignalSubject<CameraAnimatorStatus>()
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus> { cameraAnimatorStatusSignal.signal }

    /// The state of the animation. While the animation is running, the value is `.active`. Otherwise, the
    /// value is `.inactive`.
    internal var state: UIViewAnimatingState {
        switch internalState {
        case .running:
            return .active
        case .initial, .final:
            return .inactive
        }
    }

    private var internalState = InternalState.initial {
        didSet {
            switch (oldValue, internalState) {
            case (.initial, .running):
                cameraAnimatorStatusSignal.send(.started)
            case (.running, .final(let position)):
                let isCancelled = position != .end
                cameraAnimatorStatusSignal.send(.stopped(reason: isCancelled ? .cancelled : .finished))
            default:
                // this matches cases where…
                // * oldValue and internalState are the same
                // * initial transitions to final
                // * the transition is invalid…
                //     * running/final --> initial
                //     * final --> running
                break
            }
        }
    }

    /// Initializes a new ``SimpleCameraAnimator``.
    /// - Parameters:
    ///   - from: The initial camera.
    ///   - to: The target camera.
    ///   - duration: How long the animation should take.
    ///   - curve: Allows applying easing effects.
    ///   - mapboxMap: The map whose camera should be updated.
    ///   - mainQueue: The app's main queue.
    ///   - cameraOptionsInterpolator: An object that calculates interpolated camera values.
    ///   - dateProvider: An object that provides the current date.
    ///   - delegate: A delegate to inform when the animation starts or stops running.
    internal init(from: CameraOptions,
                  to: CameraOptions,
                  duration: TimeInterval,
                  curve: TimingCurve,
                  owner: AnimationOwner,
                  type: AnimationType = .unspecified,
                  mapboxMap: MapboxMapProtocol,
                  mainQueue: MainQueueProtocol,
                  cameraOptionsInterpolator: CameraOptionsInterpolatorProtocol,
                  dateProvider: DateProvider) {
        self.from = from
        self.to = to
        self.duration = duration
        self.unitBezier = UnitBezier(p1: curve.p1, p2: curve.p2)
        self.owner = owner
        self.animationType = type
        self.mapboxMap = mapboxMap
        self.mainQueue = mainQueue
        self.cameraOptionsInterpolator = cameraOptionsInterpolator
        self.dateProvider = dateProvider
    }

    internal func startAnimation() {
        startAnimation(afterDelay: 0)
    }

    /// Starts the animation.
    ///
    /// This method sets ``BasicCameraAnimator/state`` to `.active` immediately regardless
    /// of `delay`. It also call the delegate to indicate that it has started running. Does nothing if `state`
    /// is not `.inactive`.
    /// - Parameter delay: An amount of time to wait before beginning to update the map's camera.
    internal func startAnimation(afterDelay delay: TimeInterval) {
        switch internalState {
        case .initial:
            internalState = .running(startDate: dateProvider.now + delay)
        case .running:
            // already running; do nothing
            break
        case .final:
            // animators cannot be restarted
            break
        }
    }

    /// Cancels the animation.
    ///
    /// This method sets ``BasicCameraAnimator/state`` to `.inactive`, informs the delegate
    /// that the animation has stopped running, and clears and invokes
    /// ``SimpleCameraAnimator/completion``. Does nothing if `state` is not `.active`.
    internal func cancel() {
        switch internalState {
        case .initial, .running:
            internalState = .final(.current)
            invokeCompletionBlocks(with: .current) // `current` represents an interrupted animation.
        case .final:
            // Already stopped, so do nothing
            break
        }
    }

    /// An alias for ``SimpleCameraAnimator/cancel()``.
    internal func stopAnimation() {
        cancel()
    }

    /// Adds completion to the list of completion handlers to be invoked when the animation completes or is
    /// canceled. If the animation has already completed or been canceled, this method invokes the
    /// completion handler asynchronously with the same `UIViewAnimatingPosition` value.
    /// The animator only holds a strong reference to the handler until it finishes or is canceled.
    /// - Parameter completion: A handler to invoke when the animator completes.
    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        switch internalState {
        case .initial, .running:
            completionHandlers.append(completion)
        case .final(let position):
            mainQueue.async {
                completion(position)
            }
        }
    }

    private func invokeCompletionBlocks(with position: UIViewAnimatingPosition) {
        for completionHandler in completionHandlers {
            completionHandler(position)
        }
        completionHandlers.removeAll()
    }

    /// Updates the map camera.
    ///
    /// For running animations, this method calculates the elapsed time since
    /// ``SimpleCameraAnimator/startAnimation(afterDelay:)`` was invoked plus any
    /// delay, and, if that value is non-negative, applies the timing function to get a fraction complete,
    /// computes an interpolated camera given that fraction, ``SimpleCameraAnimator/from``, and
    /// ``SimpleCameraAnimator/to``, and sets the camera on the map.
    ///
    /// If the fraction complete is greater than or equal to 1, it sets the camera one final time to `to`,
    /// sets ``SimpleCameraAnimator/state`` to `.inactive`, informs the delegate that it
    /// has stopped running, and clears and invokes ``SimpleCameraAnimator/completion``.
    internal func update() {
        guard case .running(let startDate) = internalState else {
            return
        }
        let elapsedTime = dateProvider.now.timeIntervalSince(startDate)
        guard elapsedTime >= 0 else {
            return
        }
        let fractionComplete = unitBezier.solve(min(elapsedTime / duration, 1), 1e-6)
        guard fractionComplete < 1 else {
            mapboxMap.setCamera(to: to)
            internalState = .final(.end)
            invokeCompletionBlocks(with: .end)
            return
        }
        let camera = cameraOptionsInterpolator.interpolate(
            from: from,
            to: to,
            fraction: fractionComplete)
        mapboxMap.setCamera(to: camera)
    }
}
