import UIKit
@_spi(Experimental) import MapboxMaps
import CoreLocation
import MapboxCoreMaps

private let simulatedCoordinate = CLLocationCoordinate2D(latitude: 37.6421, longitude: -122.4062)

final class DynamicViewAnnotationExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()

    private var routes = [Route]() {
        didSet {
            oldValue.forEach { $0.remove() }
            routes.forEach { route in
                route.mapView = mapView
                route.display()
                route.onTap = { [unowned route, weak self] in
                    self?.select(route: route)
                }
            }
            if let last = routes.last {
                select(route: last, animated: false)
            }
        }
    }

    private lazy var modeButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor(red: 0.084, green: 0.176, blue: 0.283, alpha: 0.25).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        return button
    }()

    private var driveMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        updateModeButton()

        mapView.location.override(
            locationProvider: Signal(just: [
                Location(
                    coordinate: simulatedCoordinate,
                    bearing: 168.8)
            ]),
            headingProvider: Signal(just: Heading(direction: 180, accuracy: 0)))
        mapView.location.options = LocationOptions(puckType: .puck2D(.init(topImage: UIImage(named: "dash-puck"))), puckBearing: .heading, puckBearingEnabled: true)

        mapView.viewport.options.usesSafeAreaInsetsAsPadding = true

        mapView.mapboxMap.onStyleLoaded.observeNext { [weak self] _ in
            guard let self = self else { return }
            loadRoutes()
            self.finish()
        }.store(in: &cancelables)

        self.toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: modeButton),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]

        addParkingAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 37.445, longitude: -122.1704),
            text: "$6.99/hr")
        addParkingAnnotation(
            coordinate: CLLocationCoordinate2D(latitude: 37.4441, longitude: -122.1691),
            text: "$5.99/hr")
    }

    private func loadRoutes() {
        DispatchQueue.global(qos: .userInitiated).async {
            let route1 = Route.load(name: "route-sf-1", time: "52 min")
            let route2 = Route.load(name: "route-sf-2", time: "55 min")
            route1.hint = ETAHint(text: "Avoid traffic", icon: "maneuver-straight")
            route2.hint = ETAHint(text: "On highway", icon: "maneuver-turn-right")
            DispatchQueue.main.async {
                self.routes = [route1, route2]
            }
        }
    }

    private func select(route: Route, animated: Bool = true) {
        // Move selected route layer on top of unselected route layers
        let routeLayersIds = Set(routes.map(\.layerId))
        let lastUnselected = mapView.mapboxMap.allLayerIdentifiers.last { info in
            routeLayersIds.contains(info.id)
        }
        if let lastUnselected, lastUnselected.id != route.layerId {
            try? mapView.mapboxMap.moveLayer(withId: route.layerId, to: .above(lastUnselected.id))
        }

        for r in routes {
            // Update layer color
            r.selected = r === route
        }
        if !driveMode {
            updateViewport(animated: animated)
        }
    }

    @objc private func changeMode() {
        self.driveMode.toggle()
        updateModeButton()

        hideAnnotations(true)
        updateViewport(animated: true) {
            [weak self] in self?.hideAnnotations(false)
        }
        routes.forEach {
            $0.updateProgress(with: driveMode ? simulatedCoordinate : nil)
        }
    }

    private func updateModeButton() {
        modeButton.setTitle("Mode: \(driveMode ? "Drive" : "Overview")", for: .normal)
    }

    private func hideAnnotations(_ hidden: Bool) {
        routes.forEach {
            $0.etaAnnotation?.visible = !hidden
        }
    }

    private func updateViewport(animated: Bool, completion: (() -> Void)? = nil) {
        var viewportState: ViewportState?
        if driveMode {
            viewportState = mapView.viewport.makeFollowPuckViewportState(options: .init(zoom: 17, bearing: .course, pitch: 49))
        } else {
            if let route = routes.first(where: \.selected), let geometry = route.feature.geometry {
                let coordPadding = UIEdgeInsets(allEdges: 20)
                let options = OverviewViewportStateOptions(geometry: geometry, geometryPadding: coordPadding)
                viewportState = mapView.viewport.makeOverviewViewportState(options: options)
            }
        }

        if let viewportState {
            mapView.viewport.transition(
                to: viewportState,
                transition: animated ? mapView.viewport.makeDefaultViewportTransition() : mapView.viewport.makeImmediateViewportTransition()
            ) { _ in completion?() }
        } else {
            completion?()
        }
    }

    private func addParkingAnnotation(coordinate: CLLocationCoordinate2D, text: String) {
        let view = ParkingAnnotationView(text: text)

        let annotation = ViewAnnotation(coordinate: coordinate, view: view)
        annotation.allowOverlap = true
        mapView.viewAnnotations.add(annotation)

        view.onTap = { [unowned view, unowned annotation] in
            annotation.selected.toggle()
            view.selected = annotation.selected
            annotation.setNeedsUpdateSize()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
    }
}

