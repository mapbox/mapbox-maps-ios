import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

/// The `OrnamentSupportableView` protocol supports communication
/// from the MapboxMapsOrnaments module to the `MapView`.
internal protocol OrnamentSupportableView: UIView {
    // View has been tapped
    func tapped()

    // Compass ornament has been tapped
    func compassTapped()

    func subscribeCameraChangeHandler(_ handler: @escaping (CameraState) -> Void)
}

// Provides default implementation of OrnamentSupportableView methods.
internal extension OrnamentSupportableView {
    func compassTapped() {}
}
