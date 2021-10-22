@testable import MapboxMaps

final class MockPuck: Puck {
    var isActive: Bool = false

    let setPuckAccuracyStub = Stub<PuckAccuracy, Void>()
    var puckAccuracy: PuckAccuracy {
        get {
            fatalError("unimplemented")
        }
        set {
            setPuckAccuracyStub.call(with: newValue)
        }
    }

    let setPuckBearingSourceStub = Stub<PuckBearingSource, Void>()
    var puckBearingSource: PuckBearingSource {
        get {
            fatalError("unimplemented")
        }
        set {
            setPuckBearingSourceStub.call(with: newValue)
        }
    }
}
