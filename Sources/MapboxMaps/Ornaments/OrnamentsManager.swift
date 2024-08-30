import UIKit

/// Options used to configure the corner position of an ornament
public enum OrnamentPosition: String, Equatable, Sendable {
    // Clockwise from top left
    case topLeft
    case topRight
    case bottomRight
    case bottomLeft

    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

/// Options used to configure the visibility of an ornament
public enum OrnamentVisibility: String, Equatable, Sendable {
    /// Shows the ornament when relevant
    case adaptive
    /// Hides the ornament
    case hidden
    /// Shows the ornament
    case visible
}

internal struct Ornaments {
    static let localizableTableName = "OrnamentsLocalizable"
    static let telemetryURL = "https://www.mapbox.com/telemetry/"
}

/// APIs for managing map ornaments
public final class OrnamentsManager {

    /// The ``OrnamentOptions`` object that is used to set up and update the required ornaments on the map.
    public var options: OrnamentOptions {
        didSet {
            updateOrnaments()
        }
    }

    /// The view for the logo ornament. This view can be used to position other views relative to the logo
    /// ornament, but it should not be manipulated. Use ``OrnamentOptions/logo`` to configure the
    /// logo presentation if customization is needed.
    public var logoView: UIView {
        return _logoView
    }

    /// The view for the scale bar ornament. This view can be used to position other views relative to the
    /// scale bar ornament, but it should not be manipulated. Use ``OrnamentOptions/scaleBar``
    /// to configure the scale bar presentation if customization is needed.
    public var scaleBarView: UIView {
        return _scaleBarView
    }

    /// The view for the compass ornament. This view can be used to position other views relative to the
    /// compass ornament, but it should not be manipulated. Use ``OrnamentOptions/compass`` to
    /// configure the compass presentation if customization is needed.
    public var compassView: UIView {
        return _compassView
    }

    /// The view for the attribution button ornament. This view can be used to position other views relative
    /// to the attribution button ornament, but it should not be manipulated. Use
    /// ``OrnamentOptions/attributionButton`` to configure the attribution button presentation
    /// if customization is needed.
    public var attributionButton: UIView {
        return _attributionButton
    }
    private var cachedCamera: CameraState?

    private var cameraDebugView: CameraDebugView?

    internal var showCameraDebug: Bool = false {
        didSet {
            guard showCameraDebug != oldValue else { return }
            if showCameraDebug {
                let debugView = CameraDebugView()
                debugView.translatesAutoresizingMaskIntoConstraints = false
                debugView.cameraState = cachedCamera
                view?.addSubview(debugView)
                cameraDebugView = debugView
                updateOrnaments()
            } else {
                cameraDebugView?.removeFromSuperview()
                cameraDebugView = nil
            }
        }
    }

    private var paddingDebugView: PaddingDebugView?
    var showPaddingDebug: Bool = false {
        didSet {
            guard showPaddingDebug != oldValue else { return }
            if showPaddingDebug, let superview = self.view {
                let view = PaddingDebugView(padding: cachedCamera?.padding)
                self.paddingDebugView = view
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.frame = superview.bounds
                superview.addSubview(view)
            } else {
                paddingDebugView?.removeFromSuperview()
                paddingDebugView = nil
            }
        }
    }

    private weak var view: UIView?
    private let _logoView: LogoView
    private let _scaleBarView: MapboxScaleBarOrnamentView
    private let _compassView: MapboxCompassOrnamentView
    private let _attributionButton: InfoButtonOrnament

    private var constraints = [NSLayoutConstraint]()
    private var cancellables = Set<AnyCancelable>()

