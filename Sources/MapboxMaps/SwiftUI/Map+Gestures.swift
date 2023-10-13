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
}
