import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    func addConstrained(child: UIView, padding: CGFloat = 0, add: Bool = true) {
        child.translatesAutoresizingMaskIntoConstraints = false
        if add {
            addSubview(child)
        }
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            child.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding),
            child.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            child.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding)
        ])
    }
}
