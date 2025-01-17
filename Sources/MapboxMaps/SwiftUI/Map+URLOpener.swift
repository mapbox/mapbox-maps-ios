import SwiftUI

/// Handles url opening.
public typealias MapURLOpener = (URL) -> Void

internal final class ClosureURLOpener: AttributionURLOpener {
    var openURL: MapURLOpener?

    func openAttributionURL(_ url: URL) {
        openURL?(url)
    }
}

struct URLOpenerProvider {
    private let urlOpener: MapURLOpener
    private let preferEnvironment: Bool

    init(userUrlOpener: @escaping MapURLOpener) {
        urlOpener = userUrlOpener
        preferEnvironment = false
    }

    @available(iOSApplicationExtension, unavailable)
    init() {
        urlOpener = DefaultAttributionURLOpener().openAttributionURL(_:)
        preferEnvironment = true
    }

    func resolve(in environmentValues: EnvironmentValues) -> MapURLOpener? {
        if preferEnvironment {
            return { environmentValues.openURL($0) }
        }
        return urlOpener
    }
}
