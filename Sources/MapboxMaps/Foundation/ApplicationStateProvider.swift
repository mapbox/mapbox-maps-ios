import Foundation
import UIKit

/// A protocol to get application state.
///
/// Use this protocol when the map view is used in non-application target(e.g. application extension target).
public protocol ApplicationStateProvider {

    /// The app’s current state, or that of its most active scene.
    var applicationState: UIApplication.State { get }
}

@available(iOSApplicationExtension, unavailable)
internal final class UIApplicationApplicationStateProvider: ApplicationStateProvider {
    private let application: UIApplicationProtocol

    init(application: UIApplicationProtocol = UIApplication.shared) {
        self.application = application
    }

    var applicationState: UIApplication.State {
        application.applicationState
    }
}

internal final class DefaultApplicationStateProvider: ApplicationStateProvider {
    var applicationState: UIApplication.State { .active }
}
