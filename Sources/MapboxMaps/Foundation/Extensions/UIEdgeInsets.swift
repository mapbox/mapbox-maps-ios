import UIKit

func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(
        top: lhs.top + rhs.top,
        left: lhs.left + rhs.left,
        bottom: lhs.bottom + rhs.bottom,
        right: lhs.right + rhs.right)
}

func + (lhs: UIEdgeInsets?, rhs: UIEdgeInsets?) -> UIEdgeInsets? {
    if let lhs {
        if let rhs {
            return lhs + rhs
        }
        return lhs
    }
    return rhs
}

func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    lhs + -rhs
}

func - (lhs: UIEdgeInsets?, rhs: UIEdgeInsets?) -> UIEdgeInsets? {
    lhs + -rhs
}

prefix func - (value: UIEdgeInsets) -> UIEdgeInsets {
    UIEdgeInsets(top: -value.top, left: -value.left, bottom: -value.bottom, right: -value.right)
}

prefix func - (value: UIEdgeInsets?) -> UIEdgeInsets? {
    value.map(-)
}
