import XCTest
import MapboxCommon_Private
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

        assertMethodCall(observer.onRegionLoadProgressStub)
        XCTAssertEqual(observer.onRegionLoadProgressStub.parameters.first?.id, id)
        XCTAssertTrue(observer.onRegionLoadProgressStub.parameters.first?.progress === progress)
    }

    func testOnRegionLoadFinishedWithValidValue() throws {
        let tileRegion = TileRegion(
            id: "",
            requiredResourceCount: 0,
            completedResourceCount: 0,
            completedResourceSize: 0,
            expires: nil)
        let expected = Expected<AnyObject, AnyObject>(value: tileRegion)

        wrapper.onRegionLoadFinished(forId: id, region: expected)

        assertMethodCall(observer.onRegionLoadFinishedStub)
        let parameters = try XCTUnwrap(observer.onRegionLoadFinishedStub.parameters.first)
        XCTAssertEqual(parameters.id, id)
        guard case .success(let regionParameter) = parameters.region else {
            XCTFail("Expected region parameter to be Result.success, but found \(parameters.region)")
            return
        }
        XCTAssertTrue(tileRegion === regionParameter)
    }

    func testOnRegionLoadFinishedWithInalidValue() throws {
        let expected = Expected<AnyObject, AnyObject>(value: NSNull())

        wrapper.onRegionLoadFinished(forId: id, region: expected)

        assertMethodCall(observer.onRegionLoadFinishedStub)
        let parameters = try XCTUnwrap(observer.onRegionLoadFinishedStub.parameters.first)
        XCTAssertEqual(parameters.id, id)
        guard case .failure(TypeConversionError.unexpectedType) = parameters.region else {
            XCTFail("Expected region parameter to be Result.failure(TypeConversionError.unexpectedType), but found \(parameters.region)")
            return
        }
    }

    func testOnRegionLoadFinishedWithValidError() throws {
        let types: [TileRegionErrorType] = [.canceled, .diskFull, .doesNotExist, .other, .tileCountExceeded, .tilesetDescriptor]
        let error = MapboxCommon.TileRegionError(type: types.randomElement()!, message: .randomASCII(withLength: 10))
        let expected = Expected<AnyObject, AnyObject>(error: error)

        wrapper.onRegionLoadFinished(forId: id, region: expected)

        assertMethodCall(observer.onRegionLoadFinishedStub)
        let parameters = try XCTUnwrap(observer.onRegionLoadFinishedStub.parameters.first)
        XCTAssertEqual(parameters.id, id)
        guard case .failure(let e) = parameters.region, let tileRegionError = e as? MapboxMaps.TileRegionError else {
            XCTFail("Expected region parameter to be Result.failure with error of type TileRegionError, but found \(parameters.region)")
            return
        }
        XCTAssertEqual(tileRegionError, TileRegionError(coreError: error))
    }

    func testOnRegionLoadFinishedWithInvalidError() throws {
        let expected = Expected<AnyObject, AnyObject>(error: NSError())
        wrapper.onRegionLoadFinished(forId: id, region: expected)

        assertMethodCall(observer.onRegionLoadFinishedStub)
        let parameters = try XCTUnwrap(observer.onRegionLoadFinishedStub.parameters.first)
        XCTAssertEqual(parameters.id, id)
        guard case .failure(TypeConversionError.unexpectedType) = parameters.region else {
            XCTFail("Expected region parameter to be Result.failure(TypeConversionError.unexpectedType), but found \(parameters.region)")
            return
        }
    }

    func testOnRegionRemoved() {
        wrapper.onRegionRemoved(forId: id)

        XCTAssertEqual(observer.onRegionRemovedStub.parameters, [id!])
    }

    func testOnRegionGeometryChanged() {
        let geometry = Geometry.point(Point(.random()))

        wrapper.onRegionGeometryChanged(forId: id, geometry: MapboxCommon.Geometry(geometry))

        assertMethodCall(observer.onRegionGeometryChangedStub)
        XCTAssertEqual(observer.onRegionGeometryChangedStub.parameters.first?.id, id)
        XCTAssertEqual(observer.onRegionGeometryChangedStub.parameters.first?.geometry, geometry)
    }

    func testOnRegionMetadataChanged() {
        let value = Int.random(in: 0...10)

        wrapper.onRegionMetadataChanged(forId: id, value: value)

        assertMethodCall(observer.onRegionMetadataChangedStub)
        XCTAssertEqual(observer.onRegionMetadataChangedStub.parameters.first?.id, id)
        XCTAssertEqual(observer.onRegionMetadataChangedStub.parameters.first?.value as? Int, value)
    }
}
