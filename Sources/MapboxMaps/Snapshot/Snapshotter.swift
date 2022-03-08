// swiftlint:disable file_length
import UIKit
import CoreLocation
import CoreImage.CIFilterBuiltins

@_implementationOnly import MapboxCommon_Private

// MARK: - Snapshotter
public class Snapshotter {

    /// Internal `MapboxCoreMaps.MBXMapSnapshotter` object that takes care of
    /// rendering a snapshot.
    internal var mapSnapshotter: MapSnapshotter

    /// A `style` object that can be manipulated to set different styles for a snapshot
    public let style: Style

    private let options: MapSnapshotOptions

    private let observable: MapboxObservableProtocol

    /// Initialize a `Snapshotter` instance
    /// - Parameters:
    ///   - options: Options describing an intended snapshot
    public init(options: MapSnapshotOptions) {
        self.options = options
        mapSnapshotter = MapSnapshotter(options: MapboxCoreMaps.MapSnapshotOptions(options))
        style = Style(with: mapSnapshotter)
        observable = MapboxObservable(observable: mapSnapshotter)
        EventsManager.shared(withAccessToken: options.resourceOptions.accessToken).sendTurnstile()
    }

    /// Enables injecting mocks when unit testing
    internal init(options: MapSnapshotOptions,
                  mapboxObservableProvider: (ObservableProtocol) -> MapboxObservableProtocol) {
        self.options = options
        mapSnapshotter = MapSnapshotter(options: MapboxCoreMaps.MapSnapshotOptions(options))
        style = Style(with: mapSnapshotter)
        observable = mapboxObservableProvider(mapSnapshotter)
        EventsManager.shared(withAccessToken: options.resourceOptions.accessToken).sendTurnstile()
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

        let style = self.style
        let options = self.options

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

            // Render attributions over the snapshot
            let sourceAttributions = style.sourceAttributions()
            let attributions = Attribution.parse(sourceAttributions)

            let margin: CGFloat = 10
            let rect = CGRect(origin: .zero, size: uiImage.size)

            let (logoSize, text) = AttributionMeasure.logoAndAttributionThatFits(rect: rect,
                                                                                 attributions: attributions,
                                                                                 margin: margin)

            // Create views on the main thread
            let logoView = LogoView(logoSize: logoSize)

            // Center logo horizontally if not enough space
            let logoCenteredX = (rect.width - logoView.bounds.width)/2
            let logoOriginX: CGFloat

            if case .compact = logoSize, text == nil {
                // Center
                logoOriginX = logoCenteredX
            } else {
                // Otherwise, position logo on the left hand side with margin
                // if possible
                logoOriginX = min(margin, logoCenteredX)
            }

            logoView.frame.origin = CGPoint(x: logoOriginX,
                                            y: rect.height - logoView.bounds.height - margin)

            let attributionView: AttributionView!
            if let text = text {
                attributionView = AttributionView(text: text)

                // Attribution on RHS centered vertically with logo
                let textSize = attributionView.bounds.size
                let logoHeight = logoView.bounds.height
                let h1 = logoHeight > 0 ? logoHeight : textSize.height

                attributionView.frame.origin = CGPoint(x: rect.width - textSize.width - margin,
                                                       y: rect.height - ((h1 + textSize.height)/2) - margin)
            } else {
                attributionView = nil
            }

            // Composite custom overlay, logo and attribution
            let compositor = { (blurredImage: CGImage?) in
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

                    if options.showsLogo {
                        Snapshotter.renderLogoView(logoView, context: context)
                    }

                    if let attributionView = attributionView,
                       options.showsAttribution {
                        Snapshotter.renderAttributionView(attributionView,
                                                          blurredImage: blurredImage,
                                                          context: context)
                    }
                }
                completion(.success(compositeImage))
            }

            if text != nil {
                // Generate blurred background for
                Snapshotter.blurredAttributionBackground(for: uiImage, rect: attributionView.frame, completion: compositor)
            } else {
                compositor(nil)
            }
        }
    }

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

