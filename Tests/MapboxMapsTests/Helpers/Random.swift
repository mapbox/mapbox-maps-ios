import Foundation
@testable import MapboxMaps

extension Character {
    static func randomASCII() -> Self {
        return Character(UnicodeScalar(.random(in: 0x20...0x7E))!)
    }
}

extension String {
    static func randomASCII(withLength length: UInt) -> Self {
        return (0..<length).reduce(into: "") { s, _ in s.append(.randomASCII()) }
    }
}

extension StyleColor {
    static func random() -> Self {
        return StyleColor(
            red: .random(in: 0...255),
            green: .random(in: 0...255),
            blue: .random(in: 0...255),
            alpha: .random(in: 0...1))!
    }
}

extension Array {
    static func random(withLength length: UInt, generator: () -> Element) -> Self {
        return (0..<length).reduce(into: []) { array, _ in array.append(generator()) }
    }
}

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

extension CGPoint {
    static func random() -> Self {
        return CGPoint(
            x: .random(in: -100...100),
            y: .random(in: -100...100))
    }
}

extension CLLocationCoordinate2D {
    static func random() -> Self {
        return CLLocationCoordinate2D(
            latitude: .random(in: -90...90),
            longitude: .random(in: -180..<180))
    }
}

extension UIEdgeInsets {
    static func random() -> Self {
        return UIEdgeInsets(
            top: .random(in: 0...100),
            left: .random(in: 0...100),
            bottom: .random(in: 0...100),
            right: .random(in: 0...100))
    }
}
