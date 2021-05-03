import UIKit

public enum OrnamentPosition: String, Equatable {
    // Clockwise from top left
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft
}

public enum OrnamentVisibility: String, Equatable {
    case adaptive
    case hidden
    case visible
}

public class OrnamentsManager: NSObject {

    /// The `OrnamentOptions` object that is used to set up and update the required ornaments on the map.
    public var options: OrnamentOptions {
        didSet {
            updateOrnaments()
        }
    }

    private let logoView: LogoView
    private let scalebarView: MapboxScaleBarOrnamentView
    private let compassView: MapboxCompassOrnamentView
    private let attributionButton: MapboxInfoButtonOrnament

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
        compassView = MapboxCompassOrnamentView(visibility: options.compassViewOptions.visibility)
        compassView.translatesAutoresizingMaskIntoConstraints = false
        compassView.tapAction = { [weak view] in
            view?.compassTapped()
        }
        view.addSubview(compassView)

        // Info Button
        attributionButton = MapboxInfoButtonOrnament()
        attributionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(attributionButton)

        super.init()

        updateOrnaments()

        // Subscribe to updates for scalebar and compass
        view.subscribeCameraChangeHandler { [scalebarView, compassView] (cameraState) in

            // Update the scale bar
            scalebarView.metersPerPoint = Projection.getMetersPerPixelAtLatitude(
                forLatitude: cameraState.center.latitude,
                zoom: Double(cameraState.zoom))

            // Update the compass
            compassView.currentBearing = Double(cameraState.bearing)

        }
    }

    private func updateOrnaments() {
        // Remove previously-added constraints
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()

        // Update the position for the ornaments
        let logoViewConstraints = constraints(with: logoView,
                                              position: options.logoViewOptions.position,
                                              margins: options.logoViewOptions.margins)
        constraints.append(contentsOf: logoViewConstraints)

        let compassViewConstraints = constraints(with: compassView,
                                                 position: options.compassViewOptions.position,
                                                 margins: options.compassViewOptions.margins)
        constraints.append(contentsOf: compassViewConstraints)

        let scaleBarViewConstraints = constraints(with: scalebarView,
                                                  position: options.scaleBarOptions.position,
                                                  margins: options.scaleBarOptions.margins)
        constraints.append(contentsOf: scaleBarViewConstraints)

        let attributionButtonConstraints = constraints(with: attributionButton,
                                                       position: options.attributionButtonOptions.position,
                                                       margins: options.attributionButtonOptions.margins)
        constraints.append(contentsOf: attributionButtonConstraints)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        logoView.isHidden = !options.logoViewOptions._isVisible
        scalebarView.isHidden = options.scaleBarOptions.visibility == .hidden
        compassView.isHidden = options.compassViewOptions.visibility == .hidden
        attributionButton.isHidden = !options.attributionButtonOptions._isVisible
    }

    private func constraints(with view: UIView, position: OrnamentPosition, margins: CGPoint) -> [NSLayoutConstraint] {
        let layoutGuide = view.superview!.safeAreaLayoutGuide
        switch position {
        case .topLeft:
            return [
                view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: margins.x),
                view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margins.y)]
        case .topRight:
            return  [
                view.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -margins.x),
                view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margins.y)]
        case .bottomLeft:
            return [
                view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor, constant: margins.x),
                view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -margins.y)]
        case .bottomRight:
            return [
                view.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor, constant: -margins.x),
                view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -margins.y)]
        }
    }
}
