#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@available(iOS 13.0, *)
public extension Map {
    /// Adds an action to perform when the map is loaded.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onMapLoaded(action: @escaping (MapLoaded) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onMapLoaded, perform: action))
    }

    /// Adds an action to perform when there is an error occurred while loading the map.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onMapLoadingError(action: @escaping (MapLoadingError) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onMapLoadingError, perform: action))
    }

    /// Adds an action to perform when the requested style is fully loaded.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onStyleLoaded(action: @escaping (StyleLoaded) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleLoaded, perform: action))
    }

    /// Adds an action to perform when the requested style data is loaded.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onStyleDataLoaded(action: @escaping (StyleDataLoaded) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleDataLoaded, perform: action))
    }

    /// Adds an action to perform when the camera is changed.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onCameraChanged(action: @escaping (CameraChanged) -> Void) -> Self {
        append(\.mapDependencies.cameraChangeHandlers, action)
    }

    /// Adds an action to perform when the map has entered the idle state.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onMapIdle(action: @escaping (MapIdle) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onMapIdle, perform: action))
    }

    /// Adds an action to perform when a source is added.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onSourceAdded(action: @escaping (SourceAdded) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onSourceAdded, perform: action))
    }

    /// Adds an action to perform when a source is removed.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onSourceRemoved(action: @escaping (SourceRemoved) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onSourceRemoved, perform: action))
    }

    /// Adds an action to perform when the source data is loaded.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onSourceDataLoaded(action: @escaping (SourceDataLoaded) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onSourceDataLoaded, perform: action))
    }

    /// Adds an action to perform when the style image is missing.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onStyleImageMissing(action: @escaping (StyleImageMissing) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleImageMissing, perform: action))
    }

    /// An image added to the style is no longer needed and can be removed using ``StyleManager/removeImage(withId:)``.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onStyleImageRemoveUnused(action: @escaping (StyleImageRemoveUnused) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onStyleImageRemoveUnused, perform: action))
    }

    /// Adds an action to perform when the map started rendering a frame.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onRenderFrameStarted(action: @escaping (RenderFrameStarted) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onRenderFrameStarted, perform: action))
    }

    /// Adds an action to perform when the map finished rendering a frame.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onRenderFrameFinished(action: @escaping (RenderFrameFinished) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onRenderFrameFinished, perform: action))
    }

    /// Adds an action to perform when a resource request is performed.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onResourceRequest(action: @escaping (ResourceRequest) -> Void) -> Self {
        append(\.mapDependencies.eventsSubscriptions, AnyEventSubscription(keyPath: \.onResourceRequest, perform: action))
    }
}
