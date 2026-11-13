import UIKit
import SwiftUI
import Foundation
internal import MapboxCommon_Private

protocol AttributionDataSource: AnyObject {
    func getAttributions() -> [Attribution]
}

protocol AttributionDialogManagerDelegate: AnyObject {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController?
}

final class AttributionDialogManager {
    private weak var dataSource: AttributionDataSource?
    private weak var delegate: AttributionDialogManagerDelegate?

    private let attributionMenu: AttributionMenu

    init(
        dataSource: AttributionDataSource,
        delegate: AttributionDialogManagerDelegate?,
        attributionMenu: AttributionMenu
    ) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.attributionMenu = attributionMenu
    }
}

// MARK: Shared attribution presentation

extension AttributionDialogManager {
    func showAttribution() {
        guard let attributions = dataSource?.getAttributions() else {
            return
        }
        showAttributionSheet(for: self.attributionMenu.menu(from: attributions))
    }
}

// MARK: InfoButtonOrnamentDelegate Implementation
extension AttributionDialogManager: InfoButtonOrnamentDelegate {
    func didTap(_ infoButtonOrnament: InfoButtonOrnament) {
        showAttribution()
    }

    private func showAttributionSheet(for menu: AttributionMenuContent) {
        guard let viewController = delegate?.viewControllerForPresenting(self) else {
            Log.error("Failed to present an attribution sheet: no presenting view controller found.")
            return
        }

        let host = UIHostingController(rootView: AttributionSheetView(
            menu: menu,
            dismiss: { completion in viewController.dismiss(animated: true, completion: completion) }
        ))
        host.modalPresentationStyle = .pageSheet
#if !os(visionOS)
        if #available(iOS 15, *) {
            if let sheet = host.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        }
#endif
        viewController.present(host, animated: true)
    }
}

internal extension Attribution {
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

    static let telemetryEnabledMessage = NSLocalizedString(
        "TELEMETRY_ENABLED_MSG",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "We use anonymized data to make OpenStreetMap and Mapbox better.",
        comment: "Telemetry prompt message"
    )

    static let telemetryDisabledMessage = NSLocalizedString(
        "TELEMETRY_DISABLED_MSG",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "You can help make OpenStreetMap and Mapbox maps better by contributing anonymous usage data.",
        comment: "Telemetry prompt message"
    )
}

enum CommonStrings {
    static let learnMore = NSLocalizedString(
        "LEARN_MORE",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Learn more",
        comment: "Link to more information"
    )

    static let close = NSLocalizedString(
        "ATTRIBUTION_CLOSE_A11Y_LABEL",
        tableName: Ornaments.localizableTableName,
        bundle: .mapboxMaps,
        value: "Close",
        comment: "Accessibility label for the close button in attribution sheet"
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
}
