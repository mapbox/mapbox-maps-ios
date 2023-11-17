import Turf
import UIKit

/// A ``ViewportState`` implementation that shows an overview of the geometry specified by its
/// ``OverviewViewportStateOptions/geometry``.
///
/// Use ``ViewportManager/makeOverviewViewportState(options:)`` to create instances of this
/// class.
public final class OverviewViewportState {

    /// Configuration options.
    ///
    /// When set, the viewport reframes the geometry using the new options and updates its camera with
    /// an ``CameraAnimationsManager/ease(to:duration:curve:completion:)``
    /// animation with a linear timing curve and duration specified by the new value's
    /// ``OverviewViewportStateOptions/animationDuration``.
    public var options: OverviewViewportStateOptions {
        set { optionsSubject.value = newValue }
        get { optionsSubject.value }
    }

    private let mapboxMap: MapboxMapProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let optionsSubject: CurrentValueSignalSubject<OverviewViewportStateOptions>
    private let cameraOptions: Signal<CameraOptions>

    private var updatingCameraCancelable: AnyCancelable?
    private var cameraAnimationCancelable: Cancelable?

    internal init(options: OverviewViewportStateOptions,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  safeAreaPadding: Signal<UIEdgeInsets?>) {
        self.optionsSubject = .init(options)
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        self.cameraOptions = Signal.combineLatest(safeAreaPadding, optionsSubject.signal.skipRepeats())
            .map { safeAreaPadding, options in
                let padding = safeAreaPadding + options.padding
                let cam = try? mapboxMap.camera(
                    for: options.geometry.coordinates,
                    camera: .init(
                        padding: padding,
                        bearing: options.bearing,
                        pitch: options.pitch),
                    coordinatesPadding: options.geometryPadding,
                    maxZoom: options.maxZoom,
                    offset: options.offset)
                return cam
            }
            .skipNil()
            .skipRepeats()
    }

    private func animate(to cameraOptions: CameraOptions) {
        cameraAnimationCancelable?.cancel()
        let duration = max(0, options.animationDuration)
        if duration == 0 {
            mapboxMap.setCamera(to: cameraOptions)
            return
        }

        cameraAnimationCancelable = cameraAnimationsManager.ease(
            to: cameraOptions,
            duration: duration,
            curve: .linear,
            completion: nil)
    }
}

extension OverviewViewportState: ViewportState {
    /// :nodoc:
    /// See ``ViewportState/observeDataSource(with:)``.
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        cameraOptions.observeWithCancellingHandler(handler)
    }

    /// :nodoc:
    /// See ``ViewportState/startUpdatingCamera()``.
    public func startUpdatingCamera() {
        guard updatingCameraCancelable == nil else {
            return
        }
        updatingCameraCancelable = cameraOptions.observe { [weak self] cameraOptions in
            self?.animate(to: cameraOptions)
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
