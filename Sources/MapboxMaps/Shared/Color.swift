import Foundation

#if os(OSX)
import AppKit
public typealias Color = NSColor
#else
import UIKit
public typealias Color = UIColor
#endif
