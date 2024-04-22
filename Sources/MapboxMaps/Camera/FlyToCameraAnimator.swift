import UIKit

/// An animator that evokes powered flight and an optional transition duration and timing function.
/// It seamlessly incorporates zooming and panning to help the user find their bearings even after
/// traversing a great distance.
///
/// - SeeAlso: ``CameraAnimationsManager/fly(to:duration:curve:completion:)``
public final class FlyToCameraAnimator: CameraAnimator, CameraAnimatorProtocol {
    private enum InternalState: Equatable {
        case initial
        case running(startDate: Date)
        case final(UIViewAnimatingPosition)
    }

    /// The animator's owner
    public let owner: AnimationOwner

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

    let animationType: AnimationType

    private let mapboxMap: MapboxMapProtocol
    private let mainQueue: MainQueueProtocol
    private let interpolator: FlyToInterpolator
    private let finalCameraOptions: CameraOptions
    private let dateProvider: DateProvider
    private let unitBezier: UnitBezier
    private var completionBlocks = [AnimationCompletion]()

    private let cameraAnimatorStatusSignal = SignalSubject<CameraAnimatorStatus>()
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus> { cameraAnimatorStatusSignal.signal }

    /// Emits a signal when this animator has started.
    public var onStarted: Signal<Void> {
        onCameraAnimatorStatusChanged
            .filter { $0 == .started }
            .map { _ in }
    }

    /// Emits a signal when this animator has finished.
    public var onFinished: Signal<Void> {
        onCameraAnimatorStatusChanged
            .filter { $0 == .stopped(reason: .finished) }
            .map { _ in }
    }

    /// Emits a signal when this animator is cancelled.
    public var onCancelled: Signal<Void> {
        onCameraAnimatorStatusChanged
            .filter { $0 == .stopped(reason: .cancelled) }
            .map { _ in }
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

    init(
        toCamera: CameraOptions,
        duration: TimeInterval? = nil,
        curve: TimingCurve,
        owner: AnimationOwner,
        type: AnimationType = .unspecified,
        mapboxMap: MapboxMapProtocol,
        mainQueue: MainQueueProtocol,
        dateProvider: DateProvider
    ) {
        let flyToInterpolator = FlyToInterpolator(
            from: mapboxMap.cameraState,
            to: toCamera,
            cameraBounds: mapboxMap.cameraBounds,
            size: mapboxMap.size)
        var duration = duration ?? flyToInterpolator.duration()
        if duration < 0 {
            assertionFailure("Duration can't be negative.")
            duration = 0
        }
        self.interpolator = flyToInterpolator
        self.mapboxMap = mapboxMap
        self.mainQueue = mainQueue
        self.duration = duration
        self.unitBezier = UnitBezier(p1: curve.p1, p2: curve.p2)
        self.owner = owner
        self.animationType = type
        self.finalCameraOptions = toCamera
        self.dateProvider = dateProvider
    }

    func startAnimation() {
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

    func addCompletion(_ completion: @escaping AnimationCompletion) {
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

    func update() {
        guard case .running(let startDate) = internalState else {
            return
        }

        let elapsedTime = dateProvider.now.timeIntervalSince(startDate)

        guard elapsedTime >= 0 else {
            return
        }

        let fractionComplete = unitBezier.solve(min(elapsedTime / duration, 1), 1e-6)
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
