@_implementationOnly import MapboxCommon_Private
import UIKit

extension MapView {
    /// Errors related to rendered snapshots
    public struct SnapshotError: Error, Equatable, Sendable {
        public let message: String

        /// No metal view available. Catastrophic error.
        public static let noMetalView = SnapshotError(message: "No Metal view")

        /// Metal view or one of its subviews is missing image data.
        public static let missingImageData = SnapshotError(message: "Missing image data")
    }

    /// Synchronously captures the rendered map as a `UIImage`.
    /// - Parameters:
    ///   - includeOverlays: Whether to show ornaments (scale bar, compass, attribution, etc.) or any other custom subviews on the resulting image.
    /// - Returns: A `UIImage` of the rendered map
    public func snapshot(includeOverlays: Bool = false) throws -> UIImage {
        guard !includeOverlays else {
            return try image(for: self)
        }

        guard let metalView = metalView else {
            Log.error("No metal view present.", category: "MapView.snapshot")
            throw SnapshotError.noMetalView
        }

        return try image(for: metalView)
    }

    private func image(for view: UIView) throws -> UIImage {
        var success = false

        let image = UIGraphicsImageRenderer(bounds: view.bounds).image { _ in
            success = view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        if !success {
            throw SnapshotError.missingImageData
        }
        return image
    }
}
