import XCTest
@_spi(Restricted) @_spi(Experimental) @testable import MapboxMaps

// MARK: - ConsolidatedAttributionViewTests

final class ConsolidatedAttributionViewTests: XCTestCase {
    /// Collapses the expanded pill.
    private var mapInteraction: SignalSubject<Void>!

    override func setUp() {
        super.setUp()
        mapInteraction = SignalSubject()
    }

    override func tearDown() {
        mapInteraction = nil
        super.tearDown()
    }

    private func makeStandalonePill() -> ConsolidatedAttributionView {
        ConsolidatedAttributionView(model: ConsolidatedAttributionModel(
            introStore: makeTestIntroStore(),
            onMapInteraction: mapInteraction.signal,
            timerProvider: MockTimerProvider()))
    }

    private func makeView(
        position: OrnamentPosition = .bottomLeft,
        introExpansion: ConsolidatedAttributionIntroExpansion = .everyLaunch
    ) -> ConsolidatedAttributionView {
        let view = makeStandalonePill()
        view.model.options = ConsolidatedAttributionOptions(position: position, introExpansion: introExpansion)
        return view
    }

    // MARK: - Initial state

    func testFirstViewInSessionStartsExpanded() {
        let view = makeView()
        view.model.attributionText = "© OpenStreetMap"
        XCTAssertTrue(view.model.isExpanded, "First view in a fresh session should be expanded")
    }

    // MARK: - Position

    func testAllPositionsCreateWithoutCrash() {
        for position in [OrnamentPosition.bottomLeft, .bottomRight, .topLeft, .topRight,
                         .topLeading, .topTrailing, .bottomLeading, .bottomTrailing] {
            let view = makeView(position: position)
            XCTAssertNotNil(view)
        }
    }

    // MARK: - Appearance

    func testPillBackgroundFollowsOptions() {
        let view = makeStandalonePill()
        let tint = UIColor.systemBlue

        view.model.options = ConsolidatedAttributionOptions(material: .translucent, tintColor: tint)

        let expected = ConsolidatedAttributionPalette.pill(.translucent, tint: tint)
        for style in [UIUserInterfaceStyle.light, .dark] {
            XCTAssertEqual(view.renderedPillColor(for: style),
                           expected.resolvedColor(with: UITraitCollection(userInterfaceStyle: style)))
        }
    }

    // MARK: - Rendered layout

