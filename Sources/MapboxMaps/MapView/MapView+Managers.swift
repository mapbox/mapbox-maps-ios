import UIKit

/// The `MapManager` is responsible for managing the `mapView`
/// and orchestrating between the different components of the Mapbox SDK
extension MapView {

    /// Configures/Initializes the map with `mapOptions`
    internal func setupManagers() {

        // Initialize/configure the map if needed
        setupMapView(with: mapOptions.render)

        // Initialize/Configure camera manager first since Gestures needs it as dependency
        setupCamera(for: self, options: mapOptions.camera)

        // Initialize/Configure style manager
        setupStyle(with: __map)

        // Initialize/Configure gesture manager
        setupGestures(with: self, options: mapOptions.gestures, cameraManager: cameraManager)

        // Initialize/Configure ornaments manager
        setupOrnaments(with: self, options: mapOptions.ornaments)

        // Initialize/Configure location manager
        setupUserLocationManager(with: self, options: mapOptions.location)

        // Initialize/Configure annotations manager
        setupAnnotationManager(with: self, and: style)
    }

    /// Updates the map with new configuration options. Causes underlying structures to reload configuration synchronously.
    /// - Parameter update: A closure that is fed the current map options and manipulates it in some way.
    public func update(with updateMapOptions: (inout MapOptions) -> Void) {
        updateMapOptions(&mapOptions) // This mutates the map options

        // Update the managers in order
        updateMapView(with: mapOptions.render)
        updateCamera(with: mapOptions.camera)
        updateGestures(with: mapOptions.gestures)
        updateOrnaments(with: mapOptions.ornaments)
        updateUserLocationManager(with: mapOptions.location)
    }

    internal func setupMapView(with renderOptions: RenderOptions) {

        // Set prefetch zoom delta
        let defaultPrefetchZoomDelta: UInt8 = 4
        try! __map.setPrefetchZoomDeltaForDelta(renderOptions.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
        metalView?.presentsWithTransaction = renderOptions.presentsWithTransaction
        preferredFPS = renderOptions.preferredFramesPerSecond
    }

    internal func updateMapView(with newOptions: RenderOptions) {
        // Set prefetch zoom delta
        let defaultPrefetchZoomDelta: UInt8 = 4
        try! __map.setPrefetchZoomDeltaForDelta(newOptions.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
        metalView?.presentsWithTransaction = newOptions.presentsWithTransaction
        preferredFPS = newOptions.preferredFramesPerSecond
    }

    internal func setupGestures(with view: UIView, options: GestureOptions, cameraManager: CameraManager) {
        gestureManager = GestureManager(for: view, options: options, cameraManager: cameraManager)
    }

    internal func updateGestures(with newOptions: GestureOptions) {
        gestureManager.updateGestureOptions(with: newOptions)
    }

    internal func setupCamera(for view: MapView, options: MapCameraOptions) {
        cameraManager = CameraManager(for: view, with: mapOptions.camera)
    }

    internal func updateCamera(with newOptions: MapCameraOptions) {
        cameraManager.updateMapCameraOptions(newOptions: newOptions)
    }

    internal func setupOrnaments(with view: OrnamentSupportableView, options: OrnamentOptions) {
        ornamentsManager = OrnamentsManager(for: view,
                                            withConfig: options.makeConfig())
    }

    internal func updateOrnaments(with newOptions: OrnamentOptions) {
        ornamentsManager.ornamentConfig = newOptions.makeConfig()
    }

    internal func setupUserLocationManager(with locationSupportableMapView: LocationSupportableMapView, options: LocationOptions) {

        locationManager = LocationManager(locationOptions: options,
                                          locationSupportableMapView: locationSupportableMapView)
    }

    internal func updateUserLocationManager(with options: LocationOptions) {
        locationManager.updateLocationOptions(with: mapOptions.location)
    }

    internal func setupAnnotationManager(with annotationSupportableMap: AnnotationSupportableMap, and style: Style) {
        annotationManager = AnnotationManager(for: annotationSupportableMap, with: style)
    }

    internal func setupStyle(with map: Map) {
        style = Style(with: __map)
    }
}
