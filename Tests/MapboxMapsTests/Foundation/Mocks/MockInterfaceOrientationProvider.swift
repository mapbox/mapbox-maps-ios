import Foundation
@testable import MapboxMaps

final class MockInterfaceOrientationProvider: InterfaceOrientationProvider {
    let interfaceOrientationStub = Stub<UIView, UIInterfaceOrientation?>(defaultReturnValue: .portrait)
    func interfaceOrientation(for view: UIView) -> UIInterfaceOrientation? {
        return interfaceOrientationStub.call(with: view)

    }
}
