import Foundation
extension MapboxCoreMaps.TransitionOptions {
    public convenience init(duration: NSNumber,
                            delay: NSNumber,
                            enablePlacementTransitions: NSNumber.BooleanLiteralType? = nil){

        self.init(__duration: duration, delay: delay, enablePlacementTransitions: enablePlacementTransitions as NSNumber?)
    }
}
