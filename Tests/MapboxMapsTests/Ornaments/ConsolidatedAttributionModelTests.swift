import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ConsolidatedAttributionModelTests: XCTestCase {
    private var introStore: ConsolidatedAttributionIntroStore!
    private var onMapInteraction: SignalSubject<Void>!
    private var timerProvider: MockTimerProvider!
    private var timer: MockTimer!
    private var model: ConsolidatedAttributionModel!
    private var changes: [Bool]!

    override func setUp() {
        super.setUp()
        introStore = makeTestIntroStore()
        onMapInteraction = SignalSubject()
        timer = MockTimer()
        timerProvider = MockTimerProvider()
        timerProvider.makeScheduledTimerStub.defaultReturnValue = timer
        model = makeModel()
        changes = []
        model.onStateChange = { [unowned self] in self.changes.append($0) }
    }

    override func tearDown() {
        model = nil
        timer = nil
        timerProvider = nil
        onMapInteraction = nil
        introStore = nil
        super.tearDown()
    }

    private func makeModel() -> ConsolidatedAttributionModel {
        ConsolidatedAttributionModel(
            introStore: introStore,
            onMapInteraction: onMapInteraction.signal,
            timerProvider: timerProvider)
    }

    private func startIntro() {
        model.options = ConsolidatedAttributionOptions()
        model.attributionText = "© OpenStreetMap"
    }

    private func fireCollapseTimer() throws {
        let invocation = try XCTUnwrap(timerProvider.makeScheduledTimerStub.invocations.last)
        invocation.parameters.block(timer)
    }

    // MARK: - Intro

    func testIntroStartsWhenEnabledWithText() throws {
        startIntro()

        XCTAssertTrue(model.isExpanded)
        XCTAssertEqual(changes.last, true, "The expansion animates")
        let timerParams = try XCTUnwrap(timerProvider.makeScheduledTimerStub.invocations.first?.parameters)
        XCTAssertEqual(timerParams.timeInterval, ConsolidatedAttributionModel.collapseDelay)
        XCTAssertFalse(timerParams.repeats)
    }

    func testIntroStartsWhenTextArrivesBeforeOptions() {
        model.attributionText = "© OpenStreetMap"
        XCTAssertFalse(model.isExpanded, "A disabled pill holds the intro back")

        model.options = ConsolidatedAttributionOptions()

        XCTAssertTrue(model.isExpanded)
    }

    func testEmptyTextDoesNotStartIntro() {
        model.options = ConsolidatedAttributionOptions()
        model.attributionText = ""

        XCTAssertFalse(model.isExpanded)
        model.attributionText = "© OpenStreetMap"
        XCTAssertTrue(model.isExpanded, "Empty text must not use up the intro")
    }

    func testIntroRunsOnce() {
        startIntro()
        model.attributionText = "© Mapbox © OpenStreetMap"
        onMapInteraction.send()

        model.attributionText = "© OpenStreetMap"
        model.options = nil
        model.options = ConsolidatedAttributionOptions()

        XCTAssertFalse(model.isExpanded)
        XCTAssertEqual(timerProvider.makeScheduledTimerStub.invocations.count, 1)
    }

    func testTextUpdateKeepsStateAndDoesNotAnimate() {
        startIntro()
        changes = []

        model.attributionText = "© Mapbox © OpenStreetMap"

        XCTAssertTrue(model.isExpanded)
        XCTAssertEqual(changes, [false])
    }

    func testIntroIsSkippedWhenAlreadyShownInSession() {
        startIntro()

        let second = makeModel()
        second.options = ConsolidatedAttributionOptions()
        second.attributionText = "© OpenStreetMap"

        XCTAssertFalse(second.isExpanded)
    }

    func testSkippedIntroDoesNotAnimate() {
        introStore.recordIntroShown()

        startIntro()

        XCTAssertFalse(model.isExpanded)
        XCTAssertEqual(changes.last, false)
        XCTAssertTrue(timerProvider.makeScheduledTimerStub.invocations.isEmpty)
    }

    // MARK: - Options

    func testAppearanceChangeIsReportedOnlyWhenOptionsDiffer() {
        var appearanceChanges = 0
        model.onAppearanceChange = { appearanceChanges += 1 }

        model.options = ConsolidatedAttributionOptions()
        model.options = ConsolidatedAttributionOptions()
        model.options = ConsolidatedAttributionOptions(material: .translucent)

        XCTAssertEqual(appearanceChanges, 2)
    }

    // MARK: - Collapse

    func testCollapseTimerCollapses() throws {
        startIntro()
        changes = []

        try fireCollapseTimer()

        XCTAssertFalse(model.isExpanded)
        XCTAssertEqual(changes, [true], "The collapse animates")
    }

    func testMapInteractionCollapsesAndInvalidatesTimer() {
        startIntro()

        onMapInteraction.send()

        XCTAssertFalse(model.isExpanded)
        XCTAssertEqual(timer.invalidateStub.invocations.count, 1)
    }

    func testMapInteractionIsObservedOnlyWhileExpanded() {
        var observed = [Bool]()
        // Released one runloop turn after collapse.
        let released = expectation(description: "subscription released")
        onMapInteraction.onObserved = { isObserved in
            observed.append(isObserved)
            if !isObserved { released.fulfill() }
        }

        model.options = ConsolidatedAttributionOptions()
        XCTAssertEqual(observed, [], "A pending pill has nothing to collapse, so it observes no touches")

        model.attributionText = "© OpenStreetMap"
        XCTAssertEqual(observed, [true], "The expanded pill observes touches")

        onMapInteraction.send()
        XCTAssertFalse(model.isExpanded)

        wait(for: [released], timeout: 1)
        XCTAssertEqual(observed, [true, false], "Collapsing releases the subscription")
    }

    func testDisablingDuringIntroCollapsesWithoutAnimation() {
        startIntro()
        changes = []

        model.options = nil

        XCTAssertFalse(model.isExpanded)
        XCTAssertEqual(changes, [false], "A disabled pill is hidden, so it doesn't animate")
        XCTAssertEqual(timer.invalidateStub.invocations.count, 1)
    }

    // MARK: - Tap

    func testTapDuringIntroOpensSheetAndCollapses() {
        var taps = 0
        model.onTap = { taps += 1 }
        startIntro()

        model.handleTap()

        XCTAssertEqual(taps, 1)
        XCTAssertFalse(model.isExpanded)
        XCTAssertEqual(timer.invalidateStub.invocations.count, 1)
    }

    func testTapWhenCollapsedOpensSheetWithoutExpanding() {
        var taps = 0
        model.onTap = { taps += 1 }
        startIntro()
        onMapInteraction.send()

        model.handleTap()

        XCTAssertEqual(taps, 1)
        XCTAssertFalse(model.isExpanded)
    }

    func testTapBeforeIntroOpensSheet() {
        var taps = 0
        model.onTap = { taps += 1 }

        model.handleTap()

        XCTAssertEqual(taps, 1)
    }
}
