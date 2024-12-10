import Foundation
import UIKit

// `AnnotationView` is a custom `UIView` subclass which is used only for annotation demonstration
final class AnnotationView: UIView {

    var onSelect: ((Bool) -> Void)?
    var onClose: (() -> Void)?

    var selected: Bool = false {
        didSet {
            selectButton.setTitle(selected ? "Deselect" : "Select", for: .normal)
            vStack.spacing = selected ? 20 : 4
            onSelect?(selected)
        }
    }

    var title: String? {
        get { centerLabel.text }
        set { centerLabel.text = newValue }
    }

    lazy var centerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        return label
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("X", for: .normal)
        return button
    }()
    lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9882352941, alpha: 1)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("Select", for: .normal)
        return button
    }()
    private let vStack: UIStackView

    override init(frame: CGRect) {
        vStack = UIStackView()
        super.init(frame: frame)
        backgroundColor = .white
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.cornerRadius = 8

        let hStack = UIStackView(arrangedSubviews: [centerLabel, closeButton])
        hStack.spacing = 4

        vStack.addArrangedSubview(hStack)
        vStack.addArrangedSubview(selectButton)
        vStack.axis = .vertical
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.spacing = 4
        addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])

        closeButton.addTarget(self, action: #selector(closePressed(sender:)), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectPressed(sender:)), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action handlers

    @objc private func closePressed(sender: UIButton) {
        onClose?()
    }

    @objc private func selectPressed(sender: UIButton) {
        selected.toggle()
    }
}
