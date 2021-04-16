import Foundation
import UIKit

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

/**
Ornament positions:

               top
top            center          top
left      *------*------*      right
          |             |
          |             |
center    *             *      center
left      |             |      right
          |             |
bottom    *------*------*      bottom
left           bottom          right
               center
*/

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

internal enum OrnamentType: Hashable {
    case mapboxLogoView
    case mapboxScaleBar
    case compass
    case infoButton
    case customOrnament(value: UIView)

    // Generate an ornament for every type
    internal func makeOrnament(for view: OrnamentSupportableView, visibility: OrnamentVisibility = .visible) -> UIView {
        switch self {
        case .mapboxLogoView:
            return LogoView(logoSize: .regular)
        case .mapboxScaleBar:
            let scalebarView = MapboxScaleBarOrnamentView()

            view.subscribeCameraChangeHandler { (cameraOptions) in
                if let zoom = cameraOptions.zoom,
                   let center = cameraOptions.center {

                    let metersPerPixel = Projection.getMetersPerPixelAtLatitude(forLatitude: center.latitude,
                                                                                     zoom: Double(zoom))
                    scalebarView.metersPerPoint = metersPerPixel
                }
            }

            return scalebarView
        case .compass:
            let compassView = MapboxCompassOrnamentView(visibility: visibility)

            compassView.tapAction = { [weak view] in
                view?.compassTapped()
            }

            view.subscribeCameraChangeHandler { (cameraOptions) in
                if let bearing = cameraOptions.bearing {
                    compassView.currentBearing = Double(bearing)
                }
            }
            return compassView
        case .infoButton:
            return MapboxInfoButtonOrnament()
        case .customOrnament(value: let ornament):
            return ornament
        }
    }
}

internal class OrnamentsManager: NSObject {

    /// The `OrnamentConfig` that is used to set up the required ornaments on the map
    internal var ornamentConfig: OrnamentConfig {
        get {
            _ornamentConfig
        }
        set {
            assert(newValue.isValid(),
                   "The new config is not valid, there are at least two ornaments at the same position.")
            let toRemove = _ornamentConfig.complement(with: newValue)
            removeFromView(ornaments: toRemove.ornaments)
            let toAdd = newValue.complement(with: _ornamentConfig)
            addToView(ornaments: toAdd.ornaments)
            _ornamentConfig = newValue
        }
    }

    internal var ornaments: [Ornament] {
        ornamentConfig.ornaments
    }

    /// Shouldn't be used directly. Use the property `ornamentConfig` instead
    private var _ornamentConfig: OrnamentConfig = OrnamentConfig()

    /// The view that all ornaments will reside
    private weak var view: OrnamentSupportableView!

    /**
     Per our terms of service, a Mapbox map is required to display both
     a Mapbox logo as well as an information icon that contains attribution
     information. See https://docs.mapbox.com/help/how-mapbox-works/attribution/
     for details.

     TODO: Implement logo and attribution ornaments
     */

    internal init(for view: OrnamentSupportableView, withConfig ornamentConfig: OrnamentConfig) {
        super.init()
        self.view = view
        self.ornamentConfig = ornamentConfig

        ensureTelemetryOptOutExists()
    }

    internal func addOrnament(_ ornamentType: OrnamentType,
                              at position: OrnamentPosition,
                              visibility: OrnamentVisibility) {
        let ornament = Ornament(view: nil, type: ornamentType, position: position, visibility: visibility)
        ornamentConfig = ornamentConfig.with(ornament: ornament)
    }

    internal func addOrnament(_ ornamentView: UIView, at position: OrnamentPosition) {
        let ornament = Ornament(view: nil, type: .customOrnament(value: ornamentView), position: position)
        ornamentConfig = ornamentConfig.with(ornament: ornament)
    }

    internal func removeOrnament(_ ornamentView: UIView) {
        ornamentConfig = OrnamentConfig(ornaments: ornaments.filter {
            $0.view != ornamentView
        })
    }

    internal func removeOrnament(at position: OrnamentPosition) {
        ornamentConfig = OrnamentConfig(ornaments: ornaments.filter {
            $0.position != position
        })
    }

    internal func removeOrnament(with type: OrnamentType) {
        ornamentConfig = OrnamentConfig(ornaments: ornaments.filter {
            $0.type != type
        })
    }

    internal func add(ornament: Ornament) {
        ornamentConfig = ornamentConfig.with(ornament: ornament)
    }

