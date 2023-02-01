import Turf

/// A ``ViewportState`` implementation that shows an overview of the geometry specified by its
/// ``OverviewViewportStateOptions/geometry``.
///
/// Use ``Viewport/makeOverviewViewportState(options:)`` to create instances of this
/// class.
public final class OverviewViewportState {

    /// Configuration options.
    ///
    /// When set, the viewport reframes the geometry using the new options and updates its camera with
    /// an ``CameraAnimationsManager/ease(to:duration:curve:completion:)``
    /// animation with a linear timing curve and duration specified by the new value's
    /// ``OverviewViewportStateOptions/animationDuration``.
    public var options: OverviewViewportStateOptions {
        didSet {
            recalculateCameraOptions()
        }
    }

    // MARK: - Injected Dependencies

    private let mapboxMap: MapboxMapProtocol

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    private let observableCameraOptions: ObservableCameraOptionsProtocol

    // MARK: - Private State

    private var updatingCameraCancelable: Cancelable?

    private var cameraAnimationCancelable: Cancelable?

    // MARK: - Initialization

    internal init(options: OverviewViewportStateOptions,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  observableCameraOptions: ObservableCameraOptionsProtocol) {
        self.options = options
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        self.observableCameraOptions = observableCameraOptions
        recalculateCameraOptions()
    }

    // MARK: - Private Utilities

    private func recalculateCameraOptions() {
        observableCameraOptions.notify(with: mapboxMap.camera(
            for: options.geometry,
            padding: options.padding,
            bearing: options.bearing.map(CGFloat.init(_:)),
            pitch: options.pitch))
    }

    private func animate(to cameraOptions: CameraOptions) {
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = cameraAnimationsManager.ease(
            to: cameraOptions,
            duration: max(0, options.animationDuration),
            curve: .linear,
            completion: nil)
    }
}

extension OverviewViewportState: ViewportState {
    /// :nodoc:
    /// See ``ViewportState/observeDataSource(with:)``.
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return observableCameraOptions.observe(with: handler)
    }

    /// :nodoc:
    /// See ``ViewportState/startUpdatingCamera()``.
    public func startUpdatingCamera() {
        guard updatingCameraCancelable == nil else {
            return
        }
        updatingCameraCancelable = observableCameraOptions.observe { [weak self] cameraOptions in
            self?.animate(to: cameraOptions)
            return true
        }
    }

    /// :nodoc:
    /// See ``ViewportState/stopUpdatingCamera()``.
    public func stopUpdatingCamera() {
        updatingCameraCancelable?.cancel()
        updatingCameraCancelable = nil
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = nil
    }
}
