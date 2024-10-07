import MapboxMaps

extension CameraOptions {
    static func testConstantValue() -> Self {
        return CameraOptions(
            center: .init(latitude: 10, longitude: 10),
            padding: .init(top: 40, left: 29, bottom: 98, right: 83),
            anchor: .init(x: -28, y: -74),
            zoom: 71,
            bearing: 93,
            pitch: 45)

    }
}
