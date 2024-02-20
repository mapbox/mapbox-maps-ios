// This file is generated.
import Foundation

struct LayerWrapper: Equatable {
    // The layer ID
    let id: String

    // The layer that is wrapped
    let layer: ConcreteLayer

    // The position the layer should be placed in the layer stack
    var position: LayerPosition?

    init(_ layer: ConcreteLayer, position: LayerPosition? = nil) {
        self.layer = layer
        self.id = layer.asLayer.id
        self.position = position
    }
}

enum ConcreteLayer: Equatable {
    case fill(FillLayer)
    case line(LineLayer)
    case symbol(SymbolLayer)
    case circle(CircleLayer)
    case heatmap(HeatmapLayer)
    case fillExtrusion(FillExtrusionLayer)
    case raster(RasterLayer)
    case hillshade(HillshadeLayer)
    case model(ModelLayer)
    case background(BackgroundLayer)
    case sky(SkyLayer)
    case locationIndicator(LocationIndicatorLayer)

    var asLayer: Layer {
        switch(self) {
        case let .fill(layer): return layer
        case let .line(layer): return layer
        case let .symbol(layer): return layer
        case let .circle(layer): return layer
        case let .heatmap(layer): return layer
        case let .fillExtrusion(layer): return layer
        case let .raster(layer): return layer
        case let .hillshade(layer): return layer
        case let .model(layer): return layer
        case let .background(layer): return layer
        case let .sky(layer): return layer
        case let .locationIndicator(layer): return layer
        }
    }
}

// Wraps a layer with its ``LayerPosition`` so it can be placed appropriately in the layer stack.
@_spi(Experimental)
@_documentation(visibility: public)
public struct LayerAtPosition: MapContent, PrimitiveMapStyleContent {
    // The layer wrapped in its ``LayerPosition``
    var layer: LayerWrapper

    // Convenience getter/setter for the position of the layer
    var position: LayerPosition? {
        get {
            return layer.position
        }
        set(newPosition) {
            layer.position = newPosition
        }
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(layer)
    }
}

@_spi(Experimental)
extension FillLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .fill(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension LineLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .line(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension SymbolLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .symbol(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension CircleLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .circle(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension HeatmapLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .heatmap(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension FillExtrusionLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .fillExtrusion(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension RasterLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .raster(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension HillshadeLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .hillshade(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension ModelLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .model(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension BackgroundLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .background(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension SkyLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .sky(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

@_spi(Experimental)
extension LocationIndicatorLayer: PrimitiveMapStyleContent {
    private var concrete: ConcreteLayer { .locationIndicator(self) }

    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition {
        LayerAtPosition(layer: LayerWrapper(concrete, position: position))
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(LayerWrapper(concrete, position: nil))
    }
}

// End of generated file.