@_implementationOnly import MapboxCommon_Private
import UIKit

extension MapView {

    /// Errors related to rendered snapshots
    @_spi(Experimental) public enum SnapshotError: Error {
        /// No metal view available. Catastrophic error.
        case noMetalView

        /// Metal view or one of its subviews is missing image data.
        case missingImageData
    }

    /// Synchronously captures the rendered map as a `UIImage`. The image does not include the
    /// ornaments (scale bar, compass, attribution, etc.) or any other custom subviews. Use
    /// `drawHierarchy(in:afterScreenUpdates:)` directly to include the full hierarchy.
    /// - Returns: A `UIImage` of the rendered map
    @_spi(Experimental) public func snapshot() throws -> UIImage {
        guard let metalView = metalView else {
            Log.error(forMessage: "No metal view present.", category: "MapView.snapshot")
            throw SnapshotError.noMetalView
        }
        var success = false
        let image = UIGraphicsImageRenderer(bounds: metalView.bounds).image { _ in
            success = metalView.drawHierarchy(in: metalView.bounds, afterScreenUpdates: true)
        }
        if !success {
            throw SnapshotError.missingImageData
        }
        return image
    }
}
