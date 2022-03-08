import Foundation
@testable import MapboxMaps
import XCTest

final class UIApplicationInterfaceOrientationProviderTests: XCTestCase {
    var provider: UIApplicationInterfaceOrientationProvider!
    var view: UIView!

    override func setUp() {
        super.setUp()

        view = UIView()
        provider = UIApplicationInterfaceOrientationProvider()
    }

    override func tearDown() {
        provider = nil
        view = nil
        super.tearDown()
    }

    func testOrientationProvider() {
        let orientations: [UIInterfaceOrientation] = [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]

        for orientation in orientations {
            UIApplication.shared.statusBarOrientation = orientation
            let resolvedOrientation = provider.interfaceOrientation(for: view)

            XCTAssertEqual(resolvedOrientation, UIApplication.shared.statusBarOrientation)
        }
    }
}

@available(iOS 13.0, *)
final class DefaultInterfaceOrientationProviderTests: XCTestCase {
    var provider: DefaultInterfaceOrientationProvider!
    var view: UIView!
    var window: UIWindow!

    override func setUp() {
        super.setUp()

        view = UIView()
        window = UIWindow()
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        provider = DefaultInterfaceOrientationProvider()
    }

    override func tearDown() {
        provider = nil
        view = nil
        super.tearDown()
    }

    func testOrientationProvider() {
        let orientation = provider.interfaceOrientation(for: view)

        XCTAssertNotNil(orientation)
        XCTAssertEqual(orientation, view.window?.windowScene?.interfaceOrientation)
    }
}
