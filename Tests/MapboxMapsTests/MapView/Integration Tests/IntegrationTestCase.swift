import XCTest

internal class IntegrationTestCase: XCTestCase {

    internal var window: UIWindow?
    internal var rootViewController: UIViewController?
    internal var accessToken: String!
    internal var createdWindow = false

    internal override func setUpWithError() throws {
        try setupScreenAndWindow()
        accessToken = try mapboxAccessToken()
    }

    internal override func tearDownWithError() throws {
        if createdWindow {
            rootViewController?.viewWillDisappear(false)
            rootViewController?.viewDidDisappear(false)
        }
        rootViewController = nil
        window = nil
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
