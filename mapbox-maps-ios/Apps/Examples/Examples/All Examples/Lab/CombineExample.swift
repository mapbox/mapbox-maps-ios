import UIKit
import MapboxMaps
import Combine

/// This examples shows how to use Map events with Combine framework.
@available(iOS 13.0, *)
final class CombineExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    private var tokens = Set<AnyCancellable>()
    private let cameraLabel = UILabel.makeCameraLabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)

        cameraLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraLabel)
        cameraLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24).isActive = true
        cameraLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // The on-prefixed event signals can be used as publishers:
        mapView.mapboxMap.onCameraChanged
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .map(\.cameraState)
            .print("Camera State")
            .sink { [weak self] state in
                self?.cameraLabel.attributedText = .formatted(cameraSate: state)
                self?.cameraLabel.setNeedsLayout()
            }
            .store(in: &tokens)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The below line is used for internal testing purposes only.
        finish()
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
}
