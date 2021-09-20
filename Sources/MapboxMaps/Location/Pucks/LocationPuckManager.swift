import CoreLocation
import MapboxCoreMaps
import UIKit

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
    case puck2D(Puck2DConfiguration = Puck2DConfiguration())

    /// A 3-dimensional puck. Provide a `Puck3DConfiguration` to configure the puck's appearance.
    case puck3D(Puck3DConfiguration)
}

// MARK: PuckBearingSource
/// This enum controls how the puck is oriented
public enum PuckBearingSource: Equatable {
    /// A setting that tells the puck to orient the bearing using `heading: CLHeading`
    case heading

    /// A setting that tells the puck to orient the bearing using `course: CLLocationDirection`
    case course
}

// MARK: LocationPuckManager
/// An object that is responsible for managing the location indicator which can be view based, or layer based
internal class LocationPuckManager: LocationConsumer {

    /// Represents the latest location received from the location provider
    private var latestLocation: Location?

    /// The visual representation of a location on a map
    private var puck: Puck?

    /// Style protocol that supports limited style APIs
    internal private(set) weak var style: LocationStyleProtocol?

    /// The current  puck style. The default value is ``PuckStyle.precise``
    internal private(set) var puckStyle: PuckStyle

    /// The current puck type
    internal private(set) var puckType: PuckType

    /// The type of value that should be passed for bearing. The default value is ``PuckBearingSource.heading``.
    internal var puckBearingSource: PuckBearingSource = .heading {
        didSet {
            puck?.puckBearingSource = puckBearingSource
        }
    }

    internal init(style: LocationStyleProtocol?,
                  puckType: PuckType,
                  puckBearingSource: PuckBearingSource) {
        puckStyle = .precise
        self.puckType = puckType
        self.puckBearingSource = puckBearingSource
        self.style = style
    }

    /// ``LocationConsumer`` protocol method that will handle location updates
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
        guard let style = style else {
            return
        }

        var puck: Puck

        switch puckType {
        case let .puck2D(configuration):
            puck = Puck2D(puckStyle: puckStyle,
                          puckBearingSource: puckBearingSource,
                          style: style,
                          configuration: configuration)
        case let .puck3D(configuration):
            puck = Puck3D(puckStyle: puckStyle,
                          puckBearingSource: puckBearingSource,
                          style: style,
                          configuration: configuration)
        }

        if let location = latestLocation {
            puck.updateStyle(puckStyle: puckStyle, location: location)
        }

        self.puck = puck
    }

    internal func changePuckType(to newPuckType: PuckType) {
        puck = nil
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