extension Snapshotter {
    /// Subscribes an observer to a list of events.
    ///
    /// `Snapshotter` holds a strong reference to `observer` while it is subscribed. To stop receiving
    /// notifications, pass the same `observer` to `unsubscribe(_:events:)`.
    ///
    /// - Parameters:
    ///   - observer: An object that will receive events of the types specified by `events`
    ///   - events: Array of event types to deliver to `observer`
    ///
    /// - Note:
    ///     Prefer `onNext(_:handler:)` and `onEvery(_:handler:)` to using this lower-level APIs
    public func subscribe(_ observer: Observer, events: [String]) {
        observable.subscribe(observer, events: events)
    }

    /// Unsubscribes an observer from a list of events.
    ///
    /// `Snapshotter` holds a strong reference to `observer` while it is subscribed. To stop receiving
    /// notifications, pass the same `observer` to this method as was passed to
    /// `subscribe(_:events:)`.
    ///
    /// - Parameters:
    ///   - observer: The object to unsubscribe
    ///   - events: Array of event types to unsubscribe from. Pass an
    ///     empty array (the default) to unsubscribe from all events.
    public func unsubscribe(_ observer: Observer, events: [String] = []) {
        observable.unsubscribe(observer, events: events)
    }
}

extension Snapshotter: MapEventsObservable {
    /// Listen to a single occurrence of a Map event.
    ///
    /// This will observe the next (and only the next) event of the specified
    /// type. After observation, the underlying subscriber will unsubscribe from
    /// the map or snapshotter.
    ///
    /// If you need to unsubscribe before the event fires, call `cancel()` on
    /// the returned `Cancelable` object.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     the event. This is especially important if you have a retain cycle in
    ///     the handler.
    @discardableResult
    public func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        observable.onNext([eventType], handler: handler)
    }

    /// Listen to multiple occurrences of a Map event.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     events. This is especially important if you have a retain cycle in
    ///     the handler.
    @discardableResult
    public func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable {
        observable.onEvery([eventType], handler: handler)
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

    // MARK: - Attribution

    private static func blurredAttributionBackground(for image: UIImage, rect: CGRect, completion: @escaping (CGImage?) -> Void) {
        DispatchQueue.global().async {
            var blurredImage: CGImage?

            defer {
                DispatchQueue.main.async {
                    completion(blurredImage)
                }
            }

            let scale = image.scale

            // Image from mbxImage is flipped vertically
            let scaledCropRect = CGRect(x: rect.origin.x * scale,
                                        y: (image.size.height - rect.origin.y - rect.height) * scale,
                                        width: rect.width * scale,
                                        height: rect.height * scale)

            guard let croppedImage = image.cgImage?.cropping(to: scaledCropRect) else {
                return
            }

            // Create a ciImage
            var ciImage = CIImage(cgImage: croppedImage)

            // Store original extent (needed for the cropping below)
            let extent = ciImage.extent

            ciImage = ciImage
                .clampedToExtent()
                .applyingGaussianBlur(sigma: 5)
                .cropped(to: extent)

            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(0.1, forKey: kCIInputBrightnessKey)
                ciImage = filter.outputImage!
            }

            ciImage = ciImage.oriented(.downMirrored)

            let cicontext = CIContext(options: nil)
            blurredImage = cicontext.createCGImage(ciImage, from: extent)
        }
    }

    private static func renderLogoView(_ logoView: LogoView, context: CGContext) {
        // Don't bother rendering empty logos
        if case .none = logoView.logoSize {
            return
        }

        context.saveGState()
        defer {
            context.restoreGState()
        }

        context.translateBy(x: logoView.frame.origin.x, y: logoView.frame.origin.y)
        logoView.layer.render(in: context)
    }

    private static func renderAttributionView(_ attributionView: AttributionView, blurredImage: CGImage?, context: CGContext) {
        context.saveGState()
        defer {
            context.restoreGState()
        }

        context.translateBy(x: attributionView.frame.origin.x, y: attributionView.frame.origin.y)
        attributionView.layer.contents = blurredImage
        attributionView.layer.render(in: context)
    }
}
