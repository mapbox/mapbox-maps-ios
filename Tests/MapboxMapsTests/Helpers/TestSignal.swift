import Foundation
@testable import MapboxMaps

@propertyWrapper
final class TestSignal<T> {
    var projectedValue: SignalSubject<T> { subject }

    var wrappedValue: Signal<T> { subject.signal }

    let subject = SignalSubject<T>()
}

/// Analogous to Published in Combine.
@propertyWrapper
final class TestPublished<T> {
    var projectedValue: Signal<T> {
        subject.signal
    }

    var wrappedValue: T {
        set { subject.value = newValue }
        get { subject.value }
    }
    let subject: CurrentValueSignalSubject<T>

    init(wrappedValue: T) {
        self.subject = .init(wrappedValue)
    }
}
