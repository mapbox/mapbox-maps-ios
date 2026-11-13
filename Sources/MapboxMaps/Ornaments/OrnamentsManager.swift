import UIKit
@_spi(Experimental) import MapboxCoreMaps

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

    /// The view for the indoor selector ornament. This view can be used to position other views relative
    /// to the indoor selector ornament, but it should not be manipulated. Use
    /// ``OrnamentOptions/indoorSelector`` to configure the indoor selector presentation
    /// if customization is needed.
    @_spi(Experimental)
    public var indoorSelectorView: UIView {
        return _indoorSelectorView
    }

    /// The view for the consolidated attribution ornament. Use it to position other views,
    /// but don't change it. Configure it with ``OrnamentOptions/consolidatedAttribution``.
    /// `nil` until that option is first set.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var consolidatedAttributionView: UIView? {
        return _consolidatedAttributionView
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
                debugView.accessoryEntries = cameraDebugAccessoryEntries
                view?.addSubview(debugView)
                cameraDebugView = debugView
                updateOrnaments()
            } else {
                cameraDebugView?.removeFromSuperview()
                cameraDebugView = nil
            }
        }
    }

    /// Entries appended to the camera debug overlay. Kept when the overlay is hidden and applied again when it is shown.
    internal var cameraDebugAccessoryEntries: [CameraDebugEntry] = [] {
        didSet {
            cameraDebugView?.accessoryEntries = cameraDebugAccessoryEntries
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
    private let _indoorSelectorView: IndoorSelectorView
    /// Created the first time ``OrnamentOptions/consolidatedAttribution`` is set.
    private var _consolidatedAttributionView: ConsolidatedAttributionView?
    private let onStyleAttributionsChanged: Signal<StyleAttributionsChanged>
    private weak var attributionDataSource: AttributionDataSource?
    private let onMapInteraction: Signal<Void>
    private let consolidatedAttributionIntroStore: ConsolidatedAttributionIntroStore
    private let onConsolidatedAttributionTap: () -> Void
    private let attributionMenu: AttributionMenu

    /// `updateOrnaments()` runs on every options change; count the opt-in once.
    private var sendConsolidatedAttributionTelemetryOnce = Once()

    private var constraints = [NSLayoutConstraint]()
    private var cancellables = Set<AnyCancelable>()

    init(options: OrnamentOptions,
         view: UIView,
         onCameraChanged: Signal<CameraChanged>,
         onStyleAttributionsChanged: Signal<StyleAttributionsChanged>,
         attributionDataSource: AttributionDataSource,
         cameraAnimationsManager: CameraAnimationsManagerProtocol,
         infoButtonOrnamentDelegate: InfoButtonOrnamentDelegate,
         logoView: LogoView,
         scaleBarView: MapboxScaleBarOrnamentView,
         compassView: MapboxCompassOrnamentView,
         attributionButton: InfoButtonOrnament,
         indoorSelectorView: IndoorSelectorView,
         onMapInteraction: Signal<Void>,
         consolidatedAttributionIntroStore: ConsolidatedAttributionIntroStore,
         onConsolidatedAttributionTap: @escaping () -> Void,
         attributionMenu: AttributionMenu
    ) {
        self.options = options
        self.view = view
        self.attributionMenu = attributionMenu

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

        // Indoor Selector View
        indoorSelectorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indoorSelectorView)
        self._indoorSelectorView = indoorSelectorView

        self.onStyleAttributionsChanged = onStyleAttributionsChanged
        self.attributionDataSource = attributionDataSource
        self.onMapInteraction = onMapInteraction
        self.consolidatedAttributionIntroStore = consolidatedAttributionIntroStore
        self.onConsolidatedAttributionTap = onConsolidatedAttributionTap

        _attributionButton.delegate = infoButtonOrnamentDelegate
        _attributionButton.onTintColorDidChange = { [weak self] tintColor in
            self?.options.attributionButton.tintColor = tintColor
        }

        updateOrnaments()

        observeSignals(onCameraChanged: onCameraChanged)
    }

    private func observeSignals(onCameraChanged: Signal<CameraChanged>) {
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

        let indoorSelectorViewConstraints = constraints(with: _indoorSelectorView,
                                                        position: options.indoorSelector.position,
                                                        margins: options.indoorSelector.margins)
        constraints.append(contentsOf: indoorSelectorViewConstraints)

        if let cameraDebugView {
            constraints.append(contentsOf: cameraDebugViewConstraints(for: cameraDebugView))
        }

        constraints.append(contentsOf: consolidatedAttributionConstraints())

        // Update the image of compass
        _compassView.updateImage(image: options.compass.image)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        _consolidatedAttributionView?.model.options = options.consolidatedAttribution

        updateOrnamentVisibility()
    }

    /// Creates the pill on first enable. A disabled pill is hidden but still needs a position.
    private func consolidatedAttributionConstraints() -> [NSLayoutConstraint] {
        if options.consolidatedAttribution != nil {
            sendConsolidatedAttributionTelemetryOnce {
                sendTelemetry(\.consolidatedAttribution)
            }
            if _consolidatedAttributionView == nil {
                _consolidatedAttributionView = makeConsolidatedAttributionView()
            }
        }
        guard let consolidatedAttributionView = _consolidatedAttributionView else { return [] }
        let consolidatedOptions = options.consolidatedAttribution ?? ConsolidatedAttributionOptions()
        var result = constraints(with: consolidatedAttributionView,
                                 position: consolidatedOptions.position,
                                 margins: consolidatedOptions.margins)
        if let limit = freeEdgeLimitConstraint(with: consolidatedAttributionView,
                                               position: consolidatedOptions.position,
                                               margins: consolidatedOptions.margins) {
            result.append(limit)
        }
        return result
    }

    private func updateOrnamentVisibility() {
        let consolidatedActive = options.consolidatedAttribution != nil
        _consolidatedAttributionView?.isHidden = !consolidatedActive
        _logoView.suppressHiddenWarning = consolidatedActive
        _attributionButton.suppressHiddenWarning = consolidatedActive
        _logoView.isHidden = consolidatedActive || options.logo.visibility == .hidden
        _scaleBarView.isHidden = options.scaleBar.visibility == .hidden
        _compassView.visibility = options.compass.visibility
        _compassView.isHidden = options.compass.visibility == .hidden
        _attributionButton.isHidden = consolidatedActive || options.attributionButton.visibility == .hidden
        _scaleBarView.units = options.scaleBar.units
        if _attributionButton.tintColor != options.attributionButton.tintColor {
            _attributionButton.tintColor = options.attributionButton.tintColor
        }

        switch options.indoorSelector.visibility {
        case .visible:
            _indoorSelectorView.isHidden = false
        case .hidden:
            _indoorSelectorView.isHidden = true
        case .adaptive:
            indoorSelectorView.isHidden = false // Handled by the IndoorSelectorView itself based on floor data and uses opacity
        }
    }

    private func freeEdgeLimitConstraint(with view: UIView,
                                         position: OrnamentPosition,
                                         margins: CGPoint) -> NSLayoutConstraint? {
        guard let layoutGuide = view.superview?.safeAreaLayoutGuide else {
            return nil
        }
        // Must use the same anchor type as the pinning constraint: left/right or leading/trailing.
        switch position {
        case .topLeft, .bottomLeft:
            return view.rightAnchor.constraint(lessThanOrEqualTo: layoutGuide.rightAnchor, constant: -margins.x)
        case .topRight, .bottomRight:
            return view.leftAnchor.constraint(greaterThanOrEqualTo: layoutGuide.leftAnchor, constant: margins.x)
        case .topLeading, .bottomLeading:
            return view.trailingAnchor.constraint(lessThanOrEqualTo: layoutGuide.trailingAnchor,
                                                  constant: -margins.x)
        case .topTrailing, .bottomTrailing:
            return view.leadingAnchor.constraint(greaterThanOrEqualTo: layoutGuide.leadingAnchor,
                                                 constant: margins.x)
        }
    }

    private func cameraDebugViewConstraints(for cameraDebugView: CameraDebugView) -> [NSLayoutConstraint] {
        let margins = CGPoint(x: 8, y: 48)
        var cameraDebugViewConstraints = constraints(with: cameraDebugView,
                                                     position: .topLeft,
                                                     margins: margins)
        if let layoutGuide = cameraDebugView.superview?.safeAreaLayoutGuide {
            // Lets long entries wrap instead of stretching the overlay past the right edge.
            cameraDebugViewConstraints.append(cameraDebugView.rightAnchor.constraint(
                lessThanOrEqualTo: layoutGuide.rightAnchor,
                constant: -margins.x
            ))
        }
        return cameraDebugViewConstraints
    }

    private func constraints(with view: UIView, position: OrnamentPosition, margins: CGPoint) -> [NSLayoutConstraint] {
        guard let layoutGuide = view.superview?.safeAreaLayoutGuide else {
            return []
        }
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

// MARK: - Consolidated attribution

extension OrnamentsManager {
    private static let mapboxCopyrightTitle = "mapbox"

    private func makeConsolidatedAttributionView() -> ConsolidatedAttributionView {
        let model = ConsolidatedAttributionModel(
            introStore: consolidatedAttributionIntroStore,
            onMapInteraction: onMapInteraction)
        model.attributionText = makeConsolidatedAttributionText(from: attributionDataSource?.getAttributions() ?? [])
        model.onTap = onConsolidatedAttributionTap
        onStyleAttributionsChanged.observe { [weak self] event in
            guard let self else { return }
            model.attributionText = self.makeConsolidatedAttributionText(from: Attribution.parse(event.attributions))
        }.store(in: &cancellables)

        let consolidatedAttributionView = ConsolidatedAttributionView(model: model)
        view?.addSubview(consolidatedAttributionView)
        return consolidatedAttributionView
    }

    private func makeConsolidatedAttributionText(from attributions: [Attribution]) -> String {
        attributionMenu.copyrightItems(from: attributions)
            .filter { $0.title.lowercased() != OrnamentsManager.mapboxCopyrightTitle }
            .map { Attribution.copyrightText($0.title) }
            .joined(separator: " ")
    }
}
