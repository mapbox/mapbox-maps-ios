@_implementationOnly import MapboxCommon_Private

@available(iOSApplicationExtension, unavailable)
extension MapView {
    
    /// :nodoc:
    ///
    /// Errors related to rendered snapshots
    @_spi(Experimental) public enum RenderedSnapshotError: Error {
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
    
    /// :nodoc:
    ///
    /// Synchronously captures the last rendered map view (if available) and constructs a `UIImage` if successful
    /// - Returns: Result type of
    @_spi(Experimental) public func snapshot() -> Result<UIImage, RenderedSnapshotError> {
        
        guard let metalView = subviews.first(where: { $0 is MTKView }) as? MTKView else {
            Log.error(forMessage: "No metal view present.", category: "MapView.snapshot")
           return .failure(.noMetalView)
        }
        
        // If Metal API validation is enabled, the call to CIContext().createCGImage
        // below will crash with the following message:
        //
        //  -[MTLDebugComputeCommandEncoder setTexture:atIndex:]:373: failed
        //  assertion `frameBufferOnly texture not supported for compute.'
        guard getenv("METAL_DEVICE_WRAPPER_TYPE") == nil else {
            Log.error(forMessage: "Metal API validation is enabled - MapView snapshot is being skipped.", category: "MapView.snapshot")
            return .failure(.metalValidationEnabled)
        }
    
        guard let texture = metalView.currentDrawable?.texture else {
            Log.error(forMessage: "Metal texture could not be retrieved from current drawable.", category: "MapView.snapshot")
            return .failure(.invalidTexture)
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
    
        guard let ciImage = CIImage(mtlTexture: texture, options: [CIImageOption.colorSpace: colorSpace]),
              let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            Log.error(forMessage: "Metal texture could not be converted to CGImage.", category: "MapView.snapshot")
            return .failure(.textureConversionFailed)
        }
        
        guard !cgImage.isEmpty() else {
            Log.error(forMessage: "Converted image is empty in snapshot.", category: "MapView.snapshot")
            return .failure(.convertedImageIsEmpty)
        }

        return .success(
            UIImage(
                cgImage: cgImage,
                scale: metalView.contentScaleFactor,
                orientation: .downMirrored)
        )
    }
}
