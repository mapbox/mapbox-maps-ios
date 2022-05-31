@testable import MapboxMaps

final class MockPuckManager: PuckManagerProtocol {
    var puckType: PuckType?

    var puckBearingSource: PuckBearingSource = .heading

    var puckBearingEnabled: Bool = true

    let onPuckLocationUpdatedStub = Stub<(InterpolatedLocation) -> Void, Cancelable>(defaultReturnValue: MockCancelable())
    func onPuckLocationUpdated(_ handler: @escaping (InterpolatedLocation) -> Void) -> Cancelable {
        onPuckLocationUpdatedStub.call(with: handler)
    }
}
