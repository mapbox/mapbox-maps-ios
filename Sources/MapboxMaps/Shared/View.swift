import Foundation

#if os(OSX)
import AppKit
public typealias View = NSView
#else
import UIKit
public typealias View = UIView
#endif


#if os(OSX)
public extension NSView {
    enum AnimationCurve : Int, @unchecked Sendable {
        case easeInOut = 0

        case easeIn = 1

        case easeOut = 2

        case linear = 3
    }
}
#endif
