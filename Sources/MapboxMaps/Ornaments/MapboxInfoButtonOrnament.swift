import UIKit

internal class MapboxInfoButtonOrnament: UIView {
    private enum Constants {
        static let localizableTableName = "OrnamentsLocalizable"
        static let metricsEnabledKey = "MGLMapboxMetricsEnabled"
        static let telemetryURL = "https://www.mapbox.com/telemetry/"
    }

    private var isMetricsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.metricsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.metricsEnabledKey)
        }
    }

    public override var isHidden: Bool {
        didSet {
            if isHidden {
                Log.warning(forMessage: "Attribution must be enabled if you use data from sources that require it. See https://docs.mapbox.com/help/getting-started/attribution/ for more details.", category: "Ornaments")
            }
        }
    }

    internal init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])
        let button = UIButton(type: .infoLight)
        button.contentVerticalAlignment = .bottom
        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(button)
        translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(infoTapped), for: .primaryActionTriggered)

        let bundle = Bundle.mapboxMaps
        accessibilityLabel = NSLocalizedString("INFO_A11Y_LABEL",
                                               tableName: Constants.localizableTableName,
                                               bundle: bundle,
                                               value: "About this map",
                                               comment: "MapInfo Accessibility label")
        accessibilityHint = NSLocalizedString("INFO_A11Y_HINT",
                                              tableName: Constants.localizableTableName,
                                              bundle: bundle,
                                              value: "Shows credits, a feedback form, and more",
                                              comment: "MapInfo Accessibility hint")
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func infoTapped() {
        guard let viewController = parentViewController else { return }
        let alert: UIAlertController

        let title = NSLocalizedString("SDK_NAME",
                                      tableName: nil,
                                      value: "Mapbox Maps SDK for iOS",
                                      comment: "Action sheet title")

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        }

        let bundle = Bundle.mapboxMaps

        let telemetryTitle = NSLocalizedString("TELEMETRY_NAME",
                                               tableName: Constants.localizableTableName,
                                               bundle: bundle,
                                               value: "Mapbox Telemetry",
                                               comment: "Action in attribution sheet")
        let telemetryAction = UIAlertAction(title: telemetryTitle, style: .default) { [weak self] _ in
            self?.showTelemetryAlertController()
        }

        alert.addAction(telemetryAction)

        let cancelTitle = NSLocalizedString("CANCEL",
                                            tableName: Constants.localizableTableName,
                                            bundle: bundle,
                                            value: "Cancel",
                                            comment: "Title of button for dismissing attribution action sheet")

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))

        viewController.present(alert, animated: true)
    }

    //swiftlint:disable function_body_length
    private func showTelemetryAlertController() {
        guard let viewController = parentViewController else { return }
        let alert: UIAlertController
        let bundle = Bundle.mapboxMaps
        let telemetryTitle = NSLocalizedString("TELEMETRY_TITLE",
                                               tableName: Constants.localizableTableName,
                                               bundle: bundle,
                                               value: "Make Mapbox Maps Better",
                                               comment: "Telemetry prompt title")

        let message: String
        let participateTitle: String
        let declineTitle: String

        if isMetricsEnabled {
            message = NSLocalizedString("TELEMETRY_ENABLED_MSG",
                                        tableName: Constants.localizableTableName,
                                        bundle: bundle,
                                        value: """
                                          You are helping to make OpenStreetMap and
                                          Mapbox maps better by contributing anonymous usage data.
                                        """,
                                        comment: "Telemetry prompt message")
            participateTitle = NSLocalizedString("TELEMETRY_ENABLED_ON",
                                                 tableName: Constants.localizableTableName,
                                                 bundle: bundle,
                                                 value: "Keep Participating",
                                                 comment: "Telemetry prompt button")
            declineTitle = NSLocalizedString("TELEMETRY_ENABLED_OFF",
                                             tableName: Constants.localizableTableName,
                                             bundle: bundle,
                                             value: "Stop Participating",
                                             comment: "Telemetry prompt button")
        } else {
            message = NSLocalizedString("TELEMETRY_DISABLED_MSG",
                                        tableName: Constants.localizableTableName,
                                        bundle: bundle, value: """
                                            You can help make OpenStreetMap and Mapbox maps better
                                            by contributing anonymous usage data.
                                        """,
                                        comment: "Telemetry prompt message")
            participateTitle = NSLocalizedString("TELEMETRY_DISABLED_ON",
                                                 tableName: Constants.localizableTableName,
                                                 bundle: bundle, value: "Participate",
                                                 comment: "Telemetry prompt button")
            declineTitle = NSLocalizedString("TELEMETRY_DISABLED_OFF",
                                             tableName: Constants.localizableTableName,
                                             bundle: bundle, value: "Don’t Participate",
                                             comment: "Telemetry prompt button")
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            alert = UIAlertController(title: telemetryTitle, message: message, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: telemetryTitle, message: message, preferredStyle: .actionSheet)
        }

        let moreTitle = NSLocalizedString("TELEMETRY_MORE",
                                          tableName: Constants.localizableTableName,
                                          bundle: bundle, value: "Tell Me More",
                                          comment: "Telemetry prompt button")
        let moreAction = UIAlertAction(title: moreTitle, style: .default) { _ in
            guard let url = URL(string: Constants.telemetryURL) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        alert.addAction(moreAction)

        alert.addAction(UIAlertAction(title: declineTitle, style: .default) { [weak self] _ in
            self?.isMetricsEnabled = false
        })

        alert.addAction(UIAlertAction(title: participateTitle, style: .cancel) { [weak self] _ in
            self?.isMetricsEnabled = true
        })

        viewController.present(alert, animated: true)
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
