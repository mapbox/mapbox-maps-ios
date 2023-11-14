@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class MockMapSnapshotter: MockStyleManager, MapSnapshotterProtocol {

    public typealias SnapshotCompletion = (Expected<CoreMapSnapshot, NSString>) -> Void

    var setSizeStub = Stub<Size, Void>()
    func setSizeFor(_ size: Size) {
        setSizeStub.call(with: size)
    }

    var getSizeStub = Stub<Void, Size>(defaultReturnValue: .init(width: 0, height: 0))
    func getSize() -> Size {
        getSizeStub.call()
    }

    var isInTileModeStub = Stub<Void, Bool>(defaultReturnValue: .random())
    func isInTileMode() -> Bool {
        isInTileModeStub.call()
    }

    var setTileModeStub = Stub<Bool, Void>()
    func setTileModeForSet(_ set: Bool) {
        setTileModeStub.call(with: set)
    }

    var getCameraStateStub = Stub<Void, CoreCameraState>(defaultReturnValue: .init(center: CLLocationCoordinate2D.random(), padding: CoreEdgeInsets.init(top: Double.random(in: 0..<100), left: Double.random(in: 0..<100), bottom: Double.random(in: 0..<100), right: Double.random(in: 0..<100)), zoom: .random(in: 0...22), bearing: .random(in: 0...360), pitch: .random(in: 0...90)))
    func getCameraState() -> CoreCameraState {
        getCameraStateStub.call()
    }

    var startStub = Stub<SnapshotCompletion, Void>()
    func start(forCallback: @escaping SnapshotCompletion) {
        startStub.call(with: forCallback)
    }

    var cancelSnapshotterStub = Stub<Void, Void>()
    func cancel() {
        cancelSnapshotterStub.call()
    }

    var setCameraStub = Stub<CoreCameraOptions, Void>()
    func setCameraFor(_ cameraOptions: CoreCameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }

    struct CameraForCoordinatesParams: Equatable {
        var coordinates: [Coordinate2D]
        var padding: CoreEdgeInsets?
        var bearing: NSNumber?
        var pitch: NSNumber?
    }

    var cameraForCoordinatesStub = Stub<CameraForCoordinatesParams, CoreCameraOptions>(defaultReturnValue: .init(.random()))
    func cameraForCoordinates(for coordinates: [Coordinate2D], padding: CoreEdgeInsets?, bearing: NSNumber?, pitch: NSNumber?) -> CoreCameraOptions {
        cameraForCoordinatesStub.call(with: CameraForCoordinatesParams(coordinates: coordinates, padding: padding, bearing: bearing, pitch: pitch))
    }

    var coordinateBoundsForCameraStub = Stub<CoreCameraOptions, CoordinateBounds>(defaultReturnValue: .init(southwest: .random(), northeast: .random()))
    func coordinateBoundsForCamera(forCamera camera: CoreCameraOptions) -> CoordinateBounds {
        coordinateBoundsForCameraStub.call(with: camera)
    }

    struct TileCoverParams {
        var options: CoreTileCoverOptions
        var cameraOptions: CoreCameraOptions?
    }
    var tileCoverStub = Stub<TileCoverParams, [CanonicalTileID]>(defaultReturnValue: [])
    func __tileCover(for options: CoreTileCoverOptions, cameraOptions: CoreCameraOptions?) -> [CanonicalTileID] {
        tileCoverStub.call(with: TileCoverParams(options: options, cameraOptions: cameraOptions))
    }
}
