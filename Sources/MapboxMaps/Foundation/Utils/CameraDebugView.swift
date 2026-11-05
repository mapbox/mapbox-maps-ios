import UIKit

/// A single line of the camera debug overlay, drawn as a bold key followed by a regular value.
@_spi(Internal)
@_documentation(visibility: internal)
public struct CameraDebugEntry: Equatable, Sendable {
    public var key: String
    public var value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

final class CameraDebugView: UIView {
    var cameraState: CameraState? {
        didSet {
            guard cameraState != oldValue else { return }
            updateLabel()
        }
    }

    /// Extra entries drawn under the camera state. The view does not interpret them.
    var accessoryEntries: [CameraDebugEntry] = [] {
        didSet {
            guard accessoryEntries != oldValue else { return }
            updateLabel()
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

    private func updateLabel() {
        let entries = (cameraState.map([CameraDebugEntry].init(cameraState:)) ?? []) + accessoryEntries
        cameraStateLabel.attributedText = .formatted(entries: entries)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Array where Element == CameraDebugEntry {
    init(cameraState: CameraState) {
        self = [
            CameraDebugEntry(key: "lat", value: String(format: "%.4f", cameraState.center.latitude)),
            CameraDebugEntry(key: "lon", value: String(format: "%.4f", cameraState.center.longitude)),
            CameraDebugEntry(key: "zoom", value: String(format: "%.2f", cameraState.zoom)),
        ]
        if cameraState.bearing != 0 {
            append(CameraDebugEntry(key: "bearing", value: String(format: "%.2f", cameraState.bearing)))
        }
        if cameraState.pitch != 0 {
            append(CameraDebugEntry(key: "pitch", value: String(format: "%.2f", cameraState.pitch)))
        }
    }
}

private extension NSAttributedString {
    private static func logString(_ text: String, bold: Bool = false) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: UIFont.monospacedSystemFont(ofSize: 13, weight: bold ? .bold : .regular)
        ])
    }

    static func formatted(entries: [CameraDebugEntry]) -> NSAttributedString {
        let str = NSMutableAttributedString()
        for (index, entry) in entries.enumerated() {
            if index > 0 {
                str.append(.logString("\n"))
            }
            str.append(.logString("\(entry.key):", bold: true))
            str.append(.logString(" \(entry.value)"))
        }
        return str
    }
}
