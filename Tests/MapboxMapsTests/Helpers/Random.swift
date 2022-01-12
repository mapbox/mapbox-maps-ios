import Foundation
import CoreLocation
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

extension Location {
    static func random() -> Location {
        return Location(
            location: .random(),
            heading: .random(MockHeading()),
            accuracyAuthorization: .random())
    }
}

extension CLAccuracyAuthorization {
    static func random() -> Self {
        return .random() ? .fullAccuracy : .reducedAccuracy
    }
}

extension CLLocation {
    static func random() -> CLLocation {
        return CLLocation(
            latitude: .random(in: -89...89),
            longitude: .random(in: -180..<180))
    }
}

extension Optional {
    static func random(_ generator: @autoclosure () -> Wrapped) -> Self {
        return .random() ? .none : .some(generator())
    }
}

extension FollowingViewportStateBearing {
    static func random() -> Self {
        return [
            .constant(.random(in: 0..<360)),
            .heading,
            .course
        ].randomElement()!
    }
}

extension FollowingViewportStateOptions {
    static func random() -> Self {
        return FollowingViewportStateOptions(
            zoom: .random(in: 0...20),
            pitch: .random(in: 0...80),
            bearing: .random(),
            padding: .random(),
            animationDuration: .random(in: -2...2))
    }
}

extension DefaultViewportTransitionOptions {
    static func random() -> Self {
        return DefaultViewportTransitionOptions(
            maxDuration: .random(in: 0...20))
    }
}

extension ViewportStatus {
    static func random() -> Self {
        return [
            .state(.random(MockViewportState())),
            .transition(MockViewportTransition(), fromState: .random(MockViewportState()), toState: MockViewportState())
        ].randomElement()!
    }
}

extension ViewportOptions {
    static func random() -> Self {
        return ViewportOptions(
            transitionsToIdleUponUserInteraction: .random())
    }
}