    /// Constrains the pill the way OrnamentsManager does.
    private func hosted(
        _ view: ConsolidatedAttributionView,
        position: OrnamentPosition = .bottomLeft
    ) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        container.addSubview(view)
        switch position {
        case .bottomRight, .topRight, .bottomTrailing, .topTrailing:
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8).isActive = true
            view.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8).isActive = true
        default:
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8).isActive = true
            view.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8).isActive = true
        }
        view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8).isActive = true
        container.layoutIfNeeded()
        return container
    }

    func testCollapsingNarrowsTheRenderedControl() {
        let view = makeView()
        let container = hosted(view)

        view.model.attributionText = "© OpenStreetMap"
        container.layoutIfNeeded()
        let expandedWidth = view.bounds.width

        mapInteraction.send()
        container.layoutIfNeeded()

        XCTAssertLessThan(view.bounds.width, expandedWidth,
                          "Collapsing should narrow the rendered control")
    }

    func testIconOnlyHidesTheWordmarkWhenCollapsed() throws {
        let view = makeStandalonePill()
        view.model.options = ConsolidatedAttributionOptions(introExpansion: .everyLaunch, collapsedStyle: .iconOnly)
        let container = hosted(view)

        view.model.attributionText = "© OpenStreetMap"
        container.layoutIfNeeded()
        let contentStack = try XCTUnwrap(view.firstDescendant(ofType: UIStackView.self))
        let wordmark = try XCTUnwrap(contentStack.arrangedSubviews.compactMap { $0 as? LogoWordmarkView }.first)
        XCTAssertEqual(wordmark.alpha, 1, accuracy: 0.01, "The wordmark shows while expanded")

        mapInteraction.send()
        container.layoutIfNeeded()

        XCTAssertEqual(wordmark.alpha, 0, accuracy: 0.01,
                       "iconOnly must fade the wordmark out, not just clip it")
    }

    func testIconAndWordmarkKeepsTheWordmarkWhenCollapsed() throws {
        let view = makeView()
        let container = hosted(view)

        view.model.attributionText = "© OpenStreetMap"
        container.layoutIfNeeded()
        mapInteraction.send()
        container.layoutIfNeeded()

        let contentStack = try XCTUnwrap(view.firstDescendant(ofType: UIStackView.self))
        let wordmark = try XCTUnwrap(contentStack.arrangedSubviews.compactMap { $0 as? LogoWordmarkView }.first)
        XCTAssertEqual(wordmark.alpha, 1, accuracy: 0.01,
                       "iconAndWordmark must keep the wordmark visible when collapsed")
    }

    func testChevronIsVisibleOnlyWhileExpanded() throws {
        let view = makeView()
        let container = hosted(view)

        view.model.attributionText = "© OpenStreetMap"
        container.layoutIfNeeded()
        let chevron = try XCTUnwrap(view.firstDescendant(ofType: ChevronView.self))
        let expandedOrigin = view.convert(chevron.bounds, from: chevron).minX

        XCTAssertEqual(chevron.alpha, 1, accuracy: 0.01, "The chevron should be visible while expanded")

        mapInteraction.send()
        container.layoutIfNeeded()

        XCTAssertEqual(chevron.alpha, 0, accuracy: 0.01, "The chevron should fade out with the label")
        XCTAssertEqual(view.convert(chevron.bounds, from: chevron).minX, expandedOrigin, accuracy: 0.5,
                       "The chevron must stay put with the label and be clipped, not slide across it")
    }

    func testCollapsedWidthDoesNotReserveRoomForTheChevron() throws {
        let view = makeView()
        let container = hosted(view)

        view.model.attributionText = "© OpenStreetMap"
        container.layoutIfNeeded()
        let chevron = try XCTUnwrap(view.firstDescendant(ofType: ChevronView.self))
        let contentStack = try XCTUnwrap(view.firstDescendant(ofType: UIStackView.self))
        let wordmark = try XCTUnwrap(contentStack.arrangedSubviews.compactMap { $0 as? LogoWordmarkView }.first)

        mapInteraction.send()
        container.layoutIfNeeded()

        let trailingGap = view.bounds.maxX - view.convert(wordmark.bounds, from: wordmark).maxX
        XCTAssertLessThan(trailingGap, chevron.intrinsicContentSize.width,
                          "The collapsed pill leaves a gap wide enough to hold the chevron")
        XCTAssertGreaterThan(view.convert(chevron.bounds, from: chevron).minX, view.bounds.maxX,
                             "The chevron should sit entirely outside the collapsed pill, clipped away")
    }

    func testCollapsedWidthReflectsCollapsedStyle() {
        func collapsedWidth(_ style: ConsolidatedAttributionCollapsedStyle) -> CGFloat {
            let view = makeStandalonePill()
            view.model.options = ConsolidatedAttributionOptions(introExpansion: .everyLaunch, collapsedStyle: style)
            let container = hosted(view)
            view.model.attributionText = "© OpenStreetMap"
            container.layoutIfNeeded()
            mapInteraction.send()
            container.layoutIfNeeded()
            return view.bounds.width
        }

        let iconOnly = collapsedWidth(.iconOnly)
        let iconAndWordmark = collapsedWidth(.iconAndWordmark)

        XCTAssertLessThan(iconOnly, iconAndWordmark,
                          "iconOnly should collapse narrower than iconAndWordmark")
        XCTAssertLessThan(iconOnly, 40, "iconOnly should collapse to roughly the icon width")
    }

    func testTrailingAnchoredControlGrowsLeftward() {
        let view = makeStandalonePill()
        view.model.options = ConsolidatedAttributionOptions(position: .bottomRight, introExpansion: .everyLaunch)
        let container = hosted(view, position: .bottomRight)

        view.model.attributionText = "© OpenStreetMap"
        container.layoutIfNeeded()
        let expandedMaxX = view.frame.maxX
        let expandedWidth = view.bounds.width

        mapInteraction.send()
        container.layoutIfNeeded()

        XCTAssertEqual(view.frame.maxX, expandedMaxX, accuracy: 0.5,
                       "The anchored trailing edge should not move when collapsing")
        XCTAssertLessThan(view.bounds.width, expandedWidth)
    }

    func testLongAttributionTruncatesWithinTheContainer() throws {
        let view = makeView()
        let container = hosted(view)
        let margin: CGFloat = 8

        view.model.attributionText = (1...20).map { "© Data Provider Number \($0)" }.joined(separator: " ")
        container.layoutIfNeeded()

        XCTAssertLessThanOrEqual(view.frame.maxX, container.bounds.width - margin + 0.5,
                                 "The pill must not grow past the container's opposite margin")
        XCTAssertLessThan(view.bounds.width, container.bounds.width,
                          "The pill must stay narrower than the container")
        // Search the stack: the body button's empty titleLabel is also a UILabel.
        let contentStack = try XCTUnwrap(view.firstDescendant(ofType: UIStackView.self))
        let wordmark = try XCTUnwrap(contentStack.arrangedSubviews.compactMap { $0 as? LogoWordmarkView }.first)
        let label = try XCTUnwrap(contentStack.arrangedSubviews.compactMap { $0 as? UILabel }.first)

        XCTAssertEqual(wordmark.bounds.width, wordmark.intrinsicContentSize.width, accuracy: 0.5,
                       "The wordmark must keep its intrinsic width; the label absorbs the squeeze")
        XCTAssertGreaterThan(label.bounds.width, 0, "The label should still render, truncated")
    }

    func testLongAttributionTruncatesWithinTheContainerWhenTrailingAnchored() {
        let view = makeStandalonePill()
        view.model.options = ConsolidatedAttributionOptions(position: .bottomRight, introExpansion: .everyLaunch)
        let container = hosted(view, position: .bottomRight)
        let margin: CGFloat = 8

        view.model.attributionText = (1...20).map { "© Data Provider Number \($0)" }.joined(separator: " ")
        container.layoutIfNeeded()

        XCTAssertGreaterThanOrEqual(view.frame.minX, margin - 0.5,
                                    "The pill must not grow past the container's opposite margin")
    }

    // MARK: - Touch target

    func testTouchTargetIsCenteredAndAtLeast44Points() {
        let view = makeStandalonePill()
        view.model.options = ConsolidatedAttributionOptions(introExpansion: .everyLaunch, collapsedStyle: .iconOnly)
        let container = hosted(view)
        let pill = view.bounds
        let dx = (44 - pill.width) / 2

        XCTAssertLessThan(pill.width, 44)
        XCTAssertTrue(view.point(inside: CGPoint(x: pill.midX, y: -8), with: nil))
        XCTAssertTrue(view.point(inside: CGPoint(x: pill.midX, y: pill.maxY + 7.5), with: nil))
        XCTAssertFalse(view.point(inside: CGPoint(x: pill.midX, y: -8.5), with: nil))
        XCTAssertFalse(view.point(inside: CGPoint(x: pill.midX, y: pill.maxY + 8.5), with: nil))
        XCTAssertTrue(view.point(inside: CGPoint(x: -dx, y: pill.midY), with: nil))
        XCTAssertFalse(view.point(inside: CGPoint(x: -dx - 0.5, y: pill.midY), with: nil))
        withExtendedLifetime(container) {}
    }

    func testWidePillDoesNotGrowSideways() {
        let view = makeView()
        let container = hosted(view)

        XCTAssertGreaterThan(view.bounds.width, 44)
        XCTAssertFalse(view.point(inside: CGPoint(x: -0.5, y: view.bounds.midY), with: nil))
        withExtendedLifetime(container) {}
    }

    func testTouchAroundThePillReachesTheButton() {
        let view = makeView()
        let container = hosted(view)

        XCTAssertTrue(container.hitTest(CGPoint(x: view.frame.midX, y: view.frame.minY - 4), with: nil) is UIButton)
    }
}

private extension ConsolidatedAttributionView {
    func renderedPillColor(for style: UIUserInterfaceStyle) -> UIColor? {
        subviews.compactMap { $0 as? UIButton }.first?
            .backgroundColor?
            .resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }
}

private extension UIView {
    func firstDescendant<T: UIView>(ofType type: T.Type) -> T? {
        for subview in subviews {
            if let match = subview as? T {
                return match
            }
            if let match = subview.firstDescendant(ofType: type) {
                return match
            }
        }
        return nil
    }
}
