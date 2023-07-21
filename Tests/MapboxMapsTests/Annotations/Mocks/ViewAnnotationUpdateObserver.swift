import UIKit
@testable import MapboxMaps

final class MockViewAnnotationUpdateObserver: ViewAnnotationUpdateObserver {

    let framesDidChangeStub = Stub<[UIView], Void>()
    func framesDidChange(for annotationViews: [UIView]) {
        framesDidChangeStub.call(with: annotationViews)
    }

    let visibilityDidChangeStub = Stub<[UIView], Void>()
    func visibilityDidChange(for annotationViews: [UIView]) {
        visibilityDidChangeStub.call(with: annotationViews)
    }
}
