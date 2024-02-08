// This file is generated.
import Foundation

enum LayerWrapper: Equatable {
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

@_spi(Experimental)
extension FillLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.fill(self))
    }
}

@_spi(Experimental)
extension LineLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.line(self))
    }
}

@_spi(Experimental)
extension SymbolLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.symbol(self))
    }
}

@_spi(Experimental)
extension CircleLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.circle(self))
    }
}

@_spi(Experimental)
extension HeatmapLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.heatmap(self))
    }
}

@_spi(Experimental)
extension FillExtrusionLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.fillExtrusion(self))
    }
}

@_spi(Experimental)
extension RasterLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.raster(self))
    }
}

@_spi(Experimental)
extension HillshadeLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.hillshade(self))
    }
}

@_spi(Experimental)
extension ModelLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.model(self))
    }
}

@_spi(Experimental)
extension BackgroundLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.background(self))
    }
}

@_spi(Experimental)
extension SkyLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.sky(self))
    }
}

@_spi(Experimental)
extension LocationIndicatorLayer: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.layers.append(.locationIndicator(self))
    }
}

// End of generated file.