    internal init(options: OrnamentOptions,
                  view: UIView,
                  onCameraChanged: Signal<CameraChanged>,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  infoButtonOrnamentDelegate: InfoButtonOrnamentDelegate,
                  logoView: LogoView,
                  scaleBarView: MapboxScaleBarOrnamentView,
                  compassView: MapboxCompassOrnamentView,
                  attributionButton: InfoButtonOrnament) {
        self.options = options
        self.view = view

        // Logo View
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        self._logoView = logoView

        // Scalebar View
        // Check whether the scale bar is position on the right side of the map view.
        let scaleBarPosition = options.scaleBar.position
        scaleBarView.isOnRight = scaleBarPosition == .bottomRight || scaleBarPosition == .topRight
        scaleBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scaleBarView)
        self._scaleBarView = scaleBarView

        // Compass View
        compassView.translatesAutoresizingMaskIntoConstraints = false
        compassView.tapAction = {
            cameraAnimationsManager.cancelAnimations()
            cameraAnimationsManager.ease(
                to: CameraOptions(bearing: 0),
                duration: 0.3,
                curve: .easeOut,
                animationOwner: .compass,
                completion: nil)
        }
        view.addSubview(compassView)
        self._compassView = compassView

        // Info Button
        attributionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(attributionButton)
        self._attributionButton = attributionButton

        _attributionButton.delegate = infoButtonOrnamentDelegate

        updateOrnaments()

        onCameraChanged.observe { [weak self] event in
            guard let self else { return }
            self.cachedCamera = event.cameraState

            // Update the scale bar
            self._scaleBarView.metersPerPoint = Projection.metersPerPoint(
                for: event.cameraState.center.latitude,
                zoom: event.cameraState.zoom)

            // Update the compass
            self._compassView.currentBearing = Double(event.cameraState.bearing)

            // Update debug views
            self.cameraDebugView?.cameraState = event.cameraState
            self.paddingDebugView?.padding = event.cameraState.padding
        }.store(in: &cancellables)
    }

    private func updateOrnaments() {
        // Remove previously-added constraints
        NSLayoutConstraint.deactivate(constraints)
        constraints.removeAll()

        // Update the position for the ornaments
        let logoViewConstraints = constraints(with: _logoView,
                                              position: options.logo.position,
                                              margins: options.logo.margins)
        constraints.append(contentsOf: logoViewConstraints)

        let compassViewConstraints = constraints(with: _compassView,
                                                 position: options.compass.position,
                                                 margins: options.compass.margins)
        constraints.append(contentsOf: compassViewConstraints)

        let scaleBarViewConstraints = constraints(with: _scaleBarView,
                                                  position: options.scaleBar.position,
                                                  margins: options.scaleBar.margins)
        let scaleBarPosition = options.scaleBar.position
        _scaleBarView.isOnRight = scaleBarPosition == .bottomRight || scaleBarPosition == .topRight
        constraints.append(contentsOf: scaleBarViewConstraints)

        let attributionButtonConstraints = constraints(with: _attributionButton,
                                                       position: options.attributionButton.position,
                                                       margins: options.attributionButton.margins)
        constraints.append(contentsOf: attributionButtonConstraints)

        if let cameraDebugView {
            let cameraDebugViewConstraints = constraints(with: cameraDebugView,
                                                         position: .topLeft,
                                                         margins: CGPoint(x: 8, y: 48))
            constraints.append(contentsOf: cameraDebugViewConstraints)
        }

        // Update the image of compass
        _compassView.updateImage(image: options.compass.image)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        _logoView.isHidden = options.logo.visibility == .hidden
        _scaleBarView.isHidden = options.scaleBar.visibility == .hidden
        _compassView.visibility = options.compass.visibility
        _compassView.isHidden = options.compass.visibility == .hidden
        _attributionButton.isHidden = options.attributionButton.visibility == .hidden
        _scaleBarView.useMetricUnits = options.scaleBar.useMetricUnits
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
        case .topLeading:
            return [
                view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: margins.x),
                view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margins.y)]
        case .topTrailing:
            return  [
                view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -margins.x),
                view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margins.y)]
        case .bottomLeading:
            return [
                view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: margins.x),
                view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -margins.y)]
        case .bottomTrailing:
            return [
                view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -margins.x),
                view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -margins.y)]
        }
    }
}
