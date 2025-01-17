import UIKit

final class CameraDebugView: UIView {
    var cameraState: CameraState? {
        didSet {
            if let cameraState, cameraState != oldValue {
                self.cameraStateLabel.attributedText = .formatted(cameraState: cameraState)
            }
        }
    }

    private let cameraStateLabel = UILabel()

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 5
        layer.shadowRadius = 1.4
        layer.shadowOffset = CGSize(width: 0, height: 0.7)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        let backdropView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        backdropView.layer.cornerRadius = 5
        backdropView.clipsToBounds = true
        addConstrained(child: backdropView)

        cameraStateLabel.numberOfLines = 0

        addConstrained(child: cameraStateLabel, padding: 4.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NSAttributedString {
    private static func logString(_ text: String, bold: Bool = false) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: bold ? .bold : .regular)
        ])
    }

    static func formatted(cameraState: CameraState) -> NSAttributedString {
        let str = NSMutableAttributedString()
        str.append(.logString("lat:", bold: true))
        str.append(.logString(" \(String(format: "%.4f", cameraState.center.latitude))\n"))
        str.append(.logString("lon:", bold: true))
        str.append(.logString(" \(String(format: "%.4f", cameraState.center.longitude))\n"))
        str.append(.logString("zoom:", bold: true))
        str.append(.logString(" \(String(format: "%.2f", cameraState.zoom))"))
        if cameraState.bearing != 0 {
            str.append(.logString("\nbearing:", bold: true))
            str.append(.logString(" \(String(format: "%.2f", cameraState.bearing))"))
        }
        if cameraState.pitch != 0 {
            str.append(.logString("\npitch:", bold: true))
            str.append(.logString(" \(String(format: "%.2f", cameraState.pitch))"))
        }
        return str
    }
}
