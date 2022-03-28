import Foundation
import UIKit

protocol AnnotationViewDelegate: AnyObject {
    func annotationViewDidSelect(_ annotationView: AnnotationView)
    func annotationViewDidUnselect(_ annotationView: AnnotationView)
    func annotationViewDidPressClose(_ annotationView: AnnotationView)
}

// `AnnotationView` is a custom `UIView` subclass which is used only for annotation demonstration
final class AnnotationView: UIView {

    weak var delegate: AnnotationViewDelegate?

    var selected: Bool = false {
        didSet {
            selectButton.setTitle(selected ? "Deselect" : "Select", for: .normal)
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green

        closeButton.addTarget(self, action: #selector(closePressed(sender:)), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectPressed(sender:)), for: .touchUpInside)

        [centerLabel, closeButton, selectButton].forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(item)
        }

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),

            centerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            centerLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            centerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),

            selectButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            selectButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            selectButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Action handlers

    @objc private func closePressed(sender: UIButton) {
        delegate?.annotationViewDidPressClose(self)
    }

    @objc private func selectPressed(sender: UIButton) {
        if selected {
            selected = false
            delegate?.annotationViewDidUnselect(self)
        } else {
            selected = true
            delegate?.annotationViewDidSelect(self)
        }
    }
}
