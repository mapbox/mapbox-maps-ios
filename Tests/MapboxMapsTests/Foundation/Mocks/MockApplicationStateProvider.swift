import Foundation
@testable import MapboxMaps

final class MockApplicationStateProvider: ApplicationStateProvider {
    let applicationStateStub = Stub<UIApplication.State>(defaultReturnValue: .active)
    var applicationState: UIApplication.State {
        return applicationStateStub.call()
    }
}
