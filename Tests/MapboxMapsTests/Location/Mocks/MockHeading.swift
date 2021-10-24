import CoreLocation

final class MockHeading: CLHeading {

    let trueHeadingStub = Stub<Void, CLLocationDirection>(defaultReturnValue: 0)
    override var trueHeading: CLLocationDirection {
        get {
            trueHeadingStub.call()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("unimplemented")
        }
    }

    let magneticHeadingStub = Stub<Void, CLLocationDirection>(defaultReturnValue: 0)
    override var magneticHeading: CLLocationDirection {
        get {
            magneticHeadingStub.call()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("unimplemented")
        }
    }
}
