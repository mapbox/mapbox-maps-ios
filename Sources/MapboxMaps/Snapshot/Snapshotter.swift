// swiftlint:disable file_length
import UIKit
import CoreLocation
import CoreImage.CIFilterBuiltins

@_implementationOnly import MapboxCommon_Private

internal protocol MapSnapshotterProtocol: StyleManagerProtocol {
    func setSizeFor(_ size: Size)

    func getSize() -> Size

    func getCameraState() -> CoreCameraState

    func setCameraFor(_ cameraOptions: CoreCameraOptions)

    func start(forCallback: @escaping (Expected<CoreMapSnapshot, NSString>) -> Void)

    func cancel()

    func cameraForCoordinates(for coordinates: [Coordinate2D],
                              padding: CoreEdgeInsets?,
                              bearing: NSNumber?,
                              pitch: NSNumber?) -> CoreCameraOptions

    func coordinateBoundsForCamera(forCamera camera: CoreCameraOptions) -> CoordinateBounds
    func __tileCover(for options: CoreTileCoverOptions, cameraOptions: CoreCameraOptions?) -> [CanonicalTileID]
}

extension CoreMapSnapshotter: MapSnapshotterProtocol {

}

/// A utility class for capturing styled map snapshots.
///
/// Use a `MapSnapshotter` when you need to capture a static snapshot of a map without using the actual ``MapView``.
/// You can configure the final result via ``MapSnapshotOptions-swift.struct`` upon construction time and take.
public class Snapshotter: StyleManager {

    /// Internal `MapboxCoreMaps.MBMMapSnapshotter` object that takes care of
    /// rendering a snapshot.
    internal let mapSnapshotter: MapSnapshotterProtocol

    /// A `style` object that can be manipulated to set different styles for a snapshot.
    @available(*, deprecated, message: "Access style APIs directly from Snapshotter instance instead")
    public var style: StyleManager { return self }

    private let events: MapEvents
    private let options: MapSnapshotOptions

    /// Initializes a `Snapshotter` instance.
    /// - Parameters:
    ///   - options: Options describing an intended snapshot
    convenience public init(options: MapSnapshotOptions) {
        let impl = CoreMapSnapshotter(options: CoreMapSnapshotOptions(options))
        self.init(
            options: options,
            mapSnapshotter: impl,
            events: MapEvents(observable: impl),
            eventsManager: EventsManager())
    }

    /// Enables injecting mocks for unit testing.
    internal init(
        options: MapSnapshotOptions,
        mapSnapshotter: MapSnapshotterProtocol,
        events: MapEvents,
        eventsManager: EventsManagerProtocol
    ) {
        self.options = options
        self.mapSnapshotter = mapSnapshotter
        self.events = events

        super.init(with: mapSnapshotter, sourceManager: StyleSourceManager(styleManager: mapSnapshotter))

        eventsManager.sendTurnstile()
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
        mapSnapshotter.setCameraFor(CoreCameraOptions(cameraOptions))
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

        let options = self.options

        mapSnapshotter.start { [weak self] (expected) in
            if expected.isError() {
                completion(.failure(.snapshotFailed(reason: expected.error as String)))
                return
            }

            guard expected.isValue(), let snapshot = expected.value else {
                completion(.failure(.snapshotFailed(reason: expected.error as String)))
                return
            }

            let mbmImage = snapshot.moveImage()
            let pointForCoordinate = { (coordinate: CLLocationCoordinate2D) -> CGPoint in
                return snapshot.screenCoordinate(for: coordinate).point
            }

            let coordinateForPoint = { (point: CGPoint) -> CLLocationCoordinate2D in
                return snapshot.coordinate(for: point.screenCoordinate)
            }
            let overlayDescriptor = SnapshotOverlayDescriptor(
                handler: overlayHandler,
                pointForCoordinate: pointForCoordinate,
                coordinateForPoint: coordinateForPoint
            )
            guard let mbmImage = mbmImage,
                let uiImage = UIImage(mbmImage: mbmImage, scale: scale) else {
                completion(.failure(.snapshotFailed(reason: "Could not convert internal Image type to UIImage.")))
                return
            }

            guard let self = self else { return }

            // Render attributions over the snapshot
            Attribution.parse(snapshot.attributions()) { [weak self] attributions in
                self?.overlaySnapshotWith(
                    attributions: attributions,
                    snapshotImage: uiImage,
                    options: options,
                    overlayDescriptor: overlayDescriptor,
                    completion: completion
                )
            }
        }
    }

