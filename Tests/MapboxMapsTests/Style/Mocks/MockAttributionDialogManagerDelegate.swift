import XCTest
@testable import MapboxMaps
import Foundation

final class MockAttributionDialogManagerDelegate: AttributionDialogManagerDelegate {

    let viewControllerForPresentingStub = Stub<AttributionDialogManager, UIViewController>(defaultReturnValue: UIViewController())
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController? {
        viewControllerForPresentingStub.call(with: attributionDialogManager)
    }

    struct TriggerActionForParameters {
        let attributionDialogManager: AttributionDialogManager
        let attribution: Attribution
    }

    let attributionDialogManagerStub = Stub<TriggerActionForParameters, Void>()
    func attributionDialogManager(_ attributionDialogManager: AttributionDialogManager, didTriggerActionFor attribution: Attribution) {
        attributionDialogManagerStub.call(with:
                                            TriggerActionForParameters(attributionDialogManager: attributionDialogManager,
                                                                       attribution: attribution))
    }
}
