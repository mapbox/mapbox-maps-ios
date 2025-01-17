import os.log
final class MapContentNode: Identifiable {
    struct ID: Hashable {
        let anyId: AnyHashable
        let stringId: String
    }

    fileprivate enum Content {
        // The content is the primitive mounted component
        case mounted(any MapContentMountedComponent)

        // A user-defined implementation of MapContent
        case custom(Any)
    }

    let id: ID
    private var children: [MapContentNode] = []

    private let context: MapContentNodeContext
    private var content: Content?

    init(id: ID, context: MapContentNodeContext) {
        self.id = id
        self.context = context
    }

    var childrenIsEmpty: Bool { children.isEmpty }

    func withChildrenNodes(_ closure: (() -> MapContentNode) -> Void) {
        var idx = 0

        let nextNodeGenerator: () -> MapContentNode = {
            defer { idx += 1 }
            if idx >= self.children.endIndex {
                let uuidString = UUID().uuidString
                self.add(child: self.makeChild(id: ID(anyId: uuidString, stringId: uuidString)))
            }
            return self.children[idx]

        }
        closure(nextNodeGenerator)

        removeChildren(from: idx)
    }

    func updateMetadataRecursively() {
        content?.asMounted?.updateMetadata(with: context)
        for child in children {
            child.updateMetadataRecursively()
        }
    }

    func mount(_ component: MapContentMountedComponent) {
        content = .mounted(component)
    }

    func update(newContent: Any, traverseBody: (MapContentNode) -> Void) {
        let skipBodyCall: Bool
        if case let .custom(oldContent) = content {
            skipBodyCall = context.isEqualContent(oldContent, newContent)
        } else {
            skipBodyCall = false
        }

        if skipBodyCall {
            // If the parameters of the custom content aren't changed, we skip the body execution
            // and updating process. But the metadata of the the mounted components needs to be updated.
            updateMetadataRecursively()
        } else {
            content = .custom(newContent)
            withChildrenNodes { nextNode in
                traverseBody(nextNode())
            }
        }
    }

    func update(with primitive: some PrimitiveMapContent) {
        let oldMounted = content?.asMounted

        content = nil
        primitive.visit(self)

        // the visit function of the primitive may mount a component,
        // or expand the tree into additional nodes (e.g TupleMapContent)
        guard let mounted = content?.asMounted else {
            wrapStyleDSLError { try oldMounted?.unmount(with: context) }
            return
        }

        defer {
            mounted.updateMetadata(with: context)
        }

        if let oldMounted {
            do {
                if try mounted.tryUpdate(from: oldMounted, with: context) {
                    // if mounted components are the same, the update is enough.
                    return
                }
            } catch {
                Log.error("\(error)", category: "StyleDSL")
            }

        }

        wrapStyleDSLError { try oldMounted?.unmount(with: context) }
        removeChildren()

        wrapStyleDSLError { try mounted.mount(with: context) }
    }
}

extension MapContentNode {
    func updateChildren<Content: MapContent, Data: RandomAccessCollection, ID: Hashable>(with newChildren: ForEvery<Content, Data, ID>) {
        os_log(.debug, log: .contentDSL, "ForEvery update")

        let newIds: Set<AnyHashable> = newChildren.data.reduce(into: Set<AnyHashable>()) { result, next in
            _ = result.insert(next[keyPath: newChildren.id])
        }
        let oldIdsMaps = Dictionary(children.map { ($0.id.anyId, $0) }) { _, last in
            last
        }
        for (id, node) in oldIdsMaps where !newIds.contains(id) { node.remove() }

        children = []

        newChildren.forEach { id, content in
            let nextNode = oldIdsMaps[id] ?? makeChild(id: MapContentNode.ID(anyId: id, stringId: UUID().uuidString))
            add(child: nextNode)
            content.update(nextNode)
        }
    }

    private func remove() {
        if let mounted = content?.asMounted {
            wrapStyleDSLError { try mounted.unmount(with: context) }
        }
        removeChildren()
    }

    private func add(child: MapContentNode) {
        children.append(child)
    }

    private func makeChild(id: MapContentNode.ID) -> MapContentNode {
        MapContentNode(id: id, context: context)
    }

    /// Recursively removes all children starting from `from` index.
    private func removeChildren(from: Int = 0) {
        let subrange = from..<children.endIndex
        for child in children[subrange] { child.remove() }
        children.removeSubrange(subrange)
    }
}

func wrapStyleDSLError(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        Log.error("\(error)", category: "StyleDSL")
    }
}

private extension MapContentNode.Content {
    var asMounted: (any MapContentMountedComponent)? {
        if case let .mounted(mounted) = self {
            return mounted
        }
        return nil
    }

    var value: Any {
        switch self {
        case let .custom(any):
            return any
        case let .mounted(any):
            return any
        }
    }
}
