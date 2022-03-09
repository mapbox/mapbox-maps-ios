import Foundation
import UIKit

public protocol AttributionURLOpener {
    func openAttributionURL(_ url: URL)
}

@available(iOSApplicationExtension, unavailable)
internal final class DefaultAttributionURLOpener: AttributionURLOpener {
    let application: UIApplication

    init(application: UIApplication = .shared) {
        self.application = application
    }

    func openAttributionURL(_ url: URL) {
        application.open(url)
    }
}
