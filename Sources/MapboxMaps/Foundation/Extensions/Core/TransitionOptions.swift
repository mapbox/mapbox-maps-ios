import Foundation
extension MapboxCoreMaps.TransitionOptions {
    public convenience init(duration: TimeInterval?,
                            delay: TimeInterval?,
                            enablePlacementTransitions: Bool?){

        self.init(__duration: duration.map(NSNumber.init(value:)), delay: delay.map(NSNumber.init(value:)), enablePlacementTransitions: enablePlacementTransitions.map(NSNumber.init(value:)))
    }
}