    // swiftlint:disable:next function_body_length
    private func overlaySnapshotWith(
        attributions: [Attribution],
        snapshotImage uiImage: UIImage,
        options: MapSnapshotOptions,
        overlayDescriptor: SnapshotOverlayDescriptor?,
        completion: @escaping (Result<UIImage, SnapshotError>) -> Void
    ) {
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
            format.scale = options.pixelRatio
            let renderer = UIGraphicsImageRenderer(size: uiImage.size, format: format)
            let compositeImage = renderer.image { rendererContext in

                // First draw the snapshot image into the context
                let context = rendererContext.cgContext

                // image needs to be flipped vertically
                context.translateBy(x: 0, y: uiImage.size.height)
                context.scaleBy(x: 1, y: -1)

                if let cgImage = uiImage.cgImage {
                    context.draw(cgImage, in: rect)
                }

                // un-flip after adding the image
                context.translateBy(x: 0, y: uiImage.size.height)
                context.scaleBy(x: 1, y: -1)

                if let overlayDescriptor = overlayDescriptor {
                    // Apply the overlay, if provided.
                    let overlay = SnapshotOverlay(from: context, scale: options.pixelRatio, descriptor: overlayDescriptor)

                    context.saveGState()
                    overlayDescriptor.handler(overlay)
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

    /**
     Cancels the current snapshot operation.The callback passed to the start
     method is called with error parameter set.
     */
    public func cancel() {
        mapSnapshotter.cancel()
    }

    public enum SnapshotError: Error, Sendable {
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
        return mapSnapshotter.coordinateBoundsForCamera(forCamera: CoreCameraOptions(camera))
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
                       padding: UIEdgeInsets?,
                       bearing: Double?,
                       pitch: Double?) -> CameraOptions {
        return CameraOptions(mapSnapshotter.cameraForCoordinates(
            for: coordinates.map { Coordinate2D(value: $0) },
            padding: padding?.toMBXEdgeInsetsValue(),
            bearing: bearing?.NSNumber,
            pitch: pitch?.NSNumber))
    }

    /// Returns array of tile identifiers that cover current map camera.
    ///
    /// - Parameters:
    ///  - options: Options for the tile cover method.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func tileCover(for options: TileCoverOptions) -> [CanonicalTileID] {
        mapSnapshotter.__tileCover(
            for: CoreTileCoverOptions(options),
            cameraOptions: nil)
    }
}

// MARK: - Snapshotter Event handling

extension Snapshotter {
    /// An error that has occurred while loading the Map. The `type` property defines what resource could
    /// not be loaded and the `message` property will contain a descriptive error message.
    /// In case of `source` or `tile` loading errors, `sourceID` or `tileID` will contain the identifier of the source failing.
    public var onMapLoadingError: Signal<MapLoadingError> { events.signal(for: \.onMapLoadingError) }

    /// The requested style has been fully loaded, including the style, specified sprite and sources' metadata.
    ///
    /// The style specified sprite would be marked as loaded even with sprite loading error (an error will be emitted via ``MapboxMap/onMapLoadingError``).
    /// Sprite loading error is not fatal and we don't want it to block the map rendering, thus this event will still be emitted if style and sources are fully loaded.
    public var onStyleLoaded: Signal<StyleLoaded> { events.signal(for: \.onStyleLoaded) }

    /// The requested style data has been loaded. The `type` property defines what kind of style data has been loaded.
    /// Event may be emitted synchronously, for example, when ``MapboxMap/loadStyle(_:transition:completion:)-1ilz1`` is used to load style.
    ///
    /// Based on an event data `type` property value, following use-cases may be implemented:
    /// - `style`: Style is parsed, style layer properties could be read and modified, style layers and sources could be
    /// added or removed before rendering is started.
    /// - `sprite`: Style's sprite sheet is parsed and it is possible to add or update images.
    /// - `sources`: All sources defined by the style are loaded and their properties could be read and updated if needed.
    public var onStyleDataLoaded: Signal<StyleDataLoaded> { events.signal(for: \.onStyleDataLoaded) }

    /// A style has a missing image. This event is emitted when the map renders visible tiles and
    /// one of the required images is missing in the sprite sheet. Subscriber has to provide the missing image
    /// by calling ``StyleManager/addImage(_:id:sdf:contentInsets:)``.
    public var onStyleImageMissing: Signal<StyleImageMissing> { events.signal(for: \.onStyleImageMissing) }

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
    ///   - event: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     the event. This is especially important if you have a retain cycle in
    ///     the handler.
    @available(*, deprecated, message: "Use snapshotter.on<eventType>.observeNext instead.")
    @discardableResult
    public func onNext<Payload>(event: MapEventType<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        events.onNext(event: event, handler: handler)
    }

    /// Listen to multiple occurrences of a Map event.
    ///
    /// - Parameters:
    ///   - event: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     events. This is especially important if you have a retain cycle in
    ///     the handler.
    @available(*, deprecated, message: "Use snapshotter.on<eventType>.observe instead.")
    @discardableResult
    public func onEvery<Payload>(event: MapEventType<Payload>, handler: @escaping (Payload) -> Void) -> Cancelable {
        events.onEvery(event: event, handler: handler)
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
        MapboxMapsOptions.clearData(completion: completion)
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

            let scaledCropRect = CGRect(x: rect.origin.x * scale,
                                        y: rect.origin.y * scale,
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

            ciImage = ciImage.oriented(.up)

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

private struct SnapshotOverlayDescriptor {
    fileprivate let handler: SnapshotOverlayHandler
    fileprivate let pointForCoordinate: (CLLocationCoordinate2D) -> CGPoint
    fileprivate let coordinateForPoint: (CGPoint) -> CLLocationCoordinate2D

    init?(
        handler: SnapshotOverlayHandler?,
        pointForCoordinate: @escaping ((CLLocationCoordinate2D) -> CGPoint),
        coordinateForPoint: @escaping ((CGPoint) -> CLLocationCoordinate2D)
    ) {
        guard let handler = handler else {
            return nil
        }

        self.handler = handler
        self.pointForCoordinate = pointForCoordinate
        self.coordinateForPoint = coordinateForPoint
    }
}

private extension SnapshotOverlay {
    init(from context: CGContext, scale: CGFloat, descriptor: SnapshotOverlayDescriptor) {
        self.init(
            context: context,
            scale: scale,
            pointForCoordinate: descriptor.pointForCoordinate,
            coordinateForPoint: descriptor.coordinateForPoint)
    }
}
