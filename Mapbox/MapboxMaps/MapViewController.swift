import UIKit
import MapboxCoreMaps
import MapboxMapsGestures
import MapboxMapsOrnaments
import MapboxMapsFoundation
import MapboxMapsStyle
import MapboxMapsAnnotations
import MapboxMapsLocation


/// The MapViewController is responsible for managing the `mapView`
/// and orchestrating between the different components of the Mapbox SDK
open class MapManager: UIViewController {

    /// The `mapOptions` structure is the interface for consumers to configure the map.
    /// It's initialized on the creation of the `MapViewController` with a set of sane, default values.
    /// To synchronously update the `mapOptions` please call `updateMapOptions(with newOptions: MapOptions)`
    public private(set) var mapOptions: MapOptions = MapOptions()

    /// The `gestureManager` will be responsible for all gestures on the map
    private var gestureManager: GestureManager!

    /// The `ornamentsManager` will be responsible for all ornaments on the map
    private var ornamentsManager: OrnamentsManager!

    /// The `cameraManager` that manages a camera's view lifecycle.
    public private(set) var cameraManager: CameraManager!

    /// The `locationManager` that handles location events of the map
    public private(set) var locationManager: MapboxMapsLocation.LocationManager!

    /// The `style` object supports run time styling
    public private(set) var style: Style!

    /// The `eventsManager` manages telemetry collection, processing and emission.
    private var eventsManager: EventsListener!

    /// Controls the addition/removal of annoations  to the map.
    public private(set) var annotationManager: AnnotationManager!

    /// The frame of the `mapView`
    private var frame: CGRect!

    /// The mapbox access token used to authenticate requests to Mapbox
    private var accessToken: String!

    /// The base URL to a custom API endpoint
    private var baseURL: URL?

    public private(set) var mapView: MapView!

    override open func loadView() {
        self.view = mapView
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
        Initializes the `MapViewController` with a frame and accessToken

        - Parameters:
            - frame: The frame that the mapView should fill
            - accessToken: The Mapbox access token to be used to authenticate requests
            - baseURL: The base URL to a custom API endpoint. Default value is `nil`
     */
    public init(with frame: CGRect, accessToken: String, styleURL: URL? = StyleURL.outdoors.url, baseURL: URL? = nil) {
        self.frame = frame
        self.accessToken = accessToken
        self.baseURL = baseURL
        //self.eventsManager = EventsManager(accessToken: accessToken)
        //self.mapView = MapView(with: frame, accessToken: accessToken, baseURL: baseURL, styleURL: styleURL)
        let options = ResourceOptions(accessToken: "<#token#>")
        self.mapView = MapView(with: frame, resourceOptions: options)

        super.init(nibName: nil, bundle: nil)
        self.setupManagers()
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        eventsManager.push(event: .memoryWarning)
    }

    /// Configures/Initializes the map with `mapOptions`
    internal func setupManagers() {

        // Initialize/configure the map if needed
        setupMapView()

        // Initialize/Configure camera manager first since Gestures needs it as dependency
        setupCamera(for: mapView, options: mapOptions.camera)

        // Initialize/Configure style manager
        setupStyle(with: mapView.__map)

        // Initialize/Configure gesture manager
        setupGestures(with: mapView, options: mapOptions.gestures, cameraManager: cameraManager)

        // Initialize/Configure ornaments manager
        setupOrnaments(with: mapView, options: mapOptions.ornaments)

        // Initialize/Configure location manager
//        setupUserLocationManager(with: mapView, options: mapOptions.location)

        // Initialize/Configure annotations manager
//        setupAnnotationManager(with: mapView, and: style)
    }

    /// Updates the map with new configuration options. Causes underlying structures to reload configuration synchronously.
    /// - Parameter update: A closure that is fed the current map options and manipulates it in some way.
    public func update(with updateMapOptions: (inout MapOptions) -> Void) {
        updateMapOptions(&self.mapOptions) // This mutates the map options

        // Update the managers in order
        updateMapView(with: mapOptions)
        updateCamera(with: mapOptions.camera)
        updateGestures(with: mapOptions.gestures)
        updateOrnaments(with: mapOptions.ornaments)
//        updateUserLocationManager(with: mapOptions.location)
    }

    internal func setupMapView() {
        // Configure telemetry handler
        mapView.eventsListener = eventsManager

        // Set prefetch zoom delta
        let defaultPrefetchZoomDelta: UInt8 = 4
        //mapView.__map.setPrefetchZoomDeltaForDelta(self.mapOptions.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
    }

    internal func updateMapView(with newOptions: MapOptions) {
        let defaultPrefetchZoomDelta: UInt8 = 4
//        mapView.__map.setPrefetchZoomDeltaForDelta(newOptions.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
    }

    internal func setupGestures(with view: UIView, options: GestureOptions, cameraManager: CameraManager) {
        gestureManager = GestureManager(for: view, options: options, cameraManager: cameraManager)
    }

    internal func updateGestures(with newOptions: GestureOptions) {
        gestureManager.updateGestureOptions(with: newOptions)
    }

    internal func setupCamera(for view: MapView, options: MapCameraOptions) {
        cameraManager = CameraManager(for: mapView, with: mapOptions.camera)
    }

    internal func updateCamera(with newOptions: MapCameraOptions) {
        cameraManager.mapCameraOptions = newOptions
    }

    internal func setupOrnaments(with view: OrnamentSupportableView, options: OrnamentOptions) {
        ornamentsManager = OrnamentsManager(for: view,
                                                 withConfig: options.makeConfig())
    }

    internal func updateOrnaments(with newOptions: OrnamentOptions) {
        ornamentsManager.ornamentConfig = mapOptions.ornaments.makeConfig()
    }

//    internal func setupUserLocationManager(with locationSupportableMapView: LocationSupportableMapView, options: LocationProviderOptions) {
//
//        var locationConsumers: [LocationConsumer] = []
//        if case let LocationTrackingMode.custom(customLocationConsumer) = mapOptions.location.locationTrackingMode {
//            locationConsumers = [customLocationConsumer]
//        } else {
//            locationConsumers = [cameraManager]
//        }
//
//        locationManager = LocationManager(locationProviderOptions: options,
//                                           locationConsumers: locationConsumers,
//                                           locationSupportableMapView: locationSupportableMapView)
//    }
//
//    internal func updateUserLocationManager(with options: LocationProviderOptions) {
//        locationManager.updateLocationOptions(with: mapOptions.location)
//    }
//
//    internal func setupAnnotationManager(with annotationSupportableMap: AnnotationSupportableMap, and style: Style) {
//        annotationManager = AnnotationManager(for: annotationSupportableMap, with: style)
//    }

    internal func setupStyle(with map: Map) {
        self.style = Style(with: mapView.__map)
    }
}
