internal protocol Puck: AnyObject {
    var isActive: Bool { get set }

    var puckBearingSource: PuckBearingSource { get set }
}
