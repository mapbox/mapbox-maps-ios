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
        let type = try XCTUnwrap(types.randomElement())
        let json = ["type": type.rawValue, "id": id]
        guard let source = try type.sourceType?.init(jsonObject: json) else {
            XCTFail("Expected to return a valid source")
            return
        }

        try sourceManager.addSource(source)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)

        var expectedProperties = json
        expectedProperties.removeValue(forKey: "id")
        XCTAssertEqual(params.properties as? NSDictionary, expectedProperties as NSDictionary)
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

    func testRemoveSourceUnchecked() throws {
        let id = String.randomASCII(withLength: 23)
        styleManager.removeStyleSourceUncheckedStub.defaultReturnValue = Expected(error: "No such source")
        XCTAssertThrowsError(try sourceManager.removeSourceUnchecked(withId: id))
        XCTAssertEqual(styleManager.removeStyleSourceUncheckedStub.invocations.count, 1)

        styleManager.removeStyleSourceUncheckedStub.defaultReturnValue = Expected(value: NSNull())
        try sourceManager.removeSourceUnchecked(withId: id)
        XCTAssertEqual(styleManager.removeStyleSourceUncheckedStub.invocations.count, 2)
        XCTAssertEqual(styleManager.removeStyleSourceUncheckedStub.invocations.first?.parameters, id)
    }

    func testStyleCanCheckIfSourceExist() {
        styleManager.styleSourceExistsStub.defaultReturnValue = true
        XCTAssertTrue(sourceManager.sourceExists(withId: "dummy-source-id"))
        XCTAssertEqual(styleManager.styleSourceExistsStub.invocations.count, 1)

        styleManager.styleSourceExistsStub.defaultReturnValue = false
        XCTAssertFalse(sourceManager.sourceExists(withId: "non-exist-source-id"))
        XCTAssertEqual(styleManager.styleSourceExistsStub.invocations.count, 2)
    }

    func testUpdateGeoJSONSourceDispatchesParsingOnABackgroundThread() throws {
        let id = String.randomASCII(withLength: 10)

        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
    }

    func testUpdateGeoJSONSourceWithDataIDDispatchesParsingOnABackgroundThread() throws {
        let id = "TestSourceID"
        let dataId = "TestdataId"
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
    }

    func testDirectAsyncUpdateGeoJSONCallsPassesConvertedDataOnBackground() throws {
        let id = String.randomASCII(withLength: 10)
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.count, 1)
        let setGeoJSONParams = try XCTUnwrap(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.first?.parameters)
        XCTAssertEqual(setGeoJSONParams.sourceId, id)
        XCTAssertTrue((setGeoJSONParams.data.getNSArray()).isEmpty)
    }

    func testDirectAsyncUpdateGeoJSONCallsPassesConvertedDataOnBackgroundWithDataID() throws {
        let id = "TestSourceID"
        let dataId = "TestdataId"
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.count, 1)
        let setGeoJSONParams = try XCTUnwrap(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.first?.parameters)
        XCTAssertEqual(setGeoJSONParams.sourceId, id)
        XCTAssertTrue((setGeoJSONParams.data.getNSArray()).isEmpty)
        XCTAssertEqual(setGeoJSONParams.dataId, dataId)
    }

    func testAsyncGeoJSONUpdateSkipsParsingWhenCancelled() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)

        let workItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)
        workItem.cancel()

        // when
        workItem.perform()

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 0)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 0)
    }

    func testAsyncGeoJSONUpdateSkipsParsingWhenCancelledWithDataID() throws {
        // given
        let id = "TestSourceID"
        let dataId = "TestdataId"
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)

        let workItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)
        workItem.cancel()

        // when
        workItem.perform()

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 0)
        XCTAssertEqual(styleManager.setStyleSourcePropertyStub.invocations.count, 0)
    }

    func testMultipleDistinctDirectAsyncGeoJSONUpdateDoNotCancelEachOtherOut() throws {
        // given
        let iterations = 100
        let id = String.randomASCII(withLength: 10)
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        // when
        for _ in 0..<iterations {
            sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)
        }

        // then
        XCTAssertEqual(
            backgroundQueue.asyncWorkItemStub.invocations.filter { $0.parameters.isCancelled }.count,
            iterations - 1
        )

        backgroundQueue.asyncWorkItemStub.invocations.forEach { $0.parameters.perform() }

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, iterations)
        XCTAssertEqual(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.count, 1)
    }

    func testMultipleDistinctDirectAsyncGeoJSONUpdateDoNotCancelEachOtherOutWithDataID() throws {
        // given
        let iterations = 100
        let id = "TestSourceID"
        let dataId = "TestdataId"
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        // when
        for _ in 0..<iterations {
            sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)
        }

        // then
        XCTAssertEqual(
            backgroundQueue.asyncWorkItemStub.invocations.filter { $0.parameters.isCancelled }.count,
            iterations - 1
        )

        backgroundQueue.asyncWorkItemStub.invocations.forEach { $0.parameters.perform() }

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, iterations)
        XCTAssertEqual(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.count, 1)
    }

    func testSubsequentAsyncGeoJSONUpdateCancelsExisting() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let originalWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 2)
        XCTAssertTrue(originalWorkItem.isCancelled)
        let replacingWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations[1].parameters)
        XCTAssertFalse(replacingWorkItem.isCancelled)
    }

    func testSubsequentAsyncGeoJSONUpdateCancelsExistingWithDataID() throws {
        // given
        let id = "TestSourceID"
        let dataId = "TestdataId"
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let originalWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 2)
        XCTAssertTrue(originalWorkItem.isCancelled)
        let replacingWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations[1].parameters)
        XCTAssertFalse(replacingWorkItem.isCancelled)
    }

    func testRemoveGeoJSONSourceCancelsAsyncParsing() throws {
        // given
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource(id: id)
        source.data = .featureCollection(FeatureCollection(features: []))

        try sourceManager.addSource(source)

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
        var source = GeoJSONSource(id: id)
        source.data = .featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.addSource(source)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let addWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: nil)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 2)
        XCTAssertTrue(addWorkItem.isCancelled)
        let updateWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations[1].parameters)
        XCTAssertFalse(updateWorkItem.isCancelled)
    }

    func testAsyncGeoJSONUpdateCancelsAddWithDataID() throws {
        // given
        let id = "TestSourceID"
        let dataId = "TestdataId"
        var source = GeoJSONSource(id: id)
        source.data = .featureCollection(FeatureCollection(features: []))
        styleManager.getStyleSourcesStub.defaultReturnValue = [StyleObjectInfo(id: id, type: SourceType.geoJson.rawValue)]

        try sourceManager.addSource(source)

        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        let addWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations.first?.parameters)

        // when
        sourceManager.updateGeoJSONSource(withId: id, data: .emptyFeatureCollection(), dataId: dataId)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 2)
        XCTAssertTrue(addWorkItem.isCancelled)
        let updateWorkItem = try XCTUnwrap(backgroundQueue.asyncWorkItemStub.invocations[1].parameters)
        XCTAssertFalse(updateWorkItem.isCancelled)
    }

    func testAddGeoJSONAddsSourceWithFeatureCollection() throws {
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource(id: id)
        let feature = Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 10, longitude: 20))))
        let featureCollection = FeatureCollection(features: [feature])
        source.data = .featureCollection(featureCollection)

        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        try sourceManager.addSource(source)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let addSourceParams = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(addSourceParams.sourceId, id)
        XCTAssertEqual(addSourceParams.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)

        let setSourceParams = try XCTUnwrap(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.first?.parameters)
        XCTAssertEqual(setSourceParams.sourceId, id)
        XCTAssertEqual(setSourceParams.data.type, .nsArray)
        let coreFeatures = setSourceParams.data.getNSArray()
        XCTAssertEqual(coreFeatures.count, 1)
        let firstFeature = Feature(try XCTUnwrap(coreFeatures.first))
        XCTAssertEqual(firstFeature.geometry, feature.geometry)

    }

    func testDirectAddGeoJSONSourceWithURL() throws {
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource(id: id)
        let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson")!
        source.data = .url(url)
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        try sourceManager.addSource(source)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.count, 1)
        let setStyleGeoJSONSourceDataForSourceIdParams = try XCTUnwrap(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.first?.parameters)
        XCTAssertEqual(setStyleGeoJSONSourceDataForSourceIdParams.sourceId, id)
        XCTAssertEqual(setStyleGeoJSONSourceDataForSourceIdParams.data.getNSString(), url.absoluteString)
    }

    func testAddGeoJSONSourceWithString() throws {
        let id = String.randomASCII(withLength: 10)
        var source = GeoJSONSource(id: id)
        let geoJSON = """
        {
          "type": "FeatureCollection",
          "features": [
            { "type": "Feature", "geometry": { "type": "Point", "coordinates": [ -151.5129, 63.1016 ] } }
          ]
        }
        """
        source.data = .string(geoJSON)
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        try sourceManager.addSource(source)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 1)
        XCTAssertEqual(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.count, 1)
        let setStyleGeoJSONSourceDataForSourceIdParams = try XCTUnwrap(styleManager.setStyleGeoJSONSourceDataForSourceIdDataIDStub.invocations.first?.parameters)
        XCTAssertEqual(setStyleGeoJSONSourceDataForSourceIdParams.sourceId, id)
        XCTAssertEqual(setStyleGeoJSONSourceDataForSourceIdParams.data.getNSString(), geoJSON)
    }

    func testAddGeoJSONSourceWithNilData() throws {
        let id = String.randomASCII(withLength: 10)
        let source = GeoJSONSource(id: id)
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }
        mainQueue.asyncClosureStub.defaultSideEffect = { $0.parameters.work() }

        try sourceManager.addSource(source)

        XCTAssertEqual(styleManager.addStyleSourceStub.invocations.count, 1)
        let params = try XCTUnwrap(styleManager.addStyleSourceStub.invocations.first?.parameters)
        XCTAssertEqual(params.sourceId, id)
        XCTAssertEqual(params.properties as? NSDictionary, ["type": "geojson", "data": ""] as? NSDictionary)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 0)
        XCTAssertEqual(mainQueue.asyncClosureStub.invocations.count, 0)
    }

    func testAddGeoJSONSourceFeatures() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let dataId = String.randomASCII(withLength: 11)
        let point = Point(.random())
        let featureIdentifier = Double.random(in: 0...1000)
        var feature = Feature.init(geometry: point.geometry)
        feature.identifier = .number(featureIdentifier)
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        // when
        sourceManager.addGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: dataId)

        // then
        XCTAssertEqual(styleManager.addGeoJSONSourceFeaturesStub.invocations.count, 1)
        let parameters = try XCTUnwrap(styleManager.addGeoJSONSourceFeaturesStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.sourceId, sourceId)
        XCTAssertEqual(parameters.features.count, 1)
        XCTAssertEqual(parameters.dataId, dataId)
        let resultFeature = try XCTUnwrap(parameters.features.first)
        XCTAssertEqual(resultFeature.geometry.extractLocations()?.coordinateValue(), point.coordinates)
        XCTAssertEqual((resultFeature.identifier as? NSNumber)?.doubleValue, featureIdentifier)
    }

    func testUpdateGeoJSONSourceFeatures() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let dataId = String.randomASCII(withLength: 11)
        let point = Point(.random())
        let featureIdentifier = Double.random(in: 0...1000)
        var feature = Feature.init(geometry: point.geometry)
        feature.identifier = .number(featureIdentifier)
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        // when
        sourceManager.updateGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: dataId)

        // then
        XCTAssertEqual(styleManager.updateGeoJSONSourceFeaturesStub.invocations.count, 1)
        let parameters = try XCTUnwrap(styleManager.updateGeoJSONSourceFeaturesStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.sourceId, sourceId)
        XCTAssertEqual(parameters.features.count, 1)
        XCTAssertEqual(parameters.dataId, dataId)
        let resultFeature = try XCTUnwrap(parameters.features.first)
        XCTAssertEqual(resultFeature.geometry.extractLocations()?.coordinateValue(), point.coordinates)
        XCTAssertEqual((resultFeature.identifier as? NSNumber)?.doubleValue, featureIdentifier)
    }

    func testPartialUpdateAPIsDontCancelPreviousUpdates() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let point = Point(.random())
        let featureIdentifier = Double.random(in: 0...1000)
        var feature = Feature.init(geometry: point.geometry)
        feature.identifier = .number(featureIdentifier)

        // when
        sourceManager.updateGeoJSONSource(withId: sourceId, data: .emptyFeatureCollection(), dataId: nil)
        sourceManager.addGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: nil)
        sourceManager.updateGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: nil)
        sourceManager.removeGeoJSONSourceFeatures(forSourceId: sourceId,
                                                  featureIds: [featureIdentifier.description],
                                                  dataId: nil)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 4)
        XCTAssertTrue(backgroundQueue.asyncWorkItemStub.invocations.allSatisfy { !$0.parameters.isCancelled })
    }

    func testFullUpdateAPIsCancelsAllPreviousUpdates() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let point = Point(.random())
        let featureIdentifier = Double.random(in: 0...1000)
        var feature = Feature.init(geometry: point.geometry)
        feature.identifier = .number(featureIdentifier)

        sourceManager.updateGeoJSONSource(withId: sourceId, data: .emptyFeatureCollection(), dataId: nil)
        sourceManager.addGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: nil)
        sourceManager.updateGeoJSONSourceFeatures(forSourceId: sourceId, features: [feature], dataId: nil)
        sourceManager.removeGeoJSONSourceFeatures(forSourceId: sourceId,
                                                      featureIds: [featureIdentifier.description],
                                                      dataId: nil)

        // when
        sourceManager.updateGeoJSONSource(withId: sourceId, data: .emptyFeatureCollection(), dataId: nil)

        // then
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.count, 5)
        XCTAssertEqual(backgroundQueue.asyncWorkItemStub.invocations.filter(\.parameters.isCancelled).count, 4)
        XCTAssertFalse(backgroundQueue.asyncWorkItemStub.invocations.last!.parameters.isCancelled)
    }

    func testRemoveGeoJSONSourceFeatures() throws {
        // given
        let sourceId = String.randomASCII(withLength: 10)
        let dataId = String.randomASCII(withLength: 11)
        let featureIdentifiers = (0...10).map { String.randomASCII(withLength: $0) }
        backgroundQueue.asyncWorkItemStub.defaultSideEffect = { $0.parameters.perform() }

        // when
        sourceManager.removeGeoJSONSourceFeatures(forSourceId: sourceId, featureIds: featureIdentifiers, dataId: dataId)

        // then
        XCTAssertEqual(styleManager.removeGeoJSONSourceFeaturesStub.invocations.count, 1)
        let parameters = try XCTUnwrap(styleManager.removeGeoJSONSourceFeaturesStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.sourceId, sourceId)
        XCTAssertEqual(parameters.featureIds, featureIdentifiers)
        XCTAssertEqual(parameters.dataId, dataId)
    }
}

private extension GeoJSONSourceData {
    static func emptyFeatureCollection() -> GeoJSONSourceData {
        return .featureCollection(FeatureCollection(features: []))
    }
}
