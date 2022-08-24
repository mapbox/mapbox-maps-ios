@testable import MapboxMaps
@_implementationOnly import MapboxCommon_Private

final class MockMapSnapshot: MapSnapshotProtocol {
    @Stubbed var options: MapboxCoreMaps.MapSnapshotOptions?

    var screenCoordinateStub = Stub<CLLocationCoordinate2D, MapboxCoreMaps.ScreenCoordinate>(defaultReturnValue: .init(x: Double(0), y: Double(0)))
    func screenCoordinate(for coordinate: CLLocationCoordinate2D) -> MapboxCoreMaps.ScreenCoordinate {
        screenCoordinateStub.call(with: coordinate)
    }

    var coordinateStub = Stub<MapboxCoreMaps.ScreenCoordinate, CLLocationCoordinate2D>(defaultReturnValue: .random())
    func coordinate(for screenCoordinate: MapboxCoreMaps.ScreenCoordinate) -> CLLocationCoordinate2D {
        coordinateStub.call(with: screenCoordinate)
    }

    var attributionStub = Stub<Void, [String]>(defaultReturnValue: [.randomASCII(withLength: .random(in: 1...10))])
        func attributions() -> [String] {
        attributionStub.call()
    }

    class var testImage: UIImage? {
        if #available(iOS 13.0, *) {
          return UIImage(systemName: "house")
        } else {
          return nil
        }
      }

    var imageStub = Stub<Void, Image>(defaultReturnValue: .init(uiImage: testImage!)!)
    func image() -> Image {
        imageStub.call()
    }

}
