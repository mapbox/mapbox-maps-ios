import UIKit
@_spi(Experimental) import MapboxMaps

/// Shows collision box observing: marking, moving, hiding and removing marked subviews updates the
/// collision boxes of the annotation automatically. An active box is visible as a hole in the "✕"
/// grid, because the symbols under the box are not drawn.
///
/// The last switch creates an avoid zone below the red box. Shifting the red box into this zone
/// hides the annotation—the only way in this example to trigger collision-based hiding.
///
/// Mirrors the SwiftUI ``ViewAnnotationsCollisionObservingExample`` and the Android
/// `ViewAnnotationCollisionObservingActivity`, so the three can be compared side by side.
final class ViewAnnotationCollisionObservingExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var cancelables = Set<AnyCancelable>()
    private let pin = TwoBoxPinView()
    private var annotation: ViewAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        let options = MapInitOptions(cameraOptions: CameraOptions(center: .newYork, zoom: CollisionObservingDemo.zoom))
        mapView = MapView(frame: view.bounds, mapInitOptions: options)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        mapView.mapboxMap.mapStyle = .empty
        mapView.mapboxMap.setMapStyleContent {
            CollisionObservingDemo.styleContent
        }

        let annotation = ViewAnnotation(coordinate: .newYork, view: pin)
        annotation.enableSymbolLayerCollision = true
        // Enables avoid regions. Without it, symbol layer collision gives this annotation
        // priority, so it won't hide when moved into an avoid zone.
        annotation.enableAvoidRegions = true
        mapView.viewAnnotations.add(annotation)
        self.annotation = annotation

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.finish()
        }.store(in: &cancelables)

        addControls()
    }

    private func addControls() {
        let stack = UIStackView(arrangedSubviews: [
            makeToggle("Mark blue as collision box") { [pin] isOn in
                pin.blueBox.mbxViewAnnotationCollisionBox = isOn
            },
            makeToggle("Shift red box down") { [pin] isOn in
                pin.redOffset = isOn ? 20 : 0
                pin.setNeedsLayout()
            },
            makeToggle("Red box alpha 0 (still collides)") { [pin] isOn in
                pin.redBox.alpha = isOn ? 0 : 1
            },
            makeToggle("Remove red box (falls back to full bounds)") { [pin, weak self] isOn in
                if isOn {
                    pin.redBox.removeFromSuperview()
                } else {
                    pin.addSubview(pin.redBox)
                }
                pin.setNeedsLayout()
                // The pin's fitting size depends on its children; UIKit needs an explicit nudge.
                self?.annotation?.setNeedsUpdateSize()
            },
            makeToggle("Red box isHidden (stops colliding)") { [pin] isOn in
                pin.redBox.isHidden = isOn
            },
            makeToggle("Avoid region below red box") { [weak self] isOn in
                guard let self else { return }
                self.mapView.viewAnnotations.viewAnnotationAvoidRegions = isOn ? [self.avoidRegionBelowRedBox()] : []
            },
        ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        // Same panel look as the SwiftUI and Android examples.
        stack.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        stack.layer.cornerRadius = 12
        stack.clipsToBounds = true
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    /// A small screen rectangle just below the red box. Turning this on and then shifting the red
    /// box down moves the collision box into the region, so the map stops showing the annotation.
    /// Shifting the red box back reports the corrected box and the annotation is shown again.
    private func avoidRegionBelowRedBox() -> CGRect {
        // Derived from the red box's unshifted frame, converted to map coordinates, so the region
        // lands at the same place whichever switch is flipped first.
        let redInMap = pin.convert(pin.redBox.bounds, from: pin.redBox).offsetBy(dx: 0, dy: -pin.redOffset)
        let inView = mapView.convert(redInMap, from: pin)
        return CGRect(
            x: inView.minX,
            y: inView.maxY + Constants.regionGap,
            width: inView.width,
            height: Constants.regionHeight)
    }

    private func makeToggle(_ title: String, onChange: @escaping (Bool) -> Void) -> UIView {
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        let toggle = UISwitch()
        toggle.addAction(UIAction { _ in onChange(toggle.isOn) }, for: .valueChanged)
        let row = UIStackView(arrangedSubviews: [label, toggle])
        row.distribution = .equalSpacing
        return row
    }

    private enum Constants {
        static let regionGap: CGFloat = 5
        static let regionHeight: CGFloat = 30
    }
}

private final class TwoBoxPinView: UIView {
    let redBox = UIView()
    let blueBox = UIView()
    var redOffset: CGFloat = 0

    init() {
        super.init(frame: .zero)
        for (box, color) in [(redBox, UIColor.systemRed), (blueBox, .systemBlue)] {
            box.backgroundColor = color
            box.layer.cornerRadius = 15
            addSubview(box)
        }
        redBox.mbxViewAnnotationCollisionBox = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Adaptive, like the SwiftUI HStack: the pin shrinks when the red box is removed.
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: redBox.superview == nil ? 50 : 110, height: 50)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        redBox.frame = CGRect(x: 10, y: 10 + redOffset, width: 30, height: 30)
        blueBox.frame = CGRect(x: bounds.width - 40, y: 10, width: 30, height: 30)
    }
}
