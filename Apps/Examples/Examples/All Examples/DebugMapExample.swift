import UIKit
@_spi(Experimental) import MapboxMaps

final class DebugMapExample: UIViewController, ExampleProtocol {
    private var collectStatisticsButton = UIButton(type: .system)
    private var mapView: MapView!
    private var performanceStatisticsCancelable: AnyCancelable?
    private let settings: [Setting] = [
        Setting(option: .debug(.collision), title: "Debug collision"),
        Setting(option: .debug(.depthBuffer), title: "Show depth buffer"),
        Setting(option: .debug(.overdraw), title: "Debug overdraw"),
        Setting(option: .debug(.parseStatus), title: "Show tile coordinate"),
        Setting(option: .debug(.stencilClip), title: "Show stencil buffer"),
        Setting(option: .debug(.tileBorders), title: "Debug tile clipping"),
        Setting(option: .debug(.timestamps), title: "Show tile loaded time"),
        Setting(option: .debug(.modelBounds), title: "Show 3D model bounding boxes"),
        Setting(option: .debug(.light), title: "Show light conditions"),
        Setting(option: .debug(.camera), title: "Show camera debug view"),
        Setting(option: .debug(.padding), title: "Camera padding"),
        Setting(option: .performance(.init([.perFrame, .cumulative], samplingDurationMillis: 5000)), title: "Performance statistics"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        if #available(iOS 15.0, *) {
            let maxFPS = Float(UIScreen.main.maximumFramesPerSecond)
            mapView.preferredFrameRateRange = CAFrameRateRange(minimum: 1, maximum: maxFPS, preferred: maxFPS)
        }

        view.addSubview(mapView)
        view.backgroundColor = .skyBlue
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let debugOptionsBarItem = UIBarButtonItem(
            title: "Debug",
            style: .plain,
            target: self,
            action: #selector(openDebugOptionsMenu(_:)))
        let tileCover = UIBarButtonItem(
            title: "Tiles",
            style: .plain,
            target: self,
            action: #selector(tileCover))
        navigationItem.rightBarButtonItems = [debugOptionsBarItem, tileCover]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    @objc private func openDebugOptionsMenu(_ sender: UIBarButtonItem) {
        let settingsViewController = SettingsViewController(settings: settings)
        settingsViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender

        present(navigationController, animated: true, completion: nil)
    }

    @objc private func tileCover() {
        let tileIds = mapView.mapboxMap.tileCover(for: TileCoverOptions(tileSize: 512, minZoom: 0, maxZoom: 22, roundZoom: false))
        let message = tileIds.map { "\($0.z)/\($0.x)/\($0.y)" }.joined(separator: "\n")
        showAlert(withTitle: "Displayed tiles", and: message)
    }

    private func handle(statistics: PerformanceStatistics) {
        showAlert(with: "\(statistics.topRenderedGroupDescription)\n\(statistics.renderingDurationStatisticsDescription)")
    }
}

extension DebugMapExample: DebugOptionSettingsDelegate {
    func settingsDidChange(debugOptions: MapViewDebugOptions, performanceOptions: PerformanceStatisticsOptions?) {
        mapView.debugOptions = debugOptions

        guard let performanceOptions else { return performanceStatisticsCancelable = nil }
        performanceStatisticsCancelable?.cancel()
        performanceStatisticsCancelable = mapView.mapboxMap.collectPerformanceStatistics(performanceOptions, callback: handle(statistics:))
    }
}

final class SettingsViewController: UIViewController, UITableViewDataSource {
    weak var delegate: DebugOptionSettingsDelegate?
    private var listView: UITableView!
    private let settings: [Setting]

    fileprivate init(settings: [Setting]) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Debug options"
        listView = UITableView()
        listView.dataSource = self
        listView.register(DebugOptionCell.self, forCellReuseIdentifier: String(describing: DebugOptionCell.self))

        view.addSubview(listView)

        listView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        let debugOptions = settings
            .filter(\.isEnabled)
            .compactMap(\.option.debugOption)
            .reduce(MapViewDebugOptions()) { result, next in result.union(next) }

        let performanceOptions = settings
            .filter(\.isEnabled)
            .compactMap(\.option.performanceOption)

        delegate?.settingsDidChange(debugOptions: debugOptions, performanceOptions: performanceOptions.first)
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = String(describing: DebugOptionCell.self)
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DebugOptionCell

        let setting = settings[indexPath.row]
        cell.configure(with: setting.title, isOptionEnabled: setting.isEnabled)
        cell.onToggled(setting.toggle)

        return cell
    }
}

// MARK: Cell

private class DebugOptionCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    private var onToggleHandler: (() -> Void)?

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

    func configure(with title: String, isOptionEnabled: Bool) {
        titleLabel.text = title
        toggle.isOn = isOptionEnabled
    }

    func onToggled(_ handler: @escaping () -> Void) {
        onToggleHandler = handler
    }

    @objc private func didToggle(_ sender: UISwitch) {
        onToggleHandler?()
    }
}

protocol DebugOptionSettingsDelegate: AnyObject {
    func settingsDidChange(debugOptions: MapViewDebugOptions, performanceOptions: PerformanceStatisticsOptions?)
}

private final class Setting {
    enum Option {
        case debug(MapViewDebugOptions)
        case performance(PerformanceStatisticsOptions)
    }

    let option: Option
    let title: String
    private(set) var isEnabled: Bool

    init(option: Option, title: String, isEnabled: Bool = false) {
        self.option = option
        self.title = title
        self.isEnabled = isEnabled
    }

    func toggle() { isEnabled.toggle() }
}

extension Setting.Option {
    var debugOption: MapViewDebugOptions? {
        if case let .debug(option) = self { return option } else { return nil }
    }

    var performanceOption: PerformanceStatisticsOptions? {
        if case let .performance(option) = self { return option } else { return nil }
    }
}

extension PerformanceStatistics {
    fileprivate var topRenderedGroupDescription: String {
        if let topRenderedGroup = perFrameStatistics?.topRenderGroups.first {
            return "Top rendered group: `\(topRenderedGroup.name)` took \(topRenderedGroup.durationMillis)ms."
        } else {
            return "No information about topRenderedLayer."
        }
    }

    fileprivate var renderingDurationStatisticsDescription: String {
        guard let drawCalls = cumulativeStatistics?.drawCalls else { return "Cumulative statistics haven't been collected." }
        return """
        Number of draw calls: \(drawCalls).
        """
    }
}
