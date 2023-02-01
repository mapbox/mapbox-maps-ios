import MapboxMaps

@available(iOS 13.0, *)
class StyleTree {
    init(layers: [Layer], sources: [String: Source]) {
        self.layers = layers
        self.sources = sources
    }
    var layers: [Layer]
    var sources: [String: Source]
}

@available(iOS 13.0, *)
protocol StyleApplier {
    func addLayer(_ layer: Layer) throws
    func removeLayer(withId id: String) throws
    func addSource(_ source: Source, id: String) throws
    func removeSource(withId id: String) throws
}

@available(iOS 13.0, *)
func applyStyle(_ oldTree: StyleTree, newTree: StyleTree, style: StyleApplier) throws {
    let diff = newTree.layers.difference(from: oldTree.layers) { $0.id ==  $1.id }
    for change in diff {
        switch change {
        case let .remove(_, layer, _):
            try style.removeLayer(withId: layer.id)
        case let .insert(_, element: layer, _):
            try style.addLayer(layer)
        }
    }

    let newKeys = Set(newTree.sources.keys)
    let oldKeys = Set(oldTree.sources.keys)
    let removals = oldKeys.subtracting(newKeys)
    let inserts = newKeys.subtracting(oldKeys)
//    let updates = oldKeys.intersection(newKeys)

    for removal in removals {
        try style.removeSource(withId: removal)
    }
    for insert in inserts {
        try style.addSource(newTree.sources[insert]!, id: insert)
    }
}

//@available(iOS 13.0, *)
//extension StyleTree {
//    convenience init(component: StyleComponentProtocol) {
//        
//    }
//
//}
