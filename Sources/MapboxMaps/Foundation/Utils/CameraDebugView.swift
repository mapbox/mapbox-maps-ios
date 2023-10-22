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

        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemBackground
        } else {
            backgroundColor = .white
        }
        layer.cornerRadius = 5
        layer.shadowRadius = 1.4
        layer.shadowOffset = CGSize(width: 0, height: 0.7)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3

        cameraStateLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraStateLabel.numberOfLines = 0
        addSubview(cameraStateLabel)

        let padding: CGFloat = 4.0
        NSLayoutConstraint.activate([
            cameraStateLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            cameraStateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            cameraStateLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            cameraStateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NSAttributedString {
    private static func logString(_ text: String, bold: Bool = false) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: UIFont.safeMonospacedSystemFont(size: 13, weight: bold ? .bold : .regular)
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
