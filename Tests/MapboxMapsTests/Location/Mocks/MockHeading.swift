import CoreLocation

#if !(swift(>=5.9) && os(visionOS))
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

    let headingAccuracyStub = Stub<Void, CLLocationDirection>(defaultReturnValue: 0)
    override var headingAccuracy: CLLocationDirection {
        get {
            headingAccuracyStub.call()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("unimplemented")
        }
    }

    let timestampStub = Stub<Void, Date>(defaultReturnValue: Date())
    override var timestamp: Date {
        get {
            timestampStub.call()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            fatalError("unimplemented")
        }
    }
}
#endif
