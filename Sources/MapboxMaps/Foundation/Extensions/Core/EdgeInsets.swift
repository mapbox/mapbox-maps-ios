import UIKit

internal extension CoreEdgeInsets {
    func toUIEdgeInsetsValue() -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat(self.top),
                            left: CGFloat(self.left),
                            bottom: CGFloat(self.bottom),
                            right: CGFloat(self.right))
    }
}

extension UIEdgeInsets {
    func toMBXEdgeInsetsValue() -> CoreEdgeInsets {
        return CoreEdgeInsets(top: Double(self.top),
                          left: Double(self.left),
                          bottom: Double(self.bottom),
                          right: Double(self.right))
    }
}
