import Foundation
import UIKit

internal protocol UIApplicationProtocol: AnyObject {
    var applicationState: UIApplication.State { get }

    func open(_ url: URL)
}

@available(iOSApplicationExtension, unavailable)
extension UIApplication: UIApplicationProtocol {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
