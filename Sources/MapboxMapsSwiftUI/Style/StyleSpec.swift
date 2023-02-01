import MapboxMaps

class StyleNode {
    var children: [StyleNode] = []
    var component: StyleComponentProtocol!
    var previousComponent: StyleComponentProtocol!

    func rebuild() {
        component.buildTree(self)
    }

    func remove() {}
}

enum StyleComponentID {
    case positional
    case string(String)
}

protocol StyleComponentProtocol {
    @StyleBuilder var body: StyleContent { get }
}



extension StyleComponentProtocol {
    func buildTree(_ node: StyleNode) {

        let shouldRunBody = !equalToPrevious(node)

        guard shouldRunBody else {
            return
        }

        var children = body.components
        if children.cout < body.components
        

//        var seenSources = [String: Source]()
//        var seenLayers = [String: Layer]()

//        for child in children {
//            switch child {
//            case let layer as Layer:
//                seenLayers[id] = layer
//            default:
//            }
//            if let layer = child as? Layer {
//                seenLayers[layer.id] = layer
//            }
//        }
    }

    func equalToPrevious(_ node: StyleNode) -> Bool {
        guard let previous = node.previousComponent as? Self else { return false }
        let m1 = Mirror(reflecting: self)
        let m2 = Mirror(reflecting: previous)
        for pair in zip(m1.children, m2.children) {
            guard pair.0.label == pair.1.label else { return false }
            let p1 = pair.0.value
            let p2 = pair.1.value
            if !isEqual(p1, p2) { return false }
        }
        return true
    }
}


enum BuiltinStyleComponent: StyleComponentProtocol {
    case layer(Layer)
//    case source(Source)

    var body: StyleContent {
        return StyleContent(components: [self])
    }
}

struct StyleContent {
    var components: [BuiltinStyleComponent]
}

struct MyStyle: StyleComponentProtocol {
    var showGeoJson: Bool

    var body: StyleContent {
        SymbolLayer(id: "my-symbol-internal-layer")
        if(showGeoJson) {
            GeoJSONSource()
        }
    }
}

func test() {
    var rootNode = StyleNode()
    rootNode.component = MyStyle(showGeoJson: false)

}


struct InternalStyle: StyleComponentProtocol {
    var body: StyleContent {
        SymbolLayer(id: "my-symbol-internal-layer")
    }
}

@resultBuilder
struct StyleBuilder {
    static func buildOptional(_ component: StyleContent?) -> StyleContent {
        component ?? StyleContent(components: [])
    }

    static func buildBlock(_ contents: StyleContent...) -> StyleContent {
        return StyleContent(components: contents.map(\.components).reduce([], { $0 + $1 }))
    }

    static func buildArray(_ contents: [StyleContent]) -> StyleContent {
        return StyleContent(components: contents.map(\.components).reduce([], { $0 + $1 }))
    }

    static func buildExpression(_ componentProtocol: StyleComponentProtocol) -> StyleContent {
        componentProtocol.body
    }

    static func buildExpression(_ layer: Layer) -> StyleContent {
        StyleContent(components: [.layer(layer)])
    }

    static func buildExpression(_ source: Source) -> StyleContent {
        StyleContent(components: [.source(source)])
    }

    static func buildEither(first content: StyleContent) -> StyleContent {
        content
    }

    static func buildEither(second content: StyleContent) -> StyleContent {
        content
    }
}

