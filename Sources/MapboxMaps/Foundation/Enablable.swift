internal protocol EnablableProtocol: AnyObject {
    var isEnabled: Bool { get }
}

internal protocol MutableEnablableProtocol: EnablableProtocol {
    var isEnabled: Bool { get set }
}

internal final class Enablable: MutableEnablableProtocol {
    internal var isEnabled = true
}
