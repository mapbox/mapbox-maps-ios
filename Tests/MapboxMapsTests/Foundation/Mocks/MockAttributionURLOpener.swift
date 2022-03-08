import Foundation
@testable import MapboxMaps

final class MockAttributionURLOpener: AttributionURLOpener {
    let openAttributionURLStub = Stub<URL, Void>()
    func openAttributionURL(_ url: URL) {
        openAttributionURLStub.call(with: url)
    }
}
