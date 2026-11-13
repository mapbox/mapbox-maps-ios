import Foundation
import UIKit
internal import MapboxCommon_Private

/// API for attribution menu configuration
/// - Note: Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
@_spi(Restricted)
public class AttributionMenu {
    private let urlOpener: AttributionURLOpener
    private let feedbackURLRef: Ref<URL?>
    private let geofencingIsActiveRef: Ref<Bool>
    private let isMetricsEnabledRef = MutableRef(
        get: { UserDefaults.standard.MGLMapboxMetricsEnabled },
        set: { UserDefaults.standard.MGLMapboxMetricsEnabled = $0 }
    )

    private let isGeofencingEnabledRef = MutableRef(
        get: { __GeofencingUtils.getUserConsent() },
        set: { __GeofencingUtils.setUserConsent(isConsentGiven: $0) { expected in
            if let error = expected.error { Log.error("Error: \(error) when setting geofencing user consent.") }
        } }
    )

    /// Optional closure to filter which items appear. Return `true` to include, `false` to suppress.
    public var filter: ((AttributionMenuItem) -> Bool)?

    init(
        urlOpener: AttributionURLOpener,
        feedbackURLRef: Ref<URL?>,
        filter: ((AttributionMenuItem) -> Bool)? = nil,
        geofencingIsActiveRef: Ref<Bool> = Ref { __GeofencingUtils.isActive() }
    ) {
        self.urlOpener = urlOpener
        self.filter = filter
        self.feedbackURLRef = feedbackURLRef
        self.geofencingIsActiveRef = geofencingIsActiveRef
    }
}

extension AttributionMenu {
    /// Applies ``filter``.
    internal func menu(from attributions: [Attribution]) -> AttributionMenuContent {
        var content = AttributionMenuContent(
            title: Bundle.mapboxMaps.localizedString(
                forKey: "SDK_NAME",
                value: "Powered by Mapbox",
                table: Ornaments.localizableTableName
            ),
            sections: [],
            open: { [urlOpener] url in urlOpener.openAttributionURL(url) }
        )

        let copyrights = makeCopyrightItems(from: attributions)
        if !copyrights.isEmpty {
            content.sections.append(AttributionMenuSection(title: nil, items: copyrights))
        }

        var settings = [AttributionMenuItem]()
        if let contributeItem = contributeItem(from: attributions) {
            settings.append(contributeItem)
        }
        settings.append(telemetryItem)
        if geofencingIsActiveRef.value || !isGeofencingEnabledRef.wrappedValue {
            settings.append(geofencingItem)
        }
        settings.append(privacyPolicyItem)
        content.sections.append(AttributionMenuSection(title: nil, items: settings))

        if let filter {
            content.filter(filter)
        }
        return content
    }

    /// The sheet's copyright rows, with ``filter`` applied. Used by the consolidated attribution pill.
    internal func copyrightItems(from attributions: [Attribution]) -> [AttributionMenuItem] {
        let items = makeCopyrightItems(from: attributions)
        guard let filter else {
            return items
        }
        return items.filter(filter)
    }

    private func makeCopyrightItems(from attributions: [Attribution]) -> [AttributionMenuItem] {
        return attributions.compactMap { attribution in
            switch attribution.kind {
            case .actionable(let url):
                return AttributionMenuItem(id: .copyright, title: attribution.localizedTitle, kind: .link(url))
            case .nonActionable:
                return AttributionMenuItem(id: .copyright, title: attribution.localizedTitle, kind: .link(nil))
            case .feedback:
                return nil
            }
        }
    }

    /// Only one: every feedback attribution opens the same URL.
    private func contributeItem(from attributions: [Attribution]) -> AttributionMenuItem? {
        guard let feedbackURL = feedbackURLRef.value,
              let attribution = attributions.first(where: { $0.kind == .feedback })
        else { return nil }

        return AttributionMenuItem(id: .contribute, title: attribution.localizedTitle, kind: .link(feedbackURL))
    }

    private var privacyPolicyItem: AttributionMenuItem {
        let title = NSLocalizedString("ATTRIBUTION_PRIVACY_POLICY",
                                      tableName: Ornaments.localizableTableName,
                                      bundle: .mapboxMaps,
                                      value: "Mapbox Privacy Policy",
                                      comment: "Privacy policy action in attribution sheet")

        return AttributionMenuItem(id: .privacyPolicy, title: title, kind: .link(Attribution.privacyPolicyURL))
    }

    private var telemetryItem: AttributionMenuItem {
        let message = { (isEnabled: Bool) in
            isEnabled
                ? TelemetryStrings.telemetryEnabledMessage
                : TelemetryStrings.telemetryDisabledMessage
        }

        return AttributionMenuItem(
            id: .telemetry,
            title: TelemetryStrings.telemetryName,
            message: message(isMetricsEnabledRef.wrappedValue),
            messageForState: message,
            link: .init(title: CommonStrings.learnMore, url: URL(string: Ornaments.telemetryURL)!),
            kind: .toggle(isMetricsEnabledRef)
        )
    }

    private var geofencingItem: AttributionMenuItem {
        AttributionMenuItem(
            id: .geofencing,
            title: GeofencingStrings.geofencingName,
            message: GeofencingStrings.geofencingMessage,
            kind: .toggle(isGeofencingEnabledRef)
        )
    }
}
