@_implementationOnly import MapboxCommon_Private
import UIKit

extension MapView {

    /// Errors related to rendered snapshots
    public struct SnapshotError: Error, Equatable {
        public let message: String

        /// No metal view available. Catastrophic error.
        public static let noMetalView = SnapshotError(message: "No Metal view")

        /// Metal view or one of its subviews is missing image data.
        public static let missingImageData = SnapshotError(message: "Missing image data")
    }

    /// Synchronously captures the rendered map as a `UIImage`. The image does not include the
    /// ornaments (scale bar, compass, attribution, etc.) or any other custom subviews. Use
    /// `drawHierarchy(in:afterScreenUpdates:)` directly to include the full hierarchy.
    /// - Returns: A `UIImage` of the rendered map
    public func snapshot() throws -> UIImage {
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
