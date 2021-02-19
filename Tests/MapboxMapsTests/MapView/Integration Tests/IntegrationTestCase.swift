import XCTest

internal class IntegrationTestCase: XCTestCase {

    internal var window: UIWindow?
    internal var rootViewController: UIViewController?
    internal var accessToken: String!

    internal override func setUpWithError() throws {
        try setupScreenAndWindow()
        try setupAccessToken()
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

    private func setupAccessToken() throws {

        func token() throws -> String {
            // User defaults can override plist
            if let token = UserDefaults.standard.string(forKey: "MBXAccessToken") {
                print("Found access token from UserDefaults (command line parameter?)")
                return token
            } else if let token = Bundle.mapboxTests.infoDictionary?["MBXAccessToken"] as? String {
                print("Found access token in Info.plist")
                return token
            } else if let url = Bundle.mapboxTests.url(forResource: "MapboxAccessToken", withExtension: nil),
               let token = try? String(contentsOf: url) {
                print("Found access token in MapboxAccessToken")
                return token
            } else {
                throw XCTSkip("Mapbox access token not found")
            }
        }

        func validated(token: String) throws -> String {
            if token.starts(with: "pk.") {
                return token
            } else {
                throw XCTSkip("Mapbox access token is invalid")
            }
        }

        accessToken = try validated(token: token()).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
