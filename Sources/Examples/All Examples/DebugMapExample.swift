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
        Setting(option: .screenShape, title: "Custom culling shape"),
        Setting(option: .performance(.init([.perFrame, .cumulative], samplingDurationMillis: 5000)), title: "Performance statistics"),
    ]
    private let customCullingShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3
        layer.lineJoin = .round
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        return layer
    }()
    private let dimLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor

        return layer
    }()
    private let customCullingShape = [
        CGPoint(x: 0.35, y: 0.34),  // top-left
        CGPoint(x: 0.65, y: 0.34),  // top-right
        CGPoint(x: 0.85, y: 0.50),  // right
        CGPoint(x: 0.65, y: 0.66),  // bottom-right
        CGPoint(x: 0.35, y: 0.66),  // bottom-left
        CGPoint(x: 0.15, y: 0.50)   // left
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        let maxFPS = Float(UIScreen.main.maximumFramesPerSecond)
        mapView.preferredFrameRateRange = CAFrameRateRange(minimum: 1, maximum: maxFPS, preferred: maxFPS)
        mapView.ornaments.options.scaleBar.units = .nautical
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
        let infoBarItem = UIBarButtonItem(
            title: "Info",
            style: .plain,
            target: self,
            action: #selector(showInfo))
        navigationItem.rightBarButtonItems = [debugOptionsBarItem, infoBarItem]
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

    private func extractStyleInfo() -> StyleInfo {
        let styleJSON = mapView.mapboxMap.styleJSON

        guard let data = styleJSON.data(using: .utf8),
              let parsedStyle = try? JSONDecoder().decode(StyleJson.self, from: data) else {
            return StyleInfo(modifiedDate: "Unknown", sdkCompatibility: "Unknown", styleURL: "Unknown")
        }

        let modifiedDate = parsedStyle.modified ?? "Unknown"

        let sdkCompatibility: String
        if let compatibility = parsedStyle.metadata?.compatibility {
            var compatibilityParts: [String] = []
            if let ios = compatibility.ios {
                compatibilityParts.append("iOS: \(ios)")
            }
            if let android = compatibility.android {
                compatibilityParts.append("Android: \(android)")
            }
            if let js = compatibility.js {
                compatibilityParts.append("JS: \(js)")
            }
            sdkCompatibility = compatibilityParts.isEmpty ? "Unknown" : compatibilityParts.joined(separator: "\n")
        } else {
            sdkCompatibility = "Unknown"
        }

        let styleURL: String
        if let origin = parsedStyle.metadata?.origin, !origin.isEmpty {
            styleURL = origin
        } else {
            styleURL = mapView.mapboxMap.styleURI?.rawValue ?? "Unknown"
        }

        return StyleInfo(modifiedDate: modifiedDate, sdkCompatibility: sdkCompatibility, styleURL: styleURL)
    }

    @objc private func showInfo() {
        // Get tiles information
        let tileIds = mapView.mapboxMap.tileCover(for: TileCoverOptions(tileSize: 512, minZoom: 0, maxZoom: 22, roundZoom: false))
        let tilesMessage = tileIds.map { "\($0.z)/\($0.x)/\($0.y)" }.joined(separator: "\n")

        // Get style information
        let styleInfo = extractStyleInfo()
        let styleMessage = """
        Style URL: \(styleInfo.styleURL)
        Modified: \(styleInfo.modifiedDate)
        SDK Compatibility:
        \(styleInfo.sdkCompatibility)
        """

        // Combine both
        let combinedMessage = """
        TILES:
        \(tilesMessage)

        STYLE INFO:
        \(styleMessage)
        """
        showAlert(withTitle: "Map Info", and: combinedMessage)
    }

    private func handle(statistics: PerformanceStatistics) {
        showAlert(with: "\(statistics.topRenderedGroupDescription)\n\(statistics.renderingDurationStatisticsDescription)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let scaledShape = customCullingShape.map { CGPoint(x: $0.x * mapView.bounds.width, y: $0.y * mapView.bounds.height) }
        let cutoutPath = UIBezierPath()
        cutoutPath.move(to: scaledShape.first!)
        scaledShape.dropFirst().forEach(cutoutPath.addLine)
        cutoutPath.close()

        customCullingShapeLayer.path = cutoutPath.cgPath

        let mapViewPath = UIBezierPath(rect: mapView.bounds)
        mapViewPath.append(cutoutPath)
        mapViewPath.usesEvenOddFillRule = true

        dimLayer.path = mapViewPath.cgPath
    }

    private func setScreenShape() {
        mapView.mapboxMap.screenCullingShape = customCullingShape
        mapView.layer.addSublayer(dimLayer)
        mapView.layer.addSublayer(customCullingShapeLayer)
    }

    private func removeScreenShape() {
        customCullingShapeLayer.removeFromSuperlayer()
        dimLayer.removeFromSuperlayer()
        mapView.mapboxMap.screenCullingShape = []
    }
}

extension DebugMapExample: DebugOptionSettingsDelegate {
    func settingsDidChange(
        debugOptions: MapViewDebugOptions,
        performanceOptions: PerformanceStatisticsOptions?,
        screenShapeEnabled: Bool
    ) {
        if screenShapeEnabled {
            setScreenShape()
        } else {
            removeScreenShape()
        }
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
        let enabledSettings = settings.filter({ $0.isEnabled })
        let debugOptions = enabledSettings
            .compactMap(\.option.debugOption)
            .reduce(MapViewDebugOptions()) { result, next in result.union(next) }

        let performanceOptions = enabledSettings
            .compactMap(\.option.performanceOption)

        let screenShapeEnabled = enabledSettings.contains(where: { $0.option.isScreenShape })

        delegate?.settingsDidChange(
            debugOptions: debugOptions,
            performanceOptions: performanceOptions.first,
            screenShapeEnabled: screenShapeEnabled
        )
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
    func settingsDidChange(
        debugOptions: MapViewDebugOptions,
        performanceOptions: PerformanceStatisticsOptions?,
        screenShapeEnabled: Bool
    )
}

private final class Setting {
    enum Option {
        case debug(MapViewDebugOptions)
        case performance(PerformanceStatisticsOptions)
        case screenShape
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

    var isScreenShape: Bool {
        if case .screenShape = self { return true } else { return false }
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

struct StyleInfo {
    let modifiedDate: String
    let sdkCompatibility: String
    let styleURL: String
}

struct StyleJson: Codable {
    let modified: String?
    let metadata: Metadata?
}

struct Metadata: Codable {
    let origin: String?
    let compatibility: Compatibility?

    enum CodingKeys: String, CodingKey {
        case origin = "mapbox:origin"
        case compatibility = "mapbox:compatibility"
    }
}

struct Compatibility: Codable {
    let ios: String?
    let android: String?
    let js: String?
}
