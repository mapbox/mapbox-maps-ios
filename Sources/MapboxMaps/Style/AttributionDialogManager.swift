import UIKit
import Foundation
@_implementationOnly import MapboxCommon_Private

protocol AttributionDataSource: AnyObject {
    func loadAttributions(completion: @escaping ([Attribution]) -> Void)
}

protocol AttributionDialogManagerDelegate: AnyObject {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController?
    func attributionDialogManager(_ attributionDialogManager: AttributionDialogManager, didTriggerActionFor attribution: Attribution)
}

final class AttributionDialogManager {
    private weak var dataSource: AttributionDataSource?
    private weak var delegate: AttributionDialogManagerDelegate?
    private var inProcessOfParsingAttributions: Bool = false

    private let isGeofenceActive: () -> Bool
    private let setGeofenceConsent: (Bool) -> Void
    private let getGeofenceConsent: () -> Bool

    init(
        dataSource: AttributionDataSource,
        delegate: AttributionDialogManagerDelegate?,
        isGeofenceActive: @escaping () -> Bool = { __GeofencingUtils.isActive() },
        setGeofenceConsent: @escaping (Bool) -> Void = { isConsentGiven in
            __GeofencingUtils.setUserConsent(isConsentGiven: isConsentGiven, callback: { expected in
                if let error = expected.error { Log.error(forMessage: "Error: \(error) occurred while changing user consent for Geofencing.") }
            })
        },
        getGeofenceConsent: @escaping () -> Bool = { __GeofencingUtils.getUserConsent() }
    ) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.isGeofenceActive = isGeofenceActive
        self.setGeofenceConsent = setGeofenceConsent
        self.getGeofenceConsent = getGeofenceConsent
    }

    var isMetricsEnabled: Bool {
        get { UserDefaults.standard.MGLMapboxMetricsEnabled }
        set { UserDefaults.standard.MGLMapboxMetricsEnabled = newValue }
    }

    func showGeofencingAlertController(from viewController: UIViewController) {
        let telemetryTitle = GeofencingStrings.geofencingTitle
        let message = GeofencingStrings.geofencingMessage
        let participateTitle: String
        let declineTitle: String

        if getGeofenceConsent() {
            participateTitle = GeofencingStrings.geofencingEnabledOnMessage
            declineTitle = GeofencingStrings.geofencingEnabledOffMessage
        } else {
            participateTitle = GeofencingStrings.geofencingDisabledOnMessage
            declineTitle = GeofencingStrings.geofencingDisabledOffMessage
        }

        showAlertController(from: viewController, title: telemetryTitle, message: message, actions: [
            UIAlertAction(title: declineTitle, style: .default, handler: { _ in self.setGeofenceConsent(false) }),
            UIAlertAction(title: participateTitle, style: .cancel, handler: { _ in self.setGeofenceConsent(true) })
        ])
    }

    func showTelemetryAlertController(from viewController: UIViewController) {
        let telemetryTitle = TelemetryStrings.telemetryTitle
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

        let openTelemetryURL: (UIAlertAction) -> Void = { _ in
            guard let url = URL(string: Ornaments.telemetryURL) else { return }
            self.delegate?.attributionDialogManager(self, didTriggerActionFor: Attribution(title: "", url: url))
        }

        showAlertController(from: viewController, title: telemetryTitle, message: message, actions: [
            UIAlertAction(title: TelemetryStrings.telemetryMore, style: .default, handler: openTelemetryURL),
            UIAlertAction(title: declineTitle, style: .default, handler: { _ in self.isMetricsEnabled = false }),
            UIAlertAction(title: participateTitle, style: .cancel, handler: { _ in self.isMetricsEnabled = true })
        ])
    }

    func showAlertController(
        from viewController: UIViewController,
        title: String,
        message: String,
        actions: [UIAlertAction]
    ) {
        let alert = if UIDevice.current.userInterfaceIdiom == .pad {
            UIAlertController(title: title, message: message, preferredStyle: .alert)
        } else {
            UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        }

        actions.forEach(alert.addAction)
        viewController.present(alert, animated: true)
    }
}

// MARK: InfoButtonOrnamentDelegate Implementation
extension AttributionDialogManager: InfoButtonOrnamentDelegate {
    func didTap(_ infoButtonOrnament: InfoButtonOrnament) {
        guard inProcessOfParsingAttributions == false else { return }

        inProcessOfParsingAttributions = true
        dataSource?.loadAttributions { [weak self] attributions in
            self?.showAttributionDialog(for: attributions)
            self?.inProcessOfParsingAttributions = false
        }
    }

    private func showAttributionDialog(for attributions: [Attribution]) {
        guard let viewController = delegate?.viewControllerForPresenting(self) else {
            Log.error(forMessage: "Failed to present an attribution dialogue: no presenting view controller found.")
            return
        }

        let title = Bundle.mapboxMaps.localizedString(forKey: "SDK_NAME", value: "Powered by Mapbox", table: Ornaments.localizableTableName)

        let alert: UIAlertController

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        }

        let bundle = Bundle.mapboxMaps

