import XCTest
@testable import MapboxMaps

final class RenderedQueryOptionsTests: XCTestCase {

    func testInitWithNils() {
        let options = RenderedQueryOptions(layerIds: nil, filter: nil)

        XCTAssertNil(options.layerIds)
        XCTAssertNil(options.__filter)
    }

    func testInitWithNonNils() throws {
        let layerIds = [String].testFixture(withLength: 10) {
            .testConstantASCII(withLength: 10)
        }
        let filter = Exp(.abs) {
            0.1
        }
        let filterJSONObject = try XCTUnwrap(filter.toJSON() as? NSObject)

        let options = RenderedQueryOptions(layerIds: layerIds, filter: filter)

        XCTAssertEqual(options.layerIds, layerIds)
        let __filterObject = try XCTUnwrap(options.__filter as? NSObject)
        XCTAssertEqual(__filterObject, filterJSONObject)
    }

    func testFilterRefinementNil() {
        let options = RenderedQueryOptions(__layerIds: nil, filter: nil)

        XCTAssertNil(options.filter)
    }

    func testFilterRefinementNonNil() throws {
        let filter = Exp(.abs) {
            1.2
        }
        let filterJSON = try filter.toJSON()

        let options = RenderedQueryOptions(__layerIds: nil, filter: filterJSON)

        XCTAssertEqual(options.filter, filter)
    }
}
