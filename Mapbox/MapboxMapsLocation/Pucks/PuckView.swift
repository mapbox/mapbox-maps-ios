import Turf
import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

class PuckView: Puck {

    // MARK: Properties
    var puckView: UIView?

    // MARK: Protocol Properties
    var puckStyle: PuckStyle

    weak var locationSupportableMapView: LocationSupportableMapView?

    // MARK: Initializers
    init(currentPuckStyle: PuckStyle, locationSupportableMapView: LocationSupportableMapView) {
        self.puckStyle = currentPuckStyle
        self.locationSupportableMapView = locationSupportableMapView
    }

    // MARK: Protocol Implementation
    func updateLocation(location: Location) {
        if let puckView = self.puckView,
           let newCenter = getCenter(for: location) {

            if !locationOutOfBounds(center: newCenter) {
                puckView.center = newCenter
            }

            if let precisePuckView = self.puckView as? PrecisePuckView {
                precisePuckView.updateAccuracyRing(with: calculateAccuracyRing(location: location))
            }
        } else {
            self.updateStyle(puckStyle: self.puckStyle, location: location)
        }

    }

    func updateStyle(puckStyle: PuckStyle, location: Location) {
        guard let locationSupportableMapView = self.locationSupportableMapView,
              let center = getCenter(for: location)
        else { return }

        // Remove what exists
        removePuck()

        switch puckStyle {
        case .precise:
            let puckView = PrecisePuckView(origin: center)
            puckView.configure(with: locationSupportableMapView.tintColor, and: calculateAccuracyRing(location: location))
            self.puckView = puckView
        case .approximate:
            let puckView = ApproximatePuckView(origin: center)
            puckView.configure(with: locationSupportableMapView.tintColor, and: calculateAccuracyRing(location: location))
            self.puckView = puckView
        }

        locationSupportableMapView.addSubview(self.puckView!)
        self.puckStyle = puckStyle
    }

    func removePuck() {
        guard let puckView = self.puckView else { return }

        puckView.removeFromSuperview()

        self.puckView = nil
    }
}

// MARK: Private Helper Functions
private extension PuckView {

    /// Determines if the point is with in the bounds of the map view on screen
    /// The 150.0 pixels accounts for if the location is about to come onto screen
    func locationOutOfBounds(center: CGPoint) -> Bool {
        guard let locationSupportableMapView = self.locationSupportableMapView else { return true }

        /// Accounts for if the location is going to come into the screen
        let viewportRect = locationSupportableMapView.bounds.insetBy(dx: -150.0, dy: -150.0)

        if viewportRect.contains(center) { return false }

        return true
    }

    /// Get the location center point as a screen coordinate
    func getCenter(for location: Location) -> CGPoint? {
        guard let locationSupportableMapView = self.locationSupportableMapView else { return nil }

        let coordinates = locationSupportableMapView.screenCoordinate(for: location.coordinate)
        let center = CGPoint(x: coordinates.x, y: coordinates.y)

        return center
    }

    /// Diameter in screen points
    func calculateAccuracyRing(location: Location) -> CGFloat {
        guard let locationSupportableMapView = self.locationSupportableMapView else { return 0.0 }

        let metersPerPointAtLatitude = locationSupportableMapView.metersPerPointAtLatitude(latitude: location.coordinate.latitude)
        let horizontalAccuracy = location.horizontalAccuracy

        return CGFloat(round(horizontalAccuracy / metersPerPointAtLatitude * 2.0))
    }

    func getHeadingDirectionAsFloat(location: Location) -> CGFloat {
        guard let magneticHeading = location.headingDirection else { return 0.0 }

        return CGFloat(magneticHeading)
    }

    func rotate(for layer: CALayer, headingDirection: CGFloat) {
        let rotationAngle = Double(headingDirection).toRadians()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        layer.setAffineTransform(transform)

        CATransaction.commit()
    }
}

// MARK: Shared View Manipulation Extension
extension UIView {
    func circleLayerWithSize(layerSize: CGFloat) -> CALayer? {
        let layerSize = round(layerSize)

        let circleLayer = CALayer(layer: layer)
        circleLayer.bounds = CGRect(x: 0, y: 0, width: layerSize, height: layerSize)
        circleLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleLayer.cornerRadius = layerSize / 2.0
        circleLayer.shouldRasterize = true
        circleLayer.rasterizationScale = UIScreen.main.scale
        circleLayer.drawsAsynchronously = true

        return circleLayer
    }
}
