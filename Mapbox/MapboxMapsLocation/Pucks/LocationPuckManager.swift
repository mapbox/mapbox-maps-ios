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

// MARK: PuckBackend
/// This enum represents the different backends that can be used for Pucks
public enum LocationPuck: Equatable {
    case layer2d(customize: ((inout LocationIndicatorLayerViewModel) -> Void)? = nil) // Backed by `LocationIndicatorLayer`. Implement customize block to granularly modify the puck's styling.
    case layer3d(customize: ((inout PuckModelLayerViewModel) -> Void))// Backed by `ModelLayer`
    case view // Backed by `PuckView` which is a `UIView`

    public static func == (lhs: LocationPuck, rhs: LocationPuck) -> Bool {
        switch (lhs, rhs) {
        case (.view, .view):
            return true
        case (.layer2d(_), .layer2d(_)):
            return true
        case (.layer3d(_), .layer3d(_)):
            return true
        default:
            return false
        }
    }
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

    /// Stores the current  puck style
    internal var currentPuckStyle: PuckStyle

    /// Stores the current backend that should be used to render the puck
    internal var currentPuckBackend: LocationPuck

    public init(shouldTrackLocation: Bool,
                locationSupportableMapView: LocationSupportableMapView,
                currentPuckSource: LocationPuck) {
        self.currentPuckStyle = .precise
        self.currentPuckBackend = currentPuckSource
        self.shouldTrackLocation = shouldTrackLocation
        self.locationSupportableMapView = locationSupportableMapView
    }

    /// LocationConsumer protocol method that will handle location updates
    public func locationUpdate(newLocation: Location) {
        guard self.shouldTrackLocation else {
            removePuck()
            return
        }

        if let puck = self.puck {
            puck.updateLocation(location: newLocation)
        } else {
            // Puck does not exist so we need to create one
            createPuck()
        }

        self.latestLocation = newLocation
    }

    internal func createPuck() {
        guard let locationSupportableMapView = self.locationSupportableMapView else { return }
        var puck: Puck

        switch self.currentPuckBackend {
        case .view:
            puck = PuckView(currentPuckStyle: self.currentPuckStyle, locationSupportableMapView: locationSupportableMapView)
            subscribeRendererFrameHandler()
        case let .layer2d(customizationHandler):
            puck = PuckLocationIndicatorLayer(currentPuckStyle: self.currentPuckStyle, locationSupportableMapView: locationSupportableMapView, customizationHandler: customizationHandler)
        case let .layer3d(customizationHandler):
            puck = PuckModelLayer(currentPuckStyle: self.currentPuckStyle, locationSupportableMapView: locationSupportableMapView, customizationHandler: customizationHandler)
        }

        if let location = self.latestLocation {
            puck.updateStyle(puckStyle: self.currentPuckStyle, location: location)
        }

        self.puck = puck
    }

    internal func removePuck() {
        guard let puck = self.puck else { return }

        puck.removePuck()
        self.puck = nil
    }

    internal func changePuckBackend(newPuckBackend: LocationPuck) {
        removePuck()
        self.currentPuckBackend = newPuckBackend
        createPuck()
    }

    internal func changePuckStyle(newPuckStyle: PuckStyle) {
        self.currentPuckStyle = newPuckStyle

        if let puck = self.puck,
           let location = self.latestLocation {
            puck.updateStyle(puckStyle: newPuckStyle, location: location)
        } else {
            createPuck()
        }
    }

    /// Update the puck whenever a new frame is rendered
    /// Only needed for View backed Pucks
    private func subscribeRendererFrameHandler() {
        guard let locationSupportableMapView = self.locationSupportableMapView else { return }

        locationSupportableMapView.subscribeRenderFrameHandler { [weak self] (_) in

            guard let self = self,
                  let latestLocation = self.latestLocation,
                  let puck = self.puck
            else { return }

            if self.currentPuckBackend == .view {
                puck.updateLocation(location: latestLocation)
            }
        }
    }
}
