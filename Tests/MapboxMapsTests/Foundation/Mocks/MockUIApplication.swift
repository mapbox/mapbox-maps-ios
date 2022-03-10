import Foundation
import UIKit
@testable import MapboxMaps

final class MockUIApplication: UIApplicationProtocol {
    var statusBarOrientation: UIInterfaceOrientation = .unknown
    
    let openURLStub = Stub<URL, Void>()
    func open(_ url: URL) {
        openURLStub.call(with: url)
    }
}
