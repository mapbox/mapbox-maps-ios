#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public typealias AnimationCompletion = (UIViewAnimatingPosition) -> Void
