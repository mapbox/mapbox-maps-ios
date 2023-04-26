import UIKit
internal protocol AttributionDataSource: AnyObject {
    func loadAttributions(completion: @escaping ([Attribution]) -> Void)
}

internal protocol AttributionDialogManagerDelegate: AnyObject {
    func viewControllerForPresenting(_ attributionDialogManager: AttributionDialogManager) -> UIViewController
    func attributionDialogManager(_ attributionDialogManager: AttributionDialogManager, didTriggerActionFor attribution: Attribution)
}

internal class AttributionDialogManager {

    private weak var dataSource: AttributionDataSource?
    private weak var delegate: AttributionDialogManagerDelegate?
    private var inProcessOfParsingAttributions: Bool = false

    internal init(dataSource: AttributionDataSource, delegate: AttributionDialogManagerDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
    }

    internal var isMetricsEnabled: Bool {
        get {
            UserDefaults.standard.MGLMapboxMetricsEnabled
        }
        set {
            UserDefaults.standard.MGLMapboxMetricsEnabled = newValue
        }
    }

    //swiftlint:disable:next function_body_length
    internal func showTelemetryAlertController(from viewController: UIViewController) {
        let alert: UIAlertController
        let bundle = Bundle.mapboxMaps
        let telemetryTitle = NSLocalizedString("TELEMETRY_TITLE",
                                               tableName: Ornaments.localizableTableName,
                                               bundle: bundle,
                                               value: "Make Mapbox Maps Better",
                                               comment: "Telemetry prompt title")

        let message: String
        let participateTitle: String
        let declineTitle: String

        if isMetricsEnabled {
            message = NSLocalizedString("TELEMETRY_ENABLED_MSG",
                                        tableName: Ornaments.localizableTableName,
                                        bundle: bundle,
                                        value: """
                                      You are helping to make OpenStreetMap and
                                      Mapbox maps better by contributing anonymous usage data.
                                    """,
                                        comment: "Telemetry prompt message")
            participateTitle = NSLocalizedString("TELEMETRY_ENABLED_ON",
                                                 tableName: Ornaments.localizableTableName,
                                                 bundle: bundle,
                                                 value: "Keep Participating",
                                                 comment: "Telemetry prompt button")
            declineTitle = NSLocalizedString("TELEMETRY_ENABLED_OFF",
                                             tableName: Ornaments.localizableTableName,
                                             bundle: bundle,
                                             value: "Stop Participating",
                                             comment: "Telemetry prompt button")
        } else {
            message = NSLocalizedString("TELEMETRY_DISABLED_MSG",
                                        tableName: Ornaments.localizableTableName,
                                        bundle: bundle, value: """
                                        You can help make OpenStreetMap and Mapbox maps better
                                        by contributing anonymous usage data.
                                    """,
                                        comment: "Telemetry prompt message")
            participateTitle = NSLocalizedString("TELEMETRY_DISABLED_ON",
                                                 tableName: Ornaments.localizableTableName,
                                                 bundle: bundle, value: "Participate",
                                                 comment: "Telemetry prompt button")
            declineTitle = NSLocalizedString("TELEMETRY_DISABLED_OFF",
                                             tableName: Ornaments.localizableTableName,
                                             bundle: bundle, value: "Don’t Participate",
                                             comment: "Telemetry prompt button")
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: telemetryTitle, message: message, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: telemetryTitle, message: message, preferredStyle: .actionSheet)
        }

        let moreTitle = NSLocalizedString("TELEMETRY_MORE",
                                          tableName: Ornaments.localizableTableName,
                                          bundle: bundle, value: "Tell Me More",
                                          comment: "Telemetry prompt button")
        let moreAction = UIAlertAction(title: moreTitle, style: .default) { _ in
            guard let url = URL(string: Ornaments.telemetryURL) else { return }
            self.delegate?.attributionDialogManager(self, didTriggerActionFor: Attribution(title: "", url: url))
        }
        alert.addAction(moreAction)

        alert.addAction(UIAlertAction(title: declineTitle, style: .default) { _ in
            self.isMetricsEnabled = false
        })

        alert.addAction(UIAlertAction(title: participateTitle, style: .cancel) { _ in
            self.isMetricsEnabled = true
        })

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
            fatalError("No view controller found")
        }

        let title = NSLocalizedString("SDK_NAME",
                                      tableName: nil,
                                      value: "Powered by Mapbox Maps",
                                      comment: "Action sheet title")

        let alert: UIAlertController

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        }

        let bundle = Bundle.mapboxMaps

        // Non actionable single item gets displayed as alert's message
        if attributions.count == 1, let attribution = attributions.first, attribution.kind == .nonActionable {
            alert.message = attribution.title
        } else {
            for attribution in attributions {
                let action = UIAlertAction(title: attribution.title, style: .default) { _ in
                    self.delegate?.attributionDialogManager(self, didTriggerActionFor: attribution)
                }
                action.isEnabled = attribution.kind != .nonActionable
                alert.addAction(action)
            }
        }

        let telemetryTitle = NSLocalizedString("TELEMETRY_NAME",
                                               tableName: Ornaments.localizableTableName,
                                               bundle: bundle,
                                               value: "Mapbox Telemetry",
                                               comment: "Action in attribution sheet")
        let telemetryAction = UIAlertAction(title: telemetryTitle, style: .default) { _ in
            self.showTelemetryAlertController(from: viewController)
        }

        alert.addAction(telemetryAction)

        let cancelTitle = NSLocalizedString("CANCEL",
                                            tableName: Ornaments.localizableTableName,
                                            bundle: bundle,
                                            value: "Cancel",
                                            comment: "Title of button for dismissing attribution action sheet")

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))

        viewController.present(alert, animated: true, completion: nil)
    }
}
