import XCTest
@testable import MapboxMaps
import Foundation

final class MockAttributionDialogManagerDelegate: AttributionDialogManagerDelegate {

    let viewControllerForPresentingStub = Stub<AttributionDialogManager, UIViewController>(defaultReturnValue: UIViewController())
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController? {
        viewControllerForPresentingStub.call(with: attributionDialogManager)
    }
}
