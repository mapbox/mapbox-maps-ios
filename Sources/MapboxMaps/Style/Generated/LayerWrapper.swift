// This file is generated.
import Foundation

// Wraps a layer with its ``LayerPosition`` so it can be placed appropriately in the layer stack.
@_spi(Experimental)
@_documentation(visibility: public)
@available(iOS 13.0, *)
public struct LayerAtPosition<L>: MapStyleContent, PrimitiveMapContent where L: Layer, L: Equatable {
    // The layer wrapped in its ``LayerPosition``
    var layer: L
    var position: LayerPosition

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: layer, customPosition: position))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension FillLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension LineLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension SymbolLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension CircleLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension HeatmapLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension FillExtrusionLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension RasterLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension HillshadeLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension ModelLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension BackgroundLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension SkyLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension LocationIndicatorLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
