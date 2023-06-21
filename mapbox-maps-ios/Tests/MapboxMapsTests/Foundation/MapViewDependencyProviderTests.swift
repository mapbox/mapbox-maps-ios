import XCTest
@testable import MapboxMaps

final class MapViewDependencyProviderTests: XCTestCase {

    var dependencyProvider: MapViewDependencyProvider!

    override func setUp() {
        super.setUp()
        dependencyProvider = MapViewDependencyProvider()
    }

    override func tearDown() {
        dependencyProvider = nil
        super.tearDown()
    }

    func testMakeLocationProviderMakesWeakReferenceToView() {
        weak var userInterfaceOrientationView: UIView?
        let provider: LocationProvider

        do {
            let view = UIView()
            provider = dependencyProvider.makeLocationProvider(userInterfaceOrientationView: view)
            userInterfaceOrientationView = view
        }

        _ = provider
        XCTAssertNil(userInterfaceOrientationView)
    }
}
