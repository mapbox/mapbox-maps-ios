/// Creates handlers that will be called when the map gestures such as Pan, Pinch, Rotate, Zoom and others happen.
///
/// See ``GestureType`` for more information.
    @_documentation(visibility: public)
@_spi(Experimental)
public struct MapGestureHandlers {
    /// Called when a gesture has begun.
    @_documentation(visibility: public)
    public var onBegin: ((GestureType) -> Void)?

    /// Called when a gesture has ended. The second argument informs whether there will be a deceleration animation. Use ``MapGestureHandlers/onAnimationEnd`` to handle the animation end.
    @_documentation(visibility: public)
    public var onEnd: ((GestureType, Bool) -> Void)?

    /// Called when deceleration animations triggered due to a gesture have ended.
    @_documentation(visibility: public)
    public var onAnimationEnd: ((GestureType) -> Void)?

    /// Creates gesture handlers.
    ///
    /// - Parameters:
    ///   - onBegin: Called when a gesture has begun.
    ///   - onEnd: Called when a gesture has ended.  The second argument informs whether there will be a deceleration animation. Use `onAnimationEnd` to handle the animation end.
    ///   - onEndAnimation: Called when deceleration animation triggered due to a gesture has ended.
    @_documentation(visibility: public)
    public init(
        onBegin: ((GestureType) -> Void)? = nil,
        onEnd: ((GestureType, Bool) -> Void)? = nil,
        onEndAnimation: ((GestureType) -> Void)? = nil) {
        self.onBegin = onBegin
        self.onEnd = onEnd
        self.onAnimationEnd = onEndAnimation
    }
}

    @_documentation(visibility: public)
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
    @_documentation(visibility: public)
    func onMapTapGesture(perform action: @escaping (MapContentGestureContext) -> Void) -> Self {
        copyAssigned(self, \.mapDependencies.onMapTap, action)
    }

    /// Adds a long press gesture handler to the map.
    ///
    /// The given action will be executed when no annotation or layer have handled the long press.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
    @_documentation(visibility: public)
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
    @_documentation(visibility: public)
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
    @_documentation(visibility: public)
    func onLayerLongPressGesture(_ layerId: String, perform action: @escaping MapLayerGestureHandler) -> Self {
        var updated = self
        updated.mapDependencies.onLayerLongPress[layerId] = action
        return updated
    }

    /// Configures gesture options.
    @_documentation(visibility: public)
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
    @_documentation(visibility: public)
    func gestureHandlers(_ handlers: MapGestureHandlers) -> Self {
        copyAssigned(self, \.mapDependencies.gestureHandlers, handlers)
    }
}
