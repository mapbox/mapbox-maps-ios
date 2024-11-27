import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol InfoButtonOrnamentDelegate: AnyObject {
    func didTap(_ infoButtonOrnament: InfoButtonOrnament)
}

internal class InfoButtonOrnament: UIView {

    public override var isHidden: Bool {
        didSet {
            if isHidden {
                Log.warning("Attribution must be enabled if you use data from sources that require it. See https://docs.mapbox.com/help/getting-started/attribution/ for more details.", category: "Ornaments")
            }
        }
    }

    internal weak var delegate: InfoButtonOrnamentDelegate?

    internal init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])
        let button = UIButton(type: .infoLight)
        button.contentVerticalAlignment = .bottom
        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(button)
        translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(infoTapped), for: .primaryActionTriggered)

        let bundle = Bundle.mapboxMaps
        accessibilityLabel = NSLocalizedString("INFO_A11Y_LABEL",
                                               tableName: Ornaments.localizableTableName,
                                               bundle: bundle,
                                               value: "About this map",
                                               comment: "MapInfo Accessibility label")
        accessibilityHint = NSLocalizedString("INFO_A11Y_HINT",
                                              tableName: Ornaments.localizableTableName,
                                              bundle: bundle,
                                              value: "Shows credits, a feedback form, and more",
                                              comment: "MapInfo Accessibility hint")
    }

    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc internal func infoTapped() {
        delegate?.didTap(self)
    }
}
