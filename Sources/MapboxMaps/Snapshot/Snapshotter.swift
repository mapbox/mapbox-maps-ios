import UIKit
import CoreLocation
import CoreImage.CIFilterBuiltins

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

// MARK: - Snapshotter
public class Snapshotter {

    /// Internal `MapboxCoreMaps.MBXMapSnapshotter` object that takes care of
    /// rendering a snapshot.
    internal var mapSnapshotter: MapSnapshotter

    /// A `style` object that can be manipulated to set different styles for a snapshot
    public let style: Style

    private let options: MapSnapshotOptions

    private var eventHandlers = WeakSet<MapEventHandler>()

    deinit {
        eventHandlers.allObjects.forEach {
            $0.cancel()
        }
    }

    /// Initialize a `Snapshotter` instance
    /// - Parameters:
    ///   - options: Options describing an intended snapshot
    public init(options: MapSnapshotOptions) {
        self.options = options
        mapSnapshotter = MapSnapshotter(options: MapboxCoreMaps.MapSnapshotOptions(options))
        style = Style(with: mapSnapshotter)
    }

    /// The size of the snapshot
    public var snapshotSize: CGSize {
        get {
            let mbxSize = mapSnapshotter.getSize()
            let size = CGSize(width: CGFloat(mbxSize.width),
                              height: CGFloat(mbxSize.height))
            return size
        } set(newSize) {
            let mbxSize = MapboxCoreMaps.Size(width: Float(newSize.width), height: Float(newSize.height))
            mapSnapshotter.setSizeFor(mbxSize)
        }
    }

    /// The current camera state of the snapshotter
    public var cameraState: CameraState {
        return CameraState(mapSnapshotter.getCameraState())
    }

    /// Sets the camera of the snapshotter
    /// - Parameter cameraOptions: The target camera options
    public func setCamera(to cameraOptions: CameraOptions) {
        mapSnapshotter.setCameraFor(MapboxCoreMaps.CameraOptions(cameraOptions))
    }

    /// In the tile mode, the snapshotter fetches the still image of a single tile.
    public var tileMode: Bool {
        get {
            return mapSnapshotter.isInTileMode()
        } set(newValue) {
            mapSnapshotter.setTileModeForSet(newValue)
        }
    }

