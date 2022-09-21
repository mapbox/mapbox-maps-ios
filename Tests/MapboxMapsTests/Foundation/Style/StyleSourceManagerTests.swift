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
        XCTAssertEqual(styleManager.getStyleSourcePropertiesStub.invocations.count, 1)

        styleManager.getStyleSourcePropertiesStub.defaultReturnValue = Expected(value: NSDictionary(dictionary: ["type": "Not a valid type"]))
        XCTAssertThrowsError(try sourceManager.source(withId: "dummy-source-id"))
        XCTAssertEqual(styleManager.getStyleSourcePropertiesStub.invocations.count, 2)
    }

    func testStyleCanAddStyleSource() throws {
        styleManager.addStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        let id = "dummy-source-id"
        let props = ["foo": "bar"]
        try sourceManager.addSource(withId: id, properties: props)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, props as NSDictionary)
        styleManager.addStyleSourceStub.defaultReturnValue = Expected(error: "Cannot add style source")
        XCTAssertThrowsError(try sourceManager.addSource(withId: "dummy-source-id", properties: ["foo": "bar"]))
    }

    func testAddNonGeoJSONDataSourceDoesNotTriggerAsyncParsing() throws {
        let id = String.randomASCII(withLength: 10)
        let types: [SourceType] = [.raster, .image, .rasterDem, .vector]
        let type = types.randomElement()!
        let json = ["type": type.rawValue]
        let source = try types.randomElement()!.sourceType.init(jsonObject: json)

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, json as NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 0)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 0)
    }

    func testStyleCanRemoveSource() throws {
        let id = String.randomASCII(withLength: 23)
        styleManager.removeStyleSourceStub.defaultReturnValue = Expected(error: "Cannot remove source")
        XCTAssertThrowsError(try sourceManager.removeSource(withId: id))
        XCTAssertEqual(styleManager.removeStyleSourceStub.invocations.count, 1)

        styleManager.removeStyleSourceStub.defaultReturnValue = Expected(value: NSNull())
        try sourceManager.removeSource(withId: id)
        XCTAssertEqual(styleManager.removeStyleSourceStub.invocations.count, 2)
        XCTAssertEqual(styleManager.removeStyleSourceStub.invocations.first?.parameters, id)
    }

    func testStyleCanCheckIfSourceExist() {
        styleManager.styleSourceExistsStub.defaultReturnValue = true
        XCTAssertTrue(sourceManager.sourceExists(withId: "dummy-source-id"))
        XCTAssertEqual(styleManager.styleSourceExistsStub.invocations.count, 1)

        styleManager.styleSourceExistsStub.defaultReturnValue = false
        XCTAssertFalse(sourceManager.sourceExists(withId: "non-exist-source-id"))
        XCTAssertEqual(styleManager.styleSourceExistsStub.invocations.count, 2)
    }

    func testUpdateGeoJSONSourceThrowsForNotFoundSource() {
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))

        XCTAssertThrowsError(try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject))
    }

    func testUpdateGeoJSONSourceThrowsForNotGeoJSONSource() {
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        let type = SourceType.raster
        let info = StyleObjectInfo(id: id, type: type.rawValue)
        styleManager.getStyleSourcesStub.defaultReturnValue = [info]

        XCTAssertThrowsError(try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject))
    }

    func testUpdateGeoJSONSourceDispatchesParsingOnABackgroundThread() throws {
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
    }

    func testAsyncUpdateGeoJSONCallsMainThreadWithParsedString() throws {
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }
        mainQueue.asyncClosureStub.defaultSideEffect = { $0.parameters.work() }

        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 1)
        let setSourcePropertyParams = try XCTUnwrap(styleManager.setStyleSourcePropertyStub.invocations.first?.parameters)
        XCTAssertEqual(setSourcePropertyParams.sourceId, id)
        XCTAssertEqual(setSourcePropertyParams.property, "data")
        XCTAssertEqual(setSourcePropertyParams.value as? String, "{\"type\":\"FeatureCollection\",\"features\":[]}")
    }

    func testAsyncGeoJSONUpdateSkipsParsingWhenCancelled() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        let workItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)
        workItem.cancel()

        // when
        workItem.perform()

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 0)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 0)
    }

    func testAsyncGeoJSONUpdateIgnoresCancellationAfterStart() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        let workItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        workItem.perform()
        workItem.cancel()
        mainQueue.asyncClosureStub.invocations.first?.parameters.work()

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 1)
    }

    func testMutltipleAsyncGeoJSONUpdateCancelPreviousWork() throws {
        // given
        let iterations = 100
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        // when
        for _ in 0..<iterations {
            try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)
        }

        backgroundQueue.asyncWorkItemStub.invocations.forEach { $0.parameters.perform() }
        mainQueue.asyncClosureStub.invocations.forEach { $0.parameters.work() }

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, iterations)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 1)
    }

    func testMultipleDistrinctAsyncGeoJSONUpdateDoNotCancelEachOtherOut() throws {
        // given
        let sourceCount = 100
        let ids = (0..<sourceCount).map { _ in UUID().uuidString }
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = ids.map { StyleObjectInfo(id: $0, type: SourceType.geoJson.rawValue) }

        // when
        for id in ids {
            try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)
        }

        backgroundQueue.asyncWorkItemStub.invocations.forEach { $0.parameters.perform() }
        mainQueue.asyncClosureStub.invocations.forEach { $0.parameters.work() }

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, sourceCount)
        XCTAssert(backgroundQueue.asyncWorkItemStub.invocations.allSatisfy { !$0.parameters.isCancelled })
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, sourceCount)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, sourceCount)
    }

    func testSubsequentAsyncGeoJSONUpdateCancelsExisting() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let originalWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 2)
        XCTAssertTrue(originalWorkItem.isCancelled)
        let replacingWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations[1].parameters)
        XCTAssertFalse(replacingWorkItem.isCancelled)
    }

    func testRemoveGeoJSONSourceCancelsAsyncParsing() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: []))

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let workItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        try sourceManager.removeSource(withId: id)

        // then
        XCTAssertTrue(workItem.isCancelled)
    }

    func testAsyncGeoJSONUpdateCancelsAdd() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        let geoJSONObject = GeoJSONObject.featureCollection(FeatureCollection(features: []))
        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let addWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        try sourceManager.updateGeoJSONSource(withId: id, geoJSON: geoJSONObject)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 2)
        XCTAssertTrue(addWorkItem.isCancelled)
        let updateWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations[1].parameters)
        XCTAssertFalse(updateWorkItem.isCancelled)
    }

    func testGeoJSONWithNilDataAddedImmediately() throws {
        let source = GeoJSONSource()
        let id = String.randomASCII(withLength: 10)

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson"] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 0)
    }

    func testGeoJSONWithEmptyDataAddedImmediately() throws {
        var source = GeoJSONSource()
        source.data = .empty
        let id = String.randomASCII(withLength: 10)

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 0)
    }

    func testAddGeoJSONAddsSourceWithEmptyDataInitially() throws {
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource()
        source.data = .featureCollection(FeatureCollection(features: []))

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
    }

    func testAddGeoJSONSourceWithURL() throws {
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource()
        let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson")!
        source.data = .url(url)
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }
        mainQueue.asyncClosureStub.defaultSideEffect = { $0.parameters.work() }

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 1)
        let setSourcePropertyParams = try XCTUnwrap(styleManager.setStyleSourcePropertyStub.invocations.first?.parameters)
        XCTAssertEqual(setSourcePropertyParams.sourceId, id)
        XCTAssertEqual(setSourcePropertyParams.property, "data")
        XCTAssertEqual(setSourcePropertyParams.value as? String, url.absoluteString)
    }

    func testAddGeoJSONSourceWithEmptyData() throws {
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource()
        source.data = .empty
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }
        mainQueue.asyncClosureStub.defaultSideEffect = { $0.parameters.work() }

        try sourceManager.addSource(source, id: id)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 0)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 0)
    }
}
