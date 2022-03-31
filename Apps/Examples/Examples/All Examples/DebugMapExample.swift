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

    private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        view.addSubview(mapView)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])

        let debugOptionsBarItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(openDebugOptionsMenu(_:)))
        navigationItem.rightBarButtonItems?.insert(debugOptionsBarItem, at: 0)
    }

    @objc private func openDebugOptionsMenu(_ sender: UIBarButtonItem) {
        let settingsViewController = SettingsViewController(debugOptions: mapView.mapboxMap.debugOptions)
        settingsViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender

        present(navigationController, animated: true, completion: nil)
    }

    fileprivate func debugOptionSettingsDidChange(_ controller: SettingsViewController) {
        controller.dismiss(animated: true, completion: nil)
        mapView.mapboxMap.debugOptions = Array(controller.enabledDebugOptions)
    }
}

private final class SettingsViewController: UIViewController, UITableViewDataSource {

    weak var delegate: DebugOptionSettingsDelegate?
    private var listView: UITableView!

    private(set) var enabledDebugOptions: Set<MapDebugOptions>
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
        enabledDebugOptions = Set(debugOptions)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        listView = UITableView()
        listView.dataSource = self
        listView.register(DebugOptionCell.self, forCellReuseIdentifier: String(describing: DebugOptionCell.self))

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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DebugOptionCell

        let setting = allSettings[indexPath.row]
        cell.configure(with: setting, isOptionEnabled: enabledDebugOptions.contains(setting.debugOption))
        cell.onToggled { [unowned self] isEnabled in
            if isEnabled {
                self.enabledDebugOptions.insert(setting.debugOption)
            } else {
                self.enabledDebugOptions.remove(setting.debugOption)
            }
        }

        return cell
    }
}

// MARK: Cell

private class DebugOptionCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let toggle = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

    private var onToggleHandler: ((Bool) -> Void)?

    func onToggled(_ handler: @escaping (Bool) -> Void) {
        onToggleHandler = handler
    }

    @objc private func didToggle(_ sender: UISwitch) {
        onToggleHandler?(sender.isOn)
    }
}
