internal protocol Puck: AnyObject {
    var isActive: Bool { get set }
    var puckBearing: PuckBearing { get set }
    var puckBearingEnabled: Bool { get set }
}

internal protocol Puck2DProtocol: Puck {
    var configuration: Puck2DConfiguration { get set }
}

internal protocol Puck3DProtocol: Puck {
    var configuration: Puck3DConfiguration { get set }
}
