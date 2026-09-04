import XCTest
@testable @_spi(Restricted) import MapboxMaps

final class MapTests: XCTestCase {
    func testMakeCoordinatorReportsSwiftUIFramework() throws {
        let dependencyProvider = MockMapViewDependencyProvider()
        let eventsManager = EventsManagerMock()
        dependencyProvider.makeEventsManagerStub.defaultReturnValue = eventsManager

        let map = Map(initialViewport: .styleDefault, dependencyProvider: dependencyProvider)
        _ = map.makeCoordinator()

        XCTAssertEqual(eventsManager.sendMapLoadEventStub.invocations.count, 1)
        XCTAssertEqual(
            eventsManager.sendMapLoadEventStub.invocations.first?.parameters.uiFramework,
            .swiftUI)
    }
}
