import UIKit
import SwiftUI
@_spi(Package) import MapboxMaps

protocol ViewAnnotationsManaging: AnyObject {
    func add(_ view: UIView, id: String?, options: ViewAnnotationOptions) throws
    func update(_ view: UIView, options: ViewAnnotationOptions) throws
    func remove(_ view: UIView)
}

extension ViewAnnotationManager: ViewAnnotationsManaging {}

@available(iOS 13.0, *)
class ViewAnnotationCoordinator {

    struct Deps {
        let viewAnnotationsManager: ViewAnnotationsManaging
        let addViewController: (UIViewController) -> Void
        let removeViewController: (UIViewController) -> Void
    }

    private var deps: Deps?
    private var annotations: [AnyHashable: DisplayedViewAnnotation] = [:]

    func setup(with deps: Deps) {
        guard self.deps == nil else { return }
        self.deps = deps
    }

    func updateAnnotations<Content: View>(to newAnnotations: [AnyHashable: ViewAnnotation<Content>]) {
        guard let deps else { return }

        let oldIds = Set(annotations.keys)
        let newIds = Set(newAnnotations.keys)

        let removalIds = oldIds.subtracting(newIds)
        let insertionIds = newIds.subtracting(oldIds)
        let updateIds = oldIds.intersection(newIds).filter {
            annotations[$0]?.config != newAnnotations[$0]?.config
        }

        removalIds.forEach { id in
            guard let displayedViewAnnotation = annotations.removeValue(forKey: id) else { return }
            displayedViewAnnotation.remove()
            deps.removeViewController(displayedViewAnnotation.content)
        }

        updateIds.forEach { id in
            guard var displayedAnnotation = annotations[id], let newAnnotationConfig = newAnnotations[id]?.config else { return }
            displayedAnnotation.update(with: newAnnotationConfig)
            annotations[id] = displayedAnnotation
        }

        insertionIds.forEach { id in
            guard let newAnnotation = newAnnotations[id] else { return }

            let annotationToDisplay = DisplayedViewAnnotation(from: newAnnotation, manager: deps.viewAnnotationsManager)
            annotationToDisplay.add()
            deps.addViewController(annotationToDisplay.content)
            annotations[id] = annotationToDisplay
        }
    }

    deinit {
        for (_, displayedViewAnnotation) in annotations {
            displayedViewAnnotation.remove()
        }
        annotations = [:]
    }
}

@available(iOS 13.0, *)
private struct DisplayedViewAnnotation {
    let content: UIViewController
    private(set) var config: ViewAnnotationConfig
    private let manager: ViewAnnotationsManaging

    private var annotationOptions: ViewAnnotationOptions {
        ViewAnnotationOptions(geometry: config.point, allowOverlap: config.allowOverlap, anchor: config.anchor, offsetX: config.offsetX, offsetY: config.offsetY)
    }

    init<Content: View>(from viewAnnotation: ViewAnnotation<Content>, manager: ViewAnnotationsManaging) {
        self.manager = manager
        self.config = viewAnnotation.config

        weak var contentView: UIView?
        self.content = UIHostingController(rootView: viewAnnotation.content().onChangeOfSize { [weak manager] size in
            guard let contentView, let manager else { return }
            wrapAssignError {
                try manager.update(contentView, options: ViewAnnotationOptions(width: size.width, height: size.height))
            }
        })
        content.view.backgroundColor = .clear
        contentView = content.view
    }

    func add() {
        wrapAssignError {
            try manager.add(content.view, id: UUID().uuidString, options: annotationOptions)
        }
    }

    func remove() {
        manager.remove(content.view)
    }

    mutating func update(with newAnnotationOptions: ViewAnnotationConfig) {
        config = newAnnotationOptions
        wrapAssignError {
            try manager.update(content.view, options: annotationOptions)
        }
    }
}
