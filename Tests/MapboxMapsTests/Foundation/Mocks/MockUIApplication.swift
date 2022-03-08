import Foundation
import UIKit
@testable import MapboxMaps

final class MockUIApplication: UIApplicationProtocol {

    let openURLStub = Stub<URL, Void>()
    func open(_ url: URL) {
        openURLStub.call(with: url)
    }
}
