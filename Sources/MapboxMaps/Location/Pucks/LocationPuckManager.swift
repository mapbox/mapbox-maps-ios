import CoreLocation
import MapboxCoreMaps
import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

#if canImport(MapboxMapsStyle)
import MapboxMapsStyle
#endif

// MARK: PuckStyle Enum
/// This enum represents the different styles of pucks that can be generated
internal enum PuckStyle {
    case approximate
    case precise
}

// MARK: PuckType
/// This enum represents the different types of pucks
public enum PuckType: Equatable {
    /// A 2-dimensional puck. Optionally provide `Puck2DConfiguration` to configure the puck's appearance.
    case puck2D(Puck2DConfiguration? = nil)

    /// A 3-dimensional puck. Provide a `Puck3DConfiguration` to configure the puck's appearance.
    case puck3D(Puck3DConfiguration)
}

// MARK: LocationPuckManager
/// An object that is responsible for managing the location indicator which can be view based, or layer based
internal class LocationPuckManager: LocationConsumer {

    /// Represents the latest location received from the location provider
    private var latestLocation: Location?

    /// The visual representation of a location on a map
    private var puck: Puck?

    /// MapView that supports location events
    internal private(set) weak var locationSupportableMapView: LocationSupportableMapView?

    /// The current  puck style
    internal private(set) var puckStyle: PuckStyle

    /// The current puck type
    internal private(set) var puckType: PuckType

    internal init(locationSupportableMapView: LocationSupportableMapView,
                  puckType: PuckType) {
        puckStyle = .precise
        self.puckType = puckType
        self.locationSupportableMapView = locationSupportableMapView
    }

    deinit {
        puck?.removePuck()
    }

    /// LocationConsumer protocol method that will handle location updates
    internal func locationUpdate(newLocation: Location) {
        if let puck = self.puck {
            puck.updateLocation(location: newLocation)
        } else {
            // Puck does not exist so we need to create one
            createPuck()
        }

        latestLocation = newLocation
    }

    internal func createPuck() {
        guard let locationSupportableMapView = self.locationSupportableMapView else { return }
        var puck: Puck

        switch puckType {
        case let .puck2D(configuration):
            puck = Puck2D(puckStyle: puckStyle, locationSupportableMapView: locationSupportableMapView, configuration: configuration)
        case let .puck3D(configuration):
            puck = Puck3D(puckStyle: puckStyle, locationSupportableMapView: locationSupportableMapView, configuration: configuration)
        }

        if let location = latestLocation {
            puck.updateStyle(puckStyle: puckStyle, location: location)
        }

        self.puck = puck
    }

    internal func removePuck() {
        guard let puck = self.puck else { return }

        puck.removePuck()
        self.puck = nil
    }

    internal func changePuckType(to newPuckType: PuckType) {
        removePuck()
        puckType = newPuckType
        createPuck()
    }

    internal func changePuckStyle(to newPuckStyle: PuckStyle) {
        puckStyle = newPuckStyle

        if let puck = self.puck,
           let location = latestLocation {
            puck.updateStyle(puckStyle: newPuckStyle, location: location)
        } else {
            createPuck()
        }
    }
}
