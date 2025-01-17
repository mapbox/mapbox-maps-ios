import SwiftUI
import UIKit

/// Specifies the animation for the map ``Viewport``.
public struct ViewportAnimation {
    /// Viewport transition factory closure.
    public typealias ViewportTransitionFactory = (MapView) -> ViewportTransition

    /// A closure that creates a viewport transition using the MapView.
    public var makeViewportTransition: ViewportTransitionFactory

    /// A default viewport animation.
    ///
    /// The default animation tries to provide best-looking animation for every viewport transition.
    ///
    /// - Note: It's recommended to use the default animation with ``Viewport/followPuck(zoom:bearing:pitch:)``
    /// viewport, because it supports moving animation target (user location puck).
    public static var `default`: ViewportAnimation {
        return ViewportAnimation { mapView in
            return mapView.viewport.makeDefaultViewportTransition(options: .init())
        }
    }

    /// A default animation with the specified maximum duration.
    ///
    /// The default animation tries to provide best-looking animation for every viewport transition.
    ///
    /// - Note: It's recommended to use the default animation with ``Viewport/followPuck(zoom:bearing:pitch:)``
    /// viewport, because it supports moving animation target (user location puck).
    ///
    /// - Parameters:
    ///   - maxDuration: The maximum duration of the animation, measured in seconds.
    /// - Returns: A default viewport animation.
    public static func `default`(maxDuration: TimeInterval) -> ViewportAnimation {
        return ViewportAnimation { mapView in
            return mapView.viewport.makeDefaultViewportTransition(options: .init(maxDuration: maxDuration))
        }
    }

    /// A fly animation.
    ///
    /// The fly animation usually follows the zoom-out, flight, zoom-in pattern in animation.
    /// The duration of the animation will be calculated automatically.
    public static var fly: ViewportAnimation {
        return ViewportAnimation { mapView in
            GenericViewportTransition { cameraOptions, completion in
                mapView.camera.fly(to: cameraOptions, duration: nil, completion: completion)
            }
        }
    }

    /// A fly animation with a specified duration.
    ///
    /// The fly animation usually follows the zoom-out, flight, zoom-in pattern in animation.
    ///
    /// - Parameters:
    ///   - duration: Duration of the animation, measured in seconds.
    /// - Returns: A fly animation.
    public static func fly(duration: TimeInterval) -> ViewportAnimation {
        return ViewportAnimation { mapView in
            GenericViewportTransition { cameraOptions, completion in
                mapView.camera.fly(to: cameraOptions, duration: duration, completion: completion)
            }
        }
    }

    /// An animation that starts quickly and then slows towards the end.
    ///
    /// - Parameters:
    ///   - duration: Duration of the animation, measured in seconds.
    /// - Returns: An ease-out animation.
    public static func easeOut(duration: TimeInterval) -> ViewportAnimation {
        return .ease(curve: .easeOut, duration: duration)
    }

    /// An animation that starts slowly and then speeds up towards the end.
    ///
    /// - Parameters:
    ///   - duration: Duration of the animation, measured in seconds.
    /// - Returns: An ease-in animation.
    public static func easeIn(duration: TimeInterval) -> ViewportAnimation {
        return .ease(curve: .easeIn, duration: duration)
    }

    /// An animation that combines behavior of ease-in and ease-out animations
    ///
    /// - Parameters:
    ///   - duration: Duration of the animation, measured in seconds.
    /// - Returns: An ease-in-out animation.
    public static func easeInOut(duration: TimeInterval) -> ViewportAnimation {
        return .ease(curve: .easeInOut, duration: duration)
    }

    /// An animation that moves at a constant speed.
    ///
    /// - Parameters:
    ///   - duration: Duration of the animation, measured in seconds.
    /// - Returns: A linear animation.
    public static func linear(duration: TimeInterval) -> ViewportAnimation {
        return .ease(curve: .linear, duration: duration)
    }

    private static func ease(curve: UIView.AnimationCurve, duration: TimeInterval) -> ViewportAnimation {
        return ViewportAnimation { mapView in
            GenericViewportTransition { cameraOptions, completion in
                mapView.camera.ease(to: cameraOptions, duration: duration, curve: curve, completion: completion)
            }
        }
    }
}

private final class GenericViewportTransition: ViewportTransition {
    typealias AnimationRunner = (CameraOptions, @escaping AnimationCompletion) -> Void
    private let runAnimation: AnimationRunner

    internal init(runAnimation: @escaping AnimationRunner) {
        self.runAnimation = runAnimation
    }

    public func run(to toState: ViewportState,
                    completion: @escaping (Bool) -> Void) -> Cancelable {
        return toState.observeDataSource { [runAnimation] cameraOptions in
            runAnimation(cameraOptions) { animationPosition in
                completion(animationPosition == .end)
            }
            return false
        }
    }
}

struct ViewportAnimationData {
    var animation: ViewportAnimation
    var completion: ((Bool) -> Void)?
}

/// Applies the animation to the map viewport.
///
/// Use this function to apply animation to viewport change.
///
/// ```swift
/// @Binding viewport: Viewport
///
/// var body: some View {
///     Button("Animate viewport") {
///         withViewportAnimation {
///             viewport = .camera(...)
///         }
///     }
/// }
/// ```
///
/// See ``Viewport`` and ``ViewportAnimation`` documentation for more details.
public func withViewportAnimation<Result>(
    _ animation: ViewportAnimation = .default,
    body: () throws -> Result,
    completion: ((Bool) -> Void)? = nil
) rethrows -> Result {
    var transaction = Transaction()
    transaction.viewportAnimationData = ViewportAnimationData(animation: animation, completion: completion)
    return try withTransaction(transaction, body)
}

#if swift(>=5.9)

@available(iOS 17.0, *)
private struct MapAnimationTransactionKey: TransactionKey {
    static let defaultValue: ViewportAnimationData? = nil
}

#endif

extension Transaction {
    var viewportAnimationData: ViewportAnimationData? {
        get {
            // Custom Transaction properties via subscript are only supported starting from iOS 17 and Xcode 15.
            // For older iOS versions we use the `GlobalAnimationStore` to carry the animations options
            // to the Map.updateUIViewController method.
#if swift(>=5.9)
            if #available(iOS 17.0, *) {
                return self[MapAnimationTransactionKey.self]
            }
#endif
            let data = GlobalAnimationStore.viewportAnimationData
            // This options should be used only once in update method to prevent undesired animation.
            GlobalAnimationStore.viewportAnimationData = nil
            return data
        }
        set {
#if swift(>=5.9)
            if #available(iOS 17.0, *) {
                self[MapAnimationTransactionKey.self] = newValue
            } else {
                GlobalAnimationStore.viewportAnimationData = newValue
            }
#else
            GlobalAnimationStore.viewportAnimationData = newValue
#endif
        }
    }
}

private struct GlobalAnimationStore {
    static var viewportAnimationData: ViewportAnimationData?
}
