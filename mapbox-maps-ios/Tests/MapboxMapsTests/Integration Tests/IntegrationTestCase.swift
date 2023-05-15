import XCTest
@testable import MapboxMaps

internal class IntegrationTestCase: XCTestCase {

    internal var window: UIWindow?
    internal var rootViewController: UIViewController?
    internal var accessToken: String!
    internal var createdWindow = false
    internal var cancelables = Set<AnyCancelable>()

    internal override func setUpWithError() throws {
        try super.setUpWithError()

        cancelables.removeAll()
        try setupScreenAndWindow()
        accessToken = try mapboxAccessToken()
    }

    internal override func tearDownWithError() throws {
        cancelables.removeAll()
        if createdWindow {
            rootViewController?.viewWillDisappear(false)
            rootViewController?.viewDidDisappear(false)
        }
        rootViewController = nil
        window = nil

        try super.tearDownWithError()
    }

    internal override func invokeTest() {
        autoreleasepool {
            super.invokeTest()
        }
    }

    private func setupScreenAndWindow() throws {
        // Look for an existing window/rvc. This will be the case
        // when running with a host application
        window = UIApplication.shared.windows.first
        rootViewController = window?.rootViewController

        if (window == nil) && (rootViewController == nil) {
            createdWindow = true

            let screen = UIScreen.main
            let window = UIWindow(frame: screen.bounds)
            let rootViewController = UIViewController()
            window.screen = screen
            window.rootViewController = rootViewController

            // Load the view
            _ = rootViewController.view
            window.makeKeyAndVisible()
            rootViewController.viewWillAppear(false)
            rootViewController.viewDidAppear(false)

            self.window = window
            self.rootViewController = rootViewController
        }

        XCTAssertNotNil(window)
        XCTAssertNotNil(rootViewController?.view)
    }
}
