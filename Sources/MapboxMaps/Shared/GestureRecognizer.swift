import Foundation

#if os(OSX)
import AppKit
public typealias GestureRecognizer = NSGestureRecognizer
#else
import UIKit
public typealias GestureRecognizer = UIGestureRecognizer
#endif

