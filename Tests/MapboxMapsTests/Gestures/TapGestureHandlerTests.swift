import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class TapGestureHandlerTests: XCTestCase {

    var view: UIView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!

    override func setUp() {
        view = UIView()
        delegate = GestureHandlerDelegateMock()
    }

    override func tearDown() {
        view = nil
        delegate = nil
    }

    func testSetupOfSingleTapSingleTouchGestureHandler() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 1,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate)

        guard let validTapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                              as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        XCTAssert(validTapGestureRecognizer.numberOfTapsRequired == 1)
        XCTAssert(validTapGestureRecognizer.numberOfTouchesRequired == 1)
    }

    func testSetupOfDoubleTapSingleTouchGestureHandler() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate)

        guard let validTapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                              as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        XCTAssert(validTapGestureRecognizer.numberOfTapsRequired == 2)
        XCTAssert(validTapGestureRecognizer.numberOfTouchesRequired == 1)
    }

    func testSetupOfDoubleTapDoubleTouchGestureHandler() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 2,
                                                  withDelegate: delegate)

        guard let validTapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                              as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        XCTAssert(validTapGestureRecognizer.numberOfTapsRequired == 2)
        XCTAssert(validTapGestureRecognizer.numberOfTouchesRequired == 2)
    }

    func testHandlerSingleTapSingleTouch() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 1,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate)

        guard let tapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                         as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        tapGestureHandler.handleTap(tapGestureRecognizer)
        XCTAssertTrue(delegate.tapCalled)
        XCTAssertTrue(delegate.tapCalledWithNumberOfTaps == 1,
                      "Number of taps called does not match configured value")
        XCTAssertTrue(delegate.tapCalledWithNumberOfTouches == 1,
                      "Number of touches called does not match configured value")
    }

    func testHandlerDoubleTapSingleTouch() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 1,
                                                  withDelegate: delegate)

        guard let tapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                         as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        tapGestureHandler.handleTap(tapGestureRecognizer)
        XCTAssertTrue(delegate.tapCalled)
        XCTAssertTrue(delegate.tapCalledWithNumberOfTaps == 2,
                      "Number of taps called does not match configured value")
        XCTAssertTrue(delegate.tapCalledWithNumberOfTouches == 1,
                      "Number of touches called does not match configured value")
    }

    func testHandlerDoubleTapDoubleTouch() {
        let tapGestureHandler = TapGestureHandler(for: view,
                                                  numberOfTapsRequired: 2,
                                                  numberOfTouchesRequired: 2,
                                                  withDelegate: delegate)

        guard let tapGestureRecognizer = tapGestureHandler.view?.gestureRecognizers?.first
                                         as? UITapGestureRecognizer else {
            XCTFail("No valid tap gesture recognizer found")
            return
        }

        tapGestureHandler.handleTap(tapGestureRecognizer)
        XCTAssertTrue(delegate.tapCalled)
        XCTAssertTrue(delegate.tapCalledWithNumberOfTaps == 2,
                      "Number of taps called does not match configured value")
        XCTAssertTrue(delegate.tapCalledWithNumberOfTouches == 2,
                      "Number of touches called does not match configured value")
    }
}
