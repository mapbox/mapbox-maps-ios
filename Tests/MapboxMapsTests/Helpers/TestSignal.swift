import Foundation
@testable import MapboxMaps

@propertyWrapper
final class TestSignal<T> {
    var projectedValue: SignalSubject<T> {
        return subject
    }

    var wrappedValue: Signal<T> {
        subject.signal
    }

    let subject = SignalSubject<T>()
}
