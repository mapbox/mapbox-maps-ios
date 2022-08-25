import Foundation

#if os(OSX)
import AppKit
public typealias View = NSView
#else
import UIKit
public typealias View = UIView
#endif
