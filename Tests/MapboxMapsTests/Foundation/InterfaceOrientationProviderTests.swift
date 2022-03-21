import Foundation
@testable import MapboxMaps
import XCTest

final class UIApplicationInterfaceOrientationProviderTests: XCTestCase {
    var application: UIApplicationProtocol!
    var provider: UIApplicationInterfaceOrientationProvider!
    var view: UIView!

    override func setUp() {
        super.setUp()

        view = UIView()
        application = MockUIApplication()
        provider = UIApplicationInterfaceOrientationProvider(application: application)
    }

    override func tearDown() {
        provider = nil
        view = nil
        application = nil
        super.tearDown()
    }

    func testOrientationProvider() {
        let orientations: [UIInterfaceOrientation] = [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown]

        for orientation in orientations {
            application.statusBarOrientation = orientation
            let resolvedOrientation = provider.interfaceOrientation(for: view)

            XCTAssertEqual(resolvedOrientation, application.statusBarOrientation)
        }
    }

    func testInterfaceToDeviceOrientationConversion() throws {
        let interfaceOrientations: [UIInterfaceOrientation] =   [.portrait, .landscapeLeft, .landscapeRight, .portraitUpsideDown, .unknown]
        let deviceOrientations: [CLDeviceOrientation] =         [.portrait, .landscapeRight, .landscapeLeft, .portraitUpsideDown, .portrait]

        for (index, orientation) in interfaceOrientations.enumerated() {
            let resolvedOrientation = CLDeviceOrientation(interfaceOrientation: orientation)

            let expectedOrientation = deviceOrientations[index]
            XCTAssertEqual(resolvedOrientation, expectedOrientation)
        }
    }

    func testHeadingOrientationWrapperCallsInterfaceOrientation() {
        let provider = MockInterfaceOrientationProvider()
        _ = provider.headingOrientation(for: view)

        XCTAssertEqual(provider.interfaceOrientationStub.invocations.count, 1)
        XCTAssertEqual(provider.interfaceOrientationStub.invocations.first?.parameters, view)
    }
}

final class DefaultInterfaceOrientationProviderTests: XCTestCase {
    func testOrientationProvider() throws {
        guard #available(iOS 13.0, *) else {
            throw XCTSkip("Test requires iOS 13 or higher.")
        }

        let view = UIView()
        let window = UIWindow()
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        let provider = DefaultInterfaceOrientationProvider()

        let orientation = provider.interfaceOrientation(for: view)

        XCTAssertNotNil(orientation)
        XCTAssertEqual(orientation, view.window?.windowScene?.interfaceOrientation)
    }
}
