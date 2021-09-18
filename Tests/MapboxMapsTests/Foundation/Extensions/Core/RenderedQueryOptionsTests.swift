import XCTest
import MapboxMaps

final class RenderedQueryOptionsTests: XCTestCase {

    func testInitWithNils() {
        let options = RenderedQueryOptions(layerIds: nil, filter: nil)

        XCTAssertNil(options.layerIds)
        XCTAssertNil(options.__filter)
    }

    func testInitWithNonNils() throws {
        let layerIds = [String].random(withLength: .random(in: 0...10)) {
            .randomASCII(withLength: .random(in: 0...10))
        }
        let filter = Exp(.abs) {
            Double.random(in: 0..<(.greatestFiniteMagnitude))
        }
        let filterJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(filter), options: [])
        let filterJSONObject = try XCTUnwrap(filterJSON as? NSObject)

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
            Double.random(in: 0..<(.greatestFiniteMagnitude))
        }
        let filterJSON = try JSONSerialization.jsonObject(with: JSONEncoder().encode(filter), options: [])

        let options = RenderedQueryOptions(__layerIds: nil, filter: filterJSON)

        XCTAssertEqual(options.filter, filter)
    }
}
