import XCTest
@_spi(Experimental) @testable import MapboxMaps

extension XCTestCase {
    /// An intro store on a persistent key of its own, erased after the test.
    func makeTestIntroStore(key: String? = nil) -> ConsolidatedAttributionIntroStore {
        let key = key ?? "\(Self.self).\(UUID().uuidString)"
        let settings = SettingsServiceFactory.getInstance(storageType: .persistent)
        addTeardownBlock { _ = settings.erase(key: key) }
        return ConsolidatedAttributionIntroStore(settings: settings, key: key)
    }
}

final class ConsolidatedAttributionIntroStoreTests: XCTestCase {

    func testFreshStoreShowsIntro() {
        let store = makeTestIntroStore()

        XCTAssertFalse(store.shouldSkipIntro(.everyLaunch))
        XCTAssertFalse(store.shouldSkipIntro(.once))
    }

    func testIntroIsSkippedForRestOfSession() {
        let store = makeTestIntroStore()

        store.recordIntroShown()

        XCTAssertTrue(store.shouldSkipIntro(.everyLaunch))
        XCTAssertTrue(store.shouldSkipIntro(.once))
    }

    func testOnlyOnceSkipsIntroOnNextLaunch() {
        let key = "\(Self.self).\(UUID().uuidString)"
        makeTestIntroStore(key: key).recordIntroShown()

        let relaunched = makeTestIntroStore(key: key)

        XCTAssertFalse(relaunched.shouldSkipIntro(.everyLaunch))
        XCTAssertTrue(relaunched.shouldSkipIntro(.once))
    }

    func testStoresAreIndependent() {
        let first = makeTestIntroStore()
        let second = makeTestIntroStore()

        first.recordIntroShown()

        XCTAssertFalse(second.shouldSkipIntro(.everyLaunch))
        XCTAssertFalse(second.shouldSkipIntro(.once))
    }
}
