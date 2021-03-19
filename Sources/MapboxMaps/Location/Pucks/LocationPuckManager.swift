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
    /// A 2-dimensional puck. Optionally provide `LocationIndicatorViewModel` to configure the puck's appearance.
    case puck2D(LocationIndicatorLayerViewModel? = nil)

    /// A 3-dimensional puck. Provide a `PuckModelLayerViewModel` to configure the puck's appearance.
    case puck3D(PuckModelLayerViewModel)
}

// MARK: LocationPuckManager
/// An object that is responsible for managing the location indicator which can be view based, or layer based
public class LocationPuckManager: LocationConsumer {

    /// LocationConsumer protocol property that establishes if tracking is active
    public var shouldTrackLocation: Bool

    /// Represents the latest location received from the location provider
    private var latestLocation: Location?

    /// The visual representation of a location on a map
    private var puck: Puck?

    /// MapView that supports location events
    weak var locationSupportableMapView: LocationSupportableMapView?

    /// The current  puck style
    internal var currentPuckStyle: PuckStyle

    /// The current puck type
    internal var currentPuckType: PuckType

    public init(shouldTrackLocation: Bool,
                locationSupportableMapView: LocationSupportableMapView,
                currentPuckType: PuckType) {
        currentPuckStyle = .precise
        self.currentPuckType = currentPuckType
        self.shouldTrackLocation = shouldTrackLocation
        self.locationSupportableMapView = locationSupportableMapView
    }

    /// LocationConsumer protocol method that will handle location updates
    public func locationUpdate(newLocation: Location) {
        guard shouldTrackLocation else {
            removePuck()
            return
        }

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

        switch currentPuckType {
        case let .puck2D(viewModel):
            puck = PuckLocationIndicatorLayer(currentPuckStyle: currentPuckStyle, locationSupportableMapView: locationSupportableMapView, viewModel: viewModel)
        case let .puck3D(viewModel):
            puck = PuckModelLayer(currentPuckStyle: currentPuckStyle, locationSupportableMapView: locationSupportableMapView, viewModel: viewModel)
        }

        if let location = latestLocation {
            puck.updateStyle(puckStyle: currentPuckStyle, location: location)
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
        currentPuckType = newPuckType
        createPuck()
    }

    internal func changePuckStyle(to newPuckStyle: PuckStyle) {
        currentPuckStyle = newPuckStyle

        if let puck = self.puck,
           let location = latestLocation {
            puck.updateStyle(puckStyle: newPuckStyle, location: location)
        } else {
            createPuck()
        }
    }
}
