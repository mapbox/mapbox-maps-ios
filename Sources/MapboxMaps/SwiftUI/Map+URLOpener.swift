import SwiftUI

/// Handles url opening.
    @_documentation(visibility: public)
@_spi(Experimental)
@available(iOS 13, *)
public typealias MapURLOpener = (URL) -> Void

@available(iOS 13.0, *)
internal final class ClosureURLOpener: AttributionURLOpener {
    var openURL: MapURLOpener?

    func openAttributionURL(_ url: URL) {
        openURL?(url)
    }
}

@available(iOS 13.0, *)
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
        if preferEnvironment, #available(iOS 14.0, *) {
            return { environmentValues.openURL($0) }
        }
        return urlOpener
    }
}
