import UIKit

/// An animator that evokes powered flight and an optional transition duration and timing function
/// It seamlessly incorporates zooming and panning to help the user find their bearings even after
/// traversing a great distance.
///
/// - SeeAlso: ``CameraAnimationsManager/fly(to:duration:completion:)``
public class FlyToCameraAnimator: NSObject, CameraAnimator, CameraAnimatorProtocol {

    private let mapboxMap: MapboxMapProtocol

    /// The animator's owner
    public let owner: AnimationOwner

    private let interpolator: FlyToInterpolator

    public let duration: TimeInterval

    public private(set) var state: UIViewAnimatingState = .inactive

    private var startDate: Date?

    private let finalCameraOptions: CameraOptions

    private var completionBlocks = [AnimationCompletion]()

    private let dateProvider: DateProvider

    internal weak var delegate: CameraAnimatorDelegate?

    internal init(toCamera: CameraOptions,
                  owner: AnimationOwner,
                  duration: TimeInterval? = nil,
                  mapboxMap: MapboxMapProtocol,
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
        self.owner = owner
        self.finalCameraOptions = toCamera
        self.duration = duration ?? flyToInterpolator.duration()
        self.dateProvider = dateProvider
    }

    public func stopAnimation() {
        state = .inactive
        delegate?.cameraAnimatorDidStopRunning(self)
        invokeCompletionBlocks(with: .current) // `current` represents an interrupted animation.
    }

    internal func startAnimation() {
        state = .active
        startDate = dateProvider.now
        delegate?.cameraAnimatorDidStartRunning(self)
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
        guard state == .active, let startDate = startDate else {
            return
        }
        let fractionComplete = min(dateProvider.now.timeIntervalSince(startDate) / duration, 1)
        guard fractionComplete < 1 else {
            state = .inactive
            delegate?.cameraAnimatorDidStopRunning(self)
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
