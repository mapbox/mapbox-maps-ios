import UIKit.UIGeometry

/// `UIEdgeInsets` with Codable & Hashable support
internal struct UIEdgeInsetsCodable: Codable, Hashable {
    var top: CGFloat
    var left: CGFloat
    var bottom: CGFloat
    var right: CGFloat
}

extension UIEdgeInsetsCodable {
    var edgeInsets: UIEdgeInsets {
        get { UIEdgeInsets(top: top, left: left, bottom: bottom, right: right) }
        set {
            top = newValue.top
            left = newValue.left
            bottom = newValue.bottom
            right = newValue.right
        }
    }

    init(_ edgeInsets: UIEdgeInsets) {
        top = edgeInsets.top
        left = edgeInsets.left
        bottom = edgeInsets.bottom
        right = edgeInsets.right
    }
}
