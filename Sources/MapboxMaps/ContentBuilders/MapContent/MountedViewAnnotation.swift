import UIKit
import SwiftUI
import os.log

protocol ViewAnnotationsManaging: AnyObject {
    func add(_ annotation: ViewAnnotation)
}

final class MountedViewAnnotation: MapContentMountedComponent {
    let mapViewAnnotation: MapViewAnnotation
    var update: ((MapViewAnnotation) -> Void)?
    var remove: (() -> Void)?

    init(mapViewAnnotation: MapViewAnnotation) {
        self.mapViewAnnotation = mapViewAnnotation
    }

    func mount(with context: MapContentNodeContext) throws {
        weak var weakViewAnnotation: ViewAnnotation?

        let makeContent = { (mapViewAnnotation: MapViewAnnotation) in
            mapViewAnnotation.content
                .fixedSize()
                .allowsHitTesting(mapViewAnnotation.allowHitTesting)
                .onChangeOfSize { _ in
                    weakViewAnnotation?.setNeedsUpdateSize()
                }
        }

        let vc = UIHostingController(rootView: makeContent(mapViewAnnotation))
        vc.view.backgroundColor = .clear
        vc.disableSafeArea()

        let viewAnnotation = ViewAnnotation(
            annotatedFeature: mapViewAnnotation.annotatedFeature,
            view: vc.view
        )
        context.content?.viewAnnotations.value?.add(viewAnnotation)
        context.content?.addAnnotationViewController(vc)
        weakViewAnnotation = viewAnnotation

        self.update = { mapViewAnnotation in
            vc.rootView = makeContent(mapViewAnnotation)
            vc.view.isUserInteractionEnabled = mapViewAnnotation.allowHitTesting

            weakViewAnnotation?.annotatedFeature = mapViewAnnotation.annotatedFeature
            weakViewAnnotation?.allowOverlap = mapViewAnnotation.allowOverlap
            weakViewAnnotation?.allowOverlapWithPuck = mapViewAnnotation.allowOverlapWithPuck
            weakViewAnnotation?.allowZElevate = mapViewAnnotation.allowZElevate
            weakViewAnnotation?.ignoreCameraPadding = mapViewAnnotation.ignoreCameraPadding
            weakViewAnnotation?.visible = mapViewAnnotation.visible
            weakViewAnnotation?.selected = mapViewAnnotation.selected
            weakViewAnnotation?.priority = mapViewAnnotation.priority
            weakViewAnnotation?.variableAnchors = mapViewAnnotation.variableAnchors
            weakViewAnnotation?.onAnchorChanged = mapViewAnnotation.actions.anchor
            weakViewAnnotation?.onVisibilityChanged = mapViewAnnotation.actions.visibility
            weakViewAnnotation?.onAnchorCoordinateChanged = mapViewAnnotation.actions.anchorCoordinate
            weakViewAnnotation?.minZoom = mapViewAnnotation.minZoom
            weakViewAnnotation?.maxZoom = mapViewAnnotation.maxZoom
            os_log(.debug, log: .contentDSL, "view annotation update %s", weakViewAnnotation?.id ?? "<nil>")
        }

        self.remove = {
            os_log(.debug, log: .contentDSL, "view annotation remove %s", weakViewAnnotation?.id ?? "<nil>")
            context.content?.removeAnnotationViewController(vc)
            weakViewAnnotation?.remove()
        }

        os_log(.debug, log: .contentDSL, "view annotation add %s", weakViewAnnotation?.id ?? "<nil>")
        update?(mapViewAnnotation)
    }

    func unmount(with context: MapContentNodeContext) throws {
        guard let remove else {
            return Log.error("Could not remove the view annotation", category: "Annotations")
        }
        remove()
    }

    func tryUpdate(from old: MapContentMountedComponent, with context: MapContentNodeContext) throws -> Bool {
        guard let old = old as? Self, let oldUpdate = old.update, let oldRemove = old.remove else {
            return false
        }

        update = oldUpdate
        remove = oldRemove
        update?(mapViewAnnotation)

        return true
    }

    func updateMetadata(with: MapContentNodeContext) {}
}

private extension UIHostingController {
    func disableSafeArea() {
        if #available(iOS 16.4, *) {
            safeAreaRegions = SafeAreaRegions()
        } else {
            /// This is a private API, but it's the only good way to disable safe area in UIHostingController in iOS 16.4 and lower
            /// Details: https://stackoverflow.com/questions/70156299/cannot-place-swiftui-view-outside-the-safearea-when-embedded-in-uihostingcontrol
            _disableSafeArea = true
        }
    }
}

extension ViewAnnotationManager: ViewAnnotationsManaging {}
