internal protocol PuckRenderer: AnyObject {
    var isActive: Bool { get set }
    var puckBearing: PuckBearing { get set }
    var puckBearingEnabled: Bool { get set }
}

internal protocol Puck2DRendererProtocol: PuckRenderer {
    var configuration: Puck2DConfiguration { get set }
}

internal protocol Puck3DRendererProtocol: PuckRenderer {
    var configuration: Puck3DConfiguration { get set }
}
