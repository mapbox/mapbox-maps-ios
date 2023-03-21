internal protocol EnablableProtocol: AnyObject {
    var isEnabled: Bool { get }
}

internal protocol MutableEnablableProtocol: EnablableProtocol {
    var isEnabled: Bool { get set }
}

internal final class Enablable: MutableEnablableProtocol {
    internal var isEnabled = true
}

internal final class CompositeEnablable: EnablableProtocol {
    internal var isEnabled: Bool {
        enablables.allSatisfy(\.isEnabled)
    }

    private let enablables: [EnablableProtocol]

    internal init(enablables: [EnablableProtocol]) {
        self.enablables = enablables
    }
}
