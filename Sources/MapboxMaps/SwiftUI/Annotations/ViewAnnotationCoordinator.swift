import UIKit
import SwiftUI

protocol ViewAnnotationsManaging: AnyObject {
    func add(_ annotation: ViewAnnotation)
}

extension ViewAnnotationManager: ViewAnnotationsManaging {}

@available(iOS 13.0, *)
final class ViewAnnotationCoordinator {
    typealias ViewControllerHandler = (UIViewController) -> Void

    let viewAnnotationsManager: ViewAnnotationsManaging
    let addViewController: ViewControllerHandler
    let removeViewController: ViewControllerHandler

    private var annotations: [AnyHashable: DisplayedViewAnnotation] = [:]

    init(viewAnnotationsManager: ViewAnnotationsManaging,
         addViewController: @escaping ViewControllerHandler,
         removeViewController: @escaping ViewControllerHandler) {
        self.viewAnnotationsManager = viewAnnotationsManager
        self.addViewController = addViewController
        self.removeViewController = removeViewController
    }

    func updateAnnotations(to newAnnotations: [AnyHashable: MapViewAnnotation]) {

        let oldIds = Set(annotations.keys)
        let newIds = Set(newAnnotations.keys)

        let removalIds = oldIds.subtracting(newIds)
        let insertionIds = newIds.subtracting(oldIds)
        let updateIds = oldIds.intersection(newIds)

        removalIds.forEach { id in
            guard let displayedViewAnnotation = annotations.removeValue(forKey: id) else { return }
            displayedViewAnnotation.annotation.remove()
            removeViewController(displayedViewAnnotation.viewController)
        }

        updateIds.forEach { id in
            guard let newAnnotation = newAnnotations[id] else { return }
            annotations[id]?.update(with: newAnnotation)
        }

        insertionIds.forEach { id in
            guard let newAnnotation = newAnnotations[id] else { return }

            let annotationToDisplay = DisplayedViewAnnotation(from: newAnnotation)
            viewAnnotationsManager.add(annotationToDisplay.annotation)
            addViewController(annotationToDisplay.viewController)
            annotations[id] = annotationToDisplay
        }
    }

    deinit {
        for annotation in annotations.values {
            annotation.annotation.remove()
        }
        annotations = [:]
    }
}

@available(iOS 13.0, *)
private struct DisplayedViewAnnotation {
    let viewController: UIViewController
    let annotation: ViewAnnotation
    let _update: (AnyView) -> Void

    init(from viewAnnotation: MapViewAnnotation) {
        weak var annotation: ViewAnnotation?

        let wrapContent = { (content: AnyView) in
            content.fixedSize().onChangeOfSize { _ in
                annotation?.setNeedsUpdateSize()
            }
        }

        let vc = UIHostingController(rootView: wrapContent(viewAnnotation.content))
        self.viewController = vc
        self._update = { content in
            vc.rootView = wrapContent(content)
        }

        self.annotation = ViewAnnotation(annotatedFeature: viewAnnotation.annotatedFeature, view: vc.view)
        annotation = self.annotation
        update(with: viewAnnotation)

        vc.view.backgroundColor = .clear
    }

    func update(with viewAnnotation: MapViewAnnotation) {
        annotation.annotatedFeature = viewAnnotation.annotatedFeature
        annotation.allowOverlap = viewAnnotation.allowOverlap
        annotation.allowOverlapWithPuck = viewAnnotation.allowOverlapWithPuck
        annotation.ignoreCameraPadding = viewAnnotation.ignoreCameraPadding
        annotation.visible = viewAnnotation.visible
        annotation.selected = viewAnnotation.selected
        annotation.variableAnchors = viewAnnotation.variableAnchors
        annotation.onAnchorChanged = viewAnnotation.actions.anchor
        annotation.onVisibilityChanged = viewAnnotation.actions.visibility
        annotation.onAnchorCoordinateChanged = viewAnnotation.actions.anchorCoordinate
        _update(viewAnnotation.content)
    }
}
