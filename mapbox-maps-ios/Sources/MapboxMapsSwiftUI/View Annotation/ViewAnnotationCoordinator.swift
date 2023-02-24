import SwiftUI
@_spi(Package) import MapboxMaps

typealias AnnotationLayouts = [AnyHashable: CGRect]

@available(iOS 13.0, *)
class ViewAnnotationCoordinator {
    struct Deps {
        var map: MapboxMapProtocol
        var onLayoutUpdate: (AnnotationLayouts) -> Void
    }

    private var deps: Deps?
    var uuids = BidirectionalMap<AnyHashable, String>()
    var annotations: [AnyHashable: ViewAnnotationOptions] = [:] {
        didSet {
            updateAnnotations(from: oldValue)
        }
    }

    func setup(with deps: Deps) {
        guard self.deps == nil else { return }
        self.deps = deps
        deps.map.setViewAnnotationPositionsUpdateCallback { [weak self] in self?.updatePositions($0) }

    }

    private func updateAnnotations(from: [AnyHashable: ViewAnnotationOptions]) {
        guard let map = deps?.map else { return }

        let oldIds = Set(from.keys)
        let newIds = Set(annotations.keys)

        let removalIds = oldIds.subtracting(newIds)
        let insertionIds = newIds.subtracting(oldIds)
        let updateIds = oldIds.intersection(newIds).filter {
            annotations[$0] != from[$0]
        }

        removalIds.forEach { id in
            guard let uuid = uuids[id] else { return }
            wrapAssignError {
                try map.removeViewAnnotation(withId: uuid)
            }
        }

        updateIds.forEach { id in
            guard let uuid = uuids[id], let options = annotations[id] else { return }
            wrapAssignError {
                try map.updateViewAnnotation(withId: uuid, options: options)
            }
        }

        insertionIds.forEach { id in
            guard let options = annotations[id] else { return }
            let uuid = UUID().uuidString
            wrapAssignError {
                try map.addViewAnnotation(withId: uuid, options: options)
                uuids[id] = uuid
            }
        }
    }

    private func updatePositions(_ positions: [ViewAnnotationPositionDescriptor]) {
        let layouts = positions.reduce(into: AnnotationLayouts()) { res, pos in
            guard let id = uuids[pos.identifier] else { return }
            res[id] = pos.frame
        }
        if !layouts.isEmpty {
            deps?.onLayoutUpdate(layouts)
        }
    }

    deinit {
        deps?.map.setViewAnnotationPositionsUpdateCallback(nil)
    }
}