    /**
     Request a new snapshot. If there is a pending snapshot request, it is cancelled automatically.

     - Parameter overlayHandler: The optional block to call after the base map finishes drawing,
     but before the final snapshot has been drawn. This block provides a
     `SnapshotOverlayHandler` type, which can be used with Core Graphics
     to draw custom content directly over the snapshot image.
     - Parameter completion: The block to call once the snapshot has been generated, providing a
     `Result<UIImage, SnapshotError>` type.
     */
    public func start(overlayHandler: SnapshotOverlayHandler?,
                      completion: @escaping (Result<UIImage, SnapshotError>) -> Void) {

        let scale = CGFloat(options.pixelRatio)

        let attributions = AttributionParser.parse(style.sourceAttributions())

        mapSnapshotter.start { (expected) in
            if expected.isError() {
                completion(.failure(.snapshotFailed(reason: expected.error as? String)))
                return
            }

            guard expected.isValue(), let snapshot = expected.value as? MapSnapshot else {

                completion(.failure(.snapshotFailed(reason: expected.error as? String)))
                return
            }

            let mbxImage = snapshot.image()

            guard let uiImage = UIImage(mbxImage: mbxImage, scale: scale) else {
                completion(.failure(.snapshotFailed(reason: "Could not convert internal Image type to UIImage.")))
                return
            }

            let rect = CGRect(origin: .zero, size: uiImage.size)
            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: uiImage.size, format: format)
            let compositeImage = renderer.image { rendererContext in

                // First draw the snaphot image into the context
                let context = rendererContext.cgContext

                if let cgImage = uiImage.cgImage {
                    context.draw(cgImage, in: rect)
                }

                let pointForCoordinate = { (coordinate: CLLocationCoordinate2D) -> CGPoint in
                    let screenCoordinate = snapshot.screenCoordinate(for: coordinate)
                    return CGPoint(x: screenCoordinate.x, y: screenCoordinate.y)
                }

                let coordinateForPoint = { (point: CGPoint) -> CLLocationCoordinate2D in
                    // TODO: Fix circular dependency issues with MapboxMapsStyle/Foundation in order to use point.screenCoordinate extension
                    let screenCoordinate = ScreenCoordinate(x: Double(point.x), y: Double(point.y))
                    return snapshot.coordinate(for: screenCoordinate)
                }

                // Apply the overlay, if provided.
                let overlay = SnapshotOverlay(context: context,
                                              scale: scale,
                                              pointForCoordinate: pointForCoordinate,
                                              coordinateForPoint: coordinateForPoint)

                if let overlayHandler = overlayHandler {
                    context.saveGState()
                    overlayHandler(overlay)
                    context.restoreGState()
                }

//                // Composite the logo on the snapshot,
//                // only after everything else has been drawn.
//                let logoView = LogoView(logoSize: .compact())
//                let logoPadding = CGFloat(10.0)
//                let logoOrigin = CGPoint(x: logoPadding,
//                                         y: uiImage.size.height - logoView.frame.size.height - logoPadding)
//                context.translateBy(x: logoOrigin.x, y: logoOrigin.y)
//                logoView.layer.render(in: context)

                // $$JR: Add attribution here
                print("attributions = \(attributions)")

                let measure = AttributionMeasure()
                let margin = CGFloat(10)
                let (_, logoSize, text) = measure.attributionThatFits(rect: rect, attributions: attributions, margin: margin)

                var logoHeight: CGFloat?
                if let logoSize = logoSize {
                    context.saveGState()
                    let logoView = LogoView(logoSize: logoSize)

                    let originX = min(margin, (rect.width - logoView.bounds.width)/2)


                    let logoOrigin = CGPoint(x: originX,
                                             y: rect.height - logoView.bounds.height - margin)
//                    y: uiImage.size.height - logoView.frame.size.height - margin)
                    context.translateBy(x: logoOrigin.x, y: logoOrigin.y)
                    logoView.layer.render(in: context)
                    context.restoreGState()

                    logoHeight = logoView.frame.size.height
                }

                if let text = text {
                    context.saveGState()

                    let attributionTextView = AttributionView(text: text)
                    let textSize = attributionTextView.bounds.size

                    let h1 = logoHeight ?? textSize.height

                    let textOrigin = CGPoint(x: rect.width - textSize.width - margin,
                                             y: rect.height - ((h1 + textSize.height)/2) - margin)
//                    let textOrigin = CGPoint(x: uiImage.size.width - textSize.width - margin,
//                                             y: uiImage.size.height - ((h1 + textSize.height)/2) - margin)

                    /////////

                    let cropRect = CGRect(origin: textOrigin, size: textSize)
                    let cropRect2 = CGRect(x: cropRect.origin.x * 2,
                                           y: cropRect.origin.y * 2,
                                           width: cropRect.width * 2,
                                           height: cropRect.height * 2)
                    if let currentImage = UIGraphicsGetImageFromCurrentImageContext(),
                       let croppedImage = currentImage.cgImage?.cropping(to: cropRect2) {

                        // Create a ciImage
                        let ciImage = CIImage(cgImage: croppedImage)
                        var blurredCIImage = ciImage.applyingGaussianBlur(sigma: 5)

                        if let filter = CIFilter(name: "CIColorControls") {
                            filter.setValue(blurredCIImage, forKey: kCIInputImageKey)
                            filter.setValue(0.05, forKey: kCIInputBrightnessKey)
                            blurredCIImage = filter.outputImage!
                        }


                        let cicontext = CIContext(cgContext: context, options: nil)
                        var textSize2 = textSize
                        textSize2.width *= 2
                        textSize2.height *= 2
                        if let blurredCGImage = cicontext.createCGImage(blurredCIImage, from: CGRect(origin: .zero, size: textSize2)) {

//                            if #available(iOS 13.0, *) {
//                                let blurredUIImage = UIImage(cgImage: blurredCGImage).withTintColor(.red)
                                attributionTextView.layer.contents = blurredCGImage
//                            attributionTextView.layer.opacity = 0.8

                            //withTintColor(.red)
//                            withTintColor(_ color: UIColor)

                        }
                    }


                    /////////


                    context.translateBy(x: textOrigin.x, y: textOrigin.y)

                    attributionTextView.layer.render(in: context)
                    context.restoreGState()
                }
            }
            completion(.success(compositeImage))
        }
    }


/*
     + (MGLImage *)blurredAttributionBackground:(CIImage *)backgroundImage
     {
         CGAffineTransform transform = CGAffineTransformIdentity;
         CIFilter *clamp = [CIFilter filterWithName:@"CIAffineClamp"];
         [clamp setValue:backgroundImage forKey:kCIInputImageKey];
         [clamp setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];

         CIFilter *attributionBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
         [attributionBlurFilter setValue:[clamp outputImage] forKey:kCIInputImageKey];
         [attributionBlurFilter setValue:@10 forKey:kCIInputRadiusKey];

         CIFilter *attributionColorFilter = [CIFilter filterWithName:@"CIColorControls"];
         [attributionColorFilter setValue:[attributionBlurFilter outputImage] forKey:kCIInputImageKey];
         [attributionColorFilter setValue:@(0.1) forKey:kCIInputBrightnessKey];

         CIImage *blurredImage = attributionColorFilter.outputImage;

         CIContext *ctx = [CIContext contextWithOptions:nil];
         CGImageRef cgimg = [ctx createCGImage:blurredImage fromRect:[backgroundImage extent]];
         MGLImage *image;

     #if TARGET_OS_IPHONE
         image = [UIImage imageWithCGImage:cgimg];
     #else
         image = [[NSImage alloc] initWithCGImage:cgimg size:[backgroundImage extent].size];
     #endif

         CGImageRelease(cgimg);
         return image;
     }
*/


     
    /**
     Cancels the current snapshot operation.The callback passed to the start
     method is called with error parameter set.
     */
    public func cancel() {
        mapSnapshotter.cancel()
    }

    public enum SnapshotError: Error {
        case unknown

        /// Snapshot failed with error description
        case snapshotFailed(reason: String?)
    }

