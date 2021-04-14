import XCTest
#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsFoundation
#endif

final class ApproximatelyEquatableTests: XCTestCase {
    func testCGFloatIsApproximatelyEqual() throws {
        let val: CGFloat = 0.30000000000000004
        let otherVal: CGFloat = 0.3
        XCTAssertTrue(val.isApproximatelyEqual(to: otherVal))
    }

    func testCGFloatIsNotApproximatelyEqual() throws {
        let val: CGFloat = 0.30000000000000004
        let otherVal: CGFloat = 0.3
        XCTAssertTrue(val.isNotApproximatelyEqual(to: otherVal, within: 1e-18))
    }

    func testCLLocationCoordinate2DIsApproximatelyEqual() throws {
        let val = CLLocationCoordinate2D(latitude: 0.30000000000000004, longitude: 0.30000000000000004)
        let otherVal = CLLocationCoordinate2D(latitude: 0.3, longitude: 0.3)
        XCTAssertTrue(val.isApproximatelyEqual(to: otherVal))
    }

    func testCLLocationCoordinate2DIsNotApproximatelyEqual() throws {
        let val = CLLocationCoordinate2D(latitude: 0.30000000000000004, longitude: 0.30000000000000004)
        let otherVal = CLLocationCoordinate2D(latitude: 0.3, longitude: 0.3)
        XCTAssertTrue(val.isNotApproximatelyEqual(to: otherVal, within: CLLocationCoordinate2D(latitude: 1e-18, longitude: 1e-18)))
    }

}
