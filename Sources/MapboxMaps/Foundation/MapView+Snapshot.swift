@_implementationOnly import MapboxCommon_Private

@available(iOSApplicationExtension, unavailable)
extension MapView {
    /// :nodoc:
    ///
    /// Schedules the capturing of the "last rendered map view" (if available),
    /// generation of a UIImage and passes the result to the completion handler.
    ///
    /// Currently the image passed to the closure has a slightly washed out
    /// appearance compared with the main map view.
    /// 
    /// - Parameter completion: Closure that is passed a snapshot image if available
    ///
    /// - Note: This is an experimental API and subject to change.
    @_spi(Experimental) public func snapshot(completion: @escaping (UIImage?) -> Void ) {

        // Calling mapView.layer.render(in:) isn't sufficient for
        // capturing the Metal rendering. This is modified from
        // https://stackoverflow.com/a/47632198 and might not be
        // sufficient.
        guard let metalView = subviews.first as? MTKView else {
            completion(nil)
            return
        }

        // If Metal API validation is enabled, the call to CIContext().createCGImage
        // below will crash with the following message:
        //
        //  -[MTLDebugComputeCommandEncoder setTexture:atIndex:]:373: failed
        //  assertion `frameBufferOnly texture not supported for compute.'
        guard getenv("METAL_DEVICE_WRAPPER_TYPE") == nil else {
            Log.warning(forMessage: "Metal API validation is enabled - MapView snapshot is being skipped.", category: "MapView")
            completion(nil)
            return
        }

        // This needs to be captured on the main thread
        let scale = metalView.contentScaleFactor

        DispatchQueue.global().async {
            var snapshot: UIImage?

            defer {
                DispatchQueue.main.async {
                    completion(snapshot)
                }
            }

            // May need to schedule this for after rendering has occurred
            guard let texture = metalView.currentDrawable?.texture else {
                return
            }

            // This results in an image where the colors appear slightly washed out
            guard let ciImage = CIImage(mtlTexture: texture, options: nil),
                  let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
                return
            }

            // Sometimes (observed on simulator) the image returned is blank
            if !cgImage.isEmpty() {
                snapshot = UIImage(cgImage: cgImage, scale: scale, orientation: .downMirrored)
            }
        }
    }
}