struct ETAHint {
    var text: String
    var icon: String
}

private final class Route {
    let name: String
    let time: String
    let feature: Feature
    var hint: ETAHint?
    var selected: Bool = false {
        didSet { updateSelected() }
    }
    var layerId: String { "route-\(name)" }
    private(set) var etaAnnotation: ViewAnnotation?
    private var etaView: ETAView?
    private var displayed = false
    private var tokens = Set<AnyCancelable>()

    var onTap: (() -> Void)?
    weak var mapView: MapView?

    init(name: String, time: String, feature: Feature) {
        self.name = name
        self.time = time
        self.feature = feature
    }

    func updateProgress(with coordinate: CLLocationCoordinate2D?) {
        var progress = 0.0
        if let coordinate,
           case let .lineString(s) = feature.geometry,
           let doneDistance = s.distance(to: coordinate),
           let length = s.distance() {
            progress = doneDistance / length + 0.0005
        }

        try? mapView?.mapboxMap.setLayerProperty(for: layerId, property: "line-trim-offset", value: [0, progress])
    }

    func display() {
        guard !displayed, let mapView else { return }
        displayed = true

        func colorExpression(normal: String, selected: String) -> Exp {
            Exp(.switchCase) {
                Exp(.boolean) {
                    Exp(.featureState) { "selected" }
                    false
                }
                selected
                normal
            }
        }

        // Routes data source and layer
        var source = GeoJSONSource(id: layerId)
        source.data = .feature(feature)
        source.lineMetrics = true
        try! mapView.mapboxMap.addSource(source)

        var routeLayer = LineLayer(id: layerId, source: layerId)
        routeLayer.lineCap = .constant(.round)
        routeLayer.lineJoin = .constant(.round)
        routeLayer.lineWidth = .constant(10.0)
        routeLayer.lineColor = .expression(colorExpression(normal: "#999999", selected: "#57A9FB"))
        routeLayer.lineBorderWidth = .constant(2)
        routeLayer.lineBorderColor = .expression(colorExpression(normal: "#666666", selected: "#327AC2"))
        routeLayer.slot = .middle
        try! mapView.mapboxMap.addLayer(routeLayer)

        // Annotation
        let etaView = ETAView(text: time)
        self.etaView = etaView

        let etaAnnotation = ViewAnnotation(layerId: layerId, view: etaView)
        etaAnnotation.onAnchorChanged = { config in
            etaView.anchor = config.anchor
        }
        etaAnnotation.variableAnchors = .all
        etaView.onTap = { [weak self] in self?.onTap?() }

        self.etaAnnotation = etaAnnotation
        updateSelected()

        mapView.viewAnnotations.add(etaAnnotation)
        mapView.gestures.onLayerTap(layerId) { [weak self] feature, _ in
            guard let self,
                  let onTap = onTap,
                  let identifier = feature.feature.identifier,
                  case let .string(id) = identifier,
                  id == self.name else { return false }
            onTap()
            return true
        }.store(in: &tokens)
    }

    func remove() {
        try? mapView?.mapboxMap.removeLayer(withId: self.layerId)
        try? mapView?.mapboxMap.removeSource(withId: self.layerId)
        self.etaAnnotation?.remove()
        self.etaAnnotation = nil
        self.etaView = nil
        mapView = nil
        onTap = nil
        tokens.removeAll()
    }

    private func updateSelected() {
        etaAnnotation?.selected = selected
        etaView?.selected = selected
        mapView?.mapboxMap.setFeatureState(sourceId: layerId, featureId: name, state: ["selected": selected]) {_ in}

        etaView?.hint = selected ? nil : hint
        etaAnnotation?.setNeedsUpdateSize()
    }

    static func load(name: String, time: String) -> Route {
        let data = NSDataAsset(name: name)!.data
        let feature = try! JSONDecoder().decode(Feature.self, from: data)
        return .init(name: name, time: time, feature: feature)
    }
}

private final class ParkingAnnotationView: UIView {
    private let label = UILabel()
    private let icon = UIImageView()
    private let stack = UIStackView()
    var text: String {
        didSet { label.text = text }
    }
    var selected: Bool = false {
        didSet { updateSelection() }
    }

    var onTap: (() -> Void)?

    init(text: String) {
        self.text = text

        super.init(frame: .zero)
        icon.image = UIImage(named: "parking-icon")
        stack.axis = .horizontal
        stack.spacing = 3
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(label)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24)
        ])
        layer.shadowColor = UIColor(red: 0.084, green: 0.176, blue: 0.283, alpha: 0.25).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        updateSelection()
        updateText()
    }

    func updateText() {
        label.attributedText = .labelText(text, size: 16, color: .black)
    }

    func updateSelection() {
        backgroundColor = selected ? .systemBlue : .white
        label.textColor = selected ? .white : .black
    }

    @objc private func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2
    }
}

