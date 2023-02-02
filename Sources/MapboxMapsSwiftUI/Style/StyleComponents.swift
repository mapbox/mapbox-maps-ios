public protocol StyleComponent {
    associatedtype Body: StyleComponent
    @StyleBuilder var body: Body { get }
}

extension StyleComponent {
    func visit(_ node: Node) {
        if let builtin = self as? BuiltinComponent {
            node.component = builtin
            builtin._visit(node)
            return
        }

        let runBody = node.dirty || !self.equalToPrevious(node)
        if !runBody {
            for child in node.children {
                child.rebuild()
            }
            return
        }

        node.component = AnyBuiltinComponent(self)
        let b = body

        if(node.children.isEmpty) {
            node.children = [Node(style: node.style)]
        } // TODO remove left?
        b.visit(node.children[0])

        node.previousComponent = self
        node.dirty = false
    }

        func equalToPrevious(_ node: Node) -> Bool {
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

extension Never: StyleComponent {
    public var body: Never {
        return fatalError("never called")
    }
}

class StyleState {
    typealias LayerFactory = () -> Layer
    typealias SourceFactory = () -> Source
    typealias ImageFactory = () -> ImageComponent

    struct InternalStyleState {
        var layers = [String: LayerFactory]()
        var sources = [String: SourceFactory]()
        var images = [String: ImageFactory]()
        var projection: StyleProjection?
        var terrain: Terrain?
        var atmosphere: Atmosphere?

    }
    var s = InternalStyleState()

    func take() -> InternalStyleState {
        let s = s
        self.s = InternalStyleState()
        return s
    }
}

public class Node {
    let style: StyleState
    init(style: StyleState) {
        self.style = style
    }
    var children: [Node] = []
    var component: BuiltinComponent!
    var previousComponent: Any?
    var dirty = true

    func rebuild() {
        component._visit(self)
    }
}

public protocol BuiltinComponent {
    func _visit(_ node: Node)
}

struct AnyBuiltinComponent: BuiltinComponent {
    private let v: (Node) -> Void

    init<T: StyleComponent>(_ component: T) {
        v = component.visit(_:)
    }

    func _visit(_ node: Node) {
        v(node)
    }
}

extension BuiltinComponent {
    public var body: Never {
        fatalError("never called")
    }
}

public struct TupleComponent: BuiltinComponent, StyleComponent {
    var children: [AnyBuiltinComponent]
    init(_ children: [AnyBuiltinComponent]) {
        self.children = children
    }

    public func _visit(_ node: Node) {
        for idx in children.indices {
            if node.children.count <= idx {
                node.children.append(Node(style: node.style))
            }
            let child = children[idx]
            child._visit(node.children[idx])
        }
    }
}

public struct OptionalComponent<T: StyleComponent>: BuiltinComponent, StyleComponent {
    init(_ component: T?) {
        subject = component.map(AnyBuiltinComponent.init(_:))
    }
    var subject: AnyBuiltinComponent?
    public func _visit(_ node: Node) {
        subject?._visit(node)
    }
}

public struct EmptyComponent: BuiltinComponent, StyleComponent {
    public init() {}
    public func _visit(_ node: Node) {
    }
}


public struct ImageComponent: BuiltinComponent, StyleComponent {
    public var id: String
    public var uiImage: UIImage
    public var sdf: Bool
    public var contentInsets: UIEdgeInsets

    public init(id: String, uiImage: UIImage, sdf: Bool = false, contentInsets: UIEdgeInsets = .zero) {
        self.id = id
        self.uiImage = uiImage
        self.sdf = sdf
        self.contentInsets = contentInsets
    }

    public func _visit(_ node: Node) {
        node.style.s.images[id] = { self }
    }
}

@resultBuilder
public struct StyleBuilder {
    public static func buildBlock() -> EmptyComponent { EmptyComponent() }
    public static func buildBlock<T: StyleComponent>(_ content: T) -> T {
        content
    }
    public static func buildBlock<T1: StyleComponent, T2: StyleComponent>(_ c1: T1, _ c2: T2) -> TupleComponent {
        TupleComponent([AnyBuiltinComponent(c1), AnyBuiltinComponent(c2)])
    }
    public static func buildBlock<T1: StyleComponent, T2: StyleComponent, T3: StyleComponent>(_ c1: T1, _ c2: T2, _ c3: T3) -> TupleComponent {
        TupleComponent([AnyBuiltinComponent(c1), AnyBuiltinComponent(c2), AnyBuiltinComponent(c3)])
    }

    public static func buildOptional<T: StyleComponent>(_ component: T?) -> OptionalComponent<T> {
        OptionalComponent(component)
    }

    public static func buildIf<T: StyleComponent>(_ component: T) -> T? {
        component
    }
}

extension SymbolLayer: StyleComponent, BuiltinComponent {
    public func _visit(_ node: Node) {
        node.style.s.layers[id] = { self }
    }
}
extension CircleLayer: StyleComponent, BuiltinComponent {
    public func _visit(_ node: Node) {
        node.style.s.layers[id] = { self }
    }
}

public struct SourceWithId<T: Source> {
    var id: String
    var source: T
}

extension SourceWithId: StyleComponent, BuiltinComponent {
    public func _visit(_ node: Node) {
        node.style.s.sources[id] = { self.source }
    }
}

extension StyleProjection: StyleComponent, BuiltinComponent {
    public func _visit(_ node: Node) {
        node.style.s.projection = self
    }
}

extension Terrain: StyleComponent, BuiltinComponent {
    public func _visit(_ node: Node) {
        node.style.s.terrain = self
    }
}

extension Atmosphere: StyleComponent, BuiltinComponent {
    public func _visit(_ node: Node) {
        node.style.s.atmosphere = self
    }
}

extension StyleComponent {
    func debug(_ perform: () -> Void) -> Self {
        perform()
        return self
    }
}

extension Source {
    public func id(_ id: String) -> SourceWithId<Self> {
        SourceWithId(id: id, source: self)
    }
}

extension GeoJSONSource {
    func update(from other: Self, id: String, in applier: StyleApplier) throws {
        guard let json = data?.geoJSONObject, let otherJson = other.data?.geoJSONObject else {
            return
        }

        if json != otherJson {
            try applier.updateGeoJSONSource(withId: id, geoJSON: json)
        }
    }
}

func applyDiff<T>(from: [String: () -> T], to: [String: () -> T], insert: (String, T) -> Void, remove: (String) -> Void, update: ((String, T, T) -> Void)? = nil) {
    let fromKeys = Set(from.keys)
    let toKeys = Set(to.keys)
    let toInsert = toKeys.subtracting(fromKeys)
    let toRemove = fromKeys.subtracting(toKeys)

    for ins in toInsert {
        insert(ins, to[ins]!())
    }
    for removeId in toRemove {
        remove(removeId)
    }

    if let update = update {
        let toUpdate = fromKeys.intersection(toKeys)
        for updId in toUpdate {
            update(updId, from[updId]!(), to[updId]!())
        }
    }
}

func applyProperty<T, U: Equatable>(_ keyPath: KeyPath<T, Optional<U>>, old: T, new: T, insert: (U) throws -> Void, remove: () throws -> Void) rethrows {
    if let newVal = new[keyPath: keyPath] {
        if let oldVal = old[keyPath: keyPath] {
            if oldVal != newVal {
                try insert(newVal)
            }
        } else {
            try insert(newVal)
        }
    } else {
        if old[keyPath: keyPath] != nil {
            try remove()
        }
    }
}


extension StyleState.InternalStyleState {
    func applyDiff(to new: Self, styleApplier: StyleApplier) {
        MapboxMapsSwiftUI.applyDiff(from: images, to: new.images, insert: {
            try! styleApplier.addImage($1.uiImage, id: $1.id, sdf: $1.sdf, contentInsets: $1.contentInsets)
        }, remove: {
            try! styleApplier.removeImage(withId: $0)
        })

        MapboxMapsSwiftUI.applyDiff(from: layers, to: new.layers, insert: {
            try! styleApplier.addLayer($1)
        }, remove: {
            try! styleApplier.removeLayer(withId: $0)
        })

        MapboxMapsSwiftUI.applyDiff(from: sources, to: new.sources, insert: {
            try! styleApplier.addSource($1, id: $0)
        }, remove: {
            try! styleApplier.removeSource(withId: $0)
        }, update: { id, from, to in
            if let from = from as? GeoJSONSource, let to = to as? GeoJSONSource {
                // TODO: terrible cast, should decide if need redraw during body execution.
                try! to.update(from: from, id: id, in: styleApplier)
            }
        })

        try! applyProperty(\.terrain, old: self, new: new, insert: styleApplier.setTerrain(_:), remove: styleApplier.removeTerrain)

        try! applyProperty(\.atmosphere, old: self, new: new, insert: styleApplier.setAtmosphere(_:), remove: styleApplier.removeAtmosphere)

        try! applyProperty(\.projection, old: self, new: new, insert: styleApplier.setProjection(_:), remove: { try styleApplier.setProjection(StyleProjection(name: .mercator)) })

    }
}


extension GeoJSONSourceData {
    var geoJSONObject: GeoJSONObject? {
        switch self {
        case let .featureCollection(coll):
            return coll.geoJSONObject
        case let .feature(feature):
            return feature.geoJSONObject
        case let .geometry(geom):
            return geom.geoJSONObject
        case .url, .empty:
            return nil

        }
    }
}
