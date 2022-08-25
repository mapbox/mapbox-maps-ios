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

    static var mainScale: CGFloat {
        return NSScreen.main?.scale ?? 1
    }

    static var mainNativeScale: CGFloat {
        return NSScreen.main?.nativeScale ?? 1
    }
}
#else
public extension UIScreen {
    static var mainScale: CGFloat {
        return UIScreen.main.scale
    }

    static var mainNativeScale: CGFloat {
        return UIScreen.main.nativeScale
    }
}
#endif
