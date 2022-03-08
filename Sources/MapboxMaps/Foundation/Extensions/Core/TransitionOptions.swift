import Foundation
extension TransitionOptions {
    public convenience init(duration: TimeInterval?,
                            delay: TimeInterval?,
                            enablePlacementTransitions: Bool?) {

        self.init(__duration: duration.map(NSNumber.init(value:)), delay: delay.map(NSNumber.init(value:)), enablePlacementTransitions: enablePlacementTransitions.map(NSNumber.init(value:)))
    }

    public var duration: TimeInterval? {
        __duration?.doubleValue
    }

    public var delay: TimeInterval? {
        __delay?.doubleValue
    }

    public var enablePlacementTransitions: Bool? {
        __enablePlacementTransitions?.boolValue
    }
}
