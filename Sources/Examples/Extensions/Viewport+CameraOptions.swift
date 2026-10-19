import MapboxMaps

extension Viewport {
    /// Creates a camera viewport from `CameraOptions`, e.g. to reuse the same camera in UIKit and SwiftUI.
    static func camera(_ options: CameraOptions) -> Viewport {
        .camera(
            center: options.center,
            anchor: options.anchor,
            zoom: options.zoom,
            bearing: options.bearing,
            pitch: options.pitch
        )
    }
}
