@testable import MapboxMaps

final class MockPuck: Puck {

    let setIsActiveStub = Stub<Bool, Void>()
    var isActive: Bool {
        get {
            fatalError("unimplemented")
        }
        set {
            setIsActiveStub.call(with: newValue)
        }
    }

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
