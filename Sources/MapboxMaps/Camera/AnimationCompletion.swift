#if os(OSX)
import AppKit
#else
import UIKit
#endif

public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void
