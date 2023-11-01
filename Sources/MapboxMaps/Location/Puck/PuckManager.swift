import CoreLocation
import MapboxCoreMaps
import UIKit

internal protocol PuckManagerProtocol: AnyObject {
    var puckType: PuckType? { get set }
    var puckBearing: PuckBearing { get set }
    var puckBearingEnabled: Bool { get set }
}

internal final class PuckManager: PuckManagerProtocol {
    private enum State {
        case none
        case puck2D(Puck2DRendererProtocol)
        case puck3D(Puck3DRendererProtocol)

        var puck: PuckRenderer? {
            switch self {
            case .none: return nil
            case let .puck2D(p): return p
            case let .puck3D(p): return p
            }
        }
    }

    internal var puckType: PuckType? {
        didSet {
            // if puckType is nil, set puck to nil and return early
            guard let puckType else {
                state = .none
                return
            }
            // if the non-nil puckType hasn't changed, return early
            guard puckType != oldValue else {
                return
            }

            switch (state, puckType) {
            case let (.puck2D(puck2D), .puck2D(config)):
                puck2D.configuration = config
            case let (.puck3D(puck3D), .puck3D(config)):
                puck3D.configuration = config
            default:
                recreatePuck(with: puckType)
            }
        }
    }

    internal var puckBearing: PuckBearing = .heading {
        didSet {
            state.puck?.puckBearing = puckBearing
        }
    }

    internal var puckBearingEnabled: Bool = false {
        didSet {
            state.puck?.puckBearingEnabled = puckBearingEnabled
        }
    }

    private var state: State = .none {
        didSet {
            // this order is important so that if they're the same type of puck,
            // the old one doesn't remove the layer/source added by the new one.
            oldValue.puck?.isActive = false
            state.puck?.isActive = true
        }
    }

    private let puck2DProvider: (Puck2DConfiguration) -> Puck2DRendererProtocol
    private let puck3DProvider: (Puck3DConfiguration) -> Puck3DRendererProtocol

    internal init(puck2DProvider: @escaping (Puck2DConfiguration) -> Puck2DRendererProtocol,
                  puck3DProvider: @escaping (Puck3DConfiguration) -> Puck3DRendererProtocol) {
        self.puck2DProvider = puck2DProvider
        self.puck3DProvider = puck3DProvider
    }

    private func recreatePuck(with type: PuckType) {
        let newState: State
        switch type {
        case .puck2D(let configuration):
            newState = .puck2D(puck2DProvider(configuration))
        case .puck3D(let configuration):
            newState = .puck3D(puck3DProvider(configuration))
        }
        newState.puck?.puckBearing = puckBearing
        newState.puck?.puckBearingEnabled = puckBearingEnabled
        self.state = newState
    }
}
