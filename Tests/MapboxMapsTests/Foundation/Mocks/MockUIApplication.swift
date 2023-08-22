import Foundation
import UIKit
@testable import MapboxMaps

final class MockUIApplication: UIApplicationProtocol {
    var statusBarOrientation: UIInterfaceOrientation = .unknown
    private(set) var applicationState: UIApplication.State = .active

    let openURLStub = Stub<URL, Void>()
    func open(_ url: URL) {
        openURLStub.call(with: url)
    }

    func updateApplicationState(_ applicationState: UIApplication.State) {
        self.applicationState = applicationState
    }
}
