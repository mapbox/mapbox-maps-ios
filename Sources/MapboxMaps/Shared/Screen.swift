import Foundation

#if os(OSX)
import AppKit
public typealias Screen = NSScreen
#else
import UIKit
public typealias Screen = UIScreen
#endif

#if os(OSX)
public extension NSScreen {
    var scale: CGFloat {
        return backingScaleFactor
    }

    var nativeScale: CGFloat {
        return backingScaleFactor
    }
}
#endif
