import UIKit

/// An animator that evokes powered flight and an optional transition duration and timing function.
/// It seamlessly incorporates zooming and panning to help the user find their bearings even after
/// traversing a great distance.
///
/// - SeeAlso: ``CameraAnimationsManager/fly(to:duration:completion:)``
public final class FlyToCameraAnimator: NSObject, CameraAnimator, CameraAnimatorProtocol {
    private enum InternalState: Equatable {
        case initial
        case running(startDate: Date)
        case final(UIViewAnimatingPosition)
    }

    private let mapboxMap: MapboxMapProtocol

    private let mainQueue: MainQueueProtocol

    /// The animator's owner
    public let owner: AnimationOwner

    /// Type of the embeded animation
    internal let animationType: AnimationType

    /// The animator's duration
    public let duration: TimeInterval

    /// The animator's state
    public var state: UIViewAnimatingState {
        switch internalState {
        case .running:
            return .active
        case .initial, .final:
            return .inactive
        }
    }

    internal weak var delegate: CameraAnimatorDelegate?

    private let interpolator: FlyToInterpolator

    private let finalCameraOptions: CameraOptions

    private let dateProvider: DateProvider

    private var completionBlocks = [AnimationCompletion]()

    private var internalState = InternalState.initial {
        didSet {
            switch (oldValue, internalState) {
            case (.initial, .running):
                delegate?.cameraAnimatorDidStartRunning(self)
            case (.running, .final):
                delegate?.cameraAnimatorDidStopRunning(self)
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

    internal init(toCamera: CameraOptions,
                  owner: AnimationOwner,
                  type: AnimationType = .unspecified,
                  duration: TimeInterval? = nil,
                  mapboxMap: MapboxMapProtocol,
                  mainQueue: MainQueueProtocol,
                  dateProvider: DateProvider) {
        let flyToInterpolator = FlyToInterpolator(
            from: mapboxMap.cameraState,
            to: toCamera,
            cameraBounds: mapboxMap.cameraBounds,
            size: mapboxMap.size)
        if let duration = duration {
            precondition(duration >= 0)
        }
        self.interpolator = flyToInterpolator
        self.mapboxMap = mapboxMap
        self.mainQueue = mainQueue
        self.owner = owner
        self.animationType = type
        self.finalCameraOptions = toCamera
        self.duration = duration ?? flyToInterpolator.duration()
        self.dateProvider = dateProvider
    }

    internal func startAnimation() {
        switch internalState {
        case .initial:
            internalState = .running(startDate: dateProvider.now)
        case .running:
            // already running; do nothing
            break
        case .final:
            // animators cannot be restarted
            break
        }
    }

    public func stopAnimation() {
        switch internalState {
        case .initial, .running:
            internalState = .final(.current)
            invokeCompletionBlocks(with: .current) // `current` represents an interrupted animation.
        case .final:
            // Already stopped, so do nothing
            break
        }
    }

    public func cancel() {
        stopAnimation()
    }

    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        switch internalState {
        case .initial, .running:
            completionBlocks.append(completion)
        case .final(let position):
            mainQueue.async {
                completion(position)
            }
        }
    }

    private func invokeCompletionBlocks(with position: UIViewAnimatingPosition) {
        let blocks = completionBlocks
        for block in blocks {
            block(position)
        }
        completionBlocks.removeAll()
    }

    internal func update() {
        guard case .running(let startDate) = internalState else {
            return
        }
        let fractionComplete = min(dateProvider.now.timeIntervalSince(startDate) / duration, 1)
        guard fractionComplete < 1 else {
            internalState = .final(.end)
            mapboxMap.setCamera(to: finalCameraOptions)
            invokeCompletionBlocks(with: .end)
            return
        }
        mapboxMap.setCamera(to: CameraOptions(
            center: interpolator.coordinate(at: fractionComplete),
            padding: interpolator.padding(at: fractionComplete),
            zoom: CGFloat(interpolator.zoom(at: fractionComplete)),
            bearing: interpolator.bearing(at: fractionComplete),
            pitch: CGFloat(interpolator.pitch(at: fractionComplete))))
    }
}
