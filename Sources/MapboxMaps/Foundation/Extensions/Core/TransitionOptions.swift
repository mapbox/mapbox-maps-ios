import Foundation

/**
 * The `TransitionOptions` control timing for the interpolation between a transitionable style
 * property's previous value and new value. These can be used to define the style default property
 * transition behavior. Also, any transitionable style property may also have its own `-transition`
 * property that defines specific transition timing for that specific layer property, overriding
 * the global transition values.
 */
public struct TransitionOptions: Equatable, Sendable {
    /// Initializes `TransitionOptions` with provided `duration`, `delay` and `enablePlacementTransitions` flag.
    /// - Parameters:
    ///   - duration: Time allotted for transitions to complete.
    ///   - delay: Length of time before the transition begins.
    ///   - enablePlacementTransitions: Whether the fade in/out symbol placement transition is enabled.
    public init(duration: TimeInterval? = nil,
                delay: TimeInterval? = nil,
                enablePlacementTransitions: Bool? = nil) {
        self.duration = duration
        self.delay = delay
        self.enablePlacementTransitions = enablePlacementTransitions
    }

    /// Time allotted for transitions to complete. Defaults to `0.3` seconds.
    public var duration: TimeInterval?

    /// Length of time before a transition begins. Defaults to `0.0` seconds.
    public var delay: TimeInterval?

    /// Whether the fade in/out symbol placement transition is enabled. Defaults to `true`.
    public var enablePlacementTransitions: Bool?

    internal init(_ objValue: MapboxCoreMaps.TransitionOptions) {
        self.init(duration: objValue.__duration?.doubleValue,
                  delay: objValue.__delay?.doubleValue,
                  enablePlacementTransitions: objValue.__enablePlacementTransitions?.boolValue)
    }

    internal var coreOptions: MapboxCoreMaps.TransitionOptions {
        .init(self)
    }
}

extension MapboxCoreMaps.TransitionOptions {
    internal convenience init(_ swiftValue: TransitionOptions) {
        self.init(__duration: swiftValue.duration.map(NSNumber.init(value:)),
                  delay: swiftValue.delay.map(NSNumber.init(value:)),
                  enablePlacementTransitions: swiftValue.enablePlacementTransitions.map(NSNumber.init(value:)))
    }
}

@_spi(Experimental)
extension TransitionOptions: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.transition, value: self))
    }
}
