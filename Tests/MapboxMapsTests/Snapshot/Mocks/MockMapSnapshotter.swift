@testable import MapboxMaps
import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private

final class MockMapSnapshotter: MapSnapshotterProtocol {

    @Stubbed var style: Style?
    @Stubbed var options: MapboxCoreMaps.MapSnapshotOptions?
    @Stubbed var size: Size?

    var options = MapboxCoreMaps.MapSnapshotOptions(MapSnapshotOptions(
        size: CGSize(width: 100, height: 100),
        pixelRatio: .random(in: 1...3)))

    public typealias SnapshotCompletion = (Expected<MapboxCoreMaps.MapSnapshot, NSString>) -> ()

    var setSizeStub = Stub<Size, Void>()
    func setSizeFor(_ size: Size) {
        setSizeStub.call(with: size)
    }

    var getSizeStub = Stub<Void, Size>(defaultReturnValue: .init(width: 100, height: 100))
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

    var getCameraStateStub = Stub<Void, MapboxCoreMaps.CameraState>(defaultReturnValue: .init(center: .random(), padding: MapboxCoreMaps.EdgeInsets.init(top: .zero, left: .zero, bottom: .zero, right: .zero), zoom: .random(in: 0...22), bearing: .random(in: 0...360), pitch: .random(in: 0...90)))
    func getCameraState() -> MapboxCoreMaps.CameraState {
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

    var setCameraStub = Stub<MapboxCoreMaps.CameraOptions, Void>()
    func setCameraFor(_ cameraOptions: MapboxCoreMaps.CameraOptions) {
        setCameraStub.call(with: cameraOptions)
    }

    struct CameraForCoordinatesParams {
        var coordinates: [CLLocation]
        var padding: MapboxCoreMaps.EdgeInsets
        var bearing: NSNumber?
        var pitch: NSNumber?
    }

    var cameraForCoordinatesStub = Stub<CameraForCoordinatesParams, MapboxCoreMaps.CameraOptions>(defaultReturnValue: .init(.random()))
    func cameraForCoordinates(forCoordinates coordinates: [CLLocation], padding: MapboxCoreMaps.EdgeInsets, bearing: NSNumber?, pitch: NSNumber?) -> MapboxCoreMaps.CameraOptions {
        cameraForCoordinatesStub.call(with: .init(coordinates: coordinates, padding: padding, bearing: bearing, pitch: pitch))
    }

    var coordinateBoundsStub = Stub<MapboxCoreMaps.CameraOptions, CoordinateBounds>(defaultReturnValue: .init(southwest: .random(), northeast: .random()))
    func coordinateBoundsForCamera(forCamera camera: MapboxCoreMaps.CameraOptions) -> CoordinateBounds {
        coordinateBoundsStub.call(with: camera)
    }
}
