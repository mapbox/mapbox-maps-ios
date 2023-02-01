@_implementationOnly import MapboxCommon_Private
import UIKit

extension MapView: AttributionDialogManagerDelegate {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController {
        return parentViewController!
    }

    func attributionDialogManager(_ attributionDialogManager: AttributionDialogManager, didTriggerActionFor attribution: Attribution) {
        switch attribution.kind {
        case .actionable(let url):
            Log.debug(forMessage: "Open url: \(url))", category: "Attribution")
            attributionUrlOpener.openAttributionURL(url)
        case .feedback:
            let url = mapboxFeedbackURL()
            Log.debug(forMessage: "Open url: \(url))", category: "Attribution")
            attributionUrlOpener.openAttributionURL(url)
        case .nonActionable:
            break
        }
    }

    internal func mapboxFeedbackURL() -> URL {
        let cameraState = self.cameraState

        var components = URLComponents(string: "https://apps.mapbox.com/feedback/")!
        components.fragment = String(format: "/%.5f/%.5f/%.2f/%.1f/%i",
                                     cameraState.center.longitude,
                                     cameraState.center.latitude,
                                     cameraState.zoom,
                                     cameraState.bearing,
                                     Int(round(cameraState.pitch)))

        let applicationBundleId = Bundle.main.bundleIdentifier // com.apple.dt.xctest.tool during testing
        let referrerQueryItem = URLQueryItem(name: "referrer", value: applicationBundleId)

        var queryItems = [referrerQueryItem]

        let sdkVersion = Bundle.mapboxMapsMetadata.version
        var accessToken = resourceOptions.accessToken
        accessToken = accessToken.isEmpty ? "unknown" : accessToken

        if let styleURIString = mapboxMap.style.uri?.rawValue,
           let styleURL = URL(string: styleURIString),
           styleURL.scheme == "mapbox",
           styleURL.host == "styles" {
            let pathComponents = styleURL.pathComponents

            if pathComponents.count >= 3 {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "owner", value: pathComponents[1]),
                    URLQueryItem(name: "id", value: pathComponents[2]),
                ])
            }
        }

        queryItems.append(contentsOf: [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "map_sdk_version", value: sdkVersion),
        ])

        components.queryItems = queryItems

        return components.url!
    }
}
