import UIKit
import MapboxMaps

final class MapEventsExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private let tableView = UITableView()
    private let cameraLabel = UILabel.makeCameraLabel()
    private var clearButton = UIButton(type: .system)
    private var cancelables = Set<AnyCancelable>()
    var entries = [NSAttributedString]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        mapView = MapView(frame: view.bounds)
        mapView.ornaments.options.scaleBar.visibility = .visible
        view.addSubview(mapView)

        tableView.dataSource = self
        tableView.register(LogCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        view.addSubview(clearButton)

        view.addSubview(cameraLabel)

        let map = mapView.mapboxMap!
        logEvent(map.onMapLoaded)
        logEvent(map.onMapLoadingError)
        logEvent(map.onStyleLoaded)
        logEvent(map.onStyleDataLoaded)
        logEvent(map.onMapIdle)
        logEvent(map.onSourceAdded)
        logEvent(map.onSourceRemoved)
        logEvent(map.onSourceDataLoaded)
        logEvent(map.onStyleImageMissing)
        logEvent(map.onStyleImageRemoveUnused)
        // onResourceRequest produces too much logs for demonstration, uncomment it if needed.
        // logEvent(mapView.mapboxMap.onResourceRequest)

        map.onCameraChanged.observe { [weak self] event in
            self?.cameraLabel.attributedText = .formatted(cameraSate: event.cameraState)
            self?.view.setNeedsLayout()
        }.store(in: &cancelables)
    }

    @objc private func clear() {
        entries.removeAll()
    }

    func logEvent<T: LogableEvent>(_ signal: Signal<T>) {
        signal.observe { [weak self] event in
            self?.entries.append(.formatted(event: event))
            print("MapEvent: \(event.logString)")
        }.store(in: &cancelables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = view.bounds.inset(by: UIEdgeInsets(
            top: view.safeAreaInsets.top, left: 0, bottom: 0, right: 0))
        let halfHeight = bounds.height / 2 + 100

        mapView.frame = CGRect(x: 0, y: bounds.minY, width: bounds.width, height: halfHeight)

        tableView.frame = CGRect(x: 0, y: bounds.minY + halfHeight, width: bounds.width, height: bounds.height - halfHeight)

        let buttonSize = clearButton.sizeThatFits(bounds.size)
        clearButton.frame = CGRect(
            origin: CGPoint(
                x: bounds.width - buttonSize.width - 10,
                y: bounds.minY + halfHeight + 10),
            size: buttonSize)

        let labelSize = cameraLabel.sizeThatFits(bounds.size)
        cameraLabel.frame = CGRect(
            origin: CGPoint(
                x: (bounds.width - labelSize.width) / 2,
                y: bounds.minY + halfHeight - labelSize.height - 10),
            size: labelSize)
    }
}

extension MapEventsExample: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { entries.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LogCell
        cell.logLabel.attributedText = entries[entries.count - 1 - indexPath.row]
        return cell
    }
}

private class LogCell: UITableViewCell {
    let logLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        logLabel.numberOfLines = 0
        logLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logLabel)
        NSLayoutConstraint.activate([
            logLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            logLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            logLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            logLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol LogableEvent {
    var name: String { get }
    var info: String { get }
}

extension LogableEvent {
    var logString: String {
        return "[\(name)] \(info)"
    }
}

private extension NSAttributedString {
    static func logString(_ text: String, bold: Bool = false) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: Any]()
        if #available(iOS 13.0, *) {
            attributes[.font] = UIFont.monospacedSystemFont(ofSize: 13, weight: bold ? .bold : .regular)
        }
        return NSAttributedString(string: text, attributes: attributes)
    }

    static func formatted(cameraSate: CameraState) -> NSAttributedString {
        let str = NSMutableAttributedString()
        str.append(.logString("lat:", bold: true))
        str.append(.logString(" \(String(format: "%.2f", cameraSate.center.latitude))\n"))
        str.append(.logString("lon:", bold: true))
        str.append(.logString(" \(String(format: "%.2f", cameraSate.center.longitude))\n"))
        str.append(.logString("zoom:", bold: true))
        str.append(.logString(" \(String(format: "%.2f", cameraSate.zoom))"))
        if cameraSate.bearing != 0 {
            str.append(.logString("\nbearing:", bold: true))
            str.append(.logString(" \(String(format: "%.2f", cameraSate.bearing))"))
        }
        if cameraSate.pitch != 0 {
            str.append(.logString("\npitch:", bold: true))
            str.append(.logString(" \(String(format: "%.2f", cameraSate.pitch))"))
        }
        return str
    }

    static func formatted(event: LogableEvent) -> NSAttributedString {
        let str = NSMutableAttributedString()
        str.append(.logString(event.name, bold: true))
        if !event.info.isEmpty {
            let withNewLines = event.info.replacingOccurrences(of: ", ", with: "\n")
            str.append(.logString("\n\(withNewLines)"))
        }
        return str
    }
}

