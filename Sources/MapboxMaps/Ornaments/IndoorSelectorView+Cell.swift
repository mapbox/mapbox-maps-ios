import UIKit

extension IndoorSelectorView {
    class Cell: UICollectionViewCell {
        static let reuseIdentifier = "\(type(of: IndoorSelectorView.Cell.self))"

        private let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = Constants.titleFont
            label.adjustsFontForContentSizeCategory = true
            return label
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(titleLabel)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            titleLabel.frame = bounds
        }

        func configure(title: String, isSelected: Bool) {
            titleLabel.text = String(title.prefix(Constants.titleMaxLength))
            contentView.backgroundColor = isSelected ? Constants.selectedBackgroundColor : Constants.unselectedBackgroundColor
            titleLabel.textColor = isSelected ? Constants.selectedTextColor : Constants.unselectedTextColor
        }
    }
}

extension IndoorSelectorView.Cell {
    enum Constants {
        static let titleFont = UIFont.preferredFont(forTextStyle: .headline)
        static let selectedBackgroundColor = UIColor(white: 0.30, alpha: 1.0)
        static let unselectedBackgroundColor = UIColor.clear
        static let selectedTextColor = UIColor.white
        static let unselectedTextColor = UIColor.label
        static let titleMaxLength = 3
    }
}
