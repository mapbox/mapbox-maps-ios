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

internal struct Ornaments {
    static let localizableTableName = "OrnamentsLocalizable"
    static let telemetryURL = "https://www.mapbox.com/telemetry/"
}

@available(iOSApplicationExtension, unavailable)
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
    private let attributionButton: InfoButtonOrnament

    private var constraints = [NSLayoutConstraint]()

    internal init(options: OrnamentOptions,
                  view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  infoButtonOrnamentDelegate: InfoButtonOrnamentDelegate) {
        self.options = options

        // Logo View
        logoView = LogoView(logoSize: .regular())
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)

        // Scalebar View
        let scalebarView = MapboxScaleBarOrnamentView()
        // Check whether the scale bar is position on the right side of the map view.
        let scaleBarPosition = options.scaleBar.position
        scalebarView.isOnRight = scaleBarPosition == .bottomRight || scaleBarPosition == .topRight
        scalebarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scalebarView)
        self.scalebarView = scalebarView

        // Compass View
        let compassView = MapboxCompassOrnamentView(visibility: options.compass.visibility)
        compassView.translatesAutoresizingMaskIntoConstraints = false
        compassView.tapAction = {
            cameraAnimationsManager.cancelAnimations()
            cameraAnimationsManager.ease(
                to: CameraOptions(bearing: 0),
                duration: 0.3,
                curve: .easeOut,
                completion: nil)
        }
        view.addSubview(compassView)
        self.compassView = compassView

        // Info Button
        attributionButton = InfoButtonOrnament()
        attributionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(attributionButton)

        super.init()

        attributionButton.delegate = infoButtonOrnamentDelegate

        updateOrnaments()

        // Subscribe to updates for scalebar and compass
        // MapboxMap should not be allowed to own a strong ref to compassView
        // since compassView owns a tapAction that captures a strong ref to
        // cameraAnimationsManager which has a strong ref to mapboxMap.
        mapboxMap.onEvery(.cameraChanged) { [weak mapboxMap, weak scalebarView, weak compassView] _ in
            guard let mapboxMap = mapboxMap,
                  let scalebarView = scalebarView,
                  let compassView = compassView else {
                return
            }
            let cameraState = mapboxMap.cameraState

            // Update the scale bar
            scalebarView.metersPerPoint = Projection.metersPerPoint(
                for: cameraState.center.latitude,
                zoom: cameraState.zoom)

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
                                              position: options.logo.position,
                                              margins: options.logo.margins)
        constraints.append(contentsOf: logoViewConstraints)

        let compassViewConstraints = constraints(with: compassView,
                                                 position: options.compass.position,
                                                 margins: options.compass.margins)
        constraints.append(contentsOf: compassViewConstraints)

        let scaleBarViewConstraints = constraints(with: scalebarView,
                                                  position: options.scaleBar.position,
                                                  margins: options.scaleBar.margins)
        let scaleBarPosition = options.scaleBar.position
        scalebarView.isOnRight = scaleBarPosition == .bottomRight || scaleBarPosition == .topRight
        constraints.append(contentsOf: scaleBarViewConstraints)

        let attributionButtonConstraints = constraints(with: attributionButton,
                                                       position: options.attributionButton.position,
                                                       margins: options.attributionButton.margins)
        constraints.append(contentsOf: attributionButtonConstraints)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        logoView.isHidden = options.logo.visibility == .hidden
        scalebarView.isHidden = options.scaleBar.visibility == .hidden
        compassView.visibility = options.compass.visibility
        compassView.isHidden = options.compass.visibility == .hidden
        attributionButton.isHidden = options.attributionButton.visibility == .hidden
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
