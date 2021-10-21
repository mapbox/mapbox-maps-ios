/// This protocol is used to help manipulate the different type of puck views we have
internal protocol Puck: AnyObject {

    var isActive: Bool { get set }

    /// Property that stores the current `PuckPrecision` of the puck
    var puckPrecision: PuckPrecision { get set }

    /// Property that stores the current `PuckBearingSource` of the puck
    var puckBearingSource: PuckBearingSource { get set }
}
