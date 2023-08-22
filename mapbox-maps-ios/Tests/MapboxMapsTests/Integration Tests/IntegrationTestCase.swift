import XCTest
@testable import MapboxMaps

internal class IntegrationTestCase: XCTestCase {

    internal var window: UIWindow?
    internal var rootViewController: UIViewController?
    internal var createdWindow = false
    internal var cancelables = Set<AnyCancelable>()

    internal override func setUpWithError() throws {
        try super.setUpWithError()

        try resolveAccessToken()
        cancelables.removeAll()
        try setupScreenAndWindow()
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
            rootViewController.beginAppearanceTransition(true, animated: false)
            rootViewController.endAppearanceTransition()

            self.window = window
            self.rootViewController = rootViewController
        }

        XCTAssertNotNil(window)
        XCTAssertNotNil(rootViewController?.view)
    }

    private func resolveAccessToken() throws {
        if let userDefaultsToken = UserDefaults.standard.string(forKey: "MBXAccessToken") {
            MapboxOptions.accessToken = userDefaultsToken
        } else if let tokenFromPlist = Bundle.mapboxMapsTests.infoDictionary?["MBXAccessToken"] as? String {
            MapboxOptions.accessToken = tokenFromPlist
        } else if let tokenFromFile = try Bundle.mapboxMapsTests.path(forResource: "MapboxAccessToken", ofType: nil).map(String.init(contentsOfFile:)) {
            MapboxOptions.accessToken = tokenFromFile.trimmingCharacters(in: .newlines)
        } else if Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") == nil {
            XCTFail("Missing access token in Test bundle")
        }
    }
}
