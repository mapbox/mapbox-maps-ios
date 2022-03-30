import UIKit
import MapboxMaps

private protocol DebugOptionSettingsDelegate: AnyObject {
    func debugOptionSettingsDidChange(_ controller: SettingsViewController)
}

private struct MapDebugOptionSetting {
    let debugOption: MapDebugOptions
    let displayTitle: String
}

final class DebugMapExample: UIViewController, ExampleProtocol, DebugOptionSettingsDelegate {

    private var map: MapboxMap!

    override func loadView() {
        let mapView = MapView(frame: .zero)
        map = mapView.mapboxMap

        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        let debugOptionsBarItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(openDebugOptionsMenu(_:)))
        navigationItem.rightBarButtonItems = [debugOptionsBarItem] + rightBarButtonItems
    }

    @objc private func openDebugOptionsMenu(_ sender: UIBarButtonItem) {
        let settingsViewController = SettingsViewController(debugOptions: map.debugOptions)
        settingsViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender

        present(navigationController, animated: true, completion: nil)
    }

    fileprivate func debugOptionSettingsDidChange(_ controller: SettingsViewController) {
        controller.dismiss(animated: true, completion: nil)
        map.debugOptions = controller.enabledDebugOptions
    }
}

private final class SettingsViewController: UIViewController, UITableViewDataSource {

    weak var delegate: DebugOptionSettingsDelegate?
    private var listView: UITableView!

    private(set) var enabledDebugOptions: [MapDebugOptions]
    private let allSettings: [MapDebugOptionSetting] = [
        MapDebugOptionSetting(debugOption: .collision, displayTitle: "Debug collision"),
        MapDebugOptionSetting(debugOption: .depthBuffer, displayTitle: "Show depth buffer"),
        MapDebugOptionSetting(debugOption: .overdraw, displayTitle: "Debug overdraw"),
        MapDebugOptionSetting(debugOption: .parseStatus, displayTitle: "Show tile coordinate"),
        MapDebugOptionSetting(debugOption: .renderCache, displayTitle: "Render Cache"),
        MapDebugOptionSetting(debugOption: .stencilClip, displayTitle: "Show stencil buffer"),
        MapDebugOptionSetting(debugOption: .tileBorders, displayTitle: "Debug tile clipping"),
        MapDebugOptionSetting(debugOption: .timestamps, displayTitle: "Show tile loaded time"),
    ]

    init(debugOptions: [MapDebugOptions]) {
        enabledDebugOptions = debugOptions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        listView = UITableView()
        listView.dataSource = self

        view.addSubview(listView)

        listView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            listView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            listView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveSettings(_:)))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = listView.contentSize
    }

    @objc private func saveSettings(_ sender: UIBarButtonItem) {
        delegate?.debugOptionSettingsDidChange(self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allSettings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = String(describing: DebugOptionCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? DebugOptionCell ?? DebugOptionCell()

        let setting = allSettings[indexPath.row]
        cell.configure(with: setting, isOptionEnabled: enabledDebugOptions.contains(setting.debugOption))
        cell.onToggled { [unowned self] isEnabled in
            if !isEnabled {
                self.enabledDebugOptions.removeAll(where: { $0 == setting.debugOption })
            } else if !self.enabledDebugOptions.contains(setting.debugOption) {
                self.enabledDebugOptions.append(setting.debugOption)
            }
        }

        return cell
    }
}

// MARK: Cell

private class DebugOptionCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let toggle = UISwitch()

    init() {
        super.init(style: .default, reuseIdentifier: String(describing: Self.self))
        toggle.addTarget(self, action: #selector(didToggle(_:)), for: .valueChanged)

        contentView.addSubview(titleLabel)
        contentView.addSubview(toggle)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            toggle.leftAnchor.constraint(greaterThanOrEqualTo: titleLabel.rightAnchor, constant: 16),
            toggle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            toggle.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with setting: MapDebugOptionSetting, isOptionEnabled: Bool) {
        titleLabel.text = setting.displayTitle
        toggle.isOn = isOptionEnabled
    }

    private var _onToggled: ((Bool) -> Void)?

    func onToggled(_ handler: @escaping (Bool) -> Void) {
        _onToggled = handler
    }

    @objc private func didToggle(_ sender: UISwitch) {
        _onToggled?(sender.isOn)
    }
}
