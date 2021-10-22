import CoreLocation
import MapboxCoreMaps
import UIKit

/// This enum represents the different styles of pucks that can be generated
internal enum PuckAccuracy {
    case reduced
    case full
}

/// An object that is responsible for managing the location indicator which can be view based, or layer based
internal final class LocationPuckManager {

    var puckType: PuckType? {
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
            puck.puckAccuracy = puckAccuracy
            puck.puckBearingSource = puckBearingSource
            self.puck = puck
        }
    }

    var puckAccuracy: PuckAccuracy = .full {
        didSet {
            puck?.puckAccuracy = puckAccuracy
        }
    }

    var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            puck?.puckBearingSource = puckBearingSource
        }
    }

    private var puck: Puck? {
        didSet {
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
