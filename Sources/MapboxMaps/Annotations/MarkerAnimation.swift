import SwiftUI

/// Defines the visual effect of a marker animation.
///
/// Use predefined animation effects to animate markers when they appear or disappear from the map:
///
/// ```swift
/// Marker(coordinate: coordinate)
///     .animation(.wiggle, when: .appear)
///     .animation(.fadeOut, when: .disappear)
/// ```
@_documentation(visibility: public)
@_spi(Experimental)
public struct MarkerAnimationEffect {
    internal enum Effect {
        case wiggle
        case scale(from: Double, to: Double)
        case fade(from: Double, to: Double)
    }

    internal let value: Effect

    /// Wiggle animation (20° → -20° → 8° → -8° → 0°).
    public static let wiggle = MarkerAnimationEffect(value: .wiggle)

    /// Scale animation (default: 0 to 1).
    public static let scale = MarkerAnimationEffect(value: .scale(from: 0.0, to: 1.0))

    /// Scale animation with custom range.
    ///
    /// - Parameters:
    ///   - from: Starting scale value
    ///   - to: Ending scale value
    public static func scale(from: Double, to: Double) -> MarkerAnimationEffect {
        MarkerAnimationEffect(value: .scale(from: from, to: to))
    }

    /// Fade in animation (0 to 1 opacity).
    public static let fadeIn = MarkerAnimationEffect(value: .fade(from: 0.0, to: 1.0))

    /// Fade out animation (1 to 0 opacity).
    public static let fadeOut = MarkerAnimationEffect(value: .fade(from: 1.0, to: 0.0))

    /// Fade animation with custom range.
    ///
    /// - Parameters:
    ///   - from: Starting opacity value
    ///   - to: Ending opacity value
    public static func fade(from: Double, to: Double) -> MarkerAnimationEffect {
        MarkerAnimationEffect(value: .fade(from: from, to: to))
    }

}

/// Defines when a marker animation should be triggered.
@_documentation(visibility: public)
@_spi(Experimental)
public struct MarkerAnimationTrigger: Hashable {
    private let rawValue: String

    /// Animation triggers when marker first appears.
    public static let appear = MarkerAnimationTrigger(rawValue: "appear")

    /// Animation triggers when marker is removed.
    public static let disappear = MarkerAnimationTrigger(rawValue: "disappear")
}

/// Wiggle animation sequence with structured keyframes.
struct MarkerWiggleSequence {
    struct Keyframe {
        let angle: Double
        let duration: TimeInterval  // Time to wait before this keyframe
        let response: Double
        let dampingFraction: Double
    }

    let initialAngle: Double = 20.0
    let totalDuration: TimeInterval = 1.2

    // Wiggle sequence: 20° → -20° → 8° → -8° → 0°
    // Pure rotation - swings like a pendulum for smooth, natural motion
    // Duration indicates how long to wait before executing this keyframe
    let keyframes: [Keyframe] = [
        Keyframe(angle: -20.0, duration: 0.0, response: 0.6, dampingFraction: 0.6),   // Start immediately
        Keyframe(angle: 8.0, duration: 0.35, response: 0.35, dampingFraction: 0.7),   // After 0.35s
        Keyframe(angle: -8.0, duration: 0.30, response: 0.3, dampingFraction: 0.75),  // After 0.30s
        Keyframe(angle: 0.0, duration: 0.25, response: 0.25, dampingFraction: 0.85)   // After 0.25s
    ]
}