final class ETAView: UIView {
    private let label = UILabel()
    private let iconView = UIImageView()
    private var tail = UIView()
    private let backgroundShape = CAShapeLayer()

    var hint: ETAHint? {
        didSet { update() }
    }

    var padding = UIEdgeInsets(allEdges: 10)
    var tailSize = 8.0
    var cornerRadius = 8.0
    var selected: Bool = false {
        didSet { update() }
    }
    var onTap: (() -> Void)?

    var text: String {
        didSet { update() }
    }
    var anchor: ViewAnnotationAnchor? {
        didSet { setNeedsLayout() }
    }

    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        self.layer.addSublayer(backgroundShape)
        backgroundShape.shadowRadius = 1.4
        backgroundShape.shadowOffset = CGSize(width: 0, height: 0.7)
        backgroundShape.shadowColor = UIColor.black.cgColor
        backgroundShape.shadowOpacity = 0.3

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.04, green: 0.66, blue: 0.45, alpha: 1)
        label.numberOfLines = 0
        label.textAlignment = .left
        addSubview(label)
        addSubview(iconView)

        update()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var attributedText: NSAttributedString {
        let text = NSMutableAttributedString(attributedString:
                .labelText(text, size: 16, color: selected ? .white : .black, bold: true))
        if let hint {
            text.append(NSAttributedString(string: "\n"))
            text.append(.labelText(hint.text, size: 12, color: .gray))
        }
        return text
    }

    private func update() {
        self.backgroundShape.fillColor = selected ? UIColor.systemBlue.cgColor : UIColor.white.cgColor
        self.label.attributedText = attributedText
        self.iconView.image = hint.flatMap {
            UIImage(named: $0.icon)?.withRenderingMode(.alwaysTemplate)
        }
    }

    struct Layout {
        var label: CGRect
        var bubble: CGRect
        var icon: CGRect
        var size: CGSize

        init(availableSize: CGSize, text: NSAttributedString, showIcon: Bool, tailSize: CGFloat, padding: UIEdgeInsets) {
            let tailPadding = UIEdgeInsets(allEdges: tailSize)

            var iconToText = 0.0
            var iconFrame = CGRect.zero
            if showIcon {
                iconFrame = CGRect(padding: padding + tailPadding, size: CGSize(width: 24, height: 24))
                iconToText = 5.0
            }

            let textPadding = padding + tailPadding + UIEdgeInsets(top: 0, left: iconFrame.width + iconToText, bottom: 0, right: 0)
            let textAvailableSize = availableSize - textPadding
            var textSize = text.boundingRect(
                with: textAvailableSize,
                options: .usesLineFragmentOrigin, context: nil
            ).size.roundedUp()
            textSize.height = max(textSize.height, iconFrame.height)
            iconFrame.size.height = textSize.height
            icon = iconFrame
            label = CGRect(padding: textPadding, size: textSize)
            bubble = CGRect(padding: tailPadding, size: textSize + textPadding - tailPadding)
            size = bubble.size + tailPadding
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Layout(availableSize: size, text: attributedText, showIcon: hint != nil, tailSize: tailSize, padding: padding).size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layout = Layout(availableSize: bounds.size, text: attributedText, showIcon: hint != nil, tailSize: tailSize, padding: padding)
        label.frame = layout.label
        iconView.frame = layout.icon

        let calloutPath = UIBezierPath.calloutPath(size: bounds.size, tailSize: tailSize, cornerRadius: cornerRadius, anchor: anchor ?? .center)
        backgroundShape.path = calloutPath.cgPath
        backgroundShape.frame = bounds
    }
}

func +(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
}

func +(lhs: CGSize, rhs: UIEdgeInsets) -> CGSize {
    return CGSize(width: lhs.width + rhs.left + rhs.right, height: lhs.height + rhs.top + rhs.bottom)
}

func -(lhs: CGSize, rhs: UIEdgeInsets) -> CGSize {
    return lhs + -rhs
}

func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

prefix func -(p: CGPoint) -> CGPoint {
    p * CGPoint(x: -1, y: -1)
}

prefix func -(ins: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: -ins.top, left: -ins.left, bottom: -ins.bottom, right: -ins.right)
}

extension CGSize {
    func roundedUp() -> CGSize {
        CGSize(width: width.rounded(.up), height: height.rounded(.up))
    }
}

extension CGRect {
    init(padding: UIEdgeInsets, size: CGSize) {
        self.init(origin: CGPoint(x: padding.left, y: padding.top), size: size)
    }
}

extension UIEdgeInsets {
    init(allEdges value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}

extension NSAttributedString {
    static func labelText(_ string: String, size: CGFloat, color: UIColor, bold: Bool = false) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.11
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            .font: bold ? UIFont.boldSystemFont(ofSize: size) : .systemFont(ofSize: size),
            .foregroundColor: color,
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}
