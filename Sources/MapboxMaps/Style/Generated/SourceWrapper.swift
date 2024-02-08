// This file is generated.
import Foundation

enum SourceWrapper: Equatable  {
    case vector(VectorSource)
    case raster(RasterSource)
    case rasterDem(RasterDemSource)
    case rasterArray(RasterArraySource)
    case image(ImageSource)
    case geoJson(GeoJSONSource)

    var asSource: Source {
        switch(self) {
        case let .vector(source): return source
        case let .raster(source): return source
        case let .rasterDem(source): return source
        case let .rasterArray(source): return source
        case let .image(source): return source
        case let .geoJson(source): return source
        }
    }
}

extension SourceWrapper {
    static func update(old: SourceWrapper, new: SourceWrapper, styleSourceManager: StyleSourceManagerProtocol) throws {
        assert(old.asSource.id == new.asSource.id)

        var props = [String: Any]()

        switch (old, new) {
        case let (.vector(old), .vector(new)):
            encodeUpdate(\.url, old: old, new: new, container: &props, key: "url")
            encodeUpdate(\.tiles, old: old, new: new, container: &props, key: "tiles")
            encodeUpdate(\.minzoom, old: old, new: new, container: &props, key: "minzoom")
            encodeUpdate(\.maxzoom, old: old, new: new, container: &props, key: "maxzoom")
            encodeUpdate(\.volatile, old: old, new: new, container: &props, key: "volatile")
        case let (.raster(old), .raster(new)):
            encodeUpdate(\.url, old: old, new: new, container: &props, key: "url")
            encodeUpdate(\.tiles, old: old, new: new, container: &props, key: "tiles")
            encodeUpdate(\.minzoom, old: old, new: new, container: &props, key: "minzoom")
            encodeUpdate(\.maxzoom, old: old, new: new, container: &props, key: "maxzoom")
            encodeUpdate(\.volatile, old: old, new: new, container: &props, key: "volatile")
        case let (.rasterDem(old), .rasterDem(new)):
            encodeUpdate(\.url, old: old, new: new, container: &props, key: "url")
            encodeUpdate(\.tiles, old: old, new: new, container: &props, key: "tiles")
            encodeUpdate(\.minzoom, old: old, new: new, container: &props, key: "minzoom")
            encodeUpdate(\.maxzoom, old: old, new: new, container: &props, key: "maxzoom")
            encodeUpdate(\.volatile, old: old, new: new, container: &props, key: "volatile")
        case let (.rasterArray(old), .rasterArray(new)):
            encodeUpdate(\.url, old: old, new: new, container: &props, key: "url")
            encodeUpdate(\.tiles, old: old, new: new, container: &props, key: "tiles")
            encodeUpdate(\.minzoom, old: old, new: new, container: &props, key: "minzoom")
            encodeUpdate(\.maxzoom, old: old, new: new, container: &props, key: "maxzoom")
        case let (.image(old), .image(new)):
            encodeUpdate(\.url, old: old, new: new, container: &props, key: "url")
            encodeUpdate(\.coordinates, old: old, new: new, container: &props, key: "coordinates")
        case let (.geoJson(old), .geoJson(new)):
            if !isEqual(by: \.data, lhs: old, rhs: new) {
                guard let data = new.data else {
                    return
                }
                styleSourceManager.updateGeoJSONSource(withId: new.id, data: data, dataId: nil)
            }
        default:
            assertionFailure("Can't change type of source: \(old.asSource.type) to \(new.asSource.type)")
            return
        }

        if !props.isEmpty {
            try styleSourceManager.setSourceProperties(for: new.asSource.id, properties: props)
        }
    }

    private static func encodeUpdate<T, U: Equatable>(_ keyPath: KeyPath<T, U>, old: T, new: T, container: inout [String: Any], key: String) {
        if !isEqual(by: keyPath, lhs: old, rhs: new) {
            container[key] = new[keyPath: keyPath]
        }
    }
}

@_spi(Experimental)
extension VectorSource: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.sources[id] = .vector(self)
    }
}

@_spi(Experimental)
extension RasterSource: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.sources[id] = .raster(self)
    }
}

@_spi(Experimental)
extension RasterDemSource: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.sources[id] = .rasterDem(self)
    }
}

@_spi(Experimental)
extension RasterArraySource: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.sources[id] = .rasterArray(self)
    }
}

@_spi(Experimental)
extension ImageSource: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.sources[id] = .image(self)
    }
}

@_spi(Experimental)
extension GeoJSONSource: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.sources[id] = .geoJson(self)
    }
}

func isEqual<T, U: Equatable>(by keyPath: KeyPath<T, U>, lhs: T, rhs: T) -> Bool {
    return lhs[keyPath: keyPath] == rhs[keyPath: keyPath]
}

// End of generated file.