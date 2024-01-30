import XCTest
@testable import MapboxMaps

internal class IntegrationTestCase: XCTestCase {

    var window: UIWindow!
    var rootViewController: UIViewController?
    var cancelables = Set<AnyCancelable>()
    private var createdViewController = false

    internal override func setUpWithError() throws {
        try super.setUpWithError()

        try resolveAccessToken()
        cancelables.removeAll()
        try setupScreenAndWindow()
    }

    internal override func tearDownWithError() throws {
        cancelables.removeAll()
        if createdViewController {
            rootViewController?.viewWillDisappear(false)
            rootViewController?.viewDidDisappear(false)
        }
        createdViewController = false
        rootViewController = nil
        window = nil

        try super.tearDownWithError()
    }

    internal override func invokeTest() {
        autoreleasepool {
            super.invokeTest()
        }
    }

    private func loadWindow() -> UIWindow {
        // Look for an existing window. This will be the case
        // when running with a host application
        if let window = UIApplication.shared.keyWindowForTests {
            return window
        }

#if swift(>=5.9) && os(visionOS)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
#else
        let screen = UIScreen.main
        let window = UIWindow(frame: screen.bounds)
        window.screen = screen
#endif
        return window
    }

    private func loadRootViewController() -> UIViewController {
        if let vc = window.rootViewController {
            return vc
        }

        let rootViewController = UIViewController()
        window.rootViewController = rootViewController

        // Load the view
        _ = rootViewController.view
        window.makeKeyAndVisible()
        rootViewController.viewWillAppear(false)
        rootViewController.viewDidAppear(false)
        createdViewController = true
        return rootViewController
    }

    private func setupScreenAndWindow() throws {

        window = loadWindow()
        rootViewController = loadRootViewController()

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
