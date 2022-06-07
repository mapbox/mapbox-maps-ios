import Foundation
import UIKit

final internal class WeatherBugView: UIView {
    var imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = UIColor(red: 246.0 / 255.0, green: 206.0 / 255.0, blue: 69.0 / 255.0, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 108.0 / 255.0, green: 108.0 / 255.0, blue: 108.0 / 255.0, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(textLabel)

        let padding = UIEdgeInsets(top: 8, left: 7, bottom: 8, right: 4)
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right),
            imageView.widthAnchor.constraint(equalToConstant: 15),
            imageView.heightAnchor.constraint(equalToConstant: 15)
        ])

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textLabel)

        backgroundColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
