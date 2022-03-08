import Foundation
import UIKit

public protocol AttributionURLOpener {
    func openAttributionURL(_ url: URL)
}

@available(iOSApplicationExtension, unavailable)
internal final class DefaultAttributionURLOpener: AttributionURLOpener {
    let application: UIApplicationProtocol

    init(application: UIApplicationProtocol = UIApplication.shared) {
        self.application = application
    }

    func openAttributionURL(_ url: URL) {
        application.open(url)
    }
}
