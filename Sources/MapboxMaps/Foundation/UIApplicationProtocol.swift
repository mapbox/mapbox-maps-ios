import Foundation
import UIKit

internal protocol UIApplicationProtocol: AnyObject {
    func open(_ url: URL)
}

extension UIApplication: UIApplicationProtocol {
    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
