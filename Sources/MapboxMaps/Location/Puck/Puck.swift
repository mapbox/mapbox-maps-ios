internal protocol Puck: AnyObject {
    var isActive: Bool { get set }

    var puckBearing: PuckBearing { get set }

    var puckBearingEnabled: Bool { get set }
}
