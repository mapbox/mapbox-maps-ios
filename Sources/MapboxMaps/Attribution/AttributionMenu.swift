import Foundation
import UIKit
@_implementationOnly import MapboxCommon_Private

/// API for attribution menu configuration
/// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
@_spi(Restricted)
public class AttributionMenu {
    private let urlOpener: AttributionURLOpener
    private let feedbackURLRef: Ref<URL?>

    /// Filters attribution menu items based on the provided closure.
    public var filter: ((AttributionMenuItem) -> Bool)?

    init(
        urlOpener: AttributionURLOpener,
        feedbackURLRef: Ref<URL?>,
        filter: ((AttributionMenuItem) -> Bool)? = nil
    ) {
        self.urlOpener = urlOpener
        self.filter = filter
        self.feedbackURLRef = feedbackURLRef
    }
}

extension AttributionMenu {
    var isMetricsEnabled: Bool {
        get { UserDefaults.standard.MGLMapboxMetricsEnabled }
        set { UserDefaults.standard.MGLMapboxMetricsEnabled = newValue }
    }

    internal func menu(from attributions: [Attribution]) -> AttributionMenuSection {
        var elements = [AttributionMenuElement]()
        let items = attributions.compactMap { attribution in
            switch attribution.kind {
            case .actionable(let url):
                return AttributionMenuItem(title: attribution.localizedTitle, id: .copyright, category: .main) { [weak self] in
                    self?.urlOpener.openAttributionURL(url)
                }
            case .nonActionable:
                return AttributionMenuItem(title: attribution.localizedTitle, id: .copyright, category: .main)
            case .feedback:
                guard let feedbackURL = feedbackURLRef.value else { return nil }
                return AttributionMenuItem(title: attribution.localizedTitle, id: .contribute, category: .main) { [weak self] in
                    self?.urlOpener.openAttributionURL(feedbackURL)
                }
            }
        }
        let menuSubtitle: String?
        if items.count == 1, let item = items.first, item.action == nil {
            menuSubtitle = item.title
        } else {
            menuSubtitle = nil
            elements.append(contentsOf: items.map(AttributionMenuElement.item))
        }

        elements.append(.section(telemetryMenu))

        elements.append(.item(privacyPolicyItem))
        elements.append(.item(cancelItem))

        let mainTitle = Bundle.mapboxMaps.localizedString(
            forKey: "SDK_NAME",
            value: "Powered by Mapbox",
            table: Ornaments.localizableTableName
        )

        return AttributionMenuSection(title: mainTitle, subtitle: menuSubtitle, category: .main, elements: elements)
    }

    private var cancelItem: AttributionMenuItem {
        let cancelTitle = NSLocalizedString("ATTRIBUTION_CANCEL",
                                            tableName: Ornaments.localizableTableName,
                                            bundle: .mapboxMaps,
                                            value: "Cancel",
                                            comment: "Title of button for dismissing attribution action sheet")

        return AttributionMenuItem(title: cancelTitle, style: .cancel, id: .cancel, category: .main) { }
    }

    private var privacyPolicyItem: AttributionMenuItem {
        let privacyPolicyTitle = NSLocalizedString("ATTRIBUTION_PRIVACY_POLICY",
                                                   tableName: Ornaments.localizableTableName,
                                                   bundle: .mapboxMaps,
                                                   value: "Mapbox Privacy Policy",
                                                   comment: "Privacy policy action in attribution sheet")

        return AttributionMenuItem(title: privacyPolicyTitle, id: .privacyPolicy, category: .main) { [weak self] in
            self?.urlOpener.openAttributionURL(Attribution.privacyPolicyURL)
        }
    }

    private var telemetryMenu: AttributionMenuSection {
        let telemetryTitle = TelemetryStrings.telemetryTitle
        let telemetryURL = URL(string: Ornaments.telemetryURL)!
        let message: String
        let participateTitle: String
        let declineTitle: String

        if isMetricsEnabled {
            message = TelemetryStrings.telemetryEnabledMessage
            participateTitle = TelemetryStrings.telemetryEnabledOnMessage
            declineTitle = TelemetryStrings.telemetryEnabledOffMessage
        } else {
            message = TelemetryStrings.telemetryDisabledMessage
            participateTitle = TelemetryStrings.telemetryDisabledOnMessage
            declineTitle = TelemetryStrings.telemetryDisabledOffMessage
        }

        return AttributionMenuSection(title: telemetryTitle, actionTitle: TelemetryStrings.telemetryName, subtitle: message, category: .telemetry, elements: [
            AttributionMenuItem(title: TelemetryStrings.telemetryMore, id: .telemetryInfo, category: .telemetry) { [weak self]  in
                self?.urlOpener.openAttributionURL(telemetryURL)
            },
            AttributionMenuItem(title: declineTitle, id: .disable, category: .telemetry) { [weak self] in
                self?.isMetricsEnabled = false
            },
            AttributionMenuItem(title: participateTitle, style: .cancel, id: .enable, category: .telemetry) { [weak self] in
                self?.isMetricsEnabled = true
            }
        ].map(AttributionMenuElement.item))
    }
}
