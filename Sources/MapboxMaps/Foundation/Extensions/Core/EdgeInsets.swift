import Foundation
import MapboxCoreMaps

#if os(OSX)
public typealias SharedEdgeInsets = NSEdgeInsets
#else
public typealias SharedEdgeInsets = UIEdgeInsets
#endif

internal extension EdgeInsets {
    func toUIEdgeInsetsValue() -> SharedEdgeInsets {
        return SharedEdgeInsets(top: CGFloat(self.top),
                                left: CGFloat(self.left),
                                bottom: CGFloat(self.bottom),
                                right: CGFloat(self.right))
    }
}

extension SharedEdgeInsets {
    func toMBXEdgeInsetsValue() -> EdgeInsets {
        return EdgeInsets(top: Double(self.top),
                          left: Double(self.left),
                          bottom: Double(self.bottom),
                          right: Double(self.right))
    }
}



#if os(OSX)
public extension NSEdgeInsets {
    static var zero: NSEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension NSEdgeInsets: Equatable {
    public static func ==(lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        let epsilon = 0.00001
        return abs(lhs.top - rhs.top) <= epsilon &&
                abs(lhs.bottom - rhs.bottom) <= epsilon &&
                abs(lhs.left - rhs.left) <= epsilon &&
                abs(lhs.right - rhs.right) <= epsilon
    }
}
#endif
