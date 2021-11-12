import CoreLocation
import MapboxCoreMaps
import UIKit

internal protocol PuckManagerProtocol: AnyObject {
    var puckType: PuckType? { get set }
    var puckBearingSource: PuckBearingSource { get set }
}

internal final class PuckManager: PuckManagerProtocol {

    internal var puckType: PuckType? {
        didSet {
            // if puckType is nil, set puck to nil and return early
            guard let puckType = puckType else {
                puck = nil
                return
            }
            // if the non-nil puckType hasn't changed, return early
            guard puckType != oldValue else {
                return
            }
            // otherwise, recreate the puck
            let puck: Puck
            switch puckType {
            case .puck2D(let configuration):
                puck = puck2DProvider(configuration)
            case .puck3D(let configuration):
                puck = puck3DProvider(configuration)
            }
            puck.puckBearingSource = puckBearingSource
            self.puck = puck
        }
    }

    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            puck?.puckBearingSource = puckBearingSource
        }
    }

    private var puck: Puck? {
        didSet {
            // this order is important so that if they're the same type of puck,
            // the old one doesn't remove the layer/source added by the new one.
            oldValue?.isActive = false
            puck?.isActive = true
        }
    }

    private let puck2DProvider: (Puck2DConfiguration) -> Puck
    private let puck3DProvider: (Puck3DConfiguration) -> Puck

    internal init(puck2DProvider: @escaping (Puck2DConfiguration) -> Puck,
                  puck3DProvider: @escaping (Puck3DConfiguration) -> Puck) {
        self.puck2DProvider = puck2DProvider
        self.puck3DProvider = puck3DProvider
    }
}
