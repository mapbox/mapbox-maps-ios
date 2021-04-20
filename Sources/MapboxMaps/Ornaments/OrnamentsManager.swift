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

        // Update the position for the ornaments
        infoButton.
        // TODO: re-create new constraints for each view (and add them to the `constraints` array)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        // 2. Sync visiblity using .isHidden on each ornament view; For ornaments that support `adaptive` visibility, adaptive should map to isHidden = false. The ornament view itself should use `alpha` to when it wants to hide based on some other input. See the change handler above.

        logoView.isHidden = !options._logoViewIsVisible
        scalebarView.isHidden = options.scaleBarVisibility == .hidden
        compassView.isHidden = options.compassVisibility == .hidden
        infoButton.isHidden = !options._attributionButtonIsVisible
    }

    func constraints(with view: UIView, position: OrnamentPosition, margin: CGPoint) -> [NSLayoutConstraint {
        switch position {
        case .topLeft:
            return [view.leadingAnchor.constraint(equalTo: universalLayoutGuide.leadingAnchor,
                                          constant: margin.x),
                    

        case .topCenter:

        case .topRight:

        case .centerLeft:

        case .centerRight:

        case .bottomLeft:

        case .bottomCenter:

        case .bottomRight:
        }
    }

    internal var universalLayoutGuide: UILayoutGuide {
            if #available(iOS 11.0, *) {
                return self.view.safeAreaLayoutGuide
            } else {
                let layoutGuideIdentifier = "mapboxSafeAreaLayoutGuide"
                // If there's already a generated layout guide, return it
                if let layoutGuide = view.layoutGuides.filter({ $0.identifier == layoutGuideIdentifier }).first {
                    return layoutGuide
                } else {
                    // If not, then make a new one based off the view's edges.
                    let layoutGuide = UILayoutGuide()
                    layoutGuide.identifier = layoutGuideIdentifier
                    view.addLayoutGuide(layoutGuide)

                    NSLayoutConstraint.activate([
                        layoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        layoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        layoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
                        layoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    ])

                    return layoutGuide
                }
            }
        }
}
