@_implementationOnly import MapboxCommon_Private

@available(iOSApplicationExtension, unavailable)
extension MapView {

    /// Errors related to rendered snapshots
    @_spi(Experimental) public enum SnapshotError: Error {
        /// No metal view available. Catastrophic error.
        case noMetalView

        /// Metal texture not present in mapView.
        case invalidTexture

        /// Texture failed to convert to CGImage
        case textureConversionFailed

        /// Metal validation is enabled, unsupported configuration
        case metalValidationEnabled

        /// Converted image is empty in snapshot
        case convertedImageIsEmpty
    }

    /// Synchronously captures the last rendered map view (if available) and constructs a `UIImage` if successful.
    /// - NOTE: This API must be called on main thread
    @_spi(Experimental) public func snapshot() throws -> UIImage {
        guard let metalView = subviews.first(where: { $0 is MTKView }) as? MTKView else {
            Log.error(forMessage: "No metal view present.", category: "MapView.snapshot")
            throw SnapshotError.noMetalView
        }

        // If Metal API validation is enabled, the call to CIContext().createCGImage
        // below will crash with the following message:
        //
        //  -[MTLDebugComputeCommandEncoder setTexture:atIndex:]:373: failed
        //  assertion `frameBufferOnly texture not supported for compute.'
        guard getenv("METAL_DEVICE_WRAPPER_TYPE") == nil else {
            Log.error(forMessage: "Metal API validation is enabled - MapView snapshot is being skipped.", category: "MapView.snapshot")
            throw SnapshotError.metalValidationEnabled
        }

        guard let texture = metalView.currentDrawable?.texture else {
            Log.error(forMessage: "Metal texture could not be retrieved from current drawable.", category: "MapView.snapshot")
            throw SnapshotError.invalidTexture
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ciImage = CIImage(mtlTexture: texture, options: [CIImageOption.colorSpace: colorSpace]),
              let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            Log.error(forMessage: "Metal texture could not be converted to CGImage.", category: "MapView.snapshot")
            throw SnapshotError.textureConversionFailed
        }

        return UIImage(
            cgImage: cgImage,
            scale: metalView.contentScaleFactor,
            orientation: .downMirrored)

    }
}
