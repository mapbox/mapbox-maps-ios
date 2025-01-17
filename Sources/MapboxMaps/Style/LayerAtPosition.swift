// Wraps a layer with its ``LayerPosition`` so it can be placed appropriately in the layer stack.
public struct LayerAtPosition<L>: MapStyleContent, PrimitiveMapContent where L: Layer, L: Equatable {
    // The layer wrapped in its ``LayerPosition``
    var layer: L
    var position: LayerPosition

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: layer, customPosition: position))
    }
}

extension SlotLayer {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }
}
