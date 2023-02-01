import MapboxMaps

extension CameraState {
    static func random() -> Self {
        return CameraState(
            center: .random(),
            padding: .random(),
            zoom: .random(in: 0...20),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...50))
    }
}