//    internal func compositeLogo(for snapshotImage: UIImage) -> UIImage {
//        let rect = CGRect(origin: .zero, size: snapshotImage.size)
//        let logoView = LogoView(logoSize: .regular())
//
//        let renderer = UIGraphicsImageRenderer(size: snapshotImage.size)
//
//        let compositeImage = renderer.image { rendererContext in
//
//            // First draw the snaphot
//            let context = rendererContext.cgContext
//
//            if let cgImage = snapshotImage.cgImage {
//                context.draw(cgImage, in: rect)
//            }
//
//            // Padding between the edges of the logo and the snapshot
//            let logoPadding = CGFloat(10.0)
//
//            // Position the logo
//            let logoOrigin = CGPoint(x: logoPadding,
//                                     y: snapshotImage.size.height - logoView.frame.size.height - logoPadding)
//            context.translateBy(x: logoOrigin.x, y: logoOrigin.y)
//
//            // Composite the logo on the snapshot
//            logoView.layer.render(in: context)
//        }
//
//        return compositeImage
//    }

    // MARK: - Camera

    /// Returns the coordinate bounds corresponding to a given `CameraOptions`
    ///
    /// - Parameter camera: The camera for which the coordinate bounds will be returned.
    /// - Returns: `CoordinateBounds` for the given `CameraOptions`
    public func coordinateBounds(for camera: CameraOptions) -> CoordinateBounds {
        return mapSnapshotter.coordinateBoundsForCamera(forCamera: MapboxCoreMaps.CameraOptions(camera))
    }

    /// Calculates a `CameraOptions` to fit a list of coordinates.
    ///
    /// - Parameters:
    ///   - coordinates: Array of coordinates that should fit within the new viewport.
    ///   - padding: The new padding to be used by the camera.
    ///   - bearing: The new bearing to be used by the camera.
    ///   - pitch: The new pitch to be used by the camera.
    /// - Returns: A `CameraOptions` that fits the provided constraints
    public func camera(for coordinates: [CLLocationCoordinate2D],
                       padding: UIEdgeInsets,
                       bearing: Double?,
                       pitch: Double?) -> CameraOptions {
        return CameraOptions(mapSnapshotter.cameraForCoordinates(
                                forCoordinates: coordinates.map(\.location),
                                padding: padding.toMBXEdgeInsetsValue(),
                                bearing: bearing?.NSNumber,
                                pitch: pitch?.NSNumber))
    }
}

extension Snapshotter: ObservableProtocol {
    public func subscribe(_ observer: Observer, events: [String]) {
        mapSnapshotter.subscribe(for: observer, events: events)
    }

    public func unsubscribe(_ observer: Observer, events: [String] = []) {
        if events.isEmpty {
            mapSnapshotter.unsubscribe(for: observer)
        } else {
            mapSnapshotter.unsubscribe(for: observer, events: events)
        }
    }
}

extension Snapshotter: MapEventsObservable {
    @discardableResult
    public func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        let handler = MapEventHandler(for: [eventType.rawValue],
                                      observable: self) { event in
            handler(event)
            return true
        }
        eventHandlers.add(handler)
        return handler
    }

    @discardableResult
    public func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        let handler = MapEventHandler(for: [eventType.rawValue],
                                      observable: self) { event in
            handler(event)
            return false
        }
        eventHandlers.add(handler)
        return handler
    }
}

// MARK: - Clear data

extension Snapshotter {
    /// Clears temporary map data.
    ///
    /// Clears temporary map data from the data path defined in the given resource
    /// options. Useful to reduce the disk usage or in case the disk cache contains
    /// invalid data.
    ///
    /// - Note: Calling this API will affect all maps that use the same data path
    ///         and does not affect persistent map data like offline style packages.
    ///
    /// - Parameter completion: Called once the request is complete
    public func clearData(completion: @escaping (Error?) -> Void) {
        MapboxMap.clearData(for: options.resourceOptions, completion: completion)
    }
}
