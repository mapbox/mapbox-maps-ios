@testable import MapboxMaps

final class MockDateProvider: DateProvider {

    let nowStub = Stub<Void, Date>(defaultReturnValue: Date(timeIntervalSinceReferenceDate: 0))
    var now: Date {
        nowStub.call()
    }
}
