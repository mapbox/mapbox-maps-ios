import Foundation
import Turf

open class MapView: BaseMapView {

    /// The `mapOptions` structure is the interface for consumers to configure the map.
    /// It's initialized on the creation of the `MapView` with a set of sane, default values.
    /// To synchronously update the `mapOptions` please call `updateMapOptions(with newOptions: MapOptions)`
    internal var mapOptions: MapOptions = MapOptions()

    /// The `gestureManager` will be responsible for all gestures on the map
    public internal(set) var gestureManager: GestureManager!

    /// The `ornamentsManager` will be responsible for all ornaments on the map
    internal var ornamentsManager: OrnamentsManager!

    /// The `cameraManager` that manages a camera's view lifecycle.
    public internal(set) var cameraManager: CameraManager!

    /// The `locationManager` that handles location events of the map
    public internal(set) var locationManager: LocationManager!

    /// The `style` object supports run time styling
    public internal(set) var style: Style!

    /// Controls the addition/removal of annotations to the map.
    public internal(set) var annotationManager: AnnotationManager!

    /// A reference to the `EventsManager` used for dispatching telemetry.
    internal var eventsListener: EventsListener!

    public init(frame: CGRect, resourceOptions: ResourceOptions, glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions.default, styleURI: StyleURI? = .streets) {
        super.init(frame: frame, resourceOptions: resourceOptions, glyphsRasterizationOptions: glyphsRasterizationOptions, styleURI: styleURI?.url)
        initialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    internal func initialize() {
        setUpTelemetryLogging()
        setupManagers()
    }
}

// MARK: Telemetry
extension MapView {
    internal func setUpTelemetryLogging() {
        guard let validResourceOptions = resourceOptions else { return }
        eventsListener = EventsManager(accessToken: validResourceOptions.accessToken)

        on(.mapLoaded) { [weak self] _ in
            self?.eventsListener?.push(event: .map(event: .loaded))
        }
    }
}
