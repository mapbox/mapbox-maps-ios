import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

#if os(iOS)
internal protocol UIApplicationProtocol: AnyObject {
    var statusBarOrientation: UIInterfaceOrientation { get set }

    func open(_ url: URL)
}

@available(iOSApplicationExtension, unavailable)
extension UIApplication: UIApplicationProtocol {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
#endif
