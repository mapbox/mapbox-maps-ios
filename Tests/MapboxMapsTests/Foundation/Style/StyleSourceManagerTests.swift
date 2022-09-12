import Foundation
import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class StyleSourceManagerTests: XCTestCase {
    var sourceManager: StyleSourceManager!
    var styleManager: MockStyleManager!
    var mainQueue: MockDispatchQueue!
    var backgroundQueue: MockDispatchQueue!

    override func setUpWithError() throws {
        styleManager = MockStyleManager()
        mainQueue = MockDispatchQueue()
        backgroundQueue = MockDispatchQueue()
        sourceManager = StyleSourceManager(
            styleManager: styleManager,
            mainQueue: mainQueue,
            backgroundQueue: backgroundQueue
        )
    }

    override func tearDown() {
        styleManager = nil
        mainQueue = nil
        backgroundQueue = nil
        sourceManager = nil
    }

    func testGetAllSourceIdentifiers() {
        let stubbedStyleSources: [StyleObjectInfo] = .random(withLength: 3) {
            StyleObjectInfo(id: .randomAlphanumeric(withLength: 12), type: LayerType.random().rawValue)
        }
        styleManager.getStyleSourcesStub.defaultReturnValue = stubbedStyleSources
        XCTAssertTrue(sourceManager.allSourceIdentifiers.allSatisfy { sourceInfo in
            stubbedStyleSources.contains(where: { $0.id == sourceInfo.id && $0.type == sourceInfo.type.rawValue })
        })
    }

    func testStyleGetSourceCanFail() {
        styleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(error: "Cannot get source properties")
        XCTAssertThrowsError(try sourceManager.source(withId: "dummy-source-id"))

        styleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
        XCTAssertThrowsError(try sourceManager.source(withId: "dummy-source-id"))
    }

    func testStyleCanAddStyleSource() {
        styleManager.addStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sourceManager.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))

        styleManager.addStyleSourceStub.defaultReturnValue = Expected(error: "Cannot add style source")
        XCTAssertThrowsError(try sourceManager.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))
    }

    func testStyleCanRemoveSource() {
        styleManager.removeStyleSourceStub.defaultReturnValue = Expected(error: "Cannot remove source")
        XCTAssertThrowsError(try sourceManager.removeSource(withId: "dummy-source-id"))

        styleManager.removeStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        XCTAssertNoThrow(try sourceManager.removeSource(withId: "dummy-source-id"))
    }

    func testStyleCanCheckIfSourceExist() {
        styleManager.styleSourceExistsStub.defaultReturnValue = true
        XCTAssertTrue(sourceManager.sourceExists(withId: "dummy-source-id"))
            styleManager.styleSourceExistsStub.defaultReturnValue = false
        XCTAssertFalse(sourceManager.sourceExists(withId: "non-exist-source-id"))
    }

    func testUpdateGeoJSONSourceThrowsForNotFoundSource() {
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))

        XCTAssertThrowsError(try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject))
    }

}
