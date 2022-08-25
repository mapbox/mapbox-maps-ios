#if os(OSX)
import AppKit
#else
import UIKit
#endif


#if os(OSX)
public enum UIViewAnimatingState: Int {
    case inactive
    case active
    case stopped
}

public enum UIViewAnimatingPosition: Int {
    case end
    case start
    case current
}
#endif

public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void
