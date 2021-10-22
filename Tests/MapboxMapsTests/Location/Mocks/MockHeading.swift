import CoreLocation

final class MockHeading: CLHeading {

    let trueHeadingStub = Stub<Void, CLLocationDirection>(defaultReturnValue: 0)
    override var trueHeading: CLLocationDirection {
        get {
            trueHeadingStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }

    let magneticHeadingStub = Stub<Void, CLLocationDirection>(defaultReturnValue: 0)
    override var magneticHeading: CLLocationDirection {
        get {
            magneticHeadingStub.call()
        }
        set {
            fatalError("unimplemented")
        }
    }
}
