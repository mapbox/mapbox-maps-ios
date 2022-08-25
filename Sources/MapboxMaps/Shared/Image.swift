import Foundation

//#if os(OSX)
//import AppKit
//public typealias Image = NSImage
//#else
//import UIKit
//public typealias Image = UIImage
//#endif

#if os(OSX)
public extension NSImage {
    var scale: CGFloat {
        return self.recommendedLayerContentsScale(Screen.mainScale)
    }
}
#endif
