import Foundation
import Turf

open class MapView: BaseMapView {

    /// The `mapOptions` structure is the interface for consumers to configure the map.
    /// It's initialized on the creation of the `MapView` with a set of sane, default values.
    /// To synchronously update the `mapOptions` please call `updateMapOptions(with newOptions: MapOptions)`
    internal var mapConfig: MapConfig = MapConfig()

    /// The `gestures` object will be responsible for all gestures on the map.
    public internal(set) var gestures: GestureManager!

    /// The `ornaments`object will be responsible for all ornaments on the map.
    public internal(set) var ornaments: OrnamentsManager!

    /// The `camera` object manages a camera's view lifecycle..
    public internal(set) var camera: CameraAnimationsManager!

    /// The `location`object handles location events of the map.
    public internal(set) var location: LocationManager!

    /// The `style` object supports run time styling.
    public internal(set) var style: Style!

    /// Controls the addition/removal of annotations to the map.
    public internal(set) var annotations: AnnotationManager!

    /// A reference to the `EventsManager` used for dispatching telemetry.
    internal var eventsListener: EventsListener!

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: `MapInitOptions`; default uses `CredentialsManager.default`
    ///         to retrieve a shared default access token.
    public override init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
        super.init(frame: frame, mapInitOptions: mapInitOptions)
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

        mapboxMap.on(.mapLoaded) { [weak self] _ in
            self?.eventsListener?.push(event: .map(event: .loaded))
            return false
        }
    }
}