        // Non actionable single item gets displayed as alert's message
        if attributions.count == 1, let attribution = attributions.first, attribution.kind == .nonActionable {
            alert.message = attribution.localizedTitle
        } else {
            for attribution in attributions {
                let action = UIAlertAction(title: attribution.localizedTitle, style: .default) { _ in
                    self.delegate?.attributionDialogManager(self, didTriggerActionFor: attribution)
                }
                action.isEnabled = attribution.kind != .nonActionable
                alert.addAction(action)
            }
        }

        let telemetryAction = UIAlertAction(title: TelemetryStrings.telemetryName, style: .default) { _ in
            self.showTelemetryAlertController(from: viewController)
        }

        alert.addAction(telemetryAction)

        if isGeofenceActive() || !getGeofenceConsent() {
            let geofencingAction = UIAlertAction(title: GeofencingStrings.geofencingName, style: .default) { _ in
                self.showGeofencingAlertController(from: viewController)
            }
            alert.addAction(geofencingAction)
        }

        let privacyPolicyAttribution = Attribution.makePrivacyPolicyAttribution()
        let privacyPolicyAction = UIAlertAction(title: privacyPolicyAttribution.title, style: .default) { _ in
            self.delegate?.attributionDialogManager(self, didTriggerActionFor: privacyPolicyAttribution)
        }

        alert.addAction(privacyPolicyAction)

        let cancelTitle = NSLocalizedString("ATTRIBUTION_CANCEL",
                                            tableName: Ornaments.localizableTableName,
                                            bundle: bundle,
                                            value: "Cancel",
                                            comment: "Title of button for dismissing attribution action sheet")

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))

        viewController.present(alert, animated: true, completion: nil)
    }
}

private extension Attribution {
    var localizedTitle: String {
        NSLocalizedString(
            title,
            tableName: Ornaments.localizableTableName,
            bundle: .mapboxMaps,
            value: title,
            comment: "Attribution from sources."
        )
    }
}

enum TelemetryStrings {
    static let telemetryName = NSLocalizedString(
        "TELEMETRY_NAME",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Mapbox Telemetry",
        comment: "Action in attribution sheet"
    )

    static let telemetryTitle = NSLocalizedString(
        "TELEMETRY_TITLE",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Make Mapbox Maps Better",
        comment: "Telemetry prompt title"
    )

    static let telemetryEnabledMessage = NSLocalizedString(
        "TELEMETRY_ENABLED_MSG",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: """
        You are helping to make OpenStreetMap and
        Mapbox maps better by contributing anonymous usage data.
        """,
        comment: "Telemetry prompt message"
    )

    static let telemetryDisabledMessage = NSLocalizedString(
        "TELEMETRY_DISABLED_MSG",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: """
        You can help make OpenStreetMap and Mapbox maps better
        by contributing anonymous usage data.
        """,
        comment: "Telemetry prompt message"
    )

    static let telemetryEnabledOnMessage = NSLocalizedString(
        "TELEMETRY_ENABLED_ON",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Keep Participating",
        comment: "Telemetry prompt button"
    )

    static let telemetryEnabledOffMessage = NSLocalizedString(
        "TELEMETRY_ENABLED_OFF",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Stop Participating",
        comment: "Telemetry prompt button"
    )

    static let telemetryDisabledOnMessage = NSLocalizedString(
        "TELEMETRY_DISABLED_ON",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Participate",
        comment: "Telemetry prompt button"
    )

    static let telemetryDisabledOffMessage = NSLocalizedString(
        "TELEMETRY_DISABLED_OFF",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Don’t Participate",
        comment: "Telemetry prompt button"
    )

    static let telemetryMore = NSLocalizedString(
        "TELEMETRY_MORE",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Tell Me More",
        comment: "Telemetry prompt button"
    )
}

enum GeofencingStrings {
    static let geofencingName = NSLocalizedString(
        "GEOFENCING_NAME",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Mapbox Geofencing",
        comment: "Action in attribution sheet"
    )

    static let geofencingTitle = NSLocalizedString(
        "GEOFENCING_TITLE",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Allow This App to Use Geofencing",
        comment: "Geofencing prompt title"
    )

    static let geofencingMessage = NSLocalizedString(
        "GEOFENCING_MSG",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: """
        This app uses Mapbox Geofencing to detect your device’s presence in areas the app developer has defined.
        Only the app developer can see where those areas are.
        You have the option to disable Mapbox Geofencing, which may affect app functionality.
        """,
        comment: "Geofencing prompt message"
    )

    static let geofencingEnabledOnMessage = NSLocalizedString(
        "GEOFENCING_ENABLED_ON",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Keep Geofencing enabled",
        comment: "Geofencing prompt button"
    )

    static let geofencingEnabledOffMessage = NSLocalizedString(
        "GEOFENCING_ENABLED_OFF",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Disable Geofencing",
        comment: "Geofencing prompt button"
    )

    static let geofencingDisabledOnMessage = NSLocalizedString(
        "GEOFENCING_DISABLED_ON",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Enable Geofencing",
        comment: "Geofencing prompt button"
    )

    static let geofencingDisabledOffMessage = NSLocalizedString(
        "GEOFENCING_DISABLED_OFF",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Keep Geofencing Disabled",
        comment: "Geofencing prompt button"
    )
}
