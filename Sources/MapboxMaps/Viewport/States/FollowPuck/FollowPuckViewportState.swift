import UIKit

/// A ``ViewportState`` implementation that tracks the location puck (to show a puck, use
/// ``LocationOptions/puckType``)
///
/// Use ``ViewportManager/makeFollowPuckViewportState(options:)`` to create instances of this
/// class.
public final class FollowPuckViewportState {

    /// Configuration options for this state.
    public var options: FollowPuckViewportStateOptions {
        get { optionsSubject.value }
        set { optionsSubject.value = newValue }
    }

    private let impl: CameraViewportState
    private let optionsSubject: CurrentValueSignalSubject<FollowPuckViewportStateOptions>

    internal init(options: FollowPuckViewportStateOptions,
                  mapboxMap: MapboxMapProtocol,
                  onPuckRender: Signal<PuckRenderingData>,
                  safeAreaPadding: Signal<UIEdgeInsets?>) {
        let optionsSubject = CurrentValueSignalSubject(options)
        self.optionsSubject = optionsSubject

        let resultCamera = Signal
            .combineLatest(optionsSubject.signal.skipRepeats(), onPuckRender)
            .map { (options, puckData) in
                CameraOptions(
                    center: puckData.location.coordinate,
                    padding: options.padding,
                    zoom: options.zoom,
                    bearing: options.bearing?.evaluate(with: puckData),
                    pitch: options.pitch)
            }

        self.impl = CameraViewportState(cameraOptions: resultCamera, mapboxMap: mapboxMap, safeAreaPadding: safeAreaPadding)
    }
}

extension FollowPuckViewportState: ViewportState {
    /// :nodoc:
    /// See ``ViewportState/observeDataSource(with:)``.
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        impl.observeDataSource(with: handler)
    }

    /// :nodoc:
    /// See ``ViewportState/startUpdatingCamera()``.
    public func startUpdatingCamera() {
        impl.startUpdatingCamera()
    }

    /// :nodoc:
    /// See ``ViewportState/stopUpdatingCamera()``.
    public func stopUpdatingCamera() {
        impl.stopUpdatingCamera()
    }
}
