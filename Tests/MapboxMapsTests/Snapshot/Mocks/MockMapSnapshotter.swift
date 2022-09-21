@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class MockMapSnapshotter: MockStyleManager, MapSnapshotterProtocol {

    public typealias SnapshotCompletion = (Expected<MapSnapshot, NSString>) -> Void

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

    var getCameraStateStub = Stub<Void, MapboxCoreMaps.CameraState>(defaultReturnValue: .init(center: CLLocationCoordinate2D.random(), padding: MapboxCoreMaps.EdgeInsets.init(top: Double.random(in: 0..<100), left: Double.random(in: 0..<100), bottom: Double.random(in: 0..<100), right: Double.random(in: 0..<100)), zoom: .random(in: 0...22), bearing: .random(in: 0...360), pitch: .random(in: 0...90)))
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

    struct CameraForCoordinatesParams: Equatable {
        var coordinates: [CLLocation]
        var padding: EdgeInsets
        var bearing: NSNumber?
        var pitch: NSNumber?
    }

    var cameraForCoordinatesStub = Stub<CameraForCoordinatesParams, MapboxCoreMaps.CameraOptions>(defaultReturnValue: .init(.random()))
    func cameraForCoordinates(forCoordinates coordinates: [CLLocation], padding: EdgeInsets, bearing: NSNumber?, pitch: NSNumber?) -> MapboxCoreMaps.CameraOptions {
        cameraForCoordinatesStub.call(with: CameraForCoordinatesParams(coordinates: coordinates, padding: padding, bearing: bearing, pitch: pitch))
    }

    var coordinateBoundsForCameraStub = Stub<MapboxCoreMaps.CameraOptions, CoordinateBounds>(defaultReturnValue: .init(southwest: .random(), northeast: .random()))
    func coordinateBoundsForCamera(forCamera camera: MapboxCoreMaps.CameraOptions) -> CoordinateBounds {
        coordinateBoundsForCameraStub.call(with: camera)
    }

    struct SubscribeParams {
        var observer: Observer
        var events: [String]
    }
    var subscribeStub = Stub<SubscribeParams, Void>()
    func subscribe(for observer: Observer, events: [String]) {
        subscribeStub.call(with: SubscribeParams(observer: observer, events: events))
    }

    var unsubscribeStub = Stub<Observer, Void>()
    func unsubscribe(for observer: Observer) {
        unsubscribeStub.call(with: observer)
    }
}
