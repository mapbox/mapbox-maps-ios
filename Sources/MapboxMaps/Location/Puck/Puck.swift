internal protocol Puck: DisplayLinkParticipant {
    var isActive: Bool { get set }

    var puckBearingSource: PuckBearingSource { get set }

    var puckBearingEnabled: Bool { get set }
}
