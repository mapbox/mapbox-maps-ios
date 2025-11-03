// This file is generated.
import Foundation
import os

/// The protocol encapsulates the update process of a specific source.
protocol UpdatableSource {
    func update(from old: Self, with manager: StyleSourceManagerProtocol) throws
}

@_spi(Experimental)
extension VectorSource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: VectorSource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
        var props = [String: Any]()
        encodeUpdate(\.url, old: old, new: self, container: &props, key: "url")
        encodeUpdate(\.tiles, old: old, new: self, container: &props, key: "tiles")
        encodeUpdate(\.minzoom, old: old, new: self, container: &props, key: "minzoom")
        encodeUpdate(\.maxzoom, old: old, new: self, container: &props, key: "maxzoom")
        encodeUpdate(\.volatile, old: old, new: self, container: &props, key: "volatile")
        if !props.isEmpty {
            try manager.setSourceProperties(for: id, properties: props)
        }
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

@_spi(Experimental)
extension RasterSource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: RasterSource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
        var props = [String: Any]()
        encodeUpdate(\.url, old: old, new: self, container: &props, key: "url")
        encodeUpdate(\.tiles, old: old, new: self, container: &props, key: "tiles")
        encodeUpdate(\.minzoom, old: old, new: self, container: &props, key: "minzoom")
        encodeUpdate(\.maxzoom, old: old, new: self, container: &props, key: "maxzoom")
        encodeUpdate(\.volatile, old: old, new: self, container: &props, key: "volatile")
        if !props.isEmpty {
            try manager.setSourceProperties(for: id, properties: props)
        }
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

@_spi(Experimental)
extension RasterDemSource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: RasterDemSource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
        var props = [String: Any]()
        encodeUpdate(\.url, old: old, new: self, container: &props, key: "url")
        encodeUpdate(\.tiles, old: old, new: self, container: &props, key: "tiles")
        encodeUpdate(\.minzoom, old: old, new: self, container: &props, key: "minzoom")
        encodeUpdate(\.maxzoom, old: old, new: self, container: &props, key: "maxzoom")
        encodeUpdate(\.volatile, old: old, new: self, container: &props, key: "volatile")
        if !props.isEmpty {
            try manager.setSourceProperties(for: id, properties: props)
        }
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

@_spi(Experimental)
extension RasterArraySource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: RasterArraySource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
        var props = [String: Any]()
        encodeUpdate(\.url, old: old, new: self, container: &props, key: "url")
        encodeUpdate(\.tiles, old: old, new: self, container: &props, key: "tiles")
        encodeUpdate(\.minzoom, old: old, new: self, container: &props, key: "minzoom")
        encodeUpdate(\.maxzoom, old: old, new: self, container: &props, key: "maxzoom")
        if !props.isEmpty {
            try manager.setSourceProperties(for: id, properties: props)
        }
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

@_spi(Experimental)
extension ImageSource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: ImageSource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
        var props = [String: Any]()
        encodeUpdate(\.url, old: old, new: self, container: &props, key: "url")
        encodeUpdate(\.coordinates, old: old, new: self, container: &props, key: "coordinates")
        if !props.isEmpty {
            try manager.setSourceProperties(for: id, properties: props)
        }
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

@_spi(Experimental)
extension GeoJSONSource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: GeoJSONSource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
        if !isEqual(by: \.data, lhs: self, rhs: old) {
            guard let data else { return }
            os_log(.debug, log: .contentDSL, "source update GeoJSON data %s", id)
            manager.updateGeoJSONSource(withId: id, data: data, dataId: nil)
        }
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

extension CustomGeometrySource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: CustomGeometrySource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

extension CustomRasterSource: UpdatableSource, MapStyleContent, PrimitiveMapContent {
    func update(from old: CustomRasterSource, with manager: StyleSourceManagerProtocol) throws {
        assert(old.id == id)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedSource(source: self))
    }
}

private func isEqual<T, U: Equatable>(by keyPath: KeyPath<T, U>, lhs: T, rhs: T) -> Bool {
    return lhs[keyPath: keyPath] == rhs[keyPath: keyPath]
}

private func encodeUpdate<T, U: Equatable>(_ keyPath: KeyPath<T, U>, old: T, new: T, container: inout [String: Any], key: String) {
    if !isEqual(by: keyPath, lhs: old, rhs: new) {
        container[key] = new[keyPath: keyPath]
    }
}

// End of generated file.
