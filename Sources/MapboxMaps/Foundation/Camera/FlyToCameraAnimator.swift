import UIKit

public class FlyToCameraAnimator: NSObject, CameraAnimator, CameraAnimatorInterface {

    private let mapboxMap: CameraAnimatorMapboxMap

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
                   mapboxMap: CameraAnimatorMapboxMap,
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
        self.mapboxMap = mapboxMap
        self.owner = owner
        self.finalCameraOptions = final
        self.duration = duration ?? flyToInterpolator.duration()
        self.dateProvider = dateProvider
    }

    public func stopAnimation() {
        state = .inactive
        invokeCompletionBlocks(with: .current) // `current` represents an interrupted animation.
    }

    internal func startAnimation() {
        state = .active
        start = dateProvider.now
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

    internal func update() {
        guard state == .active, let start = start else {
            return
        }
        let fractionComplete = min(dateProvider.now.timeIntervalSince(start) / duration, 1)
        guard fractionComplete < 1 else {
            state = .inactive
            mapboxMap.setCamera(to: finalCameraOptions)
            invokeCompletionBlocks(with: .end)
            return
        }
        mapboxMap.setCamera(to: CameraOptions(
            center: interpolator.coordinate(at: fractionComplete),
            zoom: CGFloat(interpolator.zoom(at: fractionComplete)),
            bearing: interpolator.bearing(at: fractionComplete),
            pitch: CGFloat(interpolator.pitch(at: fractionComplete))))
    }

    // MARK: Cancelable

    public func cancel() {
        stopAnimation()
    }
}
