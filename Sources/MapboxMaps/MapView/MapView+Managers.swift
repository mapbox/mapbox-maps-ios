import UIKit

/// The `MapManager` is responsible for managing the `mapView`
/// and orchestrating between the different components of the Mapbox SDK
extension MapView {

    /// Configures/Initializes the map with `mapConfig`
    internal func setupManagers() {

        // Initialize/configure the map if needed
        setupMapView(with: mapConfig.render)

        // Initialize/Configure camera manager first since Gestures needs it as dependency
        setupCamera(for: self, options: mapConfig.camera)

        // Initialize/Configure style manager
        setupStyle(with: mapboxMap.__map)

        // Initialize/Configure gesture manager
        setupGestures(with: self, options: mapConfig.gestures, cameraManager: camera)

        // Initialize/Configure ornaments manager
        setupOrnaments(with: self)

        // Initialize/Configure location manager
        setupUserLocationManager(with: self, options: mapConfig.location)

        // Initialize/Configure annotations manager
        setupAnnotationManager(with: self, mapEventsObservable: mapboxMap, style: style, options: mapConfig.annotations)
    }

    /// Updates the map with new configuration options. Causes underlying structures to reload configuration synchronously.
    /// - Parameter update: A closure that is fed the current map options and manipulates it in some way.
    public func update(with updateMapConfig: (inout MapConfig) -> Void) {
        updateMapConfig(&mapConfig) // This mutates the map options

        // Update the managers in order
        updateMapView(with: mapConfig.render)
        updateCamera(with: mapConfig.camera)
        updateGestures(with: mapConfig.gestures)
        updateUserLocationManager(with: mapConfig.location)
        updateAnnotationManager(with: mapConfig.annotations)
    }

    internal func setupMapView(with renderOptions: RenderOptions) {

        // Set prefetch zoom delta
        let defaultPrefetchZoomDelta: UInt8 = 4
        self.mapboxMap.__map.setPrefetchZoomDeltaForDelta(renderOptions.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
        self.preferredFPS = renderOptions.preferredFramesPerSecond
        metalView?.presentsWithTransaction = renderOptions.presentsWithTransaction
    }

    internal func updateMapView(with newOptions: RenderOptions) {
        // Set prefetch zoom delta
        let defaultPrefetchZoomDelta: UInt8 = 4
        self.mapboxMap.__map.setPrefetchZoomDeltaForDelta(newOptions.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
        self.preferredFPS = newOptions.preferredFramesPerSecond
        metalView?.presentsWithTransaction = newOptions.presentsWithTransaction
    }

    internal func setupGestures(with view: UIView, options: GestureOptions, cameraManager: CameraAnimationsManager) {
        gestures = GestureManager(for: view, options: options, cameraManager: cameraManager)
    }

    internal func updateGestures(with newOptions: GestureOptions) {
        gestures.updateGestureOptions(with: newOptions)
    }

    internal func setupCamera(for view: MapView, options: MapCameraOptions) {
        camera = CameraAnimationsManager(for: view, with: mapConfig.camera)
    }

    internal func updateCamera(with newOptions: MapCameraOptions) {
        camera.updateMapCameraOptions(newOptions: newOptions)
    }

    internal func setupOrnaments(with view: OrnamentSupportableView) {
        ornaments = OrnamentsManager(view: view, options: OrnamentOptions())
    }

    internal func setupUserLocationManager(with locationSupportableMapView: LocationSupportableMapView, options: LocationOptions) {

        location = LocationManager(locationOptions: options,
                                          locationSupportableMapView: locationSupportableMapView)
    }

    internal func updateUserLocationManager(with options: LocationOptions) {
        location.updateLocationOptions(with: mapConfig.location)
    }

    internal func setupAnnotationManager(with annotationSupportableMap: AnnotationSupportableMap, mapEventsObservable: MapEventsObservable, style: Style, options: AnnotationOptions) {
        annotations = AnnotationManager(for: annotationSupportableMap, mapEventsObservable: mapEventsObservable, with: style, options: options)
    }

    internal func updateAnnotationManager(with newOptions: AnnotationOptions) {
        annotations.updateAnnotationOptions(with: newOptions)
    }

    internal func setupStyle(with map: Map) {
        style = Style(with: map)
    }
}