    internal func remove(ornament: Ornament) {
        ornamentConfig = ornamentConfig.without(ornament: ornament)
    }

    internal func ornament(at position: OrnamentPosition) -> [Ornament] {
        return ornaments.filter({ $0.position == position })
    }

    internal func ornament(withType type: OrnamentType) -> [Ornament] {
        return ornaments.filter({ $0.type == type })
    }

    private func addToView(ornaments: [Ornament]) {
        ornaments.forEach {
            addToView(ornament: $0)
        }
    }

    private func removeFromView(ornaments: [Ornament]) {
        ornaments.forEach {
            removeFromView(ornament: $0)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func addToView(ornament: Ornament) {
        if ornament.view == nil {
            ornament.view = ornament.type.makeOrnament(for: view, visibility: ornament.visibility)
        }
        guard let ornamentView = ornament.view else {
            assert(false, "Couldn't create view for an ornament")
            return
        }
        var constraints = [NSLayoutConstraint]()
        view.addSubview(ornamentView)

        switch ornament.position {
        case .topLeft:
            constraints.append(contentsOf: [
                ornamentView.leadingAnchor.constraint(equalTo: universalLayoutGuide.leadingAnchor,
                                                      constant: ornament.margins.x),
                ornamentView.topAnchor.constraint(equalTo: universalLayoutGuide.topAnchor,
                                                  constant: ornament.margins.y)
            ])
        case .topCenter:
            print("top center")
        case .topRight:
            constraints.append(contentsOf: [
                ornamentView.trailingAnchor.constraint(equalTo: universalLayoutGuide.trailingAnchor,
                                                       constant: -ornament.margins.x),
                ornamentView.topAnchor.constraint(equalTo: universalLayoutGuide.topAnchor,
                                                  constant: ornament.margins.y)
            ])
        case .centerRight:
            print("center right")
        case .bottomRight:
            constraints.append(contentsOf: [
                ornamentView.trailingAnchor.constraint(equalTo: universalLayoutGuide.trailingAnchor,
                                                       constant: -ornament.margins.x),
                ornamentView.bottomAnchor.constraint(equalTo: universalLayoutGuide.bottomAnchor,
                                                     constant: -ornament.margins.y)
            ])
        case .bottomCenter:
            print("bottom center")
        case .bottomLeft:
            constraints.append(contentsOf: [
                ornamentView.leadingAnchor.constraint(equalTo: universalLayoutGuide.leadingAnchor,
                                                      constant: ornament.margins.x),
                ornamentView.bottomAnchor.constraint(equalTo: universalLayoutGuide.bottomAnchor,
                                                     constant: -ornament.margins.y)
            ])
        case .centerLeft:
            print("center left")
        }

        /**
         TODO: Scaling the ornament size based off the map's availible width
         allows us to avoid hardcoding a fixed logo size. However, this will
         also make the watermark seem disproportionally large on an iPad.
         Consider using size classes to figure out height/width instead.
         */
        if ornamentView is LogoView {
            constraints.append(contentsOf: [
                ornamentView.widthAnchor.constraint(equalTo: universalLayoutGuide.widthAnchor, multiplier: 0.25),
                ornamentView.heightAnchor.constraint(equalTo: ornamentView.widthAnchor, multiplier: 0.25)
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func removeFromView(ornament: Ornament) {
        if let ornamentView = ornament.view, self.view.subviews.contains(ornamentView) {
            ornamentView.removeFromSuperview()
        }
    }
}

extension OrnamentsManager {
    // Backwards compatibility with pre-iOS 11 safeAreaLayoutGuide
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

    internal func ensureTelemetryOptOutExists() {
        let infoButton = ornaments.filter { $0.type == .infoButton }.first
        if (infoButton == nil || infoButton?.view?.isHidden == true)
            && ornamentConfig.telemetryOptOutShownInApp == false {
            preconditionFailure("""
                    End users must be able to opt out of Mapbox Telemetry in your app. By default,
                    this opt-out control is included as a menu item in the attribution action sheet.
                    If you reimplement the opt-out control inside this app, disable this assertion by
                    setting OrnamentConfig.telemetryOptOutShownInApp to `true`.

                    See https://docs.mapbox.com/help/how-mapbox-works/attribution/#mapbox-maps-sdk-for-ios for more information.
                    Additionally, by hiding this attribution control you agree to display the required attribution elsewhere in this app.
                    """)
        }
    }
}