extension MapLoaded: LogableEvent {
    var name: String { "MapLoaded" }
    var info: String { "ti: \(timeInterval.log)" }
}

extension MapIdle: LogableEvent {
    var name: String { "MapIdle" }
    var info: String { "ts: \(timestamp)" }
}

extension MapLoadingError: LogableEvent {
    var name: String { "MapLoadingError" }
    var info: String { "ts: \(timestamp), type: \(type), message: \(message), sourceId: \(String(describing: sourceId)), tileId: \(tileId?.log ?? "nil")" }
}

extension StyleLoaded: LogableEvent {
    var name: String { "StyleLoaded" }
    var info: String { "ti: \(timeInterval.log)" }
}

extension StyleDataLoaded: LogableEvent {
    var name: String { "StyleDataLoaded" }
    var info: String { "ti: \(timeInterval.log), type: \(type)" }
}

extension SourceAdded: LogableEvent {
    var name: String { "SourceAdded" }
    var info: String { "ts: \(timestamp), sourceId: \(sourceId)" }
}

extension SourceRemoved: LogableEvent {
    var name: String { "SourceRemoved" }
    var info: String { "ts: \(timestamp), sourceId: \(sourceId)" }
}

extension SourceDataLoaded: LogableEvent {
    var name: String { "SourceDataLoaded" }
    var info: String { "ti: \(timeInterval.log), sourceId: \(sourceId), tileId: \(tileId?.log ?? "nil"), dataID: \(dataId ?? "nil"), loaded: \(loaded.log)" }
}

extension StyleImageMissing: LogableEvent {
    var name: String { "StyleImageMissing" }
    var info: String { "ts: \(timestamp), imageId: \(imageId)" }
}

extension StyleImageRemoveUnused: LogableEvent {
    var name: String { "StyleImageRemoveUnused" }
    var info: String { "ts: \(timestamp), imageId: \(imageId)" }
}

extension ResourceRequest: LogableEvent {
    var name: String { "ResourceRequest" }
    var info: String { "ti: \(timeInterval), source: \(source), url: \(request.url)" }
}

extension Optional where Wrapped: CustomStringConvertible {
    var log: String {
        switch self {
        case .none: return "nil"
        case let .some(val): return "\(val)"
        }
    }
}

extension EventTimeInterval {
    var log: String {
        "\(begin) - \(end)"
    }
}

extension CanonicalTileID {
    var log: String {
        "\(z)/\(x)/\(y)"
    }
}

extension CustomRasterSourceTileStatus {
    var log: String {
        switch self {
        case .required: return "required"
        case .optional: return "optional"
        case .notNeeded: return "notNeeded"
        default: return "unknown"
        }
    }
}

extension StyleDataLoadedType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .style: return "style"
        case .sources: return "sources"
        case .sprite: return "sprite"
        default: return "unknown"
        }
    }
}

extension SourceDataLoadedType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .metadata: return "metadata"
        case .tile: return "tile"
        default: return "unknown"
        }
    }
}

extension RequestDataSourceType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .asset: return "asset"
        case .database: return "database"
        case .fileSystem: return "fileSystem"
        case .network: return "network"
        case .resourceLoader: return "resourceLoader"
        default: return "unknown"
        }
    }
}

private extension UILabel {
    static func makeCameraLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        if #available(iOS 13.0, *) {
            label.backgroundColor = UIColor.systemBackground
        } else {
            label.backgroundColor = .white
        }
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }
}
