import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

/// The `OrnamentSupportableView` protocol supports communication
/// from the MapboxMapsOrnaments module to the `MapView`.
public protocol OrnamentSupportableView: UIView {
    // View has been tapped
    func tapped()

    // Compass ornament has been tapped
    func compassTapped()

    func subscribeCameraChangeHandler(_ handler: @escaping (CameraOptions) -> Void)
}

// Provides default implementation of OrnamentSupportableView methods.
internal extension OrnamentSupportableView {
    func compassTapped() {}
}
