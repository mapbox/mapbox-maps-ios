import Foundation
extension TransitionOptions {
    /// Initializes `TransitionOptions` with provided `duration`, `delay` and `enablePlacementTransitions` flag.
    /// - Parameters:
    ///   - duration: Time allotted for transitions to complete.
    ///   - delay: Length of time before the transition begins.
    ///   - enablePlacementTransitions: Whether the fade in/out symbol placement transition is enabled.
    public convenience init(duration: TimeInterval?,
                            delay: TimeInterval?,
                            enablePlacementTransitions: Bool?) {

        self.init(__duration: duration.map(NSNumber.init(value:)), delay: delay.map(NSNumber.init(value:)), enablePlacementTransitions: enablePlacementTransitions.map(NSNumber.init(value:)))
    }

    /// Time allotted for transitions to complete. Units in milliseconds. Defaults to `300.0`.
    public var duration: TimeInterval? {
        __duration?.doubleValue
    }

    /// Length of time before a transition begins. Units in milliseconds. Defaults to `0.0`.
    public var delay: TimeInterval? {
        __delay?.doubleValue
    }

    /// Whether the fade in/out symbol placement transition is enabled. Defaults to `true`.
    public var enablePlacementTransitions: Bool? {
        __enablePlacementTransitions?.boolValue
    }
}
