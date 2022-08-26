import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

/// A protocol to open attribution URLs.
///
/// Use this protocol when the map view is used in non-application target(e.g. application extension target).
public protocol AttributionURLOpener {

    /// Asks the opener to open the provided URL.
    /// - Parameters:
    ///   - url: The URL to be opened.
    func openAttributionURL(_ url: URL)
}

#if os(OSX)
final class DefaultAttributionURLOpener: AttributionURLOpener {
    func openAttributionURL(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
#endif

#if os(iOS)
@available(iOSApplicationExtension, unavailable)
internal final class DefaultAttributionURLOpener: AttributionURLOpener {
    private let application: UIApplicationProtocol

    init(application: UIApplicationProtocol = UIApplication.shared) {
        self.application = application
    }

    func openAttributionURL(_ url: URL) {
        application.open(url)
    }
}
#endif
