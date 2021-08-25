@_implementationOnly import MapboxCommon_Private

@available(iOSApplicationExtension, unavailable)
extension MapView {
    
    @_spi(Experimental) public enum RenderedSnapshotError: Error {
        case noMetalView
        case invalidTexture
        case textureConversionFailed
    }
    
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
    @_spi(Experimental) public func snapshot(completion: @escaping (Result<UIImage, RenderedSnapshotError>) -> Void) {
        
        guard let metalView = subviews.first(where: { $0 is MTKView }) as? MTKView else {
            completion(.failure(.noMetalView))
            return
        }
        
        DispatchQueue.global().async {
            
            // May need to schedule this for after rendering has occurred
            guard let texture = metalView.currentDrawable?.texture else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidTexture))
                }
                return
            }
            
            guard let imageRef = texture.makeCGImage() else  {
                DispatchQueue.main.async {
                    completion(.failure(.textureConversionFailed))
                }
                return
            }
            
            let snapshot = UIImage(cgImage: imageRef)
            DispatchQueue.main.async {
                completion(.success(snapshot))
            }
        }
    }
}


extension MTLTexture {
    
    func bytes() -> UnsafeMutableRawPointer? {
        let width = self.width
        let height   = self.height
        let rowBytes = self.width * 4
        
        guard let p = malloc(width * height * 4) else {
            return nil
        }
        
        self.getBytes(
            p,
            bytesPerRow: rowBytes,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )
        
        return p
    }
    
    func makeCGImage() -> CGImage? {
        guard let p = bytes() else {
            return nil
        }
        
        let pColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue
            | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)
        let rowBytes = self.width * 4
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            return
        }
        guard let provider = CGDataProvider(
                dataInfo: nil,
                data: p,
                size: self.width * self.height * 4,
                releaseData: releaseMaskImagePixelData) else {
            return nil
        }
        
        guard let cgImageRef = CGImage(width: self.width,
                                       height: self.height,
                                       bitsPerComponent: 8,
                                       bitsPerPixel: 32,
                                       bytesPerRow: rowBytes,
                                       space: pColorSpace,
                                       bitmapInfo: bitmapInfo,
                                       provider: provider,
                                       decode: nil,
                                       shouldInterpolate: true,
                                       intent: CGColorRenderingIntent.defaultIntent) else {
            return nil
        }
        
        return cgImageRef
    }
}
