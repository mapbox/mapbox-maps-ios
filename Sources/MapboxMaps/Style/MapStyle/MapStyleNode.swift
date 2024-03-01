@available(iOS 13.0, *)
final class MapStyleNode {
    private(set) var children: [MapStyleNode] = []
    private let context: MapStyleNodeContext

    fileprivate enum Content {
        // The content is the primitive mounted component
        case mounted(any MapStyleMountedComponent)

        // A user-defined implementation of MapStyleContent
        case custom(Any)
    }
    private var content: Content?

    init(context: MapStyleNodeContext) {
        self.context = context
    }

    func mount(_ component: MapStyleMountedComponent) {
        self.content = .mounted(component)
    }

    func withChildrenNodes(_ closure: (() -> MapStyleNode) -> Void) {
        var idx = 0

        let nextNodeGenerator: () -> MapStyleNode = {
            defer { idx += 1 }
            if idx >= self.children.endIndex {
                self.children.append(MapStyleNode(context: self.context))
            }
            return self.children[idx]

        }
        closure(nextNodeGenerator)

        removeChildren(from: idx)
    }

    /// Recursively removes all children starting from `from` index.
    func removeChildren(from: Int = 0) {
        let subrange = from..<children.endIndex
        for child in children[subrange] {
            if let mounted = child.content?.asMounted {
                wrapStyleDSLError { try mounted.unmount(with: context) }
            }
            child.removeChildren()
        }
        children.removeSubrange(subrange)
    }

    func updateMetadataRecursively() {
        content?.asMounted?.updateMetadata(with: context)
        for child in children {
            child.updateMetadataRecursively()
        }
    }

    func update(with newContent: some MapStyleContent) {
        if let primitive = newContent as? (any PrimitiveMapStyleContent) {
            update(with: primitive)
            return
        }

        let skipBodyCall: Bool
        if case let .custom(oldContent) = content {
            skipBodyCall = arePropertiesEqual(oldContent, newContent)
        } else {
            skipBodyCall = false
        }

        if skipBodyCall {
            // If the parameters of the custom content aren't changed, we skip the body execution
            // and updating process. But the metadata of the the mounted components needs to be updated.
            updateMetadataRecursively()
        } else {
            content = .custom(newContent)
            let body = newContent.body
            withChildrenNodes { nextNode in
                nextNode().update(with: body)
            }
        }
    }

    private func update(with primitive: any PrimitiveMapStyleContent) {
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
                Log.error(forMessage: "\(error)", category: "StyleDSL")
            }

        }

        wrapStyleDSLError { try oldMounted?.unmount(with: context) }
        removeChildren()

        wrapStyleDSLError { try mounted.mount(with: context) }
    }
}

func wrapStyleDSLError(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        Log.error(forMessage: "\(error)", category: "StyleDSL")
    }
}

@available(iOS 13.0, *)
extension MapStyleNode.Content {
    var asMounted: (any MapStyleMountedComponent)? {
        switch self {
        case .mounted(let m): m
        case .custom: nil
        }
    }
}
