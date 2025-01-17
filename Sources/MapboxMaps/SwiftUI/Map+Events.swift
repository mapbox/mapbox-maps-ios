public extension Map {
    /// Adds an action to perform when the map is loaded.
    func onMapLoaded(action: @escaping (MapLoaded) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onMapLoaded, perform: action))
    }

    /// Adds an action to perform when there is an error occurred while loading the map.
    func onMapLoadingError(action: @escaping (MapLoadingError) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onMapLoadingError, perform: action))
    }

    /// Adds an action to perform when the requested style is fully loaded.
    func onStyleLoaded(action: @escaping (StyleLoaded) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleLoaded, perform: action))
    }

    /// Adds an action to perform when the requested style data is loaded.
    func onStyleDataLoaded(action: @escaping (StyleDataLoaded) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleDataLoaded, perform: action))
    }

    /// Adds an action to perform when the camera is changed.
    ///
    /// - Important: This callback is called on every rendering frame. Don't use it to modify `@State` variables, it will lead to excessive `body` execution and higher CPU consumption.
    ///
    /// For example:
    /// ```swift
    /// struct BadExample: View {
    ///     @State var zoom: Double = 0
    ///     var body: some View {
    ///         Map {
    ///             if zoom > 5 {
    ///                 CircleAnnotation(centerCoordinate: coordinate)
    ///             }
    ///         }
    ///         .onCameraChanged {
    ///             // DON'T DO THIS
    ///             zoom = $0.cameraState.zoom
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Instead update the state only when the actual value is changed:
    /// ```swift
    /// struct GoodExample: View {
    ///     private class Model: ObservableObject {
    ///         @Published var showAnnotation = false
    ///         func setZoom(_ zoom: Double) {
    ///             var showAnnotation = zoom < 5
    ///             if showAnnotation != self.showAnnotation {
    ///                 // OK, the showAnnotation updates only when actual value changed.
    ///                 // The `body` will be executed once per update.
    ///                 self.showAnnotation = showAnnotation
    ///             }
    ///         }
    ///     }
    ///
    ///     @StateObject var model = Model()
    ///     var body: some View {
    ///         Map {
    ///             if model.showAnnotation {
    ///                 CircleAnnotation(centerCoordinate: coordinate)
    ///             }
    ///         }
    ///         .onCameraChanged {
    ///             model.setZoom($0.cameraState.zoom)
    ///         }
    ///     }
    /// }
    func onCameraChanged(action: @escaping (CameraChanged) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.cameraChangeHandlers, action)
    }

    /// Adds an action to perform when the map has entered the idle state.
    func onMapIdle(action: @escaping (MapIdle) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onMapIdle, perform: action))
    }

    /// Adds an action to perform when a source is added.
    func onSourceAdded(action: @escaping (SourceAdded) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onSourceAdded, perform: action))
    }

    /// Adds an action to perform when a source is removed.
    func onSourceRemoved(action: @escaping (SourceRemoved) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onSourceRemoved, perform: action))
    }

    /// Adds an action to perform when the source data is loaded.
    func onSourceDataLoaded(action: @escaping (SourceDataLoaded) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onSourceDataLoaded, perform: action))
    }

    /// Adds an action to perform when the style image is missing.
    func onStyleImageMissing(action: @escaping (StyleImageMissing) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleImageMissing, perform: action))
    }

    /// An image added to the style is no longer needed and can be removed using ``StyleManager/removeImage(withId:)``.
    func onStyleImageRemoveUnused(action: @escaping (StyleImageRemoveUnused) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleImageRemoveUnused, perform: action))
    }

    /// Adds an action to perform when the map started rendering a frame.
    ///
    /// - Important: This callback is called on every rendering frame, don't modify `@State` in it. Consult ``Map/onCameraChanged(action:)`` for more information.
    func onRenderFrameStarted(action: @escaping (RenderFrameStarted) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onRenderFrameStarted, perform: action))
    }

    /// Adds an action to perform when the map finished rendering a frame.
    ///
    /// - Important: This callback is called on every rendering frame, don't modify `@State` in it. Consult ``Map/onCameraChanged(action:)`` for more information.
    func onRenderFrameFinished(action: @escaping (RenderFrameFinished) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onRenderFrameFinished, perform: action))
    }

    /// Adds an action to perform when a resource request is performed.
    func onResourceRequest(action: @escaping (ResourceRequest) -> Void) -> Self {
        copyAppended(self, \.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onResourceRequest, perform: action))
    }
}
