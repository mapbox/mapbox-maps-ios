import MapboxMaps

extension CameraOptions {
    static func random() -> Self {
        return CameraOptions(
            center: .random(),
            padding: .random(),
            anchor: .random(),
            zoom: .random(in: 0...20),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...50))
    }
}
