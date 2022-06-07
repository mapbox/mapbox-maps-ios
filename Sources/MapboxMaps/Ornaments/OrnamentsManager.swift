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

public class OrnamentsManager: NSObject {

    /// The `OrnamentOptions` object that is used to set up and update the required ornaments on the map.
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
    /// configure the compass presentation if customization is needed..
    public var compassView: UIView {
        return _compassView
    }

    /// The view for the attribution button ornament. This view can be used to position other views relative
    /// to the attribution button ornament, but it should not be manipulated. Use
    /// ``OrnamentOptions/attributionButton`` to configure the attribution button presentation
    /// if customization is needed..
    public var attributionButton: UIView {
        return _attributionButton
    }

    public var weatherBugView: UIView {
        return _weatherBug
    }

    private let _logoView: LogoView
    private let _scaleBarView: MapboxScaleBarOrnamentView
    private let _compassView: MapboxCompassOrnamentView
    private let _attributionButton: InfoButtonOrnament
    private let _weatherBug: WeatherBugView
    private let weatherService: WeatherServiceProtocol

    private var constraints = [NSLayoutConstraint]()

    internal init(options: OrnamentOptions,
                  view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  infoButtonOrnamentDelegate: InfoButtonOrnamentDelegate,
                  logoView: LogoView,
                  scaleBarView: MapboxScaleBarOrnamentView,
                  compassView: MapboxCompassOrnamentView,
                  attributionButton: InfoButtonOrnament,
                  weatherBugView: WeatherBugView,
                  weatherService: WeatherServiceProtocol) {
        self.options = options
        self.weatherService = weatherService
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
                completion: nil)
        }
        view.addSubview(compassView)
        self._compassView = compassView

        // Info Button
        attributionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(attributionButton)
        self._attributionButton = attributionButton

        // Weather bug
        weatherBugView.translatesAutoresizingMaskIntoConstraints = false
        weatherBugView.alpha = 0
        view.addSubview(weatherBugView)
        self._weatherBug = weatherBugView

        super.init()

        weatherService.delegate = self
        _attributionButton.delegate = infoButtonOrnamentDelegate

        updateOrnaments()

        // Subscribe to updates for scalebar and compass
        // MapboxMap should not be allowed to own a strong ref to compassView
        // since compassView owns a tapAction that captures a strong ref to
        // cameraAnimationsManager which has a strong ref to mapboxMap.
        mapboxMap.onEvery(.cameraChanged) { [weak mapboxMap, weak scaleBarView, weak compassView] _ in
            guard let mapboxMap = mapboxMap,
                  let scaleBarView = scaleBarView,
                  let compassView = compassView else {
                return
            }
            let cameraState = mapboxMap.cameraState

            // Update the scale bar
            scaleBarView.metersPerPoint = Projection.metersPerPoint(
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

        let weatherBugConstraints = constraints(with: _weatherBug,
                                                position: .bottomRight,
                                                margins: CGPoint(x: 8.0, y: 40))
        constraints.append(contentsOf: weatherBugConstraints)

        // Activate new constraints
        NSLayoutConstraint.activate(constraints)

        _logoView.isHidden = options.logo.visibility == .hidden
        _scaleBarView.isHidden = options.scaleBar.visibility == .hidden
        _compassView.visibility = options.compass.visibility
        _compassView.isHidden = options.compass.visibility == .hidden
        _attributionButton.isHidden = options.attributionButton.visibility == .hidden
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

extension OrnamentsManager: WeatherServiceDelegate {
    func weatherService(_ weatherService: WeatherService, didUpdateForecast forecast: WeatherForecast) {
        if forecast.temperature == nil {
            UIView.animate(withDuration: 0.3) {
                self._weatherBug.alpha = 0
            }
            return
        }
        let conditions = [
            "sun.max.fill",
            "cloud.fill",
            "cloud.drizzle.fill",
            "cloud.rain.fill",
            "cloud.heavyrain.fill",
            "cloud.fog.fill",
            "cloud.hail.fill",
            "cloud.snow.fill",
            "cloud.sleet.fill",
            "cloud.bolt.fill",
            "cloud.sun.fill",
            "cloud.sun.rain.fill",
            "cloud.sun.bolt.fill"
        ]
        if let temp = forecast.temperature {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .short
            formatter.locale = Locale(identifier: "fi_FI")
            formatter.numberFormatter.maximumFractionDigits = 0
            formatter.numberFormatter.roundingMode = .halfUp
            let tempString = formatter.string(from: Measurement(value: temp, unit: UnitTemperature.fahrenheit))
            self._weatherBug.textLabel.text = tempString
        }

        if #available(iOS 13.0, *) {
            self._weatherBug.imageView.image = UIImage(systemName: conditions.randomElement()!)
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self._weatherBug.alpha = 1
        }
    }
}
