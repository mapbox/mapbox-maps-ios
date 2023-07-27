import UIKit
import MapboxMaps
@testable import MapboxMapsSwiftUI

class MockViewAnnotationsManager: ViewAnnotationsManaging {
    struct AddViewParameters {
        let view: UIView
        let id: String?
        let options: ViewAnnotationOptions
    }
    let addViewStub = Stub<AddViewParameters, Void>()
    func add(_ view: UIView, id: String?, options: ViewAnnotationOptions) throws {
        addViewStub.call(with: .init(view: view, id: id, options: options))
    }

    struct UpdateViewParamaters {
        let view: UIView
        let options: ViewAnnotationOptions
    }
    let updateViewStub = Stub<UpdateViewParamaters, Void>()
    func update(_ view: UIView, options: ViewAnnotationOptions) throws {
        updateViewStub.call(with: .init(view: view, options: options))
    }

    let removeViewStub = Stub<UIView, Void>()
    func remove(_ view: UIView) {
        removeViewStub.call(with: view)
    }
}
