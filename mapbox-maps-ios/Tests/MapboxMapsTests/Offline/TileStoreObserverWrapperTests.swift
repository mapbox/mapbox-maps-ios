import XCTest
@_implementationOnly import MapboxCommon_Private
@testable import MapboxMaps

final class TileStoreObserverWrapperTests: XCTestCase {

    var observer: MockTileStoreObserver!
    var wrapper: TileStoreObserverWrapper!
    var id: String!

    override func setUp() {
        super.setUp()
        observer = MockTileStoreObserver()
        wrapper = TileStoreObserverWrapper(observer)
        id = .randomASCII(withLength: 10)
    }

    override func tearDown() {
        id = nil
        wrapper = nil
        observer = nil
        super.tearDown()
    }

    func testOnRegionLoadProgress() {
        let progress = TileRegionLoadProgress(
            completedResourceCount: 0,
            completedResourceSize: 0,
            erroredResourceCount: 0,
            requiredResourceCount: 0,
            loadedResourceCount: 0,
            loadedResourceSize: 0)

        wrapper.onRegionLoadProgress(forId: id, progress: progress)

        XCTAssertEqual(observer.onRegionLoadProgressStub.invocations.count, 1)
        XCTAssertEqual(observer.onRegionLoadProgressStub.invocations.first?.parameters.id, id)
        XCTAssertTrue(observer.onRegionLoadProgressStub.invocations.first?.parameters.progress === progress)
    }

    func testOnRegionLoadFinishedWithValidValue() throws {
        let tileRegion = TileRegion(
            id: "",
            requiredResourceCount: 0,
            completedResourceCount: 0,
            completedResourceSize: 0,
            expires: nil,
            extraData: nil)
        let expected = Expected<TileRegion, MapboxCommon.TileRegionError>(value: tileRegion)

        wrapper.onRegionLoadFinished(forId: id, region: expected)

        XCTAssertEqual(observer.onRegionLoadFinishedStub.invocations.count, 1)
        let parameters = try XCTUnwrap(observer.onRegionLoadFinishedStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.id, id)
        guard case .success(let regionParameter) = parameters.region else {
            XCTFail("Expected region parameter to be Result.success, but found \(parameters.region)")
            return
        }
        XCTAssertTrue(tileRegion === regionParameter)
    }

    func testOnRegionLoadFinishedWithValidError() throws {
        let types: [TileRegionErrorType] = [.canceled, .diskFull, .doesNotExist, .other, .tileCountExceeded, .tilesetDescriptor]
        let error = MapboxCommon.TileRegionError(type: types.randomElement()!, message: .randomASCII(withLength: 10))
        let expected = Expected<TileRegion, MapboxCommon.TileRegionError>(error: error)

        wrapper.onRegionLoadFinished(forId: id, region: expected)

        XCTAssertEqual(observer.onRegionLoadFinishedStub.invocations.count, 1)
        let parameters = try XCTUnwrap(observer.onRegionLoadFinishedStub.invocations.first?.parameters)
        XCTAssertEqual(parameters.id, id)
        guard case .failure(let e) = parameters.region, let tileRegionError = e as? MapboxMaps.TileRegionError else {
            XCTFail("Expected region parameter to be Result.failure with error of type TileRegionError, but found \(parameters.region)")
            return
        }
        XCTAssertEqual(tileRegionError, TileRegionError(coreError: error))
    }

    func testOnRegionRemoved() {
        wrapper.onRegionRemoved(forId: id)

        XCTAssertEqual(observer.onRegionRemovedStub.invocations.map(\.parameters), [id!])
    }

    func testOnRegionGeometryChanged() {
        let geometry = Geometry.point(Point(.random()))

        wrapper.onRegionGeometryChanged(forId: id, geometry: MapboxCommon.Geometry(geometry))

        XCTAssertEqual(observer.onRegionGeometryChangedStub.invocations.count, 1)
        XCTAssertEqual(observer.onRegionGeometryChangedStub.invocations.first?.parameters.id, id)
        XCTAssertEqual(observer.onRegionGeometryChangedStub.invocations.first?.parameters.geometry, geometry)
    }

    func testOnRegionMetadataChanged() {
        let value = Int.random(in: 0...10)

        wrapper.onRegionMetadataChanged(forId: id, value: value)

        XCTAssertEqual(observer.onRegionMetadataChangedStub.invocations.count, 1)
        XCTAssertEqual(observer.onRegionMetadataChangedStub.invocations.first?.parameters.id, id)
        XCTAssertEqual(observer.onRegionMetadataChangedStub.invocations.first?.parameters.value as? Int, value)
    }
}
