import UIKit

public enum OrnamentPosition: String, Equatable {
    // Clockwise from top left
    case topLeft
    case topCenter
    case topRight
    case centerRight
    case bottomRight
    case bottomCenter
    case bottomLeft
    case centerLeft
}

public enum OrnamentVisibility: String, Equatable {
    case adaptive
    case hidden
    case visible
}

internal class OrnamentsManager: NSObject {

    /// The `OrnamentOptions` that is used to set up the required ornaments on the map
    internal var options: OrnamentOptions {
        didSet {
            assert(options.isValid, "More than one ornament in a single position.")
            updateOrnaments()
        }
    }

    private let logoView: LogoView
    private let scalebarView: MapboxScaleBarOrnamentView
    private let compassView: MapboxCompassOrnamentView
    private let infoButton: MapboxInfoButtonOrnament

    private var constraints = [NSLayoutConstraint]()

    internal init(view: OrnamentSupportableView, options: OrnamentOptions) {
        self.options = options

        // Logo View
        logoView = LogoView(logoSize: .regular)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)

        // Scalebar View
        scalebarView = MapboxScaleBarOrnamentView()
        scalebarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scalebarView)

        // Compass View
        compassView = MapboxCompassOrnamentView(visibility: options.compassVisibility)
        compassView.translatesAutoresizingMaskIntoConstraints = false
        compassView.tapAction = { [weak view] in
            view?.compassTapped()
        }
        view.addSubview(compassView)

        // Info Button
        infoButton = MapboxInfoButtonOrnament()
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoButton)

        super.init()

        updateOrnaments()

        // Subscribe to updates for scalebar and compass
        view.subscribeCameraChangeHandler { [scalebarView, compassView] (cameraOptions) in
            if let zoom = cameraOptions.zoom,
               let center = cameraOptions.center {
                scalebarView.metersPerPoint = Projection.getMetersPerPixelAtLatitude(
                    forLatitude: center.latitude,
                    zoom: Double(zoom))
            }
            if let bearing = cameraOptions.bearing {
                compassView.currentBearing = Double(bearing)
            }
        }
    }

    private func updateOrnaments() {
        // 1. Move ornaments to correct locations (use margins & position from self.options)
        // remove previously-added constraints
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()

        // TODO: re-create new constraints for each view (and add them to the `constraints` array)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        // 2. Sync visiblity using .isHidden on each ornament view; For ornaments that support `adaptive` visibility, adaptive should map to isHidden = false. The ornament view itself should use `alpha` to when it wants to hide based on some other input. See the change handler above.

        logoView.isHidden = !options._logoViewIsVisible
        scalebarView.isHidden = options.scaleBarVisibility == .hidden
        compassView.isHidden = options.compassVisibility == .hidden
        infoButton.isHidden = !options._attributionButtonIsVisible
    }
}
