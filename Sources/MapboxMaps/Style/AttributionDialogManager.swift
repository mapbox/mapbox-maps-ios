import UIKit
import Foundation
@_implementationOnly import MapboxCommon_Private

protocol AttributionDataSource: AnyObject {
    func loadAttributions(completion: @escaping ([Attribution]) -> Void)
}

protocol AttributionDialogManagerDelegate: AnyObject {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController?
}

final class AttributionDialogManager {
    private weak var dataSource: AttributionDataSource?
    private weak var delegate: AttributionDialogManagerDelegate?
    private var inProcessOfParsingAttributions: Bool = false

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

    func showAlertController(
        from viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        actions: [UIAlertAction] = []
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        )

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
            guard let self else { return }
            var menu = self.attributionMenu.menu(from: attributions)
            if let filter = self.attributionMenu.filter {
                menu.filter(filter)
            }
            showAttributionDialog(for: menu)
            self.inProcessOfParsingAttributions = false
        }
    }

    private func showAttributionDialog(for menu: AttributionMenuSection) {
        guard let viewController = delegate?.viewControllerForPresenting(self) else {
            Log.error("Failed to present an attribution dialogue: no presenting view controller found.")
            return
        }

        let actions = menu.elements.compactMap { element in
            switch element {
            case .item(let item):
                let action = UIAlertAction(title: item.title, style: item.style.uiActionStyle) { _ in
                    item.action?()
                }
                action.isEnabled = item.action != nil
                return action
            case .section(let section):
                if section.elements.isEmpty {
                    return nil
                }
                return UIAlertAction(title: section.actionTitle, style: .default) { _ in
                    self.showAttributionDialog(for: section)
                }
            }
        }

        showAlertController(from: viewController, title: menu.title, message: menu.subtitle, actions: actions)
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
