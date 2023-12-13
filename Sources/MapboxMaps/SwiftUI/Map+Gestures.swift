/// Creates handlers that will be called when the map gestures such as Pan, Pinch, Rotate, Zoom and others happen.
///
/// See ``GestureType`` for more information.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct MapGestureHandlers {
    /// Called when a gesture has begun.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var onBegin: ((GestureType) -> Void)?

    /// Called when a gesture has ended. The second argument informs whether there will be a deceleration animation. Use ``MapGestureHandlers/onAnimationEnd`` to handle the animation end.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var onEnd: ((GestureType, Bool) -> Void)?

    /// Called when deceleration animations triggered due to a gesture have ended.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var onAnimationEnd: ((GestureType) -> Void)?

    /// Creates gesture handlers.
    ///
    /// - Parameters:
    ///   - onBegin: Called when a gesture has begun.
    ///   - onEnd: Called when a gesture has ended.  The second argument informs whether there will be a deceleration animation. Use `onAnimationEnd` to handle the animation end.
    ///   - onAnimationEnd: Called when deceleration animation triggered due to a gesture has ended.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(
        onBegin: ((GestureType) -> Void)? = nil,
        onEnd: ((GestureType, Bool) -> Void)? = nil,
        onEndAnimation: ((GestureType) -> Void)? = nil) {
        self.onBegin = onBegin
        self.onEnd = onEnd
        self.onAnimationEnd = onEndAnimation
    }
}

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@available(iOS 13.0, *)
public extension Map {
    /// Adds a tap gesture handler to the map.
    ///
    /// The given action will be executed when other map gestures (such as quick zoom) failed, and no annotation or layer have handled the tap.
    ///
    /// Prefer to use this method instead of `onTapGesture`.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onMapTapGesture(perform action: @escaping (MapContentGestureContext) -> Void) -> Self {
        copyAssigned(self, \.mapDependencies.onMapTap, action)
    }

    /// Adds a long press gesture handler to the map.
    ///
    /// The given action will be executed when no annotation or layer have handled the long press.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onMapLongPressGesture(perform action: @escaping (MapContentGestureContext) -> Void) -> Self {
        copyAssigned(self, \.mapDependencies.onMapLongPress, action)
    }

    /// Adds a tap action to the specified layer.
    ///
    /// The handler will be called according to the order of visibility of layers at tap location.
    ///
    /// - Parameters:
    ///  - layerId: The identifier of the layers.
    ///  - action: The action to perform. Return `true` in action if tap has been handled, or `false` to let event propagate to the layers or annotations below.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onLayerTapGesture(_ layerId: String, perform action: @escaping MapLayerGestureHandler) -> Self {
        var updated = self
        updated.mapDependencies.onLayerTap[layerId] = action
        return updated
    }

    /// Adds a long-press action to the specified layer.
    ///
    /// The handler will be called according to the order of visibility of layers at tap location.
    ///
    /// - Parameters:
    ///  - layerId: The identifier of the layers.
    ///  - action: The action to perform. Return `true` in action if tap has been handled, or `false` to let event propagate to the layers or annotations below.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func onLayerLongPressGesture(_ layerId: String, perform action: @escaping MapLayerGestureHandler) -> Self {
        var updated = self
        updated.mapDependencies.onLayerLongPress[layerId] = action
        return updated
    }

    /// Configures gesture options.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func gestureOptions(_ options: GestureOptions) -> Self {
        copyAssigned(self, \.mapDependencies.gestureOptions, options)
    }

    /// Sets handlers for common map gestures such as Pan, Pinch, Rotate, Zoom and others.
    ///
    /// - Important: This is different to Map Content gestures, such as Tap and Long Press. To handle them use
    ///  ``Map/onMapTapGesture(perform:)`` and ``Map/onMapLongPressGesture(perform:)`` modifiers.
    ///
    /// - Parameters:
    ///   - handlers: Gesture handlers.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func gestureHandlers(_ handlers: MapGestureHandlers) -> Self {
        copyAssigned(self, \.mapDependencies.gestureHandlers, handlers)
    }
}